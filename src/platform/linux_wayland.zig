const std = @import("std");
const builtin = @import("builtin");

const wl = @cImport({
    @cInclude("wayland-client.h");
    @cInclude("xdg-shell-client-protocol.h");
});

pub const PointerEventFn = *const fn (event_type: u32, x: f32, y: f32, button: u32, state: u32) callconv(.c) void;
pub const KeyboardEventFn = *const fn (key: u32, state: u32, ctrl: bool) callconv(.c) void;

pub var global_pointer_callback: ?PointerEventFn = null;
pub var global_keyboard_callback: ?KeyboardEventFn = null;

pub fn setPointerCallback(cb: ?PointerEventFn) void {
    global_pointer_callback = cb;
}

pub fn setKeyboardCallback(cb: ?KeyboardEventFn) void {
    global_keyboard_callback = cb;
}

pub const WaylandWindowState = struct {
    display: *wl.wl_display,
    registry: *wl.wl_registry,
    compositor: ?*wl.wl_compositor = null,
    wm_base: ?*wl.xdg_wm_base = null,
    seat: ?*wl.wl_seat = null,
    pointer: ?*wl.wl_pointer = null,
    keyboard: ?*wl.wl_keyboard = null,
    surface: *wl.wl_surface,
    xdg_surface: *wl.xdg_surface,
    toplevel: *wl.xdg_toplevel,
    configured: bool = false,
    width: u32,
    height: u32,
    pointer_x: f32 = 0,
    pointer_y: f32 = 0,
    pointer_button_state: u32 = 0,
    ctrl_pressed: bool = false,
};

fn wl_fixed_to_f32(f: wl.wl_fixed_t) f32 {
    return @as(f32, @floatFromInt(f)) / 256.0;
}

fn pointer_enter(data: ?*anyopaque, pointer: ?*wl.wl_pointer, serial: u32, surface: ?*wl.wl_surface, sx: wl.wl_fixed_t, sy: wl.wl_fixed_t) callconv(.c) void {
    _ = pointer;
    _ = serial;
    _ = surface;
    if (data == null) return;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    state.pointer_x = wl_fixed_to_f32(sx);
    state.pointer_y = wl_fixed_to_f32(sy);
    if (global_pointer_callback) |cb| {
        cb(0, state.pointer_x, state.pointer_y, 0, 0); // 0 = motion
    }
}

fn pointer_leave(data: ?*anyopaque, pointer: ?*wl.wl_pointer, serial: u32, surface: ?*wl.wl_surface) callconv(.c) void {
    _ = data;
    _ = pointer;
    _ = serial;
    _ = surface;
}

fn pointer_motion(data: ?*anyopaque, pointer: ?*wl.wl_pointer, time: u32, sx: wl.wl_fixed_t, sy: wl.wl_fixed_t) callconv(.c) void {
    _ = pointer;
    _ = time;
    if (data == null) return;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    state.pointer_x = wl_fixed_to_f32(sx);
    state.pointer_y = wl_fixed_to_f32(sy);
    if (global_pointer_callback) |cb| {
        cb(0, state.pointer_x, state.pointer_y, 0, 0); // 0 = motion
    }
}

fn pointer_button(data: ?*anyopaque, pointer: ?*wl.wl_pointer, serial: u32, time: u32, button: u32, btn_state: u32) callconv(.c) void {
    _ = pointer;
    _ = serial;
    _ = time;
    if (data == null) return;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    state.pointer_button_state = btn_state;
    // Map linux BTN_LEFT (272 = 0x110) to 1, BTN_RIGHT (273) to 3, BTN_MIDDLE (274) to 2
    const wpe_btn: u32 = if (button == 272) 1 else if (button == 273) 3 else if (button == 274) 2 else button;
    const event_type: u32 = if (btn_state != 0) 1 else 2; // 1 = down, 2 = up
    if (global_pointer_callback) |cb| {
        cb(event_type, state.pointer_x, state.pointer_y, wpe_btn, btn_state);
    }
}

fn pointer_axis(data: ?*anyopaque, pointer: ?*wl.wl_pointer, time: u32, axis: u32, value: wl.wl_fixed_t) callconv(.c) void {
    _ = pointer;
    _ = time;
    if (data == null) return;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    if (global_pointer_callback) |cb| {
        cb(3, state.pointer_x, state.pointer_y, axis, @bitCast(@as(u32, @truncate(@as(u64, @bitCast(@as(i64, value)))))));
    }
}

fn pointer_frame(data: ?*anyopaque, pointer: ?*wl.wl_pointer) callconv(.c) void {
    _ = data;
    _ = pointer;
}

fn pointer_axis_source(data: ?*anyopaque, pointer: ?*wl.wl_pointer, axis_source: u32) callconv(.c) void {
    _ = data;
    _ = pointer;
    _ = axis_source;
}

fn pointer_axis_stop(data: ?*anyopaque, pointer: ?*wl.wl_pointer, time: u32, axis: u32) callconv(.c) void {
    _ = data;
    _ = pointer;
    _ = time;
    _ = axis;
}

fn pointer_axis_discrete(data: ?*anyopaque, pointer: ?*wl.wl_pointer, axis: u32, discrete: i32) callconv(.c) void {
    _ = data;
    _ = pointer;
    _ = axis;
    _ = discrete;
}

const pointer_listener = wl.wl_pointer_listener{
    .enter = pointer_enter,
    .leave = pointer_leave,
    .motion = pointer_motion,
    .button = pointer_button,
    .axis = pointer_axis,
    .frame = pointer_frame,
    .axis_source = pointer_axis_source,
    .axis_stop = pointer_axis_stop,
    .axis_discrete = pointer_axis_discrete,
};

fn keyboard_keymap(data: ?*anyopaque, keyboard: ?*wl.wl_keyboard, format: u32, fd: i32, size: u32) callconv(.c) void {
    _ = data;
    _ = keyboard;
    _ = format;
    _ = size;
    if (fd >= 0) {
        _ = std.os.linux.close(fd);
    }
}

fn keyboard_enter(data: ?*anyopaque, keyboard: ?*wl.wl_keyboard, serial: u32, surface: ?*wl.wl_surface, keys: ?*wl.wl_array) callconv(.c) void {
    _ = data;
    _ = keyboard;
    _ = serial;
    _ = surface;
    _ = keys;
}

fn keyboard_leave(data: ?*anyopaque, keyboard: ?*wl.wl_keyboard, serial: u32, surface: ?*wl.wl_surface) callconv(.c) void {
    _ = data;
    _ = keyboard;
    _ = serial;
    _ = surface;
}

fn keyboard_key(data: ?*anyopaque, keyboard: ?*wl.wl_keyboard, serial: u32, time: u32, key: u32, key_state: u32) callconv(.c) void {
    _ = keyboard;
    _ = serial;
    _ = time;
    if (data == null) return;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    if (global_keyboard_callback) |cb| {
        cb(key, key_state, state.ctrl_pressed);
    }
}

fn keyboard_modifiers(data: ?*anyopaque, keyboard: ?*wl.wl_keyboard, serial: u32, mods_depressed: u32, mods_latched: u32, mods_locked: u32, group: u32) callconv(.c) void {
    _ = keyboard;
    _ = serial;
    _ = mods_latched;
    _ = mods_locked;
    _ = group;
    if (data == null) return;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    state.ctrl_pressed = (mods_depressed & 4) != 0;
}

fn keyboard_repeat_info(data: ?*anyopaque, keyboard: ?*wl.wl_keyboard, rate: i32, delay: i32) callconv(.c) void {
    _ = data;
    _ = keyboard;
    _ = rate;
    _ = delay;
}

const keyboard_listener = wl.wl_keyboard_listener{
    .keymap = keyboard_keymap,
    .enter = keyboard_enter,
    .leave = keyboard_leave,
    .key = keyboard_key,
    .modifiers = keyboard_modifiers,
    .repeat_info = keyboard_repeat_info,
};

fn seat_capabilities(data: ?*anyopaque, seat: ?*wl.wl_seat, capabilities: u32) callconv(.c) void {
    if (data == null or seat == null) return;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    const WL_SEAT_CAPABILITY_POINTER: u32 = 1;
    const WL_SEAT_CAPABILITY_KEYBOARD: u32 = 2;

    if ((capabilities & WL_SEAT_CAPABILITY_POINTER) != 0 and state.pointer == null) {
        state.pointer = wl.wl_seat_get_pointer(seat);
        if (state.pointer) |ptr| {
            _ = wl.wl_pointer_add_listener(ptr, &pointer_listener, state);
        }
    } else if ((capabilities & WL_SEAT_CAPABILITY_POINTER) == 0 and state.pointer != null) {
        wl.wl_pointer_release(state.pointer.?);
        state.pointer = null;
    }

    if ((capabilities & WL_SEAT_CAPABILITY_KEYBOARD) != 0 and state.keyboard == null) {
        state.keyboard = wl.wl_seat_get_keyboard(seat);
        if (state.keyboard) |kbd| {
            _ = wl.wl_keyboard_add_listener(kbd, &keyboard_listener, state);
        }
    } else if ((capabilities & WL_SEAT_CAPABILITY_KEYBOARD) == 0 and state.keyboard != null) {
        wl.wl_keyboard_release(state.keyboard.?);
        state.keyboard = null;
    }
}

fn seat_name(data: ?*anyopaque, seat: ?*wl.wl_seat, name: [*c]const u8) callconv(.c) void {
    _ = data;
    _ = seat;
    _ = name;
}

const seat_listener = wl.wl_seat_listener{
    .capabilities = seat_capabilities,
    .name = seat_name,
};

fn registry_global(data: ?*anyopaque, reg: ?*wl.wl_registry, name: u32, interface: [*c]const u8, version: u32) callconv(.c) void {
    _ = version;
    if (data == null or reg == null) return;
    const state: *WaylandWindowState = @ptrCast(@alignCast(data.?));
    const iface = std.mem.span(interface);
    if (std.mem.eql(u8, iface, "wl_compositor")) {
        state.compositor = @ptrCast(wl.wl_registry_bind(reg, name, &wl.wl_compositor_interface, 4));
    } else if (std.mem.eql(u8, iface, "xdg_wm_base")) {
        state.wm_base = @ptrCast(wl.wl_registry_bind(reg, name, &wl.xdg_wm_base_interface, 1));
    } else if (std.mem.eql(u8, iface, "wl_seat")) {
        state.seat = @ptrCast(wl.wl_registry_bind(reg, name, &wl.wl_seat_interface, 5));
        if (state.seat) |seat| {
            _ = wl.wl_seat_add_listener(seat, &seat_listener, state);
        }
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
    if (state.pointer) |p| wl.wl_pointer_release(p);
    if (state.keyboard) |k| wl.wl_keyboard_release(k);
    if (state.seat) |s| wl.wl_seat_release(s);
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
    _ = wl.wl_display_flush(state.display);
    _ = wl.wl_display_dispatch_pending(state.display);
}
