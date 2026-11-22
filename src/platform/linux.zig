const std = @import("std");
const builtin = @import("builtin");
const wayland = @import("linux_wayland.zig");
const x11 = @import("linux_x11.zig");

pub const surface_extension: [*:0]const u8 = "VK_KHR_surface";

pub const WindowType = enum {
    Wayland,
    X11,
};

pub const LinuxWindow = struct {
    type: WindowType,
    handle: *anyopaque,
};

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    if (builtin.os.tag != .linux) return null;

    // Prefer Wayland if running under Wayland
    if (wayland.createWindow(width, height)) |wl_win| {
        const win = std.heap.page_allocator.create(LinuxWindow) catch return null;
        win.* = .{ .type = .Wayland, .handle = @ptrCast(wl_win) };
        return @ptrCast(win);
    }

    // Fallback to X11 if available
    if (x11.createWindow(width, height)) |x11_win| {
        const win = std.heap.page_allocator.create(LinuxWindow) catch return null;
        win.* = .{ .type = .X11, .handle = x11_win };
        return @ptrCast(win);
    }

    return null;
}

pub fn createVkSurface(
    instance: ?*anyopaque,
    pfn_proc_addr: ?*const anyopaque,
    window: ?*anyopaque,
    out_surface: *?*anyopaque,
) bool {
    const w = window orelse return false;
    const win: *LinuxWindow = @ptrCast(@alignCast(w));
    return switch (win.type) {
        .Wayland => wayland.createVkSurface(instance, pfn_proc_addr, @ptrCast(@alignCast(win.handle)), out_surface),
        .X11 => x11.createVkSurface(instance, pfn_proc_addr, win.handle, out_surface),
    };
}

pub fn destroyWindow(window: ?*anyopaque) void {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => wayland.destroyWindow(@ptrCast(@alignCast(win.handle))),
            .X11 => x11.destroyWindow(win.handle),
        }
        std.heap.page_allocator.destroy(win);
    }
}

pub fn dispatchEvents(window: ?*anyopaque) void {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => wayland.dispatchEvents(@ptrCast(@alignCast(win.handle))),
            .X11 => {},
        }
    }
}

pub fn setPointerCallback(cb: anytype) void {
    wayland.setPointerCallback(cb);
}

pub fn setKeyboardCallback(cb: anytype) void {
    wayland.setKeyboardCallback(cb);
}
