# Z-Graphics RHI — Agent Instructions

## Project Context

Z-graphics is a cross-platform Render Hardware Interface (RHI) for the Zawra Browser. It provides a unified API over Vulkan (Linux), Metal (macOS), and D3D12 (Windows), enabling zero-copy compositing for web content rendering.

**Key consumers:** WebKit browser engine (C++ FFI), native applications requiring cross-platform graphics.

## Tech Stack

- **Language:** Zig 0.14.1+
- **Build:** `zig build` (builds static lib + smoke test)
- **Shader language:** GLSL (compiled to SPIR-V via `glslangValidator`)
- **Vulkan:** Linux/Android via `VK_KHR_surface`
- **Metal:** macOS/iOS via `CAMetalLayer`
- **D3D12:** Windows via `IDXGISwapChain1`
- **CI:** GitHub Actions, `zig fmt` for code style
- **Screenshot capture:** `grim` (Wayland), `swaymsg -t get_tree` for window discovery

**Note:** Tech stack originally specified HLSL + DXC, but DXC is not installed. Use `glslangValidator -V --target-env vulkan1.0` for GLSL→SPIR-V compilation.

## API Design Principles

1. **Minimalist API:** Expose only the strictly necessary surface area
2. **Defensive Design:** Fail fast with clear error messages in development
3. **Performance First:** Zero-copy, low-latency for browser compositor
4. **Safe FFI Surface:** Clean, predictable C-compatible exports (`ZG_*` and `ZawraGraphics_*` dual-FFI)
5. **Conditional Debugging:** `std.debug.print` only in Debug builds; strip in ReleaseFast/ReleaseSmall

## Workflow

### Task Lifecycle
1. Read task from active track's `plan.md`
2. Mark `[ ]` → `[~]` (in progress)
3. Implement (TDD when applicable)
4. Verify: `zig build` compiles clean
5. Commit with conventional format: `<type>(<scope>): <description>`
6. Mark `[~]` → `[x]` with commit SHA
7. Phase completion: run `zig build test`, verify, checkpoint

### Commit Format
```
feat(ffi): Add ZG_BindTexture stub
fix(vulkan): Implement descriptor sets and fix crash
chore(conductor): Create texture binding track
```

### Quality Gates
- `zig build` compiles without errors
- `zig build test` passes (smoke test renders correctly)
- `zig fmt` applied to modified files
- No debug prints in release builds

## Key Files & Architecture

```
src/
├── lib.zig                    # RHI abstraction layer (exported API)
├── linux_vulkan.zig           # Vulkan backend (2198 lines, active development)
├── macos_metal.zig            # Metal backend (stub/partial)
├── windows_d3d12.zig          # D3D12 backend (stub/partial)
├── webkit_compositor.zig      # WebKit compositor integration
└── smoke_test.zig             # Test harness for rendering verification

shaders/
├── basic.vert                 # GLSL vertex shader (fullscreen triangle)
├── basic.frag                 # GLSL fragment shader (texture sampling)
└── basic.hlsl                 # Original HLSL (superseded by GLSL)
```

### Rendering Pipeline Flow
```
smoke_test.zig:
  1. ZawraGraphics_CreateWindow(474, 323)
  2. ZawraGraphics_CreateSurface(window, 474, 323)
  3. ZawraGraphics_CreatePipeline(surface, shaders)
  4. ZawraGraphics_CreateTexture(surface, desc)     → allocates image + sampler + descriptor set
  5. ZawraGraphics_UploadTexture(surface, tex, data) → staging buffer → device-local copy
  6. Loop:
     - ZawraGraphics_BeginCommandBuffer(surface)     → acquires swapchain image
     - ZawraGraphics_CmdClearColor(cmd, r, g, b, a)  → begins render pass
     - ZawraGraphics_CmdBindPipeline(cmd, pipeline)
     - ZawraGraphics_BindTexture(cmd, texture, 0)    → vkCmdBindDescriptorSets
     - ZawraGraphics_CmdDraw(cmd, 3, 1, 0, 0)       → fullscreen triangle
     - ZawraGraphics_SubmitCommandBuffer(surface, cmd)
     - ZawraGraphics_SwapBuffers(surface)             → vkQueuePresentKHR
```

### Descriptor Set Layout
- **Binding 0:** `VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER` (GLSL `sampler2D`)
- **Stage:** Fragment only (`VK_SHADER_STAGE_FRAGMENT_BIT`)
- **Pool:** Created in `createSurface()`, maxSets=100

### Image Layout Transitions (uploadTexture)
```
UNDEFINED → TRANSFER_DST_OPTIMAL → GENERAL
```
With pipeline barriers: `TOP_OF_PIPE → TRANSFER → FRAGMENT_SHADER`

## Active Tracks

### In Progress: `implement_texture_binding_20260618`
- **Status:** Phase 4 — debugging texture black screen
- **Issue:** `texture()` sampler returns all zeros despite correct descriptor setup
- **Hardcoded colors work:** orange, magenta, rainbow all render correctly
- **Verified working:** descriptor allocation, write, bind, shader execution
- **Root cause area:** staging buffer → device-local image copy path

### Future: `implement_dma_buf_import_webprocess_20260618`
- Enable WebProcess to import DMA-BUF FDs from UIProcess
- Requires `VK_KHR_external_memory_fd`
- Not started

## Debugging Commands

```bash
# Build
zig build

# Run smoke test
zig-out/bin/smoke-test

# Capture screenshot (Wayland/Sway)
swaymsg -t get_tree | python3 -c "import sys,json; [print(f'con_id={w[\"id\"]}') for w in json.loads(sys.stdin.read())['nodes'] if 'Zawra' in w.get('name','')]"
grim /tmp/zawra_capture.png

# Verify SPIR-V bindings
glslangValidator -V --target-env vulkan1.0 -o /tmp/basic.frag.spv shaders/basic.frag
spirv-dis /tmp/basic.frag.spv | grep -i binding

# Format code
zig fmt src/*.zig
```

## Vulkan-Specific Gotchas

- `glslangValidator` ignores HLSL `register()` — use GLSL `layout(binding=N)` instead
- `std.mem.zeroInit` zeros ALL fields, losing struct defaults (e.g., `VK_QUEUE_FAMILY_IGNORED`)
- `VK_SUBOPTIMAL_KHR` (1000001003) from `vkAcquireNextImageKHR` is non-fatal when WM resizes
- `VK_IMAGE_LAYOUT_GENERAL = 1` — not in Zig C bindings, use literal value
- `ffmpeg -f x11grab` cannot capture Vulkan on bare X server — use `grim` or monitor

## Future Strategic Requirements

- Full DMA-BUF/FD pipeline (import on WebProcess side)
- Multi-layer compositing (texture sampling for web layers)
- YUV format support (hardware-accelerated video decoding)
- Dynamic shader management (shader registry/loader)
- Process residency model (per-tab GPU access)
- Layer tree IPC (composited layer trees vs raw FDs)
