// src/lib.zig: Zawra Graphics OS Abstraction
const builtin = @import("builtin");
const linux_vulkan = if (builtin.os.tag == .linux) @import("linux_vulkan.zig") else struct {};
const macos_metal = if (builtin.os.tag == .macos) @import("macos_metal.zig") else struct {};
const windows_d3d12 = if (builtin.os.tag == .windows) @import("windows_d3d12.zig") else struct {};

pub const ZawraGraphicsHandle = *anyopaque;

pub export fn ZawraGraphics_Initialize() bool {
    return true;
}

/// Creates a surface for rendering
pub export fn ZawraGraphics_CreateSurface(width: u32, height: u32) ?ZawraGraphicsHandle {
    _ = width;
    _ = height;
    
    if (builtin.os.tag == .linux) {
        return linux_vulkan.initInstance();
    } else if (builtin.os.tag == .macos) {
        return macos_metal.initInstance();
    } else if (builtin.os.tag == .windows) {
        return windows_d3d12.initInstance();
    }
    
    return null;
}

pub export fn ZawraGraphics_CreateWindow(width: u32, height: u32) ?ZawraGraphicsHandle {
    _ = width;
    _ = height;
    return null;
}
