# Z-Graphics RHI — Agent Instructions

> [!IMPORTANT]
> **Documentation Guidelines**:
> 1. Read [zig.md](file:///home/Intro/spectre-enviroment/ZAWRA-BROWSER/zawra-browser/dependencies/z-graphics/zig.md) for detailed Zig patterns, Vulkan FFI specifications, constants, and lessons learned.
> 2. Agents are permitted and encouraged to update [zig.md](file:///home/Intro/spectre-enviroment/ZAWRA-BROWSER/zawra-browser/dependencies/z-graphics/zig.md) directly when new API constraints, bugs, or FFI constants are discovered and verified.

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

### Commit Format
```
feat(ffi): Add ZG_BindTexture stub
fix(vulkan): Implement descriptor sets and fix crash
chore(conductor): Create texture binding track
```

### Quality Gates
- `zig build` compiles without errors
- `zig-out/bin/smoke-test` renders correctly
- `zig fmt` applied to modified files
- No debug prints in release builds

## Key Files & Architecture

```
src/
├── lib.zig                    # RHI abstraction layer (exported API)
├── linux_vulkan.zig           # Vulkan backend (~2800 lines)
├── macos_metal.zig            # Metal backend (~344 lines)
├── windows_d3d12.zig          # D3D12 backend (~640 lines)
├── renderer.zig               # Compositor convenience layer (134 lines)
└── smoke_test.zig             # Test harness (19/19 tests)

shaders/
├── basic.vert                 # GLSL vertex shader (fullscreen triangle)
├── basic.frag                 # GLSL fragment shader (texture sampling)
├── instanced.vert             # GLSL vertex shader (instanced rendering)
├── compute.comp               # Compute shader (storage buffer read/write)
└── basic.hlsl                 # Original HLSL (superseded by GLSL)

test_data/
├── frame_0.yuv                # YUV420 test frame (1920x1080)
└── combined_240.yuv           # YUV420 combined test data (1280x720)
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

Test modes:
  --image   Default: texture display test
  --video   YUV420 video test with frame_0.yuv
  --p2      P2 features: v-sync, instanced rendering, compute shaders
  --p3      P3 features: timer queries, MRT, stencil buffer
  --all     Run all tests sequentially
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

## Completed Work

### Texture Binding (2026-06-18)
- **Status:** COMPLETE — merged to master via PR #16
- **Root cause:** `VK_IMAGE_USAGE_SAMPLED_BIT` was `1 << 5` (0x20 = TRANSIENT_ATTACHMENT) instead of `1 << 2` (0x04 = SAMPLED)
- **Additional fixes:** Buffer usage constants, VkSamplerCreateInfo sType, VkImageMemoryBarrier sType
- **Result:** Smoke test renders 317 frames in 10s, texture displays correctly

### P1 Features
- **Multi-Layer Compositing:** Push constants for layer transforms, multi-layer support
- **YUV Format Support:** VK_KHR_sampler_ycbcr_conversion + CPU fallback for YUV420 frames
- **Dynamic Shader Management:** Runtime SPIR-V to VkShaderModule to pipeline creation
- **Uniform Buffers:** HOST_VISIBLE|HOST_COHERENT, direct upload without staging

### P2 Features
- **Command Buffer Reuse:** Persistent command pools, vkResetCommandPool per frame
- **Descriptor Set Reuse:** Extracted helper, free on destroy, fixed double-free
- **Swapchain Recreation on Resize:** oldSwapchain reuse, VK_SUBOPTIMAL auto-recovery, dynamic viewport/scissor
- **V-Sync Control:** Present mode enumeration, setPresentMode, ZG_SetVSync FFI
- **MSAA:** Auto-detect max samples, MSAA color/depth images, multi-attachment render pass
- **Instanced Rendering:** Multi-buffer binding, instanced draw, pipeline vertex layout, instanced.vert shader
- **Compute Shaders:** Compute pipeline, dispatch, storage buffer, compute.comp

### P3 Features
- **Timer Queries:** VK_KHR_timestamp_query, vkCmdWriteTimestamp, vkGetQueryPoolResults, Intel ANV limitation documented
- **Multiple Render Targets (MRT):** Render to multiple textures simultaneously
- **Stencil Buffer:** Per-pixel stencil testing for clipping/masks

### Bugs Found and Fixed
- VK_IMAGE_USAGE_SAMPLED_BIT was 1 << 5 (0x20) instead of 1 << 2 (0x04)
- VkSamplerCreateInfo sType wrong value
- VkImageMemoryBarrier sType wrong value
- Buffer usage constants were wrong
- Smoke test was missing render loop for image test (uploaded data but never drew)
- Descriptor set double-free on destroy
- VkQueryPoolCreateInfo sType was 37 instead of 42 (VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO)
- Command buffer was creating+destroying VkCommandPool every frame (fixed with persistent pools)
- VkSamplerYcbcrConversion needs KHR suffix for Intel ANV

**Tests:** 19/19 PASS (was 17/17, now 19 with timer query and MRT/stencil)

## Missing Features

See `MISSING_FEATURES.md` for the complete gap analysis covering:
1. DMA-BUF import (WebProcess side)
2. Cross-process surface sharing
3. Process residency model
4. Layer tree IPC
5. EGL/OpenGL replacement

## Debugging Commands

```bash
# Build
zig build

# Run smoke test
zig-out/bin/smoke-test

# Run specific test modes
zig-out/bin/smoke-test --image    # Default: texture display test
zig-out/bin/smoke-test --video    # YUV420 video test
zig-out/bin/smoke-test --p2       # P2 features: v-sync, instanced, compute
zig-out/bin/smoke-test --p3       # P3 features: timer queries, MRT, stencil
zig-out/bin/smoke-test --all      # Run all tests sequentially

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
- `VK_IMAGE_USAGE_SAMPLED_BIT` must be `1 << 2` (0x04), NOT `1 << 5` (0x20)
- `ffmpeg -f x11grab` cannot capture Vulkan on bare X server — use `grim` or monitor
- `VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO` = 42 (not 37 as some references say)
- `VkPhysicalDeviceLimits`: `timestampPeriod` is at byte offset 424, not 432
- Intel ANV returns `VK_NOT_READY` for timestamp queries even after `vkQueueWaitIdle`
- Always try both core and KHR suffix for Vulkan extension functions via `vkGetDeviceProcAddr`
