const std = @import("std");
const zgraphics = @import("lib");
const state_mod = @import("state.zig");
const renderer_mod = @import("renderer.zig");

pub fn main(init: std.process.Init.Minimal) !void {
    const allocator = std.heap.page_allocator;

    var args = try init.args.iterateAllocator(allocator);
    defer args.deinit();

    var width: u32 = 1280;
    var height: u32 = 800;
    var headless: bool = false;
    var max_frames: ?usize = null;
    var target_url: ?[]const u8 = null;

    _ = args.next(); // skip exe name
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--headless")) {
            headless = true;
        } else if (std.mem.eql(u8, arg, "--smoke")) {
            max_frames = 10;
        } else if (std.mem.startsWith(u8, arg, "--frames=")) {
            max_frames = try std.fmt.parseInt(usize, arg[9..], 10);
        } else if (std.mem.startsWith(u8, arg, "--width=")) {
            width = try std.fmt.parseInt(u32, arg[8..], 10);
        } else if (std.mem.startsWith(u8, arg, "--height=")) {
            height = try std.fmt.parseInt(u32, arg[9..], 10);
        } else if (!std.mem.startsWith(u8, arg, "--")) {
            target_url = arg;
        }
    }

    std.debug.print("[ZAWRA-SHELL] Initializing native Zig UI Shell ({}x{})...\n", .{ width, height });

    if (!zgraphics.ZG_Initialize()) {
        std.debug.print("[ZAWRA-SHELL] ERROR: Failed to initialize z-graphics\n", .{});
        return error.GraphicsInitFailed;
    }

    const window = if (!headless) zgraphics.ZG_CreateWindow(width, height) else null;
    const surface = zgraphics.ZG_CreateSurface(window, width, height) orelse {
        std.debug.print("[ZAWRA-SHELL] ERROR: Failed to create graphics surface\n", .{});
        return error.SurfaceCreationFailed;
    };
    defer zgraphics.ZG_DestroySurface(surface);

    var shell_state = try state_mod.ShellState.init(allocator, width, height);
    defer shell_state.deinit();

    if (target_url) |url| {
        shell_state.omnibar.setText(url);
    }

    var ui_renderer = try renderer_mod.UIRenderer.init(allocator, surface);
    defer ui_renderer.deinit();

    std.debug.print("[ZAWRA-SHELL] UI Shell initialized successfully! Entering frame loop...\n", .{});

    var frame_count: usize = 0;
    const is_limited = (max_frames != null);
    const limit = max_frames orelse 0;

    while (!is_limited or frame_count < limit) : (frame_count += 1) {
        if (window) |win| {
            zgraphics.ZG_PollEvents(win);
        }

        // Animate or update layout if needed
        shell_state.recomputeLayout();

        // Render complete Zawra UI Shell frame
        ui_renderer.render(&shell_state);

        if (is_limited and frame_count + 1 >= limit) break;

        // In interactive mode sleep ~16ms (~60fps)
        if (!is_limited) {
            const req = std.os.linux.timespec{ .sec = 0, .nsec = 16 * 1000 * 1000 };
            _ = std.os.linux.nanosleep(&req, null);
        }
    }

    std.debug.print("[ZAWRA-SHELL] Frame loop finished after {} frames.\n", .{frame_count});
}
