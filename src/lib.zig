// src/lib.zig: Zawra Graphics OS Abstraction (RHI)
const std = @import("std");
const builtin = @import("builtin");

// Platform-specific backends
const vulkan = if (builtin.os.tag == .linux) @import("vulkan.zig") else struct {};
const macos_metal = if (builtin.os.tag == .macos) @import("macos_metal.zig") else struct {};
const windows_d3d12 = if (builtin.os.tag == .windows) @import("windows_d3d12.zig") else struct {};
const compositor = @import("renderer.zig");

export fn _force_zgraphics_exports() void {
    _ = compositor.ZG_CompositorInitialize;
    _ = compositor.ZG_CompositorRenderLayer;
    _ = compositor.ZG_CompositorDestroy;
    _ = compositor.ZG_CompositorResize;
    _ = compositor.ZG_CompositorGetSurfaceHandle;
    _ = ZG_ExportSurfaceDMABuf;
    _ = ZG_ExportSurfaceSharedHandle;
    _ = ZG_ExportSurfaceFD;
    _ = ZG_ExportSurfaceIOSurface;
}

/// The internal structure representing a graphics surface.
pub const ZawraGraphicsSurface = if (builtin.os.tag == .linux)
    vulkan.VulkanSurface
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

pub export fn ZG_CreateSurface(window: ?ZawraGraphicsHandle, width: u32, height: u32) ?ZawraGraphicsHandle {
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createSurface(window, width, height));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createSurface(window, width, height));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createSurface(window, width, height));
    return null;
}

pub export fn ZG_DestroySurface(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) vulkan.destroySurface(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .macos) macos_metal.destroySurface(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .windows) windows_d3d12.destroySurface(@ptrCast(@alignCast(handle)));
}

pub export fn ZG_SwapBuffers(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) vulkan.swapBuffers(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .macos) macos_metal.swapBuffers(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .windows) windows_d3d12.swapBuffers(@ptrCast(@alignCast(handle)));
}

pub export fn ZG_ExportSurfaceFD(handle: ?ZawraGraphicsHandle) i32 {
    if (handle == null) return -1;
    if (builtin.os.tag == .linux) return vulkan.exportSurfaceFD(@ptrCast(@alignCast(handle.?)));
    if (builtin.os.tag == .macos) return macos_metal.exportSurfaceFD(@as(*macos_metal.MetalSurface, @ptrCast(@alignCast(handle.?))));
    if (builtin.os.tag == .windows) return windows_d3d12.exportSurfaceFD(@ptrCast(@alignCast(handle.?)));
    return -1;
}

pub export fn ZawraGraphics_ExportSurfaceFD(handle: ?ZawraGraphicsHandle) i32 {
    return ZG_ExportSurfaceFD(handle);
}

pub export fn ZG_ExportSurfaceIOSurface(handle: ?ZawraGraphicsHandle) ?*anyopaque {
    if (handle == null) return null;
    if (builtin.os.tag == .macos) return macos_metal.exportSurfaceIOSurface(@as(*macos_metal.MetalSurface, @ptrCast(@alignCast(handle.?))));
    return null;
}

pub export fn ZG_ExportSurfaceSharedHandle(handle: ?ZawraGraphicsHandle) ?*anyopaque {
    if (handle == null) return null;
    if (builtin.os.tag == .windows) return windows_d3d12.exportSurfaceSharedHandle(@ptrCast(@alignCast(handle.?)));
    return null;
}

pub const ZawraGraphicsDMABufInfo = extern struct {
    fd: i32,
    width: u32,
    height: u32,
    stride: u32,
    offset: u32,
    drm_format: u32,
    drm_modifier: u64,
};

/// Exports the surface's render target as a dma-buf.
///
/// On success `info.fd` is a new file descriptor owned by the caller, who must
/// close() it. The fd is *not* closed by z-graphics.
pub export fn ZG_ExportSurfaceDMABuf(surface: ?ZawraGraphicsHandle, info: *ZawraGraphicsDMABufInfo) bool {
    if (surface == null) return false;
    if (builtin.os.tag == .linux) return vulkan.exportSurfaceDMABuf(@ptrCast(@alignCast(surface.?)), info);
    return false;
}

pub export fn ZG_CreateBuffer(handle: ZawraGraphicsHandle, size: usize, buffer_type: BufferType) ?ZawraGraphicsBuffer {
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    return null;
}

pub export fn ZG_DestroyBuffer(handle: ZawraGraphicsHandle, buffer: ZawraGraphicsBuffer) void {
    if (builtin.os.tag == .linux) vulkan.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
    if (builtin.os.tag == .macos) macos_metal.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
    if (builtin.os.tag == .windows) windows_d3d12.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
}

pub export fn ZG_BeginCommandBuffer(handle: ZawraGraphicsHandle) ?ZawraGraphicsCommandBuffer {
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    return null;
}

pub export fn ZG_CmdClearColor(cmd: ZawraGraphicsCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag == .linux) vulkan.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
    if (builtin.os.tag == .macos) macos_metal.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
    if (builtin.os.tag == .windows) windows_d3d12.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
}

pub export fn ZG_CmdClearAttachments(cmd: ZawraGraphicsCommandBuffer, color: bool, depth: bool, stencil: bool, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag == .linux) vulkan.cmdClearAttachments(@ptrCast(@alignCast(cmd)), color, depth, stencil, r, g, b, a);
    if (builtin.os.tag == .macos) macos_metal.cmdClearAttachments(@ptrCast(@alignCast(cmd)), color, depth, stencil, r, g, b, a);
    if (builtin.os.tag == .windows) windows_d3d12.cmdClearAttachments(@ptrCast(@alignCast(cmd)), color, depth, stencil, r, g, b, a);
}

pub export fn ZG_SubmitCommandBuffer(handle: ZawraGraphicsHandle, cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) vulkan.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
    if (builtin.os.tag == .macos) macos_metal.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
    if (builtin.os.tag == .windows) windows_d3d12.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
}

pub export fn ZG_CreatePipeline(handle: ZawraGraphicsHandle, desc: *const PipelineDesc) ?ZawraGraphicsPipeline {
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createPipeline(@ptrCast(@alignCast(handle)), desc));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createPipeline(@ptrCast(@alignCast(handle)), desc));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createPipeline(@ptrCast(@alignCast(handle)), desc));
    return null;
}

pub export fn ZG_DestroyPipeline(handle: ZawraGraphicsHandle, pipeline: ?ZawraGraphicsPipeline) void {
    if (pipeline == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
    if (builtin.os.tag == .macos) macos_metal.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
    if (builtin.os.tag == .windows) windows_d3d12.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
}

pub export fn ZG_CmdBindPipeline(cmd: ZawraGraphicsCommandBuffer, pipeline: ZawraGraphicsPipeline) void {
    if (builtin.os.tag == .linux) vulkan.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
    if (builtin.os.tag == .macos) macos_metal.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
    if (builtin.os.tag == .windows) windows_d3d12.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
}

pub export fn ZG_CreateWindow(width: u32, height: u32) ?ZawraGraphicsHandle {
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createWindow(width, height));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createWindow(width, height));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createWindow(width, height));
    return null;
}

pub export fn ZG_DestroyWindow(window: ?ZawraGraphicsHandle) void {
    if (window == null) return;
    if (builtin.os.tag == .linux) {
        const platform = @import("platform/linux.zig");
        platform.destroyWindow(@ptrCast(@alignCast(window)));
    }
    if (builtin.os.tag == .macos) macos_metal.destroyWindow(@ptrCast(window));
}

pub export fn ZG_PollEvents(window: ?ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) vulkan.pollEvents(@ptrCast(@alignCast(window)));
    if (builtin.os.tag == .macos) macos_metal.dispatchEvents(@ptrCast(window));
}

pub export fn ZG_CheckWindowResize(window: ?ZawraGraphicsHandle, out_w: *u32, out_h: *u32) bool {
    if (builtin.os.tag == .linux) {
        return vulkan.checkWindowResize(@ptrCast(@alignCast(window)), out_w, out_h);
    }
    return false;
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

pub export fn ZG_CreateTexture(handle: ZawraGraphicsHandle, desc: *const ZawraGraphicsTextureDesc) ?ZawraGraphicsTexture {
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createTexture(@ptrCast(@alignCast(handle)), desc));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createTexture(@ptrCast(@alignCast(handle)), desc));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createTexture(@ptrCast(@alignCast(handle)), desc));
    return null;
}

pub export fn ZG_DestroyTexture(handle: ZawraGraphicsHandle, texture: ?ZawraGraphicsTexture) void {
    if (texture == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
    if (builtin.os.tag == .macos) macos_metal.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
    if (builtin.os.tag == .windows) windows_d3d12.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
}

pub export fn ZG_SetTextureParams(
    handle: ZawraGraphicsHandle,
    texture: ZawraGraphicsTexture,
    minFilter: u32,
    magFilter: u32,
    wrapS: u32,
    wrapT: u32,
) bool {
    if (builtin.os.tag == .linux) return vulkan.setTextureParams(
        @ptrCast(@alignCast(handle)),
        @ptrCast(@alignCast(texture)),
        minFilter,
        magFilter,
        wrapS,
        wrapT,
    );
    if (builtin.os.tag == .macos) return macos_metal.setTextureParams(
        @ptrCast(@alignCast(handle)),
        @ptrCast(@alignCast(texture)),
        minFilter,
        magFilter,
        wrapS,
        wrapT,
    );
    if (builtin.os.tag == .windows) return windows_d3d12.setTextureParams(
        @ptrCast(@alignCast(handle)),
        @ptrCast(@alignCast(texture)),
        minFilter,
        magFilter,
        wrapS,
        wrapT,
    );
    return false;
}

pub export fn ZG_UploadTexture(handle: ZawraGraphicsHandle, texture: ZawraGraphicsTexture, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag == .linux) return vulkan.uploadTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture)), data, dataLen);
    if (builtin.os.tag == .macos) return macos_metal.uploadTexture(@as(*macos_metal.MetalSurface, @ptrCast(@alignCast(handle))), @as(*macos_metal.MetalTexture, @ptrCast(@alignCast(texture))), data, dataLen);
    return false;
}

pub export fn ZG_UploadTextureRegion(
    surface_ptr: ?*anyopaque,
    texture_ptr: ?*anyopaque,
    x: i32,
    y: u32,
    width: u32,
    height: u32,
    data: ?[*]const u8,
    data_len: u64,
    row_stride: u32,
    src_offset_x: u32,
    src_offset_y: u32,
) bool {
    if (surface_ptr == null or texture_ptr == null or data == null or data_len == 0) return false;
    if (builtin.os.tag == .linux) {
        const surface: *vulkan.VulkanSurface = @ptrCast(@alignCast(surface_ptr.?));
        const tex: *vulkan.VulkanTexture = @ptrCast(@alignCast(texture_ptr.?));
        const data_slice: []const u8 = data.?[0..@intCast(data_len)];
        return vulkan.uploadTextureRegion(surface, tex, x, y, width, height, data_slice, row_stride, src_offset_x, src_offset_y);
    }
    if (builtin.os.tag == .macos) {
        const surface: *macos_metal.MetalSurface = @ptrCast(@alignCast(surface_ptr.?));
        const tex: *macos_metal.MetalTexture = @ptrCast(@alignCast(texture_ptr.?));
        const data_slice: []const u8 = data.?[0..@intCast(data_len)];
        return macos_metal.uploadTextureRegion(surface, tex, x, y, width, height, data_slice, row_stride, src_offset_x, src_offset_y);
    }
    return false;
}

pub export fn ZG_ReadbackTexture(handle: ?ZawraGraphicsHandle, texture: ZawraGraphicsTexture, out_buf: ?[*]u8, len: usize) bool {
    if (handle == null) return false;
    if (builtin.os.tag == .linux) return vulkan.readbackTexture(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(texture)), out_buf, len);
    if (builtin.os.tag == .macos) return macos_metal.readbackTexture(@as(*macos_metal.MetalSurface, @ptrCast(@alignCast(handle.?))), @as(*macos_metal.MetalTexture, @ptrCast(@alignCast(texture))), out_buf, len);
    return false;
}

/// Imports an fd that is already usable by this device (opaque fd, or a
/// linear dma-buf). Prefer ZG_ImportTextureDMABuf when stride/offset/modifier
/// metadata is available.
///
/// `fd` stays owned by the caller.
pub export fn ZG_ImportTextureFD(handle: ?ZawraGraphicsHandle, fd: i32, desc: *const ZawraGraphicsTextureDesc) ?ZawraGraphicsTexture {
    if (handle == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.importTextureFD(@ptrCast(@alignCast(handle.?)), fd, desc));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.importTextureFD(@as(*macos_metal.MetalSurface, @ptrCast(@alignCast(handle.?))), fd, desc));
    return null;
}

/// Imports a dma-buf using explicit format-modifier, stride and offset
/// metadata. `fd` stays owned by the caller.
pub export fn ZG_ImportTextureDMABuf(
    handle: ?ZawraGraphicsHandle,
    fd: i32,
    info: *const ZawraGraphicsDMABufInfo,
    desc: *const ZawraGraphicsTextureDesc,
) ?ZawraGraphicsTexture {
    if (handle == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.importTextureDMABuf(@ptrCast(@alignCast(handle.?)), fd, info, desc));
    return null;
}

pub var global_wpe_texture: ?ZawraGraphicsTexture = null;
pub var global_wpe_texture_setter: ?*const fn (?ZawraGraphicsTexture) callconv(.c) void = null;

pub export fn ZG_RegisterWpeTextureSetter(cb: ?*const fn (?ZawraGraphicsTexture) callconv(.c) void) void {
    global_wpe_texture_setter = cb;
}

pub export fn ZG_GetWpeTexture() ?ZawraGraphicsTexture {
    return global_wpe_texture;
}

pub export fn ZG_SetWpeTexture(texture: ?ZawraGraphicsTexture) void {
    global_wpe_texture = texture;
    if (global_wpe_texture_setter) |setter| {
        setter(texture);
    }
}

pub export fn ZG_BindWpeDMABuf(surface: ?ZawraGraphicsHandle, fd: i32, width: u32, height: u32) bool {
    if (surface == null or fd < 0 or width == 0 or height == 0) return false;

    const info = ZawraGraphicsDMABufInfo{
        .fd = fd,
        .width = width,
        .height = height,
        .stride = width * 4,
        .offset = 0,
        .drm_format = 0,
        .drm_modifier = 0,
    };
    const desc = ZawraGraphicsTextureDesc{
        .format = .R8G8B8A8_Unorm,
        .width = width,
        .height = height,
        .external_handle = null,
    };

    const texture = ZG_ImportTextureDMABuf(surface, fd, &info, &desc);
    if (texture == null) {
        return false;
    }

    ZG_SetWpeTexture(texture);
    return true;
}

pub export fn ZawraGraphics_BindWpeDMABuf(surface: ?ZawraGraphicsHandle, fd: i32, width: u32, height: u32) bool {
    return ZG_BindWpeDMABuf(surface, fd, width, height);
}

// ── WebKit Navigation & Input FFI Hooks ──────────────────────────────────────────

pub var global_load_url_handler: ?*const fn (url_ptr: [*]const u8, url_len: usize) callconv(.c) void = null;

pub export fn Zawra_SetLoadURLCallback(cb: ?*const fn (url_ptr: [*]const u8, url_len: usize) callconv(.c) void) void {
    global_load_url_handler = cb;
}

pub fn Zawra_LoadURL(url_ptr: [*]const u8, url_len: usize) void {
    if (global_load_url_handler) |cb| {
        cb(url_ptr, url_len);
    } else {
        std.debug.print("[Z-GRAPHICS] Zawra_LoadURL: {s}\n", .{url_ptr[0..url_len]});
    }
}

pub var global_wpe_pointer_handler: ?*const fn (u32, f64, f64, u32, u32) callconv(.c) void = null;
pub var global_wpe_keyboard_handler: ?*const fn (u32, u32, u32) callconv(.c) void = null;

pub export fn Zawra_SetPointerEventHandler(cb: ?*const fn (u32, f64, f64, u32, u32) callconv(.c) void) void {
    global_wpe_pointer_handler = cb;
}

pub export fn Zawra_SetKeyboardEventHandler(cb: ?*const fn (u32, u32, u32) callconv(.c) void) void {
    global_wpe_keyboard_handler = cb;
}

pub fn wpe_view_event_pointer(event_type: u32, local_x: f64, local_y: f64, button: u32, state: u32) void {
    if (global_wpe_pointer_handler) |cb| {
        cb(event_type, local_x, local_y, button, state);
    }
}

pub fn wpe_view_event_keyboard(key: u32, state: u32, modifiers: u32) void {
    if (global_wpe_keyboard_handler) |cb| {
        cb(key, state, modifiers);
    }
}

// ── BrowserDB History Integration Hooks ──────────────────────────────────────────

pub var global_get_recent_history_fn: ?*const fn (limit: u32, out_json_buf: [*]u8, out_max_len: usize) callconv(.c) usize = null;

pub export fn Zawra_SetGetRecentHistoryFn(cb: ?*const fn (limit: u32, out_json_buf: [*]u8, out_max_len: usize) callconv(.c) usize) void {
    global_get_recent_history_fn = cb;
}

pub fn Zawra_GetRecentHistory(limit: u32, out_json_buf: [*]u8, out_max_len: usize) usize {
    if (global_get_recent_history_fn) |cb| {
        return cb(limit, out_json_buf, out_max_len);
    }
    return 0;
}

// ── Platform Event Routing ───────────────────────────────────────────────────────

pub export fn ZG_SetPointerCallback(cb: ?*const fn (u32, f32, f32, u32, u32) callconv(.c) void) void {
    if (builtin.os.tag == .linux) {
        vulkan.setPointerCallback(cb);
    } else if (builtin.os.tag == .macos) {
        macos_metal.setPointerCallback(cb);
    }
}

pub export fn ZG_SetKeyboardCallback(cb: ?*const fn (u32, u32, bool) callconv(.c) void) void {
    if (builtin.os.tag == .linux) {
        vulkan.setKeyboardCallback(cb);
    } else if (builtin.os.tag == .macos) {
        macos_metal.setKeyboardCallback(cb);
    }
}

pub export fn ZG_CreateSwapchain(handle: ZawraGraphicsHandle) bool {
    if (builtin.os.tag == .linux) return true;
    if (builtin.os.tag == .macos) return macos_metal.createSwapchain(@as(*macos_metal.MetalSurface, @ptrCast(@alignCast(handle))));
    return false;
}

pub export fn ZG_Present(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) vulkan.present(@ptrCast(@alignCast(handle)));
    if (builtin.os.tag == .macos) macos_metal.present(@as(*macos_metal.MetalSurface, @ptrCast(@alignCast(handle))));
}

pub export fn ZG_UploadBuffer(handle: ZawraGraphicsHandle, buffer: ZawraGraphicsBuffer, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag == .linux) return vulkan.uploadBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)), data, dataLen);
    if (builtin.os.tag == .macos) return macos_metal.uploadBuffer(@ptrCast(@alignCast(buffer)), data, dataLen);
    if (builtin.os.tag == .windows) return windows_d3d12.uploadBuffer(@ptrCast(@alignCast(buffer)), data, dataLen);
    return false;
}

pub export fn ZG_GetBufferSize(buffer: ZawraGraphicsBuffer) usize {
    if (builtin.os.tag == .linux) return vulkan.getBufferSize(@ptrCast(@alignCast(buffer)));
    if (builtin.os.tag == .macos) return macos_metal.getBufferSize(@ptrCast(@alignCast(buffer)));
    if (builtin.os.tag == .windows) return windows_d3d12.getBufferSize(@ptrCast(@alignCast(buffer)));
    return 0;
}

pub export fn ZG_CmdBindVertexBuffer(cmd: ZawraGraphicsCommandBuffer, buffer: ZawraGraphicsBuffer, offset: usize) void {
    if (builtin.os.tag == .linux) vulkan.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
    if (builtin.os.tag == .macos) macos_metal.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
    if (builtin.os.tag == .windows) windows_d3d12.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
}

pub export fn ZG_BindTexture(cmd: ZawraGraphicsCommandBuffer, texture: ZawraGraphicsTexture, binding: u32) void {
    if (builtin.os.tag == .linux) vulkan.cmdBindTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(texture)), binding);
    if (builtin.os.tag == .macos) macos_metal.cmdBindTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(texture)), binding);
    if (builtin.os.tag == .windows) windows_d3d12.cmdBindTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(texture)), binding);
}

pub export fn ZG_CmdDraw(cmd: ZawraGraphicsCommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag == .linux) vulkan.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    if (builtin.os.tag == .macos) macos_metal.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    if (builtin.os.tag == .windows) windows_d3d12.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
}

pub export fn ZG_CmdCopyTexture(cmd: ZawraGraphicsCommandBuffer, src: ZawraGraphicsTexture, dst: ZawraGraphicsTexture) void {
    if (builtin.os.tag == .linux) vulkan.cmdCopyTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(src)), @ptrCast(@alignCast(dst)));
    if (builtin.os.tag == .macos) macos_metal.cmdCopyTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(src)), @ptrCast(@alignCast(dst)));
    if (builtin.os.tag == .windows) windows_d3d12.cmdCopyTexture(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(src)), @ptrCast(@alignCast(dst)));
}

pub export fn ZG_CmdSetViewport(cmd: ZawraGraphicsCommandBuffer, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
    if (builtin.os.tag == .linux) vulkan.cmdSetViewport(@ptrCast(@alignCast(cmd)), x, y, width, height, min_depth, max_depth);
    if (builtin.os.tag == .macos) macos_metal.cmdSetViewport(@ptrCast(@alignCast(cmd)), x, y, width, height, min_depth, max_depth);
    if (builtin.os.tag == .windows) windows_d3d12.cmdSetViewport(@ptrCast(@alignCast(cmd)), x, y, width, height, min_depth, max_depth);
}

pub export fn ZG_CmdSetScissor(cmd: ZawraGraphicsCommandBuffer, x: i32, y: i32, width: u32, height: u32) void {
    if (builtin.os.tag == .linux) vulkan.cmdSetScissor(@ptrCast(@alignCast(cmd)), x, y, width, height);
    if (builtin.os.tag == .macos) macos_metal.cmdSetScissor(@ptrCast(@alignCast(cmd)), x, y, width, height);
    if (builtin.os.tag == .windows) windows_d3d12.cmdSetScissor(@ptrCast(@alignCast(cmd)), x, y, width, height);
}

pub export fn ZG_BeginLayer(cmd: ZawraGraphicsCommandBuffer, layer_id: u32, x: f32, y: f32, width: f32, height: f32, opacity: f32) void {
    if (builtin.os.tag == .linux) vulkan.beginLayer(@ptrCast(@alignCast(cmd)), layer_id, x, y, width, height, opacity);
    if (builtin.os.tag == .macos) macos_metal.beginLayer(@ptrCast(@alignCast(cmd)), layer_id, x, y, width, height, opacity);
    if (builtin.os.tag == .windows) windows_d3d12.beginLayer(@ptrCast(@alignCast(cmd)), layer_id, x, y, width, height, opacity);
}

pub export fn ZG_EndLayer(cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) vulkan.endLayer(@ptrCast(@alignCast(cmd)));
    if (builtin.os.tag == .macos) macos_metal.endLayer(@ptrCast(@alignCast(cmd)));
    if (builtin.os.tag == .windows) windows_d3d12.endLayer(@ptrCast(@alignCast(cmd)));
}

pub export fn ZG_SetLayerOrder(order: [*]const u32, count: u32) void {
    if (builtin.os.tag == .linux) vulkan.setLayerOrder(order, count);
    if (builtin.os.tag == .macos) macos_metal.setLayerOrder(order, count);
    if (builtin.os.tag == .windows) windows_d3d12.setLayerOrder(order, count);
}

pub export fn ZG_CreateShaderModule(handle: ?ZawraGraphicsHandle, spirv: ?[*]const u8, spirv_len: usize) ?ZawraGraphicsShaderModule {
    if (handle == null or spirv == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createShaderModulePublic(@ptrCast(@alignCast(handle.?)), spirv.?, spirv_len));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createShaderModulePublic(@ptrCast(@alignCast(handle.?)), spirv.?, spirv_len));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createShaderModulePublic(@ptrCast(@alignCast(handle.?)), spirv.?, spirv_len));
    return null;
}

pub export fn ZG_DestroyShaderModule(handle: ?ZawraGraphicsHandle, module: ?ZawraGraphicsShaderModule) void {
    if (handle == null or module == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyShaderModulePublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(module.?)));
    if (builtin.os.tag == .macos) macos_metal.destroyShaderModulePublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(module.?)));
    if (builtin.os.tag == .windows) windows_d3d12.destroyShaderModulePublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(module.?)));
}

pub export fn ZG_CreatePipelineFromShaders(handle: ?ZawraGraphicsHandle, vert: ?ZawraGraphicsShaderModule, frag: ?ZawraGraphicsShaderModule) ?ZawraGraphicsPipeline {
    if (handle == null or vert == null or frag == null) return null;

    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createPipelineFromShadersPublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(vert.?)), @ptrCast(@alignCast(frag.?)), null));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createPipelineFromShadersPublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(vert.?)), @ptrCast(@alignCast(frag.?))));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createPipelineFromShadersPublic(@ptrCast(@alignCast(handle.?)), @ptrCast(@alignCast(vert.?)), @ptrCast(@alignCast(frag.?))));
    return null;
}

pub export fn ZG_CreateUniformBuffer(surface: ?ZawraGraphicsHandle, size: usize) ?ZawraGraphicsBuffer {
    if (surface == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createUniformBuffer(@ptrCast(@alignCast(surface.?)), size));
    if (builtin.os.tag == .macos) return @ptrCast(macos_metal.createUniformBuffer(@ptrCast(@alignCast(surface.?)), size));
    if (builtin.os.tag == .windows) return @ptrCast(windows_d3d12.createUniformBuffer(@ptrCast(@alignCast(surface.?)), size));
    return null;
}

pub export fn ZG_UploadUniformBuffer(surface: ?ZawraGraphicsHandle, buffer: ?ZawraGraphicsBuffer, data: ?[*]const u8, len: usize) bool {
    if (surface == null or buffer == null) return false;
    if (builtin.os.tag == .linux) return vulkan.uploadUniformBuffer(@ptrCast(@alignCast(surface.?)), @ptrCast(@alignCast(buffer.?)), data, len);
    if (builtin.os.tag == .macos) return macos_metal.uploadUniformBuffer(@ptrCast(@alignCast(surface.?)), @ptrCast(@alignCast(buffer.?)), data, len);
    if (builtin.os.tag == .windows) return windows_d3d12.uploadUniformBuffer(@ptrCast(@alignCast(surface.?)), @ptrCast(@alignCast(buffer.?)), data, len);
    return false;
}

pub export fn ZG_BindUniformBuffer(cmd: ?ZawraGraphicsCommandBuffer, buffer: ?ZawraGraphicsBuffer, binding: u32, offset: u64) void {
    if (cmd == null or buffer == null) return;
    if (builtin.os.tag == .linux) vulkan.cmdBindUniformBuffer(@ptrCast(@alignCast(cmd.?)), @ptrCast(@alignCast(buffer.?)), binding, offset);
    if (builtin.os.tag == .macos) macos_metal.cmdBindUniformBuffer(@ptrCast(@alignCast(cmd.?)), @ptrCast(@alignCast(buffer.?)), binding, offset);
    if (builtin.os.tag == .windows) windows_d3d12.cmdBindUniformBuffer(@ptrCast(@alignCast(cmd.?)), @ptrCast(@alignCast(buffer.?)), binding, offset);
}

pub export fn ZG_SetVSync(handle: ZawraGraphicsHandle, enabled: bool) void {
    if (builtin.os.tag == .linux) {
        const surface: *vulkan.VulkanSurface = @ptrCast(@alignCast(handle));
        if (enabled) {
            vulkan.setPresentMode(surface, 2); // VK_PRESENT_MODE_FIFO_KHR
        } else {
            vulkan.setPresentMode(surface, 0); // VK_PRESENT_MODE_IMMEDIATE_KHR
        }
    }
}

pub export fn ZG_RecreateSwapchain(handle: ZawraGraphicsHandle, width: u32, height: u32) void {
    if (builtin.os.tag == .linux) {
        const surface: *vulkan.VulkanSurface = @ptrCast(@alignCast(handle));
        vulkan.recreateSwapchain(surface, width, height);
    } else if (builtin.os.tag == .macos) {
        const surface: *macos_metal.MetalSurface = @ptrCast(@alignCast(handle));
        macos_metal.recreateSwapchain(surface, width, height);
    }
}

pub export fn ZG_SetMSAA(handle: ZawraGraphicsHandle, samples: u32) void {
    if (builtin.os.tag == .linux) {
        const surface: *vulkan.VulkanSurface = @ptrCast(@alignCast(handle));
        const clamped: u32 = switch (samples) {
            2 => 2,
            4 => 4,
            8 => 8,
            else => 1,
        };
        surface.msaa_samples = clamped;
    }
}

pub export fn ZG_CmdBindVertexBuffers(
    cmd: ZawraGraphicsCommandBuffer,
    first_binding: u32,
    buffers: [*]const ZawraGraphicsBuffer,
    offsets: [*]const u64,
    count: u32,
) void {
    if (builtin.os.tag == .linux) {
        const cmd_buf: *vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        const buf_slice = @as([*]const *vulkan.VulkanBuffer, @ptrCast(buffers))[0..count];
        vulkan.cmdBindVertexBuffers(cmd_buf, first_binding, buf_slice, offsets[0..count]);
    }
}

pub export fn ZG_CmdDrawInstanced(
    cmd: ZawraGraphicsCommandBuffer,
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
) void {
    if (builtin.os.tag == .linux) vulkan.cmdDrawInstanced(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    if (builtin.os.tag == .macos) macos_metal.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    if (builtin.os.tag == .windows) windows_d3d12.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
}

pub export fn ZG_CreatePipelineWithLayoutDesc(
    handle: ?ZawraGraphicsHandle,
    vert: ?ZawraGraphicsShaderModule,
    frag: ?ZawraGraphicsShaderModule,
    bindings: ?[*]const ZawraGraphicsVertexBinding,
    binding_count: u32,
    attributes: ?[*]const ZawraGraphicsVertexAttribute,
    attribute_count: u32,
    desc: ?*const PipelineDesc,
) ?ZawraGraphicsPipeline {
    if (handle == null or vert == null or frag == null) return null;
    if (builtin.os.tag == .linux) {
        const binding_slice = if (bindings) |b| @as([]const vulkan.VertexBinding, @ptrCast(b[0..binding_count])) else null;
        const attr_slice = if (attributes) |a| @as([]const vulkan.VertexAttribute, @ptrCast(a[0..attribute_count])) else null;
        return @ptrCast(vulkan.createPipelineFromShadersWithLayout(
            @ptrCast(@alignCast(handle.?)),
            @ptrCast(@alignCast(vert.?)),
            @ptrCast(@alignCast(frag.?)),
            binding_slice,
            attr_slice,
            desc,
        ));
    }
    return null;
}

pub export fn ZG_CreatePipelineWithLayout(
    handle: ?ZawraGraphicsHandle,
    vert: ?ZawraGraphicsShaderModule,
    frag: ?ZawraGraphicsShaderModule,
    bindings: ?[*]const ZawraGraphicsVertexBinding,
    binding_count: u32,
    attributes: ?[*]const ZawraGraphicsVertexAttribute,
    attribute_count: u32,
) ?ZawraGraphicsPipeline {
    return ZG_CreatePipelineWithLayoutDesc(
        handle,
        vert,
        frag,
        bindings,
        binding_count,
        attributes,
        attribute_count,
        null,
    );
}

pub export fn ZG_CreateComputePipeline(
    surface_handle: ?ZawraGraphicsHandle,
    comp_module: ?ZawraGraphicsShaderModule,
    storage_bindings: ?[*]const ZawraGraphicsStorageBinding,
    binding_count: u32,
) ?ZawraGraphicsComputePipeline {
    if (surface_handle == null or comp_module == null) return null;
    if (builtin.os.tag == .linux) {
        const bindings_slice = if (storage_bindings) |b|
            @as([]const vulkan.StorageBinding, @ptrCast(b[0..binding_count]))
        else
            &[0]vulkan.StorageBinding{};
        return @ptrCast(vulkan.createComputePipeline(
            @ptrCast(@alignCast(surface_handle.?)),
            @as(*vulkan.VulkanShaderModule, @ptrCast(@alignCast(comp_module.?))).module,
            bindings_slice,
        ));
    }
    return null;
}

pub export fn ZG_DestroyComputePipeline(
    surface_handle: ?ZawraGraphicsHandle,
    pipeline: ?ZawraGraphicsComputePipeline,
) void {
    if (surface_handle == null or pipeline == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyComputePipeline(
        @ptrCast(@alignCast(surface_handle.?)),
        @ptrCast(@alignCast(pipeline.?)),
    );
}

pub export fn ZG_BindComputePipeline(
    cmd_handle: ?ZawraGraphicsCommandBuffer,
    pipeline: ?ZawraGraphicsComputePipeline,
) void {
    if (cmd_handle == null or pipeline == null) return;
    if (builtin.os.tag == .linux) vulkan.cmdBindComputePipeline(
        @ptrCast(@alignCast(cmd_handle.?)),
        @ptrCast(@alignCast(pipeline.?)),
    );
}

pub export fn ZG_CmdDispatch(
    cmd_handle: ?ZawraGraphicsCommandBuffer,
    x: u32,
    y: u32,
    z: u32,
) void {
    if (cmd_handle == null) return;
    if (builtin.os.tag == .linux) vulkan.cmdDispatch(
        @ptrCast(@alignCast(cmd_handle.?)),
        x,
        y,
        z,
    );
}

pub export fn ZG_CreateStorageBuffer(
    surface_handle: ?ZawraGraphicsHandle,
    size: u32,
) ?ZawraGraphicsBuffer {
    if (surface_handle == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createStorageBuffer(
        @ptrCast(@alignCast(surface_handle.?)),
        size,
    ));
    return null;
}

pub export fn ZG_BindStorageBuffer(
    cmd_handle: ?ZawraGraphicsCommandBuffer,
    pipeline: ?ZawraGraphicsComputePipeline,
    buffer: ?ZawraGraphicsBuffer,
    binding: u32,
) void {
    if (cmd_handle == null or pipeline == null or buffer == null) return;
    if (builtin.os.tag == .linux) vulkan.bindStorageBuffer(
        @ptrCast(@alignCast(cmd_handle.?)),
        @ptrCast(@alignCast(pipeline.?)),
        @ptrCast(@alignCast(buffer.?)),
        binding,
    );
}

pub export fn ZG_CreateTimerQuery(surface_handle: ?ZawraGraphicsHandle) ?*anyopaque {
    if (surface_handle == null) return null;
    if (builtin.os.tag == .linux) {
        const query = vulkan.createTimerQuery(@ptrCast(@alignCast(surface_handle.?))) orelse return null;
        return @ptrCast(query);
    }
    return null;
}

pub export fn ZG_DestroyTimerQuery(surface_handle: ?ZawraGraphicsHandle, query: ?*anyopaque) void {
    if (surface_handle == null or query == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyTimerQuery(
        @ptrCast(@alignCast(surface_handle.?)),
        @ptrCast(@alignCast(query.?)),
    );
}

pub export fn ZG_CmdWriteTimestampBegin(cmd: ZawraGraphicsCommandBuffer, query: ?*anyopaque) void {
    if (query == null) return;
    if (builtin.os.tag == .linux) {
        const c_cmd: *vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        const q: *vulkan.VulkanTimerQuery = @ptrCast(@alignCast(query.?));
        vulkan.cmdResetQueryPool(c_cmd, q);
    }
}

pub export fn ZG_CmdWriteTimestampEnd(cmd: ZawraGraphicsCommandBuffer, query: ?*anyopaque) void {
    if (query == null) return;
    if (builtin.os.tag == .linux) {
        const c_cmd: *vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        const q: *vulkan.VulkanTimerQuery = @ptrCast(@alignCast(query.?));
        vulkan.cmdWriteTimestampEnd(c_cmd, q);
    }
}

pub export fn ZG_GetTimerQueryNs(surface_handle: ?ZawraGraphicsHandle, query: ?*anyopaque) f64 {
    if (surface_handle == null or query == null) return -1.0;
    if (builtin.os.tag == .linux) {
        const result = vulkan.getTimerQueryResults(
            @ptrCast(@alignCast(surface_handle.?)),
            @ptrCast(@alignCast(query.?)),
        );
        return result orelse -1.0;
    }
    return -1.0;
}

pub const ZawraGraphicsMRTSurface = *anyopaque;
pub const ZawraGraphicsStencilSurface = *anyopaque;

pub export fn ZG_CreateMRTSurface(handle: ZawraGraphicsHandle, width: u32, height: u32, attachment_count: u32) ?ZawraGraphicsMRTSurface {
    if (builtin.os.tag == .linux) {
        const result = vulkan.createMRTSurface(@ptrCast(@alignCast(handle)), width, height, attachment_count);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZG_DestroyMRTSurface(mrt_handle: ?ZawraGraphicsMRTSurface) void {
    if (mrt_handle == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyMRTSurface(@ptrCast(@alignCast(mrt_handle.?)));
}

pub export fn ZG_BeginMRTCommandBuffer(handle: ZawraGraphicsHandle, mrt_handle: ZawraGraphicsMRTSurface) ?ZawraGraphicsCommandBuffer {
    _ = handle;
    if (builtin.os.tag == .linux) {
        const mrt: *vulkan.MRTSurface = @ptrCast(@alignCast(mrt_handle));
        const result = vulkan.beginMRTCommandBuffer(mrt);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZG_EndMRTSurface(mrt_handle: ZawraGraphicsMRTSurface) void {
    if (builtin.os.tag == .linux) {
        const mrt: *vulkan.MRTSurface = @ptrCast(@alignCast(mrt_handle));
        vulkan.endMRTSurface(mrt);
    }
}

pub export fn ZG_ReadMRTTexture(mrt_handle: ZawraGraphicsMRTSurface, index: u32, out_buf: ?[*]u8, len: usize) bool {
    if (builtin.os.tag == .linux) {
        const mrt: *vulkan.MRTSurface = @ptrCast(@alignCast(mrt_handle));
        return vulkan.readMRTTexture(mrt, index, out_buf, len);
    }
    return false;
}

pub export fn ZG_CreateStencilSurface(handle: ZawraGraphicsHandle, width: u32, height: u32) ?ZawraGraphicsStencilSurface {
    if (builtin.os.tag == .linux) {
        const result = vulkan.createStencilSurface(@ptrCast(@alignCast(handle)), width, height);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZG_DestroyStencilSurface(stencil_handle: ?ZawraGraphicsStencilSurface) void {
    if (stencil_handle == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyStencilSurface(@ptrCast(@alignCast(stencil_handle.?)));
}

pub export fn ZG_BeginStencilCommandBuffer(stencil_handle: ZawraGraphicsStencilSurface) ?ZawraGraphicsCommandBuffer {
    if (builtin.os.tag == .linux) {
        const stencil: *vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        const result = vulkan.beginStencilCommandBuffer(stencil);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZG_EndStencilSurface(stencil_handle: ZawraGraphicsStencilSurface) void {
    if (builtin.os.tag == .linux) {
        const stencil: *vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        vulkan.endStencilSurface(stencil);
    }
}

pub export fn ZG_ReadStencilColorTexture(stencil_handle: ZawraGraphicsStencilSurface, out_buf: ?[*]u8, len: usize) bool {
    if (builtin.os.tag == .linux) {
        const stencil: *vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        return vulkan.readStencilColorTexture(stencil, out_buf, len);
    }
    return false;
}

pub export fn ZG_CreateStencilPipeline(handle: ?ZawraGraphicsHandle, desc: *const PipelineDesc) ?ZawraGraphicsPipeline {
    if (handle == null) return null;
    if (builtin.os.tag == .linux) return @ptrCast(vulkan.createStencilPipeline(@ptrCast(@alignCast(handle.?)), desc));
    return null;
}

pub export fn ZG_CmdSetStencilMask(cmd: ZawraGraphicsCommandBuffer, compare_op: u32, reference: u32, compare_mask: u32, write_mask: u32, fail_op: u32, depth_fail_op: u32, pass_op: u32) void {
    _ = compare_op;
    _ = compare_mask;
    _ = write_mask;
    _ = fail_op;
    _ = depth_fail_op;
    _ = pass_op;
    if (builtin.os.tag == .linux) {
        const c_cmd: *vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        vulkan.cmdSetStencilMask(c_cmd, vulkan.VK_STENCIL_FACE_FRONT_AND_BACK, reference);
    }
}

pub export fn ZG_BindStencilWritePipeline(stencil_handle: ZawraGraphicsStencilSurface, cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) {
        const stencil: *vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        const c_cmd: *vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        vulkan.cmdBindStencilPipeline(c_cmd, stencil.write_pipeline, stencil.write_pipeline_layout, stencil.descriptor_set);
    }
}

pub export fn ZG_BindStencilTestPipeline(stencil_handle: ZawraGraphicsStencilSurface, cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) {
        const stencil: *vulkan.StencilSurface = @ptrCast(@alignCast(stencil_handle));
        const c_cmd: *vulkan.VulkanCommandBuffer = @ptrCast(@alignCast(cmd));
        vulkan.cmdBindStencilPipeline(c_cmd, stencil.test_pipeline, stencil.test_pipeline_layout, stencil.descriptor_set);
    }
}

pub export fn ZG_GetDeviceProperty(handle: ZawraGraphicsHandle, name: u32) u32 {
    if (builtin.os.tag == .linux) return vulkan.getDeviceProperty(@ptrCast(@alignCast(handle)), name);
    if (builtin.os.tag == .macos) return macos_metal.getDeviceProperty(@as(*macos_metal.MetalSurface, @ptrCast(@alignCast(handle))), name);
    if (builtin.os.tag == .windows) return windows_d3d12.getDeviceProperty(@as(*windows_d3d12.D3D12Surface, @ptrCast(@alignCast(handle))), name);
    return 0;
}

pub const ZawraGraphicsRenderbuffer = *anyopaque;
pub const ZawraGraphicsFramebuffer = *anyopaque;

pub export fn ZG_CreateRenderbuffer(handle: ZawraGraphicsHandle, format: u32, width: u32, height: u32) ?ZawraGraphicsRenderbuffer {
    if (builtin.os.tag == .linux) {
        const result = vulkan.createRenderbuffer(@ptrCast(@alignCast(handle)), format, width, height);
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZG_DestroyRenderbuffer(handle: ZawraGraphicsHandle, renderbuffer: ?ZawraGraphicsRenderbuffer) void {
    if (renderbuffer == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyRenderbuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(renderbuffer.?)));
}

pub export fn ZG_CreateFramebuffer(
    handle: ZawraGraphicsHandle,
    color_texture: ?ZawraGraphicsTexture,
    width: u32,
    height: u32,
    depth_stencil_rb: ?ZawraGraphicsRenderbuffer,
) ?ZawraGraphicsFramebuffer {
    if (builtin.os.tag == .linux) {
        const result = vulkan.createFramebuffer(
            @ptrCast(@alignCast(handle)),
            if (color_texture) |t| @ptrCast(@alignCast(t)) else null,
            width,
            height,
            if (depth_stencil_rb) |rb| @ptrCast(@alignCast(rb)) else null,
        );
        if (result) |r| return @ptrCast(r);
    }
    return null;
}

pub export fn ZG_DestroyFramebuffer(handle: ZawraGraphicsHandle, framebuffer: ?ZawraGraphicsFramebuffer) void {
    if (framebuffer == null) return;
    if (builtin.os.tag == .linux) vulkan.destroyFramebuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(framebuffer.?)));
}

pub export fn ZG_CmdBindFramebuffer(handle: ZawraGraphicsHandle, cmd: ZawraGraphicsCommandBuffer, framebuffer: ZawraGraphicsFramebuffer) void {
    if (builtin.os.tag == .linux) {
        vulkan.cmdBindFramebuffer(
            @ptrCast(@alignCast(handle)),
            @ptrCast(@alignCast(cmd)),
            @ptrCast(@alignCast(framebuffer)),
        );
    }
}

pub export fn ZG_FramebufferAttachTexture(
    handle: ZawraGraphicsHandle,
    framebuffer: ZawraGraphicsFramebuffer,
    attachment: u32,
    texture: ZawraGraphicsTexture,
    mip_level: u32,
) bool {
    if (builtin.os.tag == .linux) {
        return vulkan.framebufferAttachTexture(
            @ptrCast(@alignCast(handle)),
            @ptrCast(@alignCast(framebuffer)),
            attachment,
            @ptrCast(@alignCast(texture)),
            mip_level,
        );
    }
    return false;
}

pub export fn ZG_FramebufferAttachRenderbuffer(
    handle: ZawraGraphicsHandle,
    framebuffer: ZawraGraphicsFramebuffer,
    attachment: u32,
    renderbuffer: ZawraGraphicsRenderbuffer,
) bool {
    if (builtin.os.tag == .linux) {
        return vulkan.framebufferAttachRenderbuffer(
            @ptrCast(@alignCast(handle)),
            @ptrCast(@alignCast(framebuffer)),
            attachment,
            @ptrCast(@alignCast(renderbuffer)),
        );
    }
    return false;
}
