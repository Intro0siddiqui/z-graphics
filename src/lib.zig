// src/lib.zig: Zawra Graphics OS Abstraction (RHI)
const std = @import("std");
const builtin = @import("builtin");

// Platform-specific backends
const linux_vulkan = if (builtin.os.tag == .linux) @import("linux_vulkan.zig") else struct {};
const macos_metal = if (builtin.os.tag == .macos) @import("macos_metal.zig") else struct {};
const windows_d3d12 = if (builtin.os.tag == .windows) @import("windows_d3d12.zig") else struct {};
const compositor = @import("webkit_compositor.zig");

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
};

pub export fn ZG_Initialize() bool { return true; }
pub export fn ZawraGraphics_Initialize() bool { return ZG_Initialize(); }
pub export fn Z_Graphics_Initialize() bool { return ZG_Initialize(); }

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
pub export fn ZawraGraphics_CreateSurface(window: ?ZawraGraphicsHandle, width: u32, height: u32) ?ZawraGraphicsHandle { return ZG_CreateSurface(window, width, height); }

pub export fn ZG_DestroySurface(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) linux_vulkan.destroySurface(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .macos) macos_metal.destroySurface(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .windows) windows_d3d12.destroySurface(@ptrCast(@alignCast(handle)));
}
pub export fn ZawraGraphics_DestroySurface(handle: ZawraGraphicsHandle) void { ZG_DestroySurface(handle); }

pub export fn ZG_SwapBuffers(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) linux_vulkan.swapBuffers(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .macos) macos_metal.swapBuffers(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .windows) windows_d3d12.swapBuffers(@ptrCast(@alignCast(handle)));
}
pub export fn ZawraGraphics_SwapBuffers(handle: ZawraGraphicsHandle) void { ZG_SwapBuffers(handle); }

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

pub const ZawraGraphicsTextureFormat = enum(u32) { R8G8B8A8_Unorm = 0 };

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

pub export fn ZG_CreateSwapchain(handle: ZawraGraphicsHandle) bool {
    _ = handle;
    if (builtin.os.tag == .linux) return true;
    return false;
}
pub export fn ZawraGraphics_CreateSwapchain(handle: ZawraGraphicsHandle) bool { return ZG_CreateSwapchain(handle); }

pub export fn ZG_Present(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) linux_vulkan.present(@ptrCast(@alignCast(handle)));
}
pub export fn ZawraGraphics_Present(handle: ZawraGraphicsHandle) void { ZG_Present(handle); }

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
