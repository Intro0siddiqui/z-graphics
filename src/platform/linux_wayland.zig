const std = @import("std");
const builtin = @import("builtin");

const wl = @cImport({
    @cInclude("wayland-client.h");
    @cInclude("xdg-shell-client-protocol.h");
});

pub const WaylandWindowState = struct {
    display: *wl.wl_display,
    registry: *wl.wl_registry,
    compositor: ?*wl.wl_compositor = null,
    wm_base: ?*wl.xdg_wm_base = null,
    surface: *wl.wl_surface,
    xdg_surface: *wl.xdg_surface,
    toplevel: *wl.xdg_toplevel,
    configured: bool = false,
    width: u32,
    height: u32,
};

fn registry_global(data: ?*anyopaque, reg: ?*wl.wl_registry, name: u32, interface: [*c]const u8, version: u32) callconv(.c) void {
    _ = version;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    const iface = std.mem.span(interface);
    if (std.mem.eql(u8, iface, "wl_compositor")) {
        state.compositor = @ptrCast(wl.wl_registry_bind(reg, name, &wl.wl_compositor_interface, 4));
    } else if (std.mem.eql(u8, iface, "xdg_wm_base")) {
        state.wm_base = @ptrCast(wl.wl_registry_bind(reg, name, &wl.xdg_wm_base_interface, 1));
    }
}

fn registry_remove(data: ?*anyopaque, reg: ?*wl.wl_registry, name: u32) callconv(.c) void {
    _ = data;
    _ = reg;
    _ = name;
}

const reg_listener = wl.wl_registry_listener{
    .global = registry_global,
    .global_remove = registry_remove,
};

fn xdg_wm_base_ping(data: ?*anyopaque, wm_base: ?*wl.xdg_wm_base, serial: u32) callconv(.c) void {
    _ = data;
    wl.xdg_wm_base_pong(wm_base, serial);
}

const wm_base_listener = wl.xdg_wm_base_listener{
    .ping = xdg_wm_base_ping,
};

fn xdg_surface_configure(data: ?*anyopaque, xdg_surface: ?*wl.xdg_surface, serial: u32) callconv(.c) void {
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    wl.xdg_surface_ack_configure(xdg_surface, serial);
    state.configured = true;
}

const xdg_surface_listener = wl.xdg_surface_listener{
    .configure = xdg_surface_configure,
};

fn xdg_toplevel_configure(data: ?*anyopaque, toplevel: ?*wl.xdg_toplevel, width: i32, height: i32, states: ?*wl.wl_array) callconv(.c) void {
    _ = data;
    _ = toplevel;
    _ = width;
    _ = height;
    _ = states;
}

fn xdg_toplevel_close(data: ?*anyopaque, toplevel: ?*wl.xdg_toplevel) callconv(.c) void {
    _ = data;
    _ = toplevel;
}

const xdg_toplevel_listener = wl.xdg_toplevel_listener{
    .configure = xdg_toplevel_configure,
    .close = xdg_toplevel_close,
};

extern "c" fn getenv(name: [*:0]const u8) callconv(.c) ?[*:0]const u8;

pub fn createWindow(width: u32, height: u32) ?*WaylandWindowState {
    if (builtin.os.tag != .linux) return null;

    const wayland_display = getenv("WAYLAND_DISPLAY");
    if (wayland_display == null) {
        return null;
    }
    const display_str = std.mem.span(wayland_display.?);
    if (display_str.len == 0) {
        return null;
    }

    std.debug.print("[Z-GRAPHICS] createWindow: connecting to Wayland ({s})\n", .{display_str});
    const dpy = wl.wl_display_connect(null) orelse {
        std.debug.print("[Z-GRAPHICS] createWindow: wl_display_connect failed\n", .{});
        return null;
    };

    const state = std.heap.page_allocator.create(WaylandWindowState) catch {
        wl.wl_display_disconnect(dpy);
        return null;
    };

    const reg = wl.wl_display_get_registry(dpy) orelse {
        wl.wl_display_disconnect(dpy);
        std.heap.page_allocator.destroy(state);
        return null;
    };

    state.* = .{
        .display = dpy,
        .registry = reg,
        .compositor = null,
        .wm_base = null,
        .surface = undefined,
        .xdg_surface = undefined,
        .toplevel = undefined,
        .configured = false,
        .width = width,
        .height = height,
    };

    _ = wl.wl_registry_add_listener(reg, &reg_listener, state);
    _ = wl.wl_display_roundtrip(dpy);

    if (state.compositor == null or state.wm_base == null) {
        std.debug.print("[Z-GRAPHICS] createWindow: missing wl_compositor or xdg_wm_base\n", .{});
        wl.wl_registry_destroy(reg);
        wl.wl_display_disconnect(dpy);
        std.heap.page_allocator.destroy(state);
        return null;
    }

    _ = wl.xdg_wm_base_add_listener(state.wm_base, &wm_base_listener, state);

    const surface = wl.wl_compositor_create_surface(state.compositor) orelse {
        wl.wl_registry_destroy(reg);
        wl.wl_display_disconnect(dpy);
        std.heap.page_allocator.destroy(state);
        return null;
    };
    state.surface = surface;

    const xdg_surface = wl.xdg_wm_base_get_xdg_surface(state.wm_base, surface) orelse {
        wl.wl_surface_destroy(surface);
        wl.wl_registry_destroy(reg);
        wl.wl_display_disconnect(dpy);
        std.heap.page_allocator.destroy(state);
        return null;
    };
    state.xdg_surface = xdg_surface;
    _ = wl.xdg_surface_add_listener(xdg_surface, &xdg_surface_listener, state);

    const toplevel = wl.xdg_surface_get_toplevel(xdg_surface) orelse {
        wl.xdg_surface_destroy(xdg_surface);
        wl.wl_surface_destroy(surface);
        wl.wl_registry_destroy(reg);
        wl.wl_display_disconnect(dpy);
        std.heap.page_allocator.destroy(state);
        return null;
    };
    state.toplevel = toplevel;
    _ = wl.xdg_toplevel_add_listener(toplevel, &xdg_toplevel_listener, state);

    wl.xdg_toplevel_set_title(toplevel, "Zawra Browser");
    wl.xdg_toplevel_set_app_id(toplevel, "zawra-shell");

    wl.wl_surface_commit(surface);
    var tries: usize = 0;
    while (!state.configured and tries < 20) : (tries += 1) {
        if (wl.wl_display_roundtrip(dpy) < 0) break;
    }

    std.debug.print("[Z-GRAPHICS] createWindow: Wayland window successfully created {}x{} (configured={})\n", .{ width, height, state.configured });
    return state;
}

const VkWaylandSurfaceCreateInfoKHR = extern struct {
    sType: u32 = 1000006000,
    pNext: ?*const anyopaque = null,
    flags: u32 = 0,
    display: ?*anyopaque,
    surface: ?*anyopaque,
};

const PFN_vkCreateWaylandSurfaceKHR = *const fn (
    instance: ?*anyopaque,
    pCreateInfo: *const VkWaylandSurfaceCreateInfoKHR,
    pAllocator: ?*const anyopaque,
    pSurface: *?*anyopaque,
) callconv(.c) i32;

pub fn createVkSurface(
    instance: ?*anyopaque,
    pfn_proc_addr: ?*const anyopaque,
    window: *WaylandWindowState,
    out_surface: *?*anyopaque,
) bool {
    if (pfn_proc_addr == null) return false;
    const getProcAddr: *const fn (?*anyopaque, [*:0]const u8) callconv(.c) ?*anyopaque = @ptrCast(@alignCast(pfn_proc_addr.?));
    const pfnCreateWayland = @as(?PFN_vkCreateWaylandSurfaceKHR, @ptrCast(@alignCast(getProcAddr(instance, "vkCreateWaylandSurfaceKHR")))) orelse {
        std.debug.print("[Z-GRAPHICS] createVkSurface: vkCreateWaylandSurfaceKHR not found\n", .{});
        return false;
    };
    const wayland_info = VkWaylandSurfaceCreateInfoKHR{
        .display = @ptrCast(window.display),
        .surface = @ptrCast(window.surface),
    };
    const res = pfnCreateWayland(instance, &wayland_info, null, out_surface);
    std.debug.print("[Z-GRAPHICS] createVkSurface: vkCreateWaylandSurfaceKHR result={}\n", .{res});
    return res == 0;
}

pub fn destroyWindow(state: *WaylandWindowState) void {
    wl.xdg_toplevel_destroy(state.toplevel);
    wl.xdg_surface_destroy(state.xdg_surface);
    wl.wl_surface_destroy(state.surface);
    if (state.wm_base) |wb| wl.xdg_wm_base_destroy(wb);
    if (state.compositor) |c| wl.wl_compositor_destroy(c);
    wl.wl_registry_destroy(state.registry);
    wl.wl_display_disconnect(state.display);
    std.heap.page_allocator.destroy(state);
}

pub fn dispatchEvents(state: *WaylandWindowState) void {
    _ = wl.wl_display_dispatch_pending(state.display);
}
