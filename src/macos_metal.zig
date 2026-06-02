const std = @import("std");
const builtin = @import("builtin");

/// The internal structure representing a Metal graphics surface.
pub const MetalSurface = struct {
    device: ?*anyopaque,
    command_queue: ?*anyopaque,
    texture: ?*anyopaque, // MTLTexture used as the offscreen render target
    window: ?*anyopaque,  // NSWindow
    view: ?*anyopaque,    // NSView / CAMetalLayer
    width: u32,
    height: u32,
};

// --- Objective-C FFI ---
extern fn objc_getClass(name: [*:0]const u8) ?*anyopaque;
extern fn sel_registerName(name: [*:0]const u8) ?*anyopaque;
extern fn objc_msgSend(self: ?*anyopaque, op: ?*anyopaque, ...) ?*anyopaque;

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    if (builtin.os.tag != .macos) return null;

    const NSWindow = objc_getClass("NSWindow") orelse return null;
    const alloc = sel_registerName("alloc");
    const init = sel_registerName("initWithContentRect:styleMask:backing:defer:");
    const makeKeyAndOrderFront = sel_registerName("makeKeyAndOrderFront:");
    const setTitle = sel_registerName("setTitle:");
    const NSString = objc_getClass("NSString");
    const stringWithUTF8String = sel_registerName("stringWithUTF8String:");

    // Minimal rect: {{100, 100}, {width, height}}
    const rect = [4]f64{ 100, 100, @floatFromInt(width), @floatFromInt(height) };

    // styleMask: 1 (Titled) | 2 (Closable) | 4 (Resizable)
    const styleMask: usize = 1 | 2 | 4;
    const backing: usize = 2; // Buffered

    const window_alloc = objc_msgSend(NSWindow, alloc);
    const window = objc_msgSend(window_alloc, init, &rect, styleMask, backing, @as(u8, 0));

    const title = objc_msgSend(NSString, stringWithUTF8String, @as([*:0]const u8, "Zawra Browser"));
    _ = objc_msgSend(window, setTitle, title);
    _ = objc_msgSend(window, makeKeyAndOrderFront, @as(?*anyopaque, null));

    return window;
}

// Extern declarations for C-linkable Metal symbols
extern fn MTLCreateSystemDefaultDevice() ?*anyopaque;

pub fn createSurface(window: ?*anyopaque, width: u32, height: u32) ?*MetalSurface {
    if (builtin.os.tag != .macos) return null;

    // 1. Create the system default Metal device
    const device = MTLCreateSystemDefaultDevice() orelse return null;

    // 2. Allocate the surface state
    var surface_obj = std.heap.page_allocator.create(MetalSurface) catch return null;
    surface_obj.device = device;
    surface_obj.window = window;
    
    // 3. Create Command Queue
    const newCommandQueue = sel_registerName("newCommandQueue");
    surface_obj.command_queue = objc_msgSend(device, newCommandQueue);
    
    // 4. Create Offscreen Image Buffer (MTLTexture)
    const MTLTextureDescriptor = objc_getClass("MTLTextureDescriptor") orelse return null;
    const texture2DDescriptorWithPixelFormat = sel_registerName("texture2DDescriptorWithPixelFormat:width:height:mipmapped:");
    const newTextureWithDescriptor = sel_registerName("newTextureWithDescriptor:");

    // MTLPixelFormatRGBA8Unorm = 70
    const pixelFormat: usize = 70;
    const mipmapped: usize = 0; // NO

    const descriptor = objc_msgSend(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        pixelFormat,
        @as(usize, width),
        @as(usize, height),
        mipmapped,
    );

    // Set usage to RenderTarget (1) | ShaderRead (2)
    const setUsage = sel_registerName("setUsage:");
    _ = objc_msgSend(descriptor, setUsage, @as(usize, 1 | 2));

    surface_obj.texture = objc_msgSend(device, newTextureWithDescriptor, descriptor);
    
    surface_obj.window = null;
    surface_obj.view = null;
    surface_obj.width = width;
    surface_obj.height = height;

    return surface_obj;
}

pub fn destroySurface(surface: *MetalSurface) void {
    if (builtin.os.tag != .macos) return;
    
    // Note: Metal uses ARC (Automatic Reference Counting).
    // In a pure C/Zig context, we would use CFRelease or similar if they were CoreFoundation objects,
    // but Metal objects usually require [object release] via Obj-C runtime.
    // Cleanup of surface.texture and surface.command_queue would happen here.
    
    std.heap.page_allocator.destroy(surface);
}

pub fn swapBuffers(surface: *MetalSurface) void {
    if (builtin.os.tag != .macos) return;
    _ = surface;
    // Command Buffer submission and presentation would occur here.
    // [command_buffer commit];
    // [command_buffer waitUntilCompleted]; // For headless sync
}

pub fn exportSurfaceFD(surface: *MetalSurface) i32 {
    if (builtin.os.tag != .macos) return -1;
    _ = surface;
    // For macOS, we'd typically export an IOSurfaceID.
    // We cast it to i32 for the generic FFI interface.
    return -1; // Stub
}

// ---------------------------------------------------------
// RESOURCE MANAGEMENT
// ---------------------------------------------------------

pub const MetalBuffer = struct {
    buffer: ?*anyopaque, // MTLBuffer
    size: usize,
};

pub fn createBuffer(surface: *MetalSurface, size: usize, buffer_type: u32) ?*MetalBuffer {
    if (builtin.os.tag != .macos) return null;
    _ = surface;
    _ = size;
    _ = buffer_type;
    return null;
}

pub fn destroyBuffer(surface: *MetalSurface, buffer: *MetalBuffer) void {
    if (builtin.os.tag != .macos) return;
    _ = surface;
    _ = buffer;
}

// ---------------------------------------------------------
// COMMAND RECORDING
// ---------------------------------------------------------

pub const MetalCommandBuffer = struct {
    cmd_buffer: ?*anyopaque, // MTLCommandBuffer
    render_encoder: ?*anyopaque, // MTLRenderCommandEncoder
};

pub fn beginCommandBuffer(surface: *MetalSurface) ?*MetalCommandBuffer {
    if (builtin.os.tag != .macos) return null;
    _ = surface;
    return null;
}

pub fn cmdClearColor(cmd: *MetalCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd;
    _ = r; _ = g; _ = b; _ = a;
}

pub fn submitCommandBuffer(surface: *MetalSurface, cmd: *MetalCommandBuffer) void {
    if (builtin.os.tag != .macos) return;
    _ = surface;
    _ = cmd;
}

// ---------------------------------------------------------
// PIPELINE MANAGEMENT
// ---------------------------------------------------------

pub const MetalPipeline = struct {
    pipeline_state: ?*anyopaque, // MTLRenderPipelineState
};

pub fn createPipeline(surface: *MetalSurface, desc: *const @import("lib.zig").PipelineDesc) ?*MetalPipeline {
    if (builtin.os.tag != .macos) return null;
    _ = surface;
    _ = desc;
    return null;
}

pub fn destroyPipeline(surface: *MetalSurface, pipeline: ?*MetalPipeline) void {
    if (builtin.os.tag != .macos or pipeline == null) return;
    _ = surface;
    std.heap.page_allocator.destroy(pipeline.?);
}

pub fn cmdBindPipeline(cmd: *MetalCommandBuffer, pipeline: *MetalPipeline) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd;
    _ = pipeline;
}
