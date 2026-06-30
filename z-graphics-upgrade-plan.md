# Z-Graphics Upgrade Plan: Complete EGL/OpenGL Replacement

## Current State

z-graphics (`dependencies/z-graphics/src/lib.zig`) exports 55+ functions. The C++ bridge (`ZawraGraphicsBridge.h/cpp`) currently exposes only **11** — used by `TextureMapperGL.cpp` (draw path) and UIProcess init. Four files still call raw EGL/GL:

| File | Lines of GL | Process |
|---|---|---|
| `BitmapTextureGL.cpp` | ~70 GL calls (textures, FBOs, renderbuffers) | WebProcess |
| `TextureMapperShaderProgram.cpp` | ~15 GL calls (shader compile/link) | WebProcess |
| `TextureMapperContextAttributes.cpp` | 1 GL call (extensions query) | WebProcess |
| `PlatformDisplay.cpp` | ~20 EGL calls (display init/term) | Both |

---

## Phase 1: DMA-BUF FIXES (BLOCKER — DO FIRST)

### Bug 1: Export/Import FD type mismatch

**File**: `dependencies/z-graphics/src/linux_vulkan.zig`

The export function uses `VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT = 1` but `importTextureFD` expects `VK_EXTERNAL_MEMORY_HANDLE_TYPE_DMA_BUF_BIT_EXT = 512`.

**Fix**: In the export path, change to use `DMA_BUF_BIT_EXT` when the memory will be imported as a texture (not just opaque memory). Or use DMA_BUF everywhere for texture sharing.

### Bug 2: `bridgeHandle` null in cross-process import

`importTextureFD` receives a null handle when called from the WebProcess. Root cause: the Vulkan surface/device handle is not properly transferred to the WebProcess via the DMABuf FD path.

**Fix**: Ensure the z-graphics `device` and `physicalDevice` are accessible from the WebProcess. This may require:
- Making device handles available via a new export (e.g., `Z_Graphics_GetDeviceInfo`) 
- Or initializing z-graphics in the WebProcess independently and importing the FD into a locally-created device

---

## Phase 2: NEW ZIG EXPORTS NEEDED

These are functions that DON'T exist in `lib.zig` yet and need to be added to both `lib.zig` and `linux_vulkan.zig` (and stubs in `macos_metal.zig` / `windows_d3d12.zig`):

---

### 2.1 Per-Texture Framebuffer API (for BitmapTextureGL `createFboIfNeeded`, `bindAsSurface`)

BitmapTextureGL creates one FBO per texture that renders INTO the texture. This is the most critical missing feature.

```
export fn ZawraGraphics_CreateFramebuffer(
    handle: ZawraGraphicsHandle,
    colorAttachment: ZawraGraphicsTexture,
    width: u32,
    height: u32,
    depthStencilAttachment: ?ZawraGraphicsTexture,  // optional depth/stencil
) ?ZawraGraphicsHandle

export fn ZawraGraphics_DestroyFramebuffer(
    handle: ZawraGraphicsHandle,
    fb: ZawraGraphicsHandle,
) void

export fn ZawraGraphics_CmdBindFramebuffer(
    cmd: ZawraGraphicsCommandBuffer,
    fb: ZawraGraphicsHandle,
) void

export fn ZawraGraphics_FramebufferAttachTexture(
    fb: ZawraGraphicsHandle,
    attachment: u32,       // 0 = COLOR_ATTACHMENT0, depth/stencil later
    texture: ZawraGraphicsTexture,
    mipLevel: u32,
) bool

export fn ZawraGraphics_FramebufferAttachRenderbuffer(
    fb: ZawraGraphicsHandle,
    attachment: u32,
    rbo: ZawraGraphicsHandle,
) bool
```

**Implementation notes**:
- On Vulkan: Create `VkFramebuffer` with `VkFramebufferCreateInfo` referencing the texture's `VkImageView` and the swapchain's `VkRenderPass`
- `CmdBindFramebuffer` should begin a render pass targeting this framebuffer (equivalent to `glBindFramebuffer` + `glViewport`)
- The render pass must match what `TextureMapperGL` expects (one color attachment, optional depth/stencil)
- Store the `VkFramebuffer`, `VkRenderPass`, and dimensions in a new struct

---

### 2.2 Renderbuffer API (for BitmapTextureGL `initializeStencil`, `initializeDepthBuffer`)

```
export fn ZawraGraphics_CreateRenderbuffer(
    handle: ZawraGraphicsHandle,
    format: u32,        // DEPTH_COMPONENT16, STENCIL_INDEX8, DEPTH24_STENCIL8
    width: u32,
    height: u32,
) ?ZawraGraphicsHandle

export fn ZawraGraphics_DestroyRenderbuffer(
    handle: ZawraGraphicsHandle,
    rbo: ZawraGraphicsHandle,
) void
```

**Implementation notes**:
- In Vulkan: create a `VkImage` with `VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT`, allocate memory, create `VkImageView`
- Track format for the attachment

---

### 2.3 Sub-Rectangle Texture Upload with Row Pitch (for BitmapTextureGL `updateContents`)

BitmapTextureGL calls `glTexSubImage2D` with `UNPACK_ROW_LENGTH`, `SKIP_ROWS`, `SKIP_PIXELS` — this allows uploading a sub-rectangle where the source data has a different stride than the rect width.

```
export fn ZawraGraphics_UploadTextureRegion(
    handle: ZawraGraphicsHandle,
    texture: ZawraGraphicsTexture,
    x: i32,
    y: i32,
    width: u32,
    height: u32,
    data: ?*const anyopaque,
    dataLen: usize,
    rowStride: u32,         // bytes per row in source data (may differ from width * bpp)
    srcOffsetX: u32,        // pixel offset into source row
    srcOffsetY: u32,        // row offset into source data
) bool
```

**Implementation notes**:
- Vulkan: Use `vkCmdCopyBufferToImage` with `VkBufferImageCopy.bufferRowLength` set to handle row pitch
- If the driver doesn't support `bufferRowLength` efficiently, fall back to CPU-side copy that re-packs rows into tightly-packed buffer
- The existing `ZawraGraphics_UploadTexture` uploads the full texture — this is the partial variant

---

### 2.4 Runtime Texture Parameter Changes (for BitmapTextureGL `didReset`)

Currently `ZawraGraphics_CreateTexture` hardcodes sampler params. BitmapTextureGL sets them after creation.

```
export fn ZawraGraphics_SetTextureParams(
    handle: ZawraGraphicsHandle,
    texture: ZawraGraphicsTexture,
    minFilter: u32,      // NEAREST=0, LINEAR=1, NEAREST_MIPMAP=2, etc.
    magFilter: u32,
    wrapS: u32,          // CLAMP_TO_EDGE=0, REPEAT=1, MIRRORED_REPEAT=2
    wrapT: u32,
) bool
```

**Implementation notes**:
- Vulkan: Sampler parameters are baked into `VkSampler` at creation. This requires either destroying and recreating the sampler, or creating all sampler variants upfront
- Simpler approach: Destroy the old `VkSampler`, create a new one with new params, update the descriptor set
- Mipmap filter requires also setting `VkImageCreateInfo.mipLevels > 1` at texture creation time

---

### 2.5 GPU Device Properties Query (for TextureMapperContextAttributes)

```
export fn ZawraGraphics_GetDeviceProperty(
    name: u32,           // 0 = MAX_TEXTURE_SIZE, 1 = NPOT_SUPPORT, 2 = UNPACK_SUBIMAGE_SUPPORT
) u32
```

**Implementation notes**:
- For MAX_TEXTURE_SIZE: return `VkPhysicalDeviceLimits.maxImageDimension2D`
- NPOT support is always true in Vulkan (not an extension like in GLES)
- UNPACK_SUBIMAGE_SUPPORT maps to whether `VkBufferImageCopy.bufferRowLength` is supported (always on Vulkan, but may have alignment constraints)

---

### 2.6 Shader Module from GLSL String (for TextureMapperShaderProgram)

This is the hardest. TextureMapperShaderProgram builds GLSL strings at runtime with #define-based feature toggling, then compiles them. z-graphics currently expects pre-compiled SPIR-V.

**Option A (simpler)**: Add a `ZawraGraphics_CompileShader` that takes GLSL source + shader stage and returns a shader module (wraps `glslangValidator` or `shaderc` at runtime).

**Option B (cleaner but requires C++ changes)**: Keep SPIR-V approach. The C++ side would pre-compile the GLSL strings using `glslangValidator` offline, store them as binary blobs, and pass SPIR-V to `ZawraGraphics_CreateShaderModule`.

For the plan, implement Option A:

```
export fn ZawraGraphics_CompileShaderModule(
    handle: ZawraGraphicsHandle,
    glslSource: ?[*]const u8,
    glslSourceLen: usize,
    stage: u32,          // 0 = VERTEX, 1 = FRAGMENT
) ?ZawraGraphicsShaderModule
```

This requires embedding a GLSL-to-SPIR-V compiler. Use `glslang` C API or `shaderc`. If embedding a compiler is too heavy, Option B is the fallback.

---

### 2.7 Clear with Draw Buffer Select (for BitmapTextureGL `clearIfNeeded`)

```
export fn ZawraGraphics_CmdClearAttachments(
    cmd: ZawraGraphicsCommandBuffer,
    color: bool,
    depth: bool,
    stencil: bool,
    r: f32, g: f32, b: f32, a: f32,
) void
```

**Note**: `ZawraGraphics_CmdClearColor` already exists but clears everything. This variant selects which buffers to clear (color/depth/stencil independently), matching `glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)`.

---

### 2.8 Copy Texture (for BitmapTextureGL `copyFromExternalTexture`)

```
export fn ZawraGraphics_CmdCopyTexture(
    cmd: ZawraGraphicsCommandBuffer,
    src: ZawraGraphicsTexture,
    dst: ZawraGraphicsTexture,
) void
```

Uses `vkCmdCopyImage` with appropriate layout transitions.

---

## Phase 3: C++ BRIDGE DECLARATIONS

### 3.1 Update `ZawraGraphicsBridge.h`

Add declarations for **all** functions that the patched TextureMapperGL.cpp already uses via its own `extern "C"` block (they should go in the bridge):

```cpp
// Already declared (keep these):
bool Z_Graphics_Initialize();
void* Z_Graphics_CreateWindow(unsigned int width, unsigned int height);
void* Z_Graphics_CreateSurface(void* window, unsigned int width, unsigned int height);
void Z_Graphics_SwapBuffers(void* handle);
int Z_Graphics_ExportSurfaceFD(void* handle);
void Z_Graphics_DestroySurface(void* handle);
void* Z_Graphics_CompositorInitialize(void* surface, unsigned int width, unsigned int height);
bool Z_Graphics_CompositorRenderLayer(void* state);
void Z_Graphics_CompositorDestroy(void* state);
bool Z_Graphics_CompositorResize(void* state, unsigned int width, unsigned int height);

// NEW: Texture/Buffer/Command functions (move from TextureMapperGL.cpp's local extern "C"):
void* ZawraGraphics_CreateTexture(void* handle, void* desc);
void ZawraGraphics_DestroyTexture(void* handle, void* texture);
bool ZawraGraphics_UploadTexture(void* handle, void* texture, const void* data, unsigned long dataLen);
void* ZawraGraphics_ImportTextureFD(void* handle, int fd, void* desc);
bool ZawraGraphics_ReadbackTexture(void* handle, void* texture, unsigned char* outBuf, unsigned long len);

void* ZawraGraphics_CreateBuffer(void* handle, unsigned long size, int bufferType);
void ZawraGraphics_DestroyBuffer(void* handle, void* buffer);
bool ZawraGraphics_UploadBuffer(void* handle, void* buffer, const void* data, unsigned long dataLen);

void* ZawraGraphics_BeginCommandBuffer(void* handle);
void ZawraGraphics_SubmitCommandBuffer(void* handle, void* cmd);

void* ZawraGraphics_CreatePipeline(void* handle, const void* desc);
void ZawraGraphics_DestroyPipeline(void* handle, void* pipeline);
void ZawraGraphics_CmdBindPipeline(void* cmd, void* pipeline);

void ZawraGraphics_CmdClearColor(void* cmd, float r, float g, float b, float a);
void ZawraGraphics_CmdSetViewport(void* cmd, float x, float y, float w, float h, float minD, float maxD);
void ZawraGraphics_CmdSetScissor(void* cmd, int x, int y, unsigned int w, unsigned int h);
void ZawraGraphics_CmdBindVertexBuffer(void* cmd, void* buffer, unsigned long offset);
void ZawraGraphics_CmdDraw(void* cmd, unsigned int vertexCount, unsigned int instanceCount, unsigned int firstVertex, unsigned int firstInstance);
void ZawraGraphics_BindTexture(void* cmd, void* texture, unsigned int binding);
void ZawraGraphics_BindUniformBuffer(void* cmd, void* buffer, unsigned int binding, unsigned long offset);
void* ZawraGraphics_CreateUniformBuffer(void* surface, unsigned long size);
bool ZawraGraphics_UploadUniformBuffer(void* surface, void* buffer, const unsigned char* data, unsigned long len);

// NEW: Phase 2 functions
void* ZawraGraphics_CreateFramebuffer(void* handle, void* colorTexture, unsigned int width, unsigned int height, void* depthStencilTexture);
void ZawraGraphics_DestroyFramebuffer(void* handle, void* fb);
void ZawraGraphics_CmdBindFramebuffer(void* cmd, void* fb);
bool ZawraGraphics_FramebufferAttachTexture(void* fb, unsigned int attachment, void* texture, unsigned int mipLevel);
bool ZawraGraphics_FramebufferAttachRenderbuffer(void* fb, unsigned int attachment, void* rbo);

void* ZawraGraphics_CreateRenderbuffer(void* handle, unsigned int format, unsigned int width, unsigned int height);
void ZawraGraphics_DestroyRenderbuffer(void* handle, void* rbo);

bool ZawraGraphics_UploadTextureRegion(void* handle, void* texture, int x, int y, unsigned int w, unsigned int h, const void* data, unsigned long dataLen, unsigned int rowStride, unsigned int srcOffsetX, unsigned int srcOffsetY);
bool ZawraGraphics_SetTextureParams(void* handle, void* texture, unsigned int minFilter, unsigned int magFilter, unsigned int wrapS, unsigned int wrapT);

unsigned int ZawraGraphics_GetDeviceProperty(unsigned int name);

void* ZawraGraphics_CompileShaderModule(void* handle, const unsigned char* glslSource, unsigned long glslSourceLen, unsigned int stage);
void ZawraGraphics_DestroyShaderModule(void* handle, void* module);
void* ZawraGraphics_CreatePipelineFromShaders(void* handle, void* vertModule, void* fragModule);

void ZawraGraphics_CmdClearAttachments(void* cmd, bool color, bool depth, bool stencil, float r, float g, float b, float a);
void ZawraGraphics_CmdCopyTexture(void* cmd, void* src, void* dst);
```

### 3.2 Clean up `TextureMapperGL.cpp`'s local `extern "C"`

Once the bridge header has all declarations, remove the duplicate `extern "C"` block from the patched `TextureMapperGL.cpp` and `#include "ZawraGraphicsBridge.h"` instead.

---

## Phase 4: C++ PATCHES FOR REMAINING GL FILES

### 4.1 `BitmapTextureGL.cpp` — Replace with Vulkan via z-graphics

**File**: `patches/webkit/Source/WebCore/platform/graphics/texmap/BitmapTextureGL.cpp`

Replace all GL types with z-graphics equivalents:
- `GLuint m_id` → `void* m_texture` (ZawraGraphicsTexture)
- `GLuint m_fbo` → `void* m_framebuffer` 
- `GLuint m_rbo` → `void* m_renderbuffer`
- `GLuint m_depthBufferObject` → `void* m_depthRenderbuffer`
- `GLint m_internalFormat` → `uint32_t m_format` (using ZawraGraphicsTextureFormat enum)
- `GLenum m_format` → remove (derive from m_internalFormat)
- `GLenum m_type` → remove

Method replacements:
| GL Method | Replacement |
|---|---|
| `glGenTextures(1, &m_id)` | `m_texture = ZawraGraphics_CreateTexture(surface, &desc)` |
| `glBindTexture(GL_TEXTURE_2D, m_id)` | removed — textures are bound via CmdBindTexture in draw |
| `glTexParameteri(...)` | `ZawraGraphics_SetTextureParams(handle, m_texture, LINEAR, LINEAR, CLAMP_TO_EDGE, CLAMP_TO_EDGE)` |
| `glTexImage2D(...)` | `ZawraGraphics_UploadTexture(handle, m_texture, nullptr, 0)` (allocate without data) |
| `glTexSubImage2D(...)` + pixelstorei | `ZawraGraphics_UploadTextureRegion(handle, m_texture, x, y, w, h, data, len, rowStride, offX, offY)` |
| `glGenFramebuffers(1, &m_fbo)` | `m_framebuffer = ZawraGraphics_CreateFramebuffer(handle, m_texture, w, h, nullptr)` |
| `glBindFramebuffer(GL_FRAMEBUFFER, m_fbo)` | `ZawraGraphics_CmdBindFramebuffer(cmd, m_framebuffer)` |
| `glFramebufferTexture2D(...)` | `ZawraGraphics_FramebufferAttachTexture(m_framebuffer, 0, m_texture, 0)` |
| `glGenRenderbuffers(1, &m_rbo)` | `m_renderbuffer = ZawraGraphics_CreateRenderbuffer(handle, format, w, h)` |
| `glFramebufferRenderbuffer(...)` | `ZawraGraphics_FramebufferAttachRenderbuffer(m_framebuffer, attachment, m_rbo)` |
| `glClearColor + glClear(...)` | `ZawraGraphics_CmdClearAttachments(cmd, color, depth, stencil, r, g, b, a)` |
| `glViewport(...)` | `ZawraGraphics_CmdSetViewport(cmd, 0, 0, w, h, 0, 1)` |
| `glDeleteTextures`, `glDeleteFramebuffers`, `glDeleteRenderbuffers` | Corresponding Destroy functions |
| `glCopyTexSubImage2D(...)` | `ZawraGraphics_CmdCopyTexture(cmd, srcTex, m_texture)` |

### 4.2 `TextureMapperShaderProgram.cpp` — Replace with SPIR-V

**File**: `patches/webkit/Source/WebCore/platform/graphics/texmap/TextureMapperShaderProgram.cpp`

Two approaches:

**Approach A (runtime GLSL→SPIR-V compilation)**:
- Replace `glCreateShader + glShaderSource + glCompileShader` with `ZawraGraphics_CompileShaderModule(handle, glslString, len, stage)`
- Replace `glCreateProgram + glAttachShader + glLinkProgram` with `ZawraGraphics_CreatePipelineFromShaders(handle, vertModule, fragModule)`
- Replace `glGetUniformLocation` with a lookup table mapping uniform names to descriptor bindings (pre-built via SPIR-V reflection or hardcoded)
- Replace `glUniformMatrix4fv` with `ZawraGraphics_UploadUniformBuffer` + `ZawraGraphics_BindUniformBuffer`

**Approach B (offline SPIR-V, requires build-time compilation)**:
- Generate SPIR-V blobs during the build for each shader variant (all combinations of the #define toggles)
- Load pre-compiled SPIR-V at runtime via `ZawraGraphics_CreateShaderModule`
- Faster but more complex build system changes

**Recommendation**: Start with Approach A for simplicity. The shader compilation can happen once at startup.

### 4.3 `TextureMapperContextAttributes.cpp` — Replace GL query

**File**: `patches/webkit/Source/WebCore/platform/graphics/texmap/TextureMapperContextAttributes.cpp`

Replace:
```cpp
auto extensionsString = String::fromLatin1(reinterpret_cast<const char*>(glGetString(GL_EXTENSIONS)));
attributes.supportsNPOTTextures = extensionsString.contains("GL_OES_texture_npot"_s);
attributes.supportsUnpackSubimage = extensionsString.contains("GL_EXT_unpack_subimage"_s);
```
with:
```cpp
attributes.isGLES2Compliant = true;
attributes.supportsNPOTTextures = true;  // Always true in Vulkan
attributes.supportsUnpackSubimage = true; // Always true in Vulkan (via bufferRowLength)
uint32_t maxTexSize = ZawraGraphics_GetDeviceProperty(0); // if needed
```

### 4.4 `PlatformDisplay.cpp` — Remove EGL initialization

**File**: `patches/webkit/Source/WebCore/platform/graphics/PlatformDisplay.cpp`

- Remove `initializeEGLDisplay()` call chain
- Remove `m_eglDisplay` member (replace with null or remove)
- Remove `eglCreateImage`/`eglDestroyImage` wrappers
- The function `sharingGLContext()` already calls the stubbed `GLContext::createSharing()` — no change needed there
- Keep `PlatformDisplay` as a process-level singleton but without EGL init

---

## Phase 5: BUILD SYSTEM CLEANUP

### 5.1 `OptionsWPE.cmake`

After all patches are in place and verified working:
- Change `find_package(LibEpoxy ...)` from `REQUIRED` to optional
- Remove `SET_AND_EXPOSE_TO_BUILD(USE_EGL TRUE)` (or keep if WebGL still needs it)
- Remove `SET_AND_EXPOSE_TO_BUILD(USE_LIBEPOXY TRUE)`

### 5.2 `PlatformWPE.cmake`

- Remove `platform/graphics/egl` and `platform/graphics/epoxy` from include paths (after verifying nothing needs them)
- Keep link to `libz-graphics.a` and `vulkan`

---

## Implementation Order

```
Phase 1 (BLOCKER) → Fix DMA-BUF FD type mismatch + bridgeHandle null
         ↓
Phase 2 (Zig)     → Add new exports in lib.zig + linux_vulkan.zig:
                     2.1 Framebuffer API
                     2.2 Renderbuffer API  
                     2.3 UploadTextureRegion
                     2.4 SetTextureParams
                     2.5 GetDeviceProperty
                     2.6 CompileShaderModule
                     2.7 CmdClearAttachments
                     2.8 CmdCopyTexture
         ↓
Phase 3 (C++ bridge) → Update ZawraGraphicsBridge.h/cpp with all declarations
         ↓
Phase 4 (C++ patches) → Patch BitmapTextureGL.cpp (largest file)
                      → Patch TextureMapperShaderProgram.cpp (complex shader change)
                      → Patch TextureMapperContextAttributes.cpp (trivial)
                      → Patch PlatformDisplay.cpp (remove EGL init)
         ↓
Phase 5 (Build)     → Remove LibEpoxy dependency
                   → Remove EGL from feature flags
```
