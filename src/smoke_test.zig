const std = @import("std");
const zgraphics = @import("lib.zig");

pub fn main() !void {
    const initialized = zgraphics.ZawraGraphics_Initialize();
    if (!initialized) {
        std.debug.print("Failed to initialize ZawraGraphics\n", .{});
        std.process.exit(1);
    }
    std.debug.print("ZawraGraphics initialized successfully\n", .{});
    
    const window = zgraphics.ZawraGraphics_CreateWindow(800, 600);
    if (window != null) {
        std.debug.print("Window created successfully (unexpectedly, expected null stub)\n", .{});
        std.process.exit(1);
    }
    std.debug.print("Window creation correctly returned null stub\n", .{});
}
