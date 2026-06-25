# Zig Engineering Rules — Z-Graphics RHI

This guide defines the engineering standards and Zig patterns for the z-graphics cross-platform RHI.

## 1. Core Language Standards

- **Memory Management**: Use `std.heap.page_allocator` for all allocations. This is the project's standard allocator.
- **Allocator Pattern**: Always pass `std.heap.page_allocator` to functions that allocate. Prefer `page_allocator.create(T)` for single objects, `page_allocator.alloc(T, n)` for arrays.
- **Error Handling**: Use `try` for syscalls. Map errors to domain-specific types when needed.
- **Pointer Casting**:
    - `@ptrCast` requires explicit target types: `@as([*]const T, @ptrCast(ptr))`
    - `@alignCast` is required before `@ptrCast` for alignment: `@ptrCast(@alignCast(ptr))`
- **Struct Initialization**: Use `std.mem.zeroInit(T, .{...})` for Vulkan structs with non-zero defaults, or `std.mem.zeroes(T)` + manual field assignment when zeroInit causes issues.

## 2. Platform Portability (The "Zig Method")

Use compile-time dispatch via `builtin.os.tag` to provide platform-specific implementations while maintaining a single public API.

**Rule:** **1 API, 3 Fast Code Paths.**

```zig
pub fn createSurface(window: ?*anyopaque, width: u32, height: u32) ?*VulkanSurface {
    if (builtin.os.tag == .linux) return linux_vulkan.createSurface(window, width, height);
    if (builtin.os.tag == .macos) return macos_metal.createSurface(window, width, height);
    if (builtin.os.tag == .windows) return windows_d3d12.createSurface(window, width, height);
    return null;
}
```

## 3. Vulkan FFI Patterns

- **Struct Defaults**: Vulkan structs have sType constants. Use explicit values, not zeroInit, when defaults matter (e.g., `VK_QUEUE_FAMILY_IGNORED = 4294967295`).
- **Pointer Safety**: C API pointers are optional (`?*anyopaque`). Always null-check before use.
- **Image Layouts**: Track layout transitions explicitly. `VK_IMAGE_LAYOUT_GENERAL = 1` is not in Zig bindings—use literal values.
- **Pipeline Barriers**: Use `vkCmdPipelineBarrier` with correct src/dst access masks and stage flags.
- **CRITICAL**: Ensure `VkImageMemoryBarrier.sType` is always set to `45` (`VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER`). Setting it to `44` (`VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER`) will cause silent layout transition failures or black textures on many GPU drivers (especially Intel ANV).
- **Sampler Creation sType**: Always set `VkSamplerCreateInfo.sType` to `35` (`VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO`). Setting it to `32` (`VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO`) will lead to invalid sampler states and silent texture sampling failures.
- **Query Pool Info**: `VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO = 42` (not 37 as some references say).
- **Physical Device Limits**: `VkPhysicalDeviceLimits.timestampPeriod` is at byte offset 424, not 432.
- **Dynamic State Constants**: Always verify integer values of dynamic states. For example, `VK_DYNAMIC_STATE_VIEWPORT` is `0`, `VK_DYNAMIC_STATE_SCISSOR` is `1`, and `VK_DYNAMIC_STATE_STENCIL_REFERENCE` is `8`. Setting incorrect values (e.g., `9`, `10`, or `34`) prevents Vulkan from registering the dynamic states, causing all rasterized geometry to be silently discarded.
- **Intel GPU Limitations**: Intel ANV returns `VK_NOT_READY` for timestamp queries even after `vkQueueWaitIdle`. Intel HD Graphics 520 (SKL GT2) does not support timestamp queries.
- **Extension Function Suffix**: Always try both core and KHR suffix for Vulkan extension functions via `vkGetDeviceProcAddr` (e.g., both `vkCreateSamplerYcbcrConversion` and `vkCreateSamplerYcbcrConversionKHR`).
- **Swapchain Recreation on Resize**: When recreating the swapchain during window resizes, ensure MSAA resolve and depth attachments (e.g., `msaa_color_view`, `msaa_depth_view`) are also destroyed and recreated to match the new swapchain dimensions, otherwise mismatched framebuffer attachment sizes will cause rendering failures.
- **Stencil Buffer Pipeline Layout**: If the fragment shader used in stencil passes expects a descriptor set (like `sampler2D` at binding 0), you must allocate a descriptor set and bind it when drawing (using `vkCmdBindDescriptorSets`), even if color output is not needed, otherwise the driver (especially Intel) will segfault during `vkCmdDraw`.

## 4. Code Style

- Run `zig fmt src/*.zig` before committing.
- No debug prints in release builds—use `if (builtin.mode == .Debug)` guards.
- Keep exports clean: `ZG_*` and `ZawraGraphics_*` dual-FFI pattern.
- All C-compatible exports are prefixed with either `ZG_` or `ZawraGraphics_`.
- Handle types are passed as opaque pointers (`ZawraGraphicsHandle`) and cast using `@ptrCast(@alignCast(handle))` internally to backend-specific structs (e.g., `*VulkanSurface`).

## 5. Testing

- Use `zig build` to verify compilation.
- Use `zig build test` to run the smoke test.
- Capture screenshots with `grim` (Wayland) for visual verification.

### Smoke Test Modes
```bash
zig-out/bin/smoke-test          # Default: texture display test
zig-out/bin/smoke-test --image  # Explicit texture display test
zig-out/bin/smoke-test --video  # YUV420 video test with frame_0.yuv
zig-out/bin/smoke-test --p2     # P2 features: v-sync, instanced rendering, compute shaders
zig-out/bin/smoke-test --p3     # P3 features: timer queries, MRT, stencil buffer
zig-out/bin/smoke-test --all    # Run all tests sequentially
```

### Test Data
YUV420 test frames are in `test_data/`:
- `frame_0.yuv` — 1920x1080 YUV420 test frame
- `combined_240.yuv` — 1280x720 YUV420 combined test data

## 6. Shaders

### Vertex Shaders
- **basic.vert**: Fullscreen triangle vertex shader for texture sampling
- **instanced.vert**: Instanced rendering vertex shader for multiple draw calls with per-instance data

### Fragment Shaders
- **basic.frag**: Texture sampling fragment shader with `sampler2D` binding

### Compute Shaders
- **compute.comp**: Storage buffer read/write compute shader for general-purpose GPU computation

### Compilation
```bash
glslangValidator -V --target-env vulkan1.0 -o shaders/basic.vert.spv shaders/basic.vert
glslangValidator -V --target-env vulkan1.0 -o shaders/basic.frag.spv shaders/basic.frag
glslangValidator -V --target-env vulkan1.0 -o shaders/instanced.vert.spv shaders/instanced.vert
glslangValidator -V --target-env vulkan1.0 -o shaders/compute.comp.spv shaders/compute.comp
```
