const std = @import("std");
const zgraphics = @import("lib.zig");

pub fn main() !void {
    const initialized = zgraphics.ZawraGraphics_Initialize();
    if (!initialized) {
        std.debug.print("Failed to initialize z-graphics\n", .{});
        std.process.exit(1);
    }
    std.debug.print("z-graphics initialized successfully\n", .{});

    const window = zgraphics.ZawraGraphics_CreateWindow(474, 323);
    const surface = zgraphics.ZawraGraphics_CreateSurface(window, 474, 323) orelse {
        std.debug.print("Surface creation failed\n", .{});
        return;
    };

    // 1. Load image data
    const pixel_data = @embedFile("pixels.raw");
    std.debug.print("Loaded image data, size: {d}\n", .{pixel_data.len});

    const shaders = @import("shaders");
    const pipeline_desc = zgraphics.PipelineDesc{
        .vertex_shader = shaders.vert.ptr,
        .vertex_shader_len = shaders.vert.len,
        .pixel_shader = shaders.frag.ptr,
        .pixel_shader_len = shaders.frag.len,
    };
    std.debug.print("Creating pipeline...\n", .{});
    const pipeline = zgraphics.ZawraGraphics_CreatePipeline(surface, &pipeline_desc).?;

    // 2. Create Texture
    const tex_desc = zgraphics.ZawraGraphicsTextureDesc{
        .format = .R8G8B8A8_Unorm,
        .width = 474,
        .height = 323,
        .external_handle = null,
    };
    std.debug.print("Creating texture...\n", .{});
    const texture = zgraphics.ZawraGraphics_CreateTexture(surface, &tex_desc) orelse {
        std.debug.print("Texture creation failed\n", .{});
        return;
    };
    std.debug.print("Texture created. Uploading...\n", .{});
    const uploaded = zgraphics.ZawraGraphics_UploadTexture(surface, texture, pixel_data.ptr, pixel_data.len);
    std.debug.print("Texture uploaded: {}\n", .{uploaded});

    // 3. Render loop
    std.debug.print("Starting render loop for 10 seconds...\n", .{});
    var start_ts: std.os.linux.timespec = undefined;
    _ = std.os.linux.clock_gettime(std.os.linux.CLOCK.MONOTONIC, &start_ts);
    const start_time = start_ts.sec;

    var frame_count: usize = 0;
    while (true) : (frame_count += 1) {
        var curr_ts: std.os.linux.timespec = undefined;
        _ = std.os.linux.clock_gettime(std.os.linux.CLOCK.MONOTONIC, &curr_ts);
        if (curr_ts.sec - start_time >= 10) break;

        const cmd = zgraphics.ZawraGraphics_BeginCommandBuffer(surface).?;
        
        zgraphics.ZawraGraphics_CmdClearColor(cmd, 1.0, 0.0, 0.0, 1.0);
        
        zgraphics.ZawraGraphics_CmdBindPipeline(cmd, pipeline);
        zgraphics.ZawraGraphics_BindTexture(cmd, texture, 0); // Bind texture at slot 0
        // Draw 3 vertices to generate the fullscreen triangle via SV_VertexID
        zgraphics.ZawraGraphics_CmdDraw(cmd, 3, 1, 0, 0);
        
        zgraphics.ZawraGraphics_SubmitCommandBuffer(surface, cmd);
        zgraphics.ZawraGraphics_SwapBuffers(surface);

        // Primitive pacing (~60fps)
        var spin: usize = 0;
        while (spin < 5_000_000) : (spin += 1) {}
    }
    
    std.debug.print("Render loop finished after 10 seconds. Frames rendered: {d}\n", .{frame_count});

    zgraphics.ZawraGraphics_DestroyPipeline(surface, pipeline);
    zgraphics.ZawraGraphics_DestroyTexture(surface, texture);
    zgraphics.ZawraGraphics_DestroySurface(surface);
}
