# Native Swapchain Implementation: Metal and D3D12

## Objective
Extend the native swapchain presentation architecture (previously implemented for Linux/Vulkan) to the macOS (Metal) and Windows (D3D12) backends to eliminate the hybrid EGL/OpenGL compositor dependency.

## Key Files & Context
- `src/macos_metal.zig`: Metal RHI backend.
- `src/windows_d3d12.zig`: D3D12 RHI backend.
- `src/linux_vulkan.zig`: Reference implementation of robust Vulkan swapchain presentation.

## Implementation Steps

### 1. Metal (`macos_metal.zig`)
- [ ] Review `swapBuffers` for proper `MTLDrawable` and `MTLCommandBuffer` synchronization.
- [ ] Ensure `CAMetalLayer` is correctly initialized with the window handle for native presentation.
- [ ] Validate synchronization between CPU/GPU to prevent frame tearing and stutters.

### 2. D3D12 (`windows_d3d12.zig`)
- [ ] Enhance `createSurface` to robustly initialize `IDXGISwapChain1` (already partially implemented).
- [ ] Implement `ID3D12Fence` synchronization for swapchain buffer acquisition and presentation to replace the current basic `Present` call.
- [ ] Ensure buffers are correctly managed and released in `destroySurface`.

## Verification & Testing
- [ ] Run the existing smoke test (`zig build test`) on macOS (if available in CI) to verify Metal presentation.
- [ ] Run the smoke test on Windows (if available in CI) to verify D3D12 presentation.
- [ ] Verify that the screen is no longer black and the texture/image renders correctly (or at least the clear color is visible).

## Migration & Rollback
- If presentation breaks, revert to the previous "headless" offscreen buffer export model by toggling the `external_memory_enabled` flag (for Vulkan) or equivalent in the other backends.
