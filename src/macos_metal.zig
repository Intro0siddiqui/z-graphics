const std = @import("std");
const builtin = @import("builtin");

/// The internal structure representing a Metal graphics surface.
pub const MetalSurface = struct {
    device: ?*anyopaque,
    command_queue: ?*anyopaque,
    texture: ?*anyopaque, // MTLTexture used as the offscreen render target
    width: u32,
    height: u32,
};

// Extern declarations for C-linkable Metal symbols
extern fn MTLCreateSystemDefaultDevice() ?*anyopaque;

pub fn createSurface(width: u32, height: u32) ?*MetalSurface {
    if (builtin.os.tag != .macos) return null;

    // 1. Create the system default Metal device
    const device = MTLCreateSystemDefaultDevice() orelse return null;

    // 2. Allocate the surface state
    var surface_obj = std.heap.page_allocator.create(MetalSurface) catch return null;
    surface_obj.device = device;
    surface_obj.command_queue = null; // Next: [device newCommandQueue]
    
    // 3. Create Offscreen Image Buffer (MTLTexture)
    // Next: Create MTLTextureDescriptor (pixelFormat = MTLPixelFormatRGBA8Unorm, usage = renderTarget)
    // Next: [device newTextureWithDescriptor:]
    surface_obj.texture = null; 
    
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
