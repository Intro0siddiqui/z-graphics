const std = @import("std");
const zgraphics = @import("lib");
const state_mod = @import("state.zig");
const renderer_mod = @import("renderer.zig");

var global_shell_state: ?*state_mod.ShellState = null;

fn onPointerEvent(event_type: u32, x: f32, y: f32, button: u32, state: u32) callconv(.c) void {
    if (global_shell_state) |shell| {
        // Event types: 0 = motion, 1 = button down, 2 = button up, 3 = axis/scroll
        if (event_type == 0) {
            shell.handleMouseMove(x, y);
        } else if (event_type == 1) {
            shell.handleMouseDown(x, y);
        }

        // Viewport relative event forwarding to WPE
        const vp = shell.layout.viewport_rect;
        if (vp.contains(x, y)) {
            const active_tab = shell.getActiveTabConst();
            const is_start = if (active_tab) |tab| state_mod.isStartPage(tab.getUrl()) else true;
            if (!is_start) {
                const local_x: f64 = @floatCast(x - vp.x);
                const local_y: f64 = @floatCast(y - vp.y);
                zgraphics.wpe_view_event_pointer(event_type, local_x, local_y, button, state);
            }
        }
    }
}

fn onKeyboardEvent(key: u32, state: u32, ctrl: bool) callconv(.c) void {
    if (global_shell_state) |shell| {
        const is_down = (state == 1);
        shell.handleKey(key, is_down, ctrl);

        // Forward keystrokes to WPE only when neither omnibar nor search_hud is focused
        if (shell.focus == .none) {
            const active_tab = shell.getActiveTabConst();
            const is_start = if (active_tab) |tab| state_mod.isStartPage(tab.getUrl()) else true;
            if (!is_start) {
                const mods: u32 = if (ctrl) 4 else 0;
                zgraphics.wpe_view_event_keyboard(key, state, mods);
            }
        }
    }
}

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

    var ui_renderer = try renderer_mod.UIRenderer.init(allocator, surface);
    defer ui_renderer.deinit();

    // Register global shell state & callbacks for input and DMA-BUF texture routing
    global_shell_state = &shell_state;
    renderer_mod.setGlobalUIRenderer(&ui_renderer);
    zgraphics.ZG_SetPointerCallback(&onPointerEvent);
    zgraphics.ZG_SetKeyboardCallback(&onKeyboardEvent);
    defer {
        zgraphics.ZG_SetPointerCallback(null);
        zgraphics.ZG_SetKeyboardCallback(null);
        renderer_mod.setGlobalUIRenderer(null);
        global_shell_state = null;
    }

    if (target_url) |url| {
        shell_state.navigateToUrl(url);
    }

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
