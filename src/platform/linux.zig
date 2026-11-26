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

pub fn flush(window: ?*anyopaque) void {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => wayland.flush(@ptrCast(@alignCast(win.handle))),
            .X11 => {},
        }
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

pub fn checkResize(window: ?*anyopaque, out_w: *u32, out_h: *u32) bool {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => return wayland.checkResize(@ptrCast(@alignCast(win.handle)), out_w, out_h),
            .X11 => return false,
        }
    }
    return false;
}

pub fn shouldClose(window: ?*anyopaque) bool {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => return wayland.shouldClose(@ptrCast(@alignCast(win.handle))),
            .X11 => return false,
        }
    }
    return false;
}

pub fn setPointerCallback(cb: ?wayland.PointerEventFn) void {
    wayland.setPointerCallback(cb);
}

pub fn setScrollCallback(cb: ?wayland.ScrollEventFn) void {
    wayland.setScrollCallback(cb);
}

pub fn setKeyboardCallback(cb: ?wayland.KeyboardEventFn) void {
    wayland.setKeyboardCallback(cb);
}

pub fn getWlDisplay(window: ?*anyopaque) ?*anyopaque {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => {
                const s: *wayland.WaylandWindowState = @ptrCast(@alignCast(win.handle));
                return @ptrCast(s.getWlDisplay());
            },
            .X11 => return null,
        }
    }
    return null;
}

pub fn getWlSurface(window: ?*anyopaque) ?*anyopaque {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => {
                const s: *wayland.WaylandWindowState = @ptrCast(@alignCast(win.handle));
                return @ptrCast(s.getWlSurface());
            },
            .X11 => return null,
        }
    }
    return null;
}

pub fn getWlSubcompositor(window: ?*anyopaque) ?*anyopaque {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => {
                const s: *wayland.WaylandWindowState = @ptrCast(@alignCast(win.handle));
                if (s.getWlSubcompositor()) |sub| return @ptrCast(sub);
                return null;
            },
            .X11 => return null,
        }
    }
    return null;
}

pub fn getWlCompositor(window: ?*anyopaque) ?*anyopaque {
    if (window) |w| {
        const win: *LinuxWindow = @ptrCast(@alignCast(w));
        switch (win.type) {
            .Wayland => {
                const s: *wayland.WaylandWindowState = @ptrCast(@alignCast(win.handle));
                if (s.getWlCompositor()) |comp| return @ptrCast(comp);
                return null;
            },
            .X11 => return null,
        }
    }
    return null;
}
