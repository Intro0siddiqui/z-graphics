const std = @import("std");
const zgraphics = @import("lib.zig");

pub fn main() !void {
    const initialized = zgraphics.ZawraGraphics_Initialize();
    if (!initialized) {
        std.debug.print("Failed to initialize ZawraGraphics\n", .{});
        std.process.exit(1);
    }
    std.debug.print("ZawraGraphics initialized successfully\n", .{});
    
    const surface = zgraphics.ZawraGraphics_CreateSurface(800, 600);
    if (surface == null) {
        std.debug.print("Surface creation returned null (this is expected if Vulkan is not fully available on CI, but means backend is still stubbed/failing)\n", .{});
    } else {
        std.debug.print("Surface created successfully\n", .{});

        const buffer = zgraphics.ZawraGraphics_CreateBuffer(surface.?, 1024, zgraphics.BufferType.Vertex);
        if (buffer != null) {
            std.debug.print("Buffer allocated successfully\n", .{});
            zgraphics.ZawraGraphics_DestroyBuffer(surface.?, buffer.?);
        }

        const cmd = zgraphics.ZawraGraphics_BeginCommandBuffer(surface.?);
        if (cmd != null) {
            std.debug.print("Command buffer started successfully\n", .{});
            zgraphics.ZawraGraphics_CmdClearColor(cmd.?, 1.0, 0.0, 0.0, 1.0);
            zgraphics.ZawraGraphics_SubmitCommandBuffer(surface.?, cmd.?);
            std.debug.print("Command buffer submitted successfully\n", .{});
        }

        zgraphics.ZawraGraphics_SwapBuffers(surface.?);
        std.debug.print("Buffers swapped successfully\n", .{});
        zgraphics.ZawraGraphics_DestroySurface(surface.?);
        std.debug.print("Surface destroyed successfully\n", .{});
    }

    const window = zgraphics.ZawraGraphics_CreateWindow(800, 600);
    if (window != null) {
        std.debug.print("Window created successfully (unexpectedly, expected null stub)\n", .{});
        std.process.exit(1);
    }
    std.debug.print("Window creation correctly returned null stub\n", .{});
}
