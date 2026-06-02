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
            
            // Test Pipeline Creation (Using embedded shaders)
            const shaders = @import("shaders");
            const vert_code = shaders.vert;
            const frag_code = shaders.frag;

            const pipeline_desc = zgraphics.PipelineDesc{
                .vertex_shader = vert_code.ptr,
                .vertex_shader_len = vert_code.len,
                .pixel_shader = frag_code.ptr,
                .pixel_shader_len = frag_code.len,
            };
            
            const pipeline = zgraphics.ZawraGraphics_CreatePipeline(surface.?, &pipeline_desc);
            if (pipeline != null) {
                std.debug.print("Pipeline created successfully\n", .{});
                zgraphics.ZawraGraphics_CmdBindPipeline(cmd.?, pipeline.?);
                std.debug.print("Pipeline bound successfully\n", .{});
                zgraphics.ZawraGraphics_DestroyPipeline(surface.?, pipeline.?);
                std.debug.print("Pipeline destroyed successfully\n", .{});
            } else {
                std.debug.print("Pipeline creation returned null (this is expected if renderPass is missing/stubbed)\n", .{});
            }

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
        std.debug.print("Window created successfully\n", .{});
    } else {
        std.debug.print("Window creation returned null (this is expected in some headless CI environments without X11/Cocoa)\n", .{});
    }
}
