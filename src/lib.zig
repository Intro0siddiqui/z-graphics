// src/lib.zig: Zawra Graphics OS Abstraction (RHI)
const std = @import("std");
const builtin = @import("builtin");

// Platform-specific backends
const linux_vulkan = if (builtin.os.tag == .linux) @import("linux_vulkan.zig") else struct {};
const macos_metal = if (builtin.os.tag == .macos) @import("macos_metal.zig") else struct {};
const windows_d3d12 = if (builtin.os.tag == .windows) @import("windows_d3d12.zig") else struct {};

/// The internal structure representing a graphics surface.
/// This is platform-dependent and opaque to the user (FFI).
pub const ZawraGraphicsSurface = if (builtin.os.tag == .linux)
    linux_vulkan.VulkanSurface
else if (builtin.os.tag == .macos)
    macos_metal.MetalSurface
else if (builtin.os.tag == .windows)
    windows_d3d12.D3D12Surface
else
    struct { dummy: u8 };

/// Opaque pointer to the graphics surface for C/C++ FFI.
pub const ZawraGraphicsHandle = *anyopaque;

/// Initializes the global graphics state.
pub export fn ZawraGraphics_Initialize() bool {
    // Basic global initialization logic can go here.
    return true;
}

/// Creates a surface for rendering.
/// Returns an opaque handle to a platform-specific surface object.
pub export fn ZawraGraphics_CreateSurface(width: u32, height: u32) ?ZawraGraphicsHandle {
    if (builtin.os.tag == .linux) {
        return @ptrCast(linux_vulkan.createSurface(width, height));
    } else if (builtin.os.tag == .macos) {
        return @ptrCast(macos_metal.createSurface(width, height));
    } else if (builtin.os.tag == .windows) {
        return @ptrCast(windows_d3d12.createSurface(width, height));
    }
    
    return null;
}

/// Destroys a graphics surface and frees its resources.
pub export fn ZawraGraphics_DestroySurface(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.destroySurface(@ptrCast(@alignCast(handle)));
    } else if (builtin.os.tag == .macos) {
        macos_metal.destroySurface(@ptrCast(@alignCast(handle)));
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.destroySurface(@ptrCast(@alignCast(handle)));
    }
}

/// Headfull window creation (optional/debug).
pub export fn ZawraGraphics_CreateWindow(width: u32, height: u32) ?ZawraGraphicsHandle {
    _ = width;
    _ = height;
    return null;
}
