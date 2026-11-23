# z-graphics Implementation TODO

> **Status:** 56.5% of overall graphics roadmap items completed (13 completed, 5 partial, 5 remaining).  
> **Zig RHI Status:** Core Vulkan RHI P0–P3 and all Phase 2 RHI exports are **100% COMPLETED** and smoke-tested.

---

## 1. Core Architecture & Surface Infrastructure
- [x] Initialize project structure and CI
- [x] Functional smoke test for FFI (`smoke_test.zig`)
- [x] Implement platform-agnostic surface struct (`lib.zig`)
- [x] Linux (Vulkan) implementation
    - [x] Vulkan instance, physical device, logical device, queue creation
    - [x] Offscreen rendering buffers and render passes
    - [x] Direct Wayland XDG shell swapchain presentation (`linux_wayland.zig`)
    - [x] X11 windowing with non-blocking event pump (`linux_x11.zig`)
- [x] Windows (D3D12/Vulkan) implementation
    - [x] Structure definitions and FFI scaffolding
    - [x] DXGI shared handle surface export (`exportSurfaceSharedHandle`)
    - [ ] Import texture FD / handle completion
- [x] macOS (Metal) implementation
    - [x] Dynamic Obj-C runtime dispatch, Metal device/queue creation
    - [x] IOSurface lookup texture sharing and Cocoa event pump
    - [ ] Compute pipeline & WebKit compositing bridge completion

---

## 2. Linux Vulkan RHI Feature Levels
- [x] **P0: DMA-BUF Import & CPU Readback**
    - [x] `importTextureFD` using `VK_EXTERNAL_MEMORY_HANDLE_TYPE_DMA_BUF_BIT_EXT`
    - [x] `readbackTexture` with exact byte verification in smoke tests
- [x] **P1: Multi-Layer Compositing & Formats**
    - [x] Push constants for transform matrices and layer tinting
    - [x] YUV sampler conversions (YUV420, NV12, P010) with 0 crashes
- [x] **P2: Pipeline Optimization & Advanced Shaders**
    - [x] Command buffer & descriptor set reuse across frames
    - [x] Swapchain recreation on window resize
    - [x] 4x MSAA (Multisample Anti-Aliasing) pipeline
    - [x] Compute shader pipeline dispatch (`vkCreateComputePipelines`)
- [x] **P3: Advanced Render Targets**
    - [x] Multiple Render Targets (MRT) 4-attachment pipeline
    - [x] Stencil buffer operations and masking
    - [x] GPU timestamp / timer queries

---

## 3. WebKit Compositor Replacement (Phase 1 & Phase 2 Exports)
- [x] **Phase 1: DMA-BUF Handle Alignment**
    - [x] Fixed export handle type mismatch to `VK_EXTERNAL_MEMORY_HANDLE_TYPE_DMA_BUF_BIT_EXT`
    - [x] Offscreen DMA-BUF surface export (`ZG_ExportSurfaceFD`)
- [x] **Phase 2: RHI Exports for TextureMapper (Implemented in `lib.zig` & `vulkan.zig`)**
    - [x] 2.1 Per-Texture Framebuffer API (`ZG_CreateFramebuffer`, `ZG_DestroyFramebuffer`)
    - [x] 2.2 Renderbuffer API (`ZG_CreateRenderbuffer`, `ZG_DestroyRenderbuffer`)
    - [x] 2.3 Sub-Rectangle Texture Upload with Row Pitch (`ZG_UploadTextureRegion`)
    - [x] 2.4 Runtime Texture Parameter Changes (`ZG_SetTextureParams`)
    - [x] 2.5 GPU Device Properties Query (`ZG_GetDeviceProperty`)
    - [x] 2.6 Dynamic Shader Module Lifecycle (`ZG_CreateShaderModule`, `ZG_CreatePipelineFromShaders`)
    - [x] 2.7 Clear Attachments with Buffer Select Mask (`ZG_CmdClearAttachments`)
    - [x] 2.8 Copy Texture Region (`ZG_CmdCopyTexture`)

---

## 4. Remaining Tasks (C++ WebKit Integration)
- [ ] **Phase 3: C++ Bridge Declarations**
    - [ ] Expose 30+ Phase 2 RHI functions in `ZawraGraphicsBridge.h`
    - [ ] Declare `initializeFromHostFD(int fd, uint32_t width, uint32_t height)`
- [ ] **Cross-Process Surface Sharing (P0 Blocker)**
    - [ ] Wire `m_hostFileDescriptor` from `WebPage.cpp:726` into `ZawraGraphicsBridge`
    - [ ] Eliminate WebProcess duplicate Vulkan device and window instantiations
- [ ] **Phase 4: C++ Patches for Remaining GL Files**
    - [ ] Patch `BitmapTextureGL.cpp` (~70 GL calls) to use z-graphics RHI
    - [ ] Patch `TextureMapperShaderProgram.cpp` to use z-graphics shader modules
    - [ ] Patch `TextureMapperContextAttributes.cpp` and `PlatformDisplay.cpp`
- [ ] **Phase 5: Build System Cleanup**
    - [ ] Remove `SET_AND_EXPOSE_TO_BUILD(USE_LIBEPOXY TRUE)` from `OptionsWPE.cmake`
    - [ ] Remove EGL build dependency from WPE target
