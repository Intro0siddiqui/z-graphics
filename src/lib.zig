// src/lib.zig: Zawra Graphics OS Abstraction (RHI)
const std = @import("std");
const builtin = @import("builtin");

// Platform-specific backends
const linux_vulkan = if (builtin.os.tag == .linux) @import("linux_vulkan.zig") else struct {};
const macos_metal = if (builtin.os.tag == .macos) @import("macos_metal.zig") else struct {};
const windows_d3d12 = if (builtin.os.tag == .windows) @import("windows_d3d12.zig") else struct {};
const compositor = @import("renderer.zig");

export fn _force_zgraphics_exports() void {
    _ = compositor.ZawraGraphics_CompositorInitialize;
    _ = compositor.ZawraGraphics_CompositorRenderLayer;
    _ = compositor.ZawraGraphics_CompositorDestroy;
    _ = compositor.ZawraGraphics_CompositorResize;
    _ = compositor.ZawraGraphics_CompositorGetSurfaceHandle;
}

/// The internal structure representing a graphics surface.
pub const ZawraGraphicsSurface = if (builtin.os.tag == .linux)
    linux_vulkan.VulkanSurface
else if (builtin.os.tag == .macos)
    macos_metal.MetalSurface
else if (builtin.os.tag == .windows)
    windows_d3d12.D3D12Surface
else
    struct { dummy: u8 };

pub const ZawraGraphicsHandle = *anyopaque;
pub const ZawraGraphicsBuffer = *anyopaque;
pub const ZawraGraphicsCommandBuffer = *anyopaque;
pub const ZawraGraphicsPipeline = *anyopaque;
pub const ZawraGraphicsComputePipeline = *anyopaque;
pub const ZawraGraphicsShaderModule = *anyopaque;

pub const ZawraGraphicsVertexBinding = extern struct {
    binding: u32,
    stride: u32,
    input_rate: u32,
};

pub const ZawraGraphicsVertexAttribute = extern struct {
    location: u32,
    binding: u32,
    format: u32,
    offset: u32,
};

pub const ZawraGraphicsStorageBinding = extern struct {
    binding: u32,
    descriptor_type: u32,
};

pub const BufferType = enum(u32) {
    Vertex = 1,
    Index = 2,
    Uniform = 3,
};

pub const PipelineDesc = extern struct {
    vertex_shader: ?[*]const u8,
    vertex_shader_len: usize,
    pixel_shader: ?[*]const u8,
    pixel_shader_len: usize,
    blend_enable: u32 = 0,
    src_color_blend_factor: u32 = 0,
    dst_color_blend_factor: u32 = 0,
    color_blend_op: u32 = 0,
    src_alpha_blend_factor: u32 = 0,
    dst_alpha_blend_factor: u32 = 0,
    alpha_blend_op: u32 = 0,
};

pub export fn ZG_Initialize() bool {
    return true;
}
pub export fn ZawraGraphics_Initialize() bool {
    return ZG_Initialize();
}
pub export fn Z_Graphics_Initialize() bool {
    return ZG_Initialize();
}

pub export fn Z_Graphics_CreateWindow(width: u32, height: u32) ?ZawraGraphicsHandle {
    return ZawraGraphics_CreateWindow(width, height);
}
pub export fn Z_Graphics_CreateSurface(window: ?ZawraGraphicsHandle, width: u32, height: u32) ?ZawraGraphicsHandle {
    return ZawraGraphics_CreateSurface(window, width, height);
}
pub export fn Z_Graphics_SwapBuffers(handle: ZawraGraphicsHandle) void {
    ZawraGraphics_SwapBuffers(handle);
}
pub export fn Z_Graphics_ExportSurfaceFD(handle: ?ZawraGraphicsHandle) i32 {
    return ZawraGraphics_ExportSurfaceFD(handle);
}
pub export fn Z_Graphics_DestroySurface(handle: ZawraGraphicsHandle) void {
    ZawraGraphics_DestroySurface(handle);
}
pub export fn Z_Graphics_CompositorInitialize(surface: ?ZawraGraphicsHandle, width: u32, height: u32) ?*anyopaque {
    return compositor.ZawraGraphics_CompositorInitialize(surface, width, height);
}
pub export fn Z_Graphics_CompositorRenderLayer(state: *anyopaque) bool {
    return compositor.ZawraGraphics_CompositorRenderLayer(@ptrCast(@alignCast(state)));
}
pub export fn Z_Graphics_CompositorDestroy(state: *anyopaque) void {
    compositor.ZawraGraphics_CompositorDestroy(@ptrCast(@alignCast(state)));
}
pub export fn Z_Graphics_CompositorResize(state: *anyopaque, new_width: u32, new_height: u32) bool {
    return compositor.ZawraGraphics_CompositorResize(@ptrCast(@alignCast(state)), new_width, new_height);
}

pub export fn ZG_CreateSurface(window: ?ZawraGraphicsHandle, width: u32, height: u32) ?ZawraGraphicsHandle {
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createSurface(window, width, height));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createSurface(window, width, height));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createSurface(window, width, height));
    return null;
}
pub export fn ZawraGraphics_CreateSurface(window: ?ZawraGraphicsHandle, width: u32, height: u32) ?ZawraGraphicsHandle {
    return ZG_CreateSurface(window, width, height);
}

pub export fn ZG_DestroySurface(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) linux_vulkan.destroySurface(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .macos) macos_metal.destroySurface(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .windows) windows_d3d12.destroySurface(@ptrCast(@alignCast(handle)));
}
pub export fn ZawraGraphics_DestroySurface(handle: ZawraGraphicsHandle) void {
    ZG_DestroySurface(handle);
}

pub export fn ZG_SwapBuffers(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) linux_vulkan.swapBuffers(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .macos) macos_metal.swapBuffers(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .windows) windows_d3d12.swapBuffers(@ptrCast(@alignCast(handle)));
}
pub export fn ZawraGraphics_SwapBuffers(handle: ZawraGraphicsHandle) void {
    ZG_SwapBuffers(handle);
}

pub export fn ZawraGraphics_ExportSurfaceFD(handle: ?ZawraGraphicsHandle) i32 {
    if (handle == null) return -1;
    if (builtin.os.tag == .linux) return linux_vulkan.exportSurfaceFD(@ptrCast(@alignCast(handle.?)));
    return -1;
}

pub export fn ZawraGraphics_CreateBuffer(handle: ZawraGraphicsHandle, size: usize, buffer_type: BufferType) ?ZawraGraphicsBuffer {
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    return null;
}

pub export fn ZawraGraphics_DestroyBuffer(handle: ZawraGraphicsHandle, buffer: ZawraGraphicsBuffer) void {
    if (builtin.os.tag == .linux) linux_vulkan.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
    if (builtin.os.tag == .macos) macos_metal.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
    if (builtin.os.tag == .windows) windows_d3d12.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
}

pub export fn ZawraGraphics_BeginCommandBuffer(handle: ZawraGraphicsHandle) ?ZawraGraphicsCommandBuffer {
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    return null;
}

pub export fn ZawraGraphics_CmdClearColor(cmd: ZawraGraphicsCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag == .linux) linux_vulkan.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
    if (builtin.os.tag == .macos) macos_metal.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
    if (builtin.os.tag == .windows) windows_d3d12.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
}

pub export fn ZawraGraphics_SubmitCommandBuffer(handle: ZawraGraphicsHandle, cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) linux_vulkan.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
    if (builtin.os.tag == .macos) macos_metal.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
    if (builtin.os.tag == .windows) windows_d3d12.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
}

pub export fn ZawraGraphics_CreatePipeline(handle: ZawraGraphicsHandle, desc: *const PipelineDesc) ?ZawraGraphicsPipeline {
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createPipeline(@ptrCast(@alignCast(handle)), desc));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createPipeline(@ptrCast(@alignCast(handle)), desc));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createPipeline(@ptrCast(@alignCast(handle)), desc));
    return null;
}

pub export fn ZawraGraphics_DestroyPipeline(handle: ZawraGraphicsHandle, pipeline: ?ZawraGraphicsPipeline) void {
    if (pipeline == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
    if (builtin.os.tag == .macos) macos_metal.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
    if (builtin.os.tag == .windows) windows_d3d12.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
}

pub export fn ZawraGraphics_CmdBindPipeline(cmd: ZawraGraphicsCommandBuffer, pipeline: ZawraGraphicsPipeline) void {
    if (builtin.os.tag == .linux) linux_vulkan.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
    if (builtin.os.tag == .macos) macos_metal.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
    if (builtin.os.tag == .windows) windows_d3d12.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
}

pub export fn ZawraGraphics_CreateWindow(width: u32, height: u32) ?ZawraGraphicsHandle {
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createWindow(width, height));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createWindow(width, height));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createWindow(width, height));
    return null;
}

pub const ZawraGraphicsTextureFormat = enum(u32) {
    R8G8B8A8_Unorm = 0,
    YUV420_3Plane = 1,
    NV12_2Plane = 2,
    P010_10bit = 3,
};

pub const ZawraGraphicsTextureDesc = extern struct {
    format: ZawraGraphicsTextureFormat,
    width: u32,
    height: u32,
    external_handle: ?*anyopaque,
};

pub const ZawraGraphicsTexture = *anyopaque;

pub export fn ZawraGraphics_CreateTexture(handle: ZawraGraphicsHandle, desc: *const ZawraGraphicsTextureDesc) ?ZawraGraphicsTexture {
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createTexture(@ptrCast(@alignCast(handle)), desc));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createTexture(@ptrCast(@alignCast(handle)), desc));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createTexture(@ptrCast(@alignCast(handle)), desc));
    return null;
}

pub export fn ZawraGraphics_DestroyTexture(handle: ZawraGraphicsHandle, texture: ?ZawraGraphicsTexture) void {
    if (texture == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
    if (builtin.os.tag == .macos) macos_metal.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
    if (builtin.os.tag == .windows) windows_d3d12.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
}

pub export fn ZawraGraphics_UploadTexture(handle: ZawraGraphicsHandle, texture: ZawraGraphicsTexture, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag == .linux) return linux_vulkan.uploadTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture)), data, dataLen);
    return false;
}

pub export fn ZawraGraphics_ReadbackTexture(handle: ?ZawraGraphicsHandle, texture: ZawraGraphicsTexture, out_buf: ?[*]u8, len: usize) bool {
    if (handle == null) return false;
    if (builtin.os.tag == .linux) return linux_vulkan.readbackTexture(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(texture)), out_buf, len);
    return false;
}

pub export fn ZawraGraphics_ImportTextureFD(handle: ?ZawraGraphicsHandle, fd: i32, desc: *const ZawraGraphicsTextureDesc) ?ZawraGraphicsTexture {
    if (handle == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.importTextureFD(@ptrCast(@alignCast(handle.?)), fd, desc));
    return null;
}

pub export fn ZG_CreateSwapchain(handle: ZawraGraphicsHandle) bool {
    _ = handle;
    if (builtin.os.tag == .linux) return true;
    return false;
}
pub export fn ZawraGraphics_CreateSwapchain(handle: ZawraGraphicsHandle) bool {
    return ZG_CreateSwapchain(handle);
}

pub export fn ZG_Present(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) linux_vulkan.present(@ptrCast(@alignCast(handle)));
}
pub export fn ZawraGraphics_Present(handle: ZawraGraphicsHandle) void {
    ZG_Present(handle);
}

pub export fn ZawraGraphics_UploadBuffer(handle: ZawraGraphicsHandle, buffer: ZawraGraphicsBuffer, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag == .linux) return linux_vulkan.uploadBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)), data, dataLen);
    if (builtin.os.tag == .macos) return macos_metal.uploadBuffer(@ptrCast(@alignCast(buffer)), data, dataLen);
    if (builtin.os.tag == .windows) return windows_d3d12.uploadBuffer(@ptrCast(@alignCast(buffer)), data, dataLen);
    return false;
}

pub export fn ZawraGraphics_GetBufferSize(buffer: ZawraGraphicsBuffer) usize {
    if (builtin.os.tag == .linux) return linux_vulkan.getBufferSize(@ptrCast(@alignCast(buffer)));
    if (builtin.os.tag == .macos) return macos_metal.getBufferSize(@ptrCast(@alignCast(buffer)));
    if (builtin.os.tag == .windows) return windows_d3d12.getBufferSize(@ptrCast(@alignCast(buffer)));
    return 0;
}

pub export fn ZawraGraphics_CmdBindVertexBuffer(cmd: ZawraGraphicsCommandBuffer, buffer: ZawraGraphicsBuffer, offset: usize) void {
    if (builtin.os.tag == .linux) linux_vulkan.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
    if (builtin.os.tag == .macos) macos_metal.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
    if (builtin.os.tag == .windows) windows_d3d12.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
}

pub export fn ZG_BindTexture(cmd: ZawraGraphicsCommandBuffer, texture: ZawraGraphicsTexture, binding: u32) void {
    if (builtin.os.tag == .linux) linux_vulkan.cmdBindTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(texture)), binding);
    if (builtin.os.tag == .macos) macos_metal.cmdBindTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(texture)), binding);
    if (builtin.os.tag == .windows) windows_d3d12.cmdBindTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(texture)), binding);
}
pub export fn ZawraGraphics_BindTexture(cmd: ZawraGraphicsCommandBuffer, texture: ZawraGraphicsTexture, binding: u32) void {
    ZG_BindTexture(cmd, texture, binding);
}

pub export fn ZawraGraphics_CmdDraw(cmd: ZawraGraphicsCommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag == .linux) linux_vulkan.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    if (builtin.os.tag == .macos) macos_metal.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    if (builtin.os.tag == .windows) windows_d3d12.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
}

pub export fn ZG_CmdSetViewport(cmd: ZawraGraphicsCommandBuffer, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
    if (builtin.os.tag == .linux) linux_vulkan.cmdSetViewport(@ptrCast(@alignCast(cmd)), x, y, width, height, min_depth, max_depth);
    if (builtin.os.tag == .macos) macos_metal.cmdSetViewport(@ptrCast(@alignCast(cmd)), x, y, width, height, min_depth, max_depth);
    if (builtin.os.tag == .windows) windows_d3d12.cmdSetViewport(@ptrCast(@alignCast(cmd)), x, y, width, height, min_depth, max_depth);
}
pub export fn ZawraGraphics_CmdSetViewport(cmd: ZawraGraphicsCommandBuffer, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
    ZG_CmdSetViewport(cmd, x, y, width, height, min_depth, max_depth);
}

pub export fn ZG_CmdSetScissor(cmd: ZawraGraphicsCommandBuffer, x: i32, y: i32, width: u32, height: u32) void {
    if (builtin.os.tag == .linux) linux_vulkan.cmdSetScissor(@ptrCast(@alignCast(cmd)), x, y, width, height);
    if (builtin.os.tag == .macos) macos_metal.cmdSetScissor(@ptrCast(@alignCast(cmd)), x, y, width, height);
    if (builtin.os.tag == .windows) windows_d3d12.cmdSetScissor(@ptrCast(@alignCast(cmd)), x, y, width, height);
}
pub export fn ZawraGraphics_CmdSetScissor(cmd: ZawraGraphicsCommandBuffer, x: i32, y: i32, width: u32, height: u32) void {
    ZG_CmdSetScissor(cmd, x, y, width, height);
}

pub export fn ZawraGraphics_BeginLayer(cmd: ZawraGraphicsCommandBuffer, layer_id: u32, x: f32, y: f32, width: f32, height: f32, opacity: f32) void {
    if (builtin.os.tag == .linux) linux_vulkan.beginLayer(@ptrCast(@alignCast(cmd)), layer_id, x, y, width, height, opacity);
    if (builtin.os.tag == .macos) macos_metal.beginLayer(@ptrCast(@alignCast(cmd)), layer_id, x, y, width, height, opacity);
    if (builtin.os.tag == .windows) windows_d3d12.beginLayer(@ptrCast(@alignCast(cmd)), layer_id, x, y, width, height, opacity);
}

pub export fn ZawraGraphics_EndLayer(cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) linux_vulkan.endLayer(@ptrCast(@alignCast(cmd)));
    if (builtin.os.tag == .macos) macos_metal.endLayer(@ptrCast(@alignCast(cmd)));
    if (builtin.os.tag == .windows) windows_d3d12.endLayer(@ptrCast(@alignCast(cmd)));
}

pub export fn ZawraGraphics_SetLayerOrder(order: [*]const u32, count: u32) void {
    if (builtin.os.tag == .linux) linux_vulkan.setLayerOrder(order, count);
    if (builtin.os.tag == .macos) macos_metal.setLayerOrder(order, count);
    if (builtin.os.tag == .windows) windows_d3d12.setLayerOrder(order, count);
}

pub export fn ZawraGraphics_CreateShaderModule(handle: ?ZawraGraphicsHandle, spirv: ?[*]const u8, spirv_len: usize) ?ZawraGraphicsShaderModule {
    if (handle == null or spirv == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createShaderModulePublic(@ptrCast(@alignCast(handle.?)), spirv.?, spirv_len));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createShaderModulePublic(@ptrCast(@alignCast(handle.?)), spirv.?, spirv_len));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createShaderModulePublic(@ptrCast(@alignCast(handle.?)), spirv.?, spirv_len));
    return null;
}

pub export fn ZawraGraphics_DestroyShaderModule(handle: ?ZawraGraphicsHandle, module: ?ZawraGraphicsShaderModule) void {
    if (handle == null or module == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.destroyShaderModulePublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(module.?)));
    if (builtin.os.tag == .macos) macos_metal.destroyShaderModulePublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(module.?)));
    if (builtin.os.tag == .windows) windows_d3d12.destroyShaderModulePublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(module.?)));
}

pub export fn ZawraGraphics_CreatePipelineFromShaders(handle: ?ZawraGraphicsHandle, vert: ?ZawraGraphicsShaderModule, frag: ?ZawraGraphicsShaderModule) ?ZawraGraphicsPipeline {
    if (handle == null or vert == null or frag == null) return null;

    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createPipelineFromShadersPublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(vert.?)), @ptrCast(@alignCast(frag.?)), null));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createPipelineFromShadersPublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(vert.?)), @ptrCast(@alignCast(frag.?))));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createPipelineFromShadersPublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(vert.?)), @ptrCast(@alignCast(frag.?))));
    return null;
}

pub export fn ZawraGraphics_CreateUniformBuffer(surface: ?ZawraGraphicsHandle, size: usize) ?ZawraGraphicsBuffer {
    if (surface == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createUniformBuffer(@ptrCast(@alignCast(surface.?)), size));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createUniformBuffer(@ptrCast(@alignCast(surface.?)), size));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createUniformBuffer(@ptrCast(@alignCast(surface.?)), size));
    return null;
}

pub export fn ZawraGraphics_UploadUniformBuffer(surface: ?ZawraGraphicsHandle, buffer: ?ZawraGraphicsBuffer, data: ?[*]const u8, len: usize) bool {
    if (surface == null or buffer == null) return false;
    if (builtin.os.tag == .linux) return linux_vulkan.uploadUniformBuffer(@ptrCast(@alignCast(surface.?)), @ptrCast(@alignCast(buffer.?)), data, len);
    if (builtin.os.tag == .macos) return macos_metal.uploadUniformBuffer(@ptrCast(@alignCast(surface.?)), @ptrCast(@alignCast(buffer.?)), data, len);
    if (builtin.os.tag == .windows) return windows_d3d12.uploadUniformBuffer(@ptrCast(@alignCast(surface.?)), @ptrCast(@alignCast(buffer.?)), data, len);
    return false;
}

pub export fn ZawraGraphics_BindUniformBuffer(cmd: ?ZawraGraphicsCommandBuffer, buffer: ?ZawraGraphicsBuffer, binding: u32, offset: u64) void {
    if (cmd == null or buffer == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.cmdBindUniformBuffer(@ptrCast(@alignCast(cmd.?)), @ptrCast(@alignCast(buffer.?)), binding, offset);
    if (builtin.os.tag == .macos) macos_metal.cmdBindUniformBuffer(@ptrCast(@alignCast(cmd.?)), @ptrCast(@alignCast(buffer.?)), binding, offset);
    if (builtin.os.tag == .windows) windows_d3d12.cmdBindUniformBuffer(@ptrCast(@alignCast(cmd.?)), @ptrCast(@alignCast(buffer.?)), binding, offset);
}

pub export fn ZawraGraphics_SetVSync(handle: ZawraGraphicsHandle, enabled: bool) void {
    if (builtin.os.tag == .linux) {
        const surface: *linux_vulkan.VulkanSurface = @ptrCast(@alignCast(handle));
        if (enabled) {
            linux_vulkan.setPresentMode(surface, 2); // VK_PRESENT_MODE_FIFO_KHR
        } else {
            linux_vulkan.setPresentMode(surface, 0); // VK_PRESENT_MODE_IMMEDIATE_KHR
        }
    }
}
pub const ZG_SetVSync = ZawraGraphics_SetVSync;

pub export fn ZawraGraphics_RecreateSwapchain(handle: ZawraGraphicsHandle, width: u32, height: u32) void {
    if (builtin.os.tag == .linux) {
        const surface: *linux_vulkan.VulkanSurface = @ptrCast(@alignCast(handle));
        linux_vulkan.recreateSwapchain(surface, width, height);
    }
}
pub const ZG_RecreateSwapchain = ZawraGraphics_RecreateSwapchain;

pub export fn ZawraGraphics_SetMSAA(handle: ZawraGraphicsHandle, samples: u32) void {
    if (builtin.os.tag == .linux) {
        const surface: *linux_vulkan.VulkanSurface = @ptrCast(@alignCast(handle));
        const clamped: u32 = switch (samples) {
            2 => 2,
            4 => 4,
            8 => 8,
            else => 1,
        };
        surface.msaa_samples = clamped;
    }
}
pub const ZG_SetMSAA = ZawraGraphics_SetMSAA;

pub export fn ZawraGraphics_CmdBindVertexBuffers(
    cmd: ZawraGraphicsCommandBuffer,
    first_binding: u32,
    buffers: [*]const ZawraGraphicsBuffer,
    offsets: [*]const u64,
    count: u32,
) void {
    if (builtin.os.tag == .linux) {
        const cmd_buf: *linux_vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        const buf_slice = @as([*]const *linux_vulkan.VulkanBuffer, @ptrCast(buffers))[0..count];
        linux_vulkan.cmdBindVertexBuffers(cmd_buf, first_binding, buf_slice, offsets[0..count]);
    }
}

pub export fn ZawraGraphics_CmdDrawInstanced(
    cmd: ZawraGraphicsCommandBuffer,
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
) void {
    if (builtin.os.tag == .linux) linux_vulkan.cmdDrawInstanced(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    if (builtin.os.tag == .macos) macos_metal.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    if (builtin.os.tag == .windows) windows_d3d12.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
}

pub export fn ZawraGraphics_CreatePipelineWithLayout(
    handle: ?ZawraGraphicsHandle,
    vert: ?ZawraGraphicsShaderModule,
    frag: ?ZawraGraphicsShaderModule,
    bindings: ?[*]const ZawraGraphicsVertexBinding,
    binding_count: u32,
    attributes: ?[*]const ZawraGraphicsVertexAttribute,
    attribute_count: u32,
) ?ZawraGraphicsPipeline {
    if (handle == null or vert == null or frag == null) return null;
    if (builtin.os.tag == .linux) {
        const binding_slice = if (bindings) |b| @as([]const linux_vulkan.VertexBinding, @ptrCast(b[0..binding_count])) else null;
        const attr_slice = if (attributes) |a| @as([]const linux_vulkan.VertexAttribute, @ptrCast(a[0..attribute_count])) else null;
        return @ptrCast(linux_vulkan.createPipelineFromShadersWithLayout(
            @ptrCast(@alignCast(handle.?)),
            @ptrCast(@alignCast(vert.?)),
            @ptrCast(@alignCast(frag.?)),
            binding_slice,
            attr_slice,
            null,
        ));
    }
    return null;
}

pub export fn ZawraGraphics_CreateComputePipeline(
    surface_handle: ?ZawraGraphicsHandle,
    comp_module: ?ZawraGraphicsShaderModule,
    storage_bindings: ?[*]const ZawraGraphicsStorageBinding,
    binding_count: u32,
) ?ZawraGraphicsComputePipeline {
    if (surface_handle == null or comp_module == null) return null;
    if (builtin.os.tag == .linux) {
        const bindings_slice = if (storage_bindings) |b|
            @as([]const linux_vulkan.StorageBinding, @ptrCast(b[0..binding_count]))
        else
            &[0]linux_vulkan.StorageBinding{};
        return @ptrCast(linux_vulkan.createComputePipeline(
            @ptrCast(@alignCast(surface_handle.?)),
            @as(*linux_vulkan.VulkanShaderModule, @ptrCast(@alignCast(comp_module.?))).module,
            bindings_slice,
        ));
    }
    return null;
}

pub export fn ZawraGraphics_DestroyComputePipeline(
    surface_handle: ?ZawraGraphicsHandle,
    pipeline: ?ZawraGraphicsComputePipeline,
) void {
    if (surface_handle == null or pipeline == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.destroyComputePipeline(
        @ptrCast(@alignCast(surface_handle.?)),
        @ptrCast(@alignCast(pipeline.?)),
    );
}

pub export fn ZawraGraphics_BindComputePipeline(
    cmd_handle: ?ZawraGraphicsCommandBuffer,
    pipeline: ?ZawraGraphicsComputePipeline,
) void {
    if (cmd_handle == null or pipeline == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.cmdBindComputePipeline(
        @ptrCast(@alignCast(cmd_handle.?)),
        @ptrCast(@alignCast(pipeline.?)),
    );
}

pub export fn ZawraGraphics_CmdDispatch(
    cmd_handle: ?ZawraGraphicsCommandBuffer,
    x: u32,
    y: u32,
    z: u32,
) void {
    if (cmd_handle == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.cmdDispatch(
        @ptrCast(@alignCast(cmd_handle.?)),
        x,
        y,
        z,
    );
}

pub export fn ZawraGraphics_CreateStorageBuffer(
    surface_handle: ?ZawraGraphicsHandle,
    size: u32,
) ?ZawraGraphicsBuffer {
    if (surface_handle == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createStorageBuffer(
        @ptrCast(@alignCast(surface_handle.?)),
        size,
    ));
    return null;
}

pub export fn ZawraGraphics_BindStorageBuffer(
    cmd_handle: ?ZawraGraphicsCommandBuffer,
    pipeline: ?ZawraGraphicsComputePipeline,
    buffer: ?ZawraGraphicsBuffer,
    binding: u32,
) void {
    if (cmd_handle == null or pipeline == null or buffer == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.bindStorageBuffer(
        @ptrCast(@alignCast(cmd_handle.?)),
        @ptrCast(@alignCast(pipeline.?)),
        @ptrCast(@alignCast(buffer.?)),
        binding,
    );
}

pub export fn ZawraGraphics_CreateTimerQuery(surface_handle: ?ZawraGraphicsHandle) ?*anyopaque {
    if (surface_handle == null) return null;
    if (builtin.os.tag == .linux) {
        const query = linux_vulkan.createTimerQuery(@ptrCast(@alignCast(surface_handle.?))) orelse return null;
        return @ptrCast(query);
    }
    return null;
}

pub export fn ZawraGraphics_DestroyTimerQuery(surface_handle: ?ZawraGraphicsHandle, query: ?*anyopaque) void {
    if (surface_handle == null or query == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.destroyTimerQuery(
        @ptrCast(@alignCast(surface_handle.?)),
        @ptrCast(@alignCast(query.?)),
    );
}

pub export fn ZawraGraphics_CmdWriteTimestampBegin(cmd: ZawraGraphicsCommandBuffer, query: ?*anyopaque) void {
    if (query == null) return;
    if (builtin.os.tag == .linux) {
        const c_cmd: *linux_vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        const q: *linux_vulkan.VulkanTimerQuery = @ptrCast(@alignCast(query.?));
        linux_vulkan.cmdResetQueryPool(c_cmd, q);
    }
}

pub export fn ZawraGraphics_CmdWriteTimestampEnd(cmd: ZawraGraphicsCommandBuffer, query: ?*anyopaque) void {
    if (query == null) return;
    if (builtin.os.tag == .linux) {
        const c_cmd: *linux_vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        const q: *linux_vulkan.VulkanTimerQuery = @ptrCast(@alignCast(query.?));
        linux_vulkan.cmdWriteTimestampEnd(c_cmd, q);
    }
}

pub export fn ZawraGraphics_GetTimerQueryNs(surface_handle: ?ZawraGraphicsHandle, query: ?*anyopaque) f64 {
    if (surface_handle == null or query == null) return -1.0;
    if (builtin.os.tag == .linux) {
        const result = linux_vulkan.getTimerQueryResults(
            @ptrCast(@alignCast(surface_handle.?)),
            @ptrCast(@alignCast(query.?)),
        );
        return result orelse -1.0;
    }
    return -1.0;
}

pub const ZawraGraphicsMRTSurface = *anyopaque;
pub const ZawraGraphicsStencilSurface = *anyopaque;

pub export fn ZawraGraphics_CreateMRTSurface(handle: ZawraGraphicsHandle, width: u32, height: u32, attachment_count: u32) ?ZawraGraphicsMRTSurface {
    if (builtin.os.tag == .linux) {
        const result = linux_vulkan.createMRTSurface(@ptrCast(@alignCast(handle)), width, height, attachment_count);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZawraGraphics_DestroyMRTSurface(mrt_handle: ?ZawraGraphicsMRTSurface) void {
    if (mrt_handle == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.destroyMRTSurface(@ptrCast(@alignCast(mrt_handle.?)));
}

pub export fn ZawraGraphics_BeginMRTCommandBuffer(handle: ZawraGraphicsHandle, mrt_handle: ZawraGraphicsMRTSurface) ?ZawraGraphicsCommandBuffer {
    _ = handle;
    if (builtin.os.tag == .linux) {
        const mrt: *linux_vulkan.MRTSurface = @ptrCast(@alignCast(mrt_handle));
        const result = linux_vulkan.beginMRTCommandBuffer(mrt);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZawraGraphics_EndMRTSurface(mrt_handle: ZawraGraphicsMRTSurface) void {
    if (builtin.os.tag == .linux) {
        const mrt: *linux_vulkan.MRTSurface = @ptrCast(@alignCast(mrt_handle));
        linux_vulkan.endMRTSurface(mrt);
    }
}

pub export fn ZawraGraphics_ReadMRTTexture(mrt_handle: ZawraGraphicsMRTSurface, index: u32, out_buf: ?[*]u8, len: usize) bool {
    if (builtin.os.tag == .linux) {
        const mrt: *linux_vulkan.MRTSurface = @ptrCast(@alignCast(mrt_handle));
        return linux_vulkan.readMRTTexture(mrt, index, out_buf, len);
    }
    return false;
}

pub export fn ZawraGraphics_CreateStencilSurface(handle: ZawraGraphicsHandle, width: u32, height: u32) ?ZawraGraphicsStencilSurface {
    if (builtin.os.tag == .linux) {
        const result = linux_vulkan.createStencilSurface(@ptrCast(@alignCast(handle)), width, height);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZawraGraphics_DestroyStencilSurface(stencil_handle: ?ZawraGraphicsStencilSurface) void {
    if (stencil_handle == null) return;
    if (builtin.os.tag == .linux) linux_vulkan.destroyStencilSurface(@ptrCast(@alignCast(stencil_handle.?)));
}

pub export fn ZawraGraphics_BeginStencilCommandBuffer(stencil_handle: ZawraGraphicsStencilSurface) ?ZawraGraphicsCommandBuffer {
    if (builtin.os.tag == .linux) {
        const stencil: *linux_vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        const result = linux_vulkan.beginStencilCommandBuffer(stencil);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZawraGraphics_EndStencilSurface(stencil_handle: ZawraGraphicsStencilSurface) void {
    if (builtin.os.tag == .linux) {
        const stencil: *linux_vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        linux_vulkan.endStencilSurface(stencil);
    }
}

pub export fn ZawraGraphics_ReadStencilColorTexture(stencil_handle: ZawraGraphicsStencilSurface, out_buf: ?[*]u8, len: usize) bool {
    if (builtin.os.tag == .linux) {
        const stencil: *linux_vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        return linux_vulkan.readStencilColorTexture(stencil, out_buf, len);
    }
    return false;
}

pub export fn ZawraGraphics_CreateStencilPipeline(handle: ?ZawraGraphicsHandle, desc: *const PipelineDesc) ?ZawraGraphicsPipeline {
    if (handle == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(linux_vulkan.createStencilPipeline(@ptrCast(@alignCast(handle.?)), desc));
    return null;
}

pub export fn ZawraGraphics_CmdSetStencilMask(cmd: ZawraGraphicsCommandBuffer, compare_op: u32, reference: u32, compare_mask: u32, write_mask: u32, fail_op: u32, depth_fail_op: u32, pass_op: u32) void {
    _ = compare_op;
    _ = compare_mask;
    _ = write_mask;
    _ = fail_op;
    _ = depth_fail_op;
    _ = pass_op;
    if (builtin.os.tag == .linux) {
        const c_cmd: *linux_vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        linux_vulkan.cmdSetStencilMask(c_cmd, linux_vulkan.VK_STENCIL_FACE_FRONT_AND_BACK, reference);
    }
}

pub export fn ZawraGraphics_BindStencilWritePipeline(stencil_handle: ZawraGraphicsStencilSurface, cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) {
        const stencil: *linux_vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        const c_cmd: *linux_vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        linux_vulkan.cmdBindStencilPipeline(c_cmd, stencil.write_pipeline, stencil.write_pipeline_layout, stencil.descriptor_set);
    }
}

pub export fn ZawraGraphics_BindStencilTestPipeline(stencil_handle: ZawraGraphicsStencilSurface, cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) {
        const stencil: *linux_vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        const c_cmd: *linux_vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        linux_vulkan.cmdBindStencilPipeline(c_cmd, stencil.test_pipeline, stencil.test_pipeline_layout, stencil.descriptor_set);
    }
}
