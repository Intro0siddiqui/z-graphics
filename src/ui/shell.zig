const std = @import("std");
const zgraphics = @import("lib");
const state_mod = @import("state.zig");
const renderer_mod = @import("renderer.zig");

pub const ZawraPendingWpeFrame = extern struct {
    dmabuf: zgraphics.ZawraGraphicsDMABufInfo,
    view: ?*anyopaque,
    buffer: ?*anyopaque,
};

extern "c" fn Zawra_PollPendingWpeFrame(out_frame: *ZawraPendingWpeFrame) callconv(.c) bool;
extern "c" fn Zawra_NotifyWpeBufferRendered(view: ?*anyopaque, buffer: ?*anyopaque) callconv(.c) void;
extern "c" fn Zawra_ResizeViewport(width: u32, height: u32) callconv(.c) void;

extern "c" fn Zawra_TakePendingDMABuf(
    out_fd: *c_int,
    out_w: *u32,
    out_h: *u32,
    out_stride: *u32,
    out_fourcc: *u32,
    out_modifier: *u64,
) callconv(.c) bool;

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

pub fn runShell(width: u32, height: u32, headless: bool, max_frames: ?usize, target_url: ?[]const u8) !void {
    const allocator = std.heap.c_allocator;
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

    var active_wpe_tex: ?zgraphics.ZawraGraphicsTexture = null;
    var active_wpe_view: ?*anyopaque = null;
    var active_wpe_buf: ?*anyopaque = null;

    var old_wpe_tex: ?zgraphics.ZawraGraphicsTexture = null;
    var old_wpe_view: ?*anyopaque = null;
    var old_wpe_buf: ?*anyopaque = null;

    // Register global shell state & callbacks for input and DMA-BUF texture routing
    global_shell_state = &shell_state;
    renderer_mod.setGlobalUIRenderer(&ui_renderer);
    zgraphics.ZG_RegisterWpeTextureSetter(&renderer_mod.wpeTextureCallback);
    zgraphics.ZG_SetPointerCallback(&onPointerEvent);
    zgraphics.ZG_SetKeyboardCallback(&onKeyboardEvent);
    defer {
        zgraphics.ZG_SetPointerCallback(null);
        zgraphics.ZG_SetKeyboardCallback(null);
        zgraphics.ZG_RegisterWpeTextureSetter(null);
        renderer_mod.setGlobalUIRenderer(null);
        global_shell_state = null;

        if (active_wpe_buf != null) {
            if (active_wpe_tex) |at| {
                zgraphics.ZG_DestroyTexture(surface, at);
            }
            Zawra_NotifyWpeBufferRendered(active_wpe_view, active_wpe_buf);
            active_wpe_tex = null;
            active_wpe_buf = null;
        }
        if (old_wpe_buf != null) {
            if (old_wpe_tex) |ot| {
                zgraphics.ZG_DestroyTexture(surface, ot);
            }
            Zawra_NotifyWpeBufferRendered(old_wpe_view, old_wpe_buf);
            old_wpe_tex = null;
            old_wpe_buf = null;
        }
    }

    if (target_url) |url| {
        shell_state.navigateToUrl(url);
    }

    std.debug.print("[ZAWRA-SHELL] UI Shell initialized successfully! Entering frame loop...\n", .{});

    var frame_count: usize = 0;
    const is_limited = (max_frames != null);
    const limit = max_frames orelse 0;

    while (!is_limited or frame_count < limit) : (frame_count += 1) {
        // At top of frame: check mailbox for incoming WPE DMA-BUF frame
        var frame_info: ZawraPendingWpeFrame = undefined;
        var has_new_frame = false;
        if (Zawra_PollPendingWpeFrame(&frame_info)) {
            if (zgraphics.ZG_ImportTextureDMABuf(surface, &frame_info.dmabuf)) |new_tex| {
                if (old_wpe_buf != null) {
                    if (old_wpe_tex) |ot| {
                        zgraphics.ZG_DestroyTexture(surface, ot);
                    }
                    Zawra_NotifyWpeBufferRendered(old_wpe_view, old_wpe_buf);
                    old_wpe_tex = null;
                    old_wpe_view = null;
                    old_wpe_buf = null;
                }

                old_wpe_tex = active_wpe_tex;
                old_wpe_view = active_wpe_view;
                old_wpe_buf = active_wpe_buf;

                active_wpe_tex = new_tex;
                active_wpe_view = frame_info.view;
                active_wpe_buf = frame_info.buffer;
                zgraphics.ZG_SetWpeTexture(active_wpe_tex);
                has_new_frame = true;
                std.debug.print("[ZAWRA-SHELL] >>> Imported WPE DMA-BUF Frame into Vulkan Pass 1: {}x{} <<<\n", .{ frame_info.dmabuf.width, frame_info.dmabuf.height });
            }
        } else {
            // Fallback for legacy mailbox
            var dmabuf_fd: c_int = -1;
            var dmabuf_w: u32 = 0;
            var dmabuf_h: u32 = 0;
            var dmabuf_stride: u32 = 0;
            var dmabuf_fourcc: u32 = 0;
            var dmabuf_modifier: u64 = 0;
            if (Zawra_TakePendingDMABuf(&dmabuf_fd, &dmabuf_w, &dmabuf_h, &dmabuf_stride, &dmabuf_fourcc, &dmabuf_modifier)) {
                if (dmabuf_fd >= 0 and dmabuf_w > 0 and dmabuf_h > 0) {
                    const info = zgraphics.ZawraGraphicsDMABufInfo{
                        .fd = dmabuf_fd,
                        .width = dmabuf_w,
                        .height = dmabuf_h,
                        .stride = if (dmabuf_stride > 0) dmabuf_stride else dmabuf_w * 4,
                        .offset = 0,
                        .drm_format = dmabuf_fourcc,
                        .drm_modifier = dmabuf_modifier,
                    };
                    if (zgraphics.ZG_ImportTextureDMABuf(surface, &info)) |new_tex| {
                        if (old_wpe_buf != null) {
                            if (old_wpe_tex) |ot| {
                                zgraphics.ZG_DestroyTexture(surface, ot);
                            }
                            Zawra_NotifyWpeBufferRendered(old_wpe_view, old_wpe_buf);
                            old_wpe_tex = null;
                            old_wpe_view = null;
                            old_wpe_buf = null;
                        }
                        old_wpe_tex = active_wpe_tex;
                        old_wpe_view = active_wpe_view;
                        old_wpe_buf = active_wpe_buf;

                        active_wpe_tex = new_tex;
                        active_wpe_view = null;
                        active_wpe_buf = null;
                        zgraphics.ZG_SetWpeTexture(active_wpe_tex);
                        has_new_frame = true;
                    }
                }
            }
        }

        if (window) |win| {
            zgraphics.ZG_PollEvents(win);
            var new_w: u32 = 0;
            var new_h: u32 = 0;
            if (zgraphics.ZG_CheckWindowResize(win, &new_w, &new_h)) {
                if (new_w > 0 and new_h > 0 and (new_w != shell_state.window_width or new_h != shell_state.window_height)) {
                    shell_state.setWindowSize(new_w, new_h);
                    zgraphics.ZG_RecreateSwapchain(surface, new_w, new_h);
                    if (new_w > 260) {
                        Zawra_ResizeViewport(new_w - 260, new_h);
                    }
                    std.debug.print("[ZAWRA-SHELL] Window resized to {}x{}\n", .{ new_w, new_h });
                }
            }
        }

        // Animate or update layout if needed
        shell_state.recomputeLayout();

        // Render complete Zawra UI Shell frame (Pass 1 Viewport Quad + Pass 2 UI Elements, fence wait + swap)
        ui_renderer.render(&shell_state);

        // Hold onto active_wpe_buf until the next frame's vkWaitForFences / swap finishes,
        // then destroy old VulkanTexture and notify Rust
        if (has_new_frame and old_wpe_buf != null) {
            if (old_wpe_tex) |ot| {
                zgraphics.ZG_DestroyTexture(surface, ot);
            }
            Zawra_NotifyWpeBufferRendered(old_wpe_view, old_wpe_buf);
            old_wpe_tex = null;
            old_wpe_view = null;
            old_wpe_buf = null;
        }

        if (is_limited and frame_count + 1 >= limit) break;

        // In interactive mode sleep ~16ms (~60fps)
        if (!is_limited) {
            const req = std.os.linux.timespec{ .sec = 0, .nsec = 16 * 1000 * 1000 };
            _ = std.os.linux.nanosleep(&req, null);
        }
    }

    std.debug.print("[ZAWRA-SHELL] Frame loop finished after {} frames.\n", .{frame_count});
}

pub export fn Zawra_UI_Run(argc: c_int, argv: ?[*][*:0]const u8) c_int {
    _ = argc;
    _ = argv;
    runShell(1280, 800, false, null, null) catch |err| {
        std.debug.print("[ZAWRA-SHELL] Error: {}\n", .{err});
        return 1;
    };
    return 0;
}

pub export fn roundq(x: f128) f128 {
    return @round(x);
}

pub fn runShellFromArgs(init: std.process.Init.Minimal) !void {
    const allocator = std.heap.c_allocator;

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

    try runShell(width, height, headless, max_frames, target_url);
}
