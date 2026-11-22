const std = @import("std");
const builtin = @import("builtin");

pub const surface_extension: [*:0]const u8 = "VK_KHR_xlib_surface";

// --- X11 FFI ---
const Display = anyopaque;
const Window = usize;
extern "X11" fn XOpenDisplay(display_name: ?[*:0]const u8) callconv(.c) ?*Display;
extern "X11" fn XCloseDisplay(display: *Display) callconv(.c) i32;
extern "X11" fn XCreateSimpleWindow(
    display: *Display,
    parent: Window,
    x: i32,
    y: i32,
    width: u32,
    height: u32,
    border_width: u32,
    border: usize,
    background: usize,
) callconv(.c) Window;
extern "X11" fn XMapWindow(display: *Display, w: Window) callconv(.c) i32;
extern "X11" fn XDefaultRootWindow(display: *Display) callconv(.c) Window;
extern "X11" fn XStoreName(display: *Display, w: Window, name: [*:0]const u8) callconv(.c) i32;
extern "X11" fn XFlush(display: *Display) callconv(.c) i32;
extern "X11" fn XSelectInput(display: *Display, w: Window, event_mask: u32) callconv(.c) i32;
extern "X11" fn XNextEvent(display: *Display, event_return: *XEvent) callconv(.c) i32;
extern "X11" fn XPending(display: *Display) callconv(.c) i32;

const XEvent = extern struct {
    type: u32,
    pad: [19 * @sizeOf(usize)]u8,
};

const StructureNotifyMask = 1 << 19;
const MapNotify = 19;

pub const X11WindowState = struct {
    display: *Display,
    window: Window,
};

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    if (builtin.os.tag != .linux) return null;
    std.debug.print("[Z-GRAPHICS] createWindow: opening X11 display\n", .{});

    const display = XOpenDisplay(null) orelse {
        std.debug.print("[Z-GRAPHICS] createWindow: XOpenDisplay failed\n", .{});
        return null;
    };
    std.debug.print("[Z-GRAPHICS] createWindow: display={any}, creating {}x{} window\n", .{ display, width, height });
    const root = XDefaultRootWindow(display);
    const window = XCreateSimpleWindow(display, root, 100, 100, width, height, 0, 0, 0);
    _ = XStoreName(display, window, "Zawra Browser");

    _ = XSelectInput(display, window, StructureNotifyMask);
    _ = XMapWindow(display, window);
    _ = XFlush(display);
    std.debug.print("[Z-GRAPHICS] createWindow: mapped, waiting for MapNotify...\n", .{});

    var event: XEvent = undefined;
    var safety: u32 = 0;
    while (safety < 100) : (safety += 1) {
        if (XPending(display) > 0) {
            _ = XNextEvent(display, &event);
            if (event.type == MapNotify) {
                std.debug.print("[Z-GRAPHICS] createWindow: got MapNotify after {} iterations\n", .{safety});
                break;
            }
        } else {
            const req = std.os.linux.timespec{ .sec = 0, .nsec = 10 * std.time.ns_per_ms };
            _ = std.os.linux.nanosleep(&req, null);
        }
    }
    if (safety >= 100) {
        std.debug.print("[Z-GRAPHICS] createWindow: WARNING timed out waiting for MapNotify, proceeding anyway\n", .{});
    }

    const state = std.heap.page_allocator.create(X11WindowState) catch {
        std.debug.print("[Z-GRAPHICS] createWindow: failed to allocate X11WindowState\n", .{});
        _ = XCloseDisplay(display);
        return null;
    };
    state.* = .{ .display = display, .window = window };
    std.debug.print("[Z-GRAPHICS] createWindow: success, window={}\n", .{window});
    return @ptrFromInt(@intFromPtr(state));
}

const VkXlibSurfaceCreateInfoKHR = extern struct {
    sType: u32 = 1000004000,
    pNext: ?*const anyopaque = null,
    flags: u32 = 0,
    dpy: ?*anyopaque,
    window: usize,
};

const PFN_vkCreateXlibSurfaceKHR = *const fn (
    instance: ?*anyopaque,
    pCreateInfo: *const VkXlibSurfaceCreateInfoKHR,
    pAllocator: ?*const anyopaque,
    pSurface: *?*anyopaque,
) callconv(.c) i32;

pub fn createVkSurface(
    instance: ?*anyopaque,
    pfn_proc_addr: ?*const anyopaque,
    window: ?*anyopaque,
    out_surface: *?*anyopaque,
) bool {
    const w = window orelse return false;
    const state: *X11WindowState = @ptrCast(@alignCast(w));
    if (pfn_proc_addr == null) return false;
    const getProcAddr: *const fn (?*anyopaque, [*:0]const u8) callconv(.c) ?*anyopaque = @ptrCast(@alignCast(pfn_proc_addr.?));
    const pfnCreateXlib = @as(?PFN_vkCreateXlibSurfaceKHR, @ptrCast(@alignCast(getProcAddr(instance, "vkCreateXlibSurfaceKHR")))) orelse {
        std.debug.print("[Z-GRAPHICS] createVkSurface: vkCreateXlibSurfaceKHR not found\n", .{});
        return false;
    };
    const x_create_info = VkXlibSurfaceCreateInfoKHR{
        .dpy = @as(?*anyopaque, @ptrCast(state.display)),
        .window = state.window,
    };
    const res = pfnCreateXlib(instance, &x_create_info, null, out_surface);
    std.debug.print("[Z-GRAPHICS] createVkSurface: vkCreateXlibSurfaceKHR result={}\n", .{res});
    return res == 0;
}

pub fn destroyWindow(window: ?*anyopaque) void {
    if (window) |w| {
        const state: *X11WindowState = @ptrCast(@alignCast(w));
        _ = XCloseDisplay(state.display);
        std.heap.page_allocator.destroy(state);
    }
}
