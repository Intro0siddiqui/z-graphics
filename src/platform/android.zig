const std = @import("std");

pub const surface_extension: [*:0]const u8 = "VK_KHR_android_surface";

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    _ = width;
    _ = height;
    return null;
}

const VkAndroidSurfaceCreateInfoKHR = extern struct {
    sType: u32 = 1000008000,
    pNext: ?*const anyopaque = null,
    flags: u32 = 0,
    window: ?*anyopaque,
};

const PFN_vkCreateAndroidSurfaceKHR = *const fn (
    instance: ?*anyopaque,
    pCreateInfo: *const VkAndroidSurfaceCreateInfoKHR,
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
    if (pfn_proc_addr == null) return false;
    const getProcAddr: *const fn (?*anyopaque, [*:0]const u8) callconv(.c) ?*anyopaque = @ptrCast(@alignCast(pfn_proc_addr.?));
    const pfnCreateAndroid = @as(?PFN_vkCreateAndroidSurfaceKHR, @ptrCast(@alignCast(getProcAddr(instance, "vkCreateAndroidSurfaceKHR")))) orelse {
        std.debug.print("[Z-GRAPHICS] createVkSurface: vkCreateAndroidSurfaceKHR not found\n", .{});
        return false;
    };
    const android_create_info = VkAndroidSurfaceCreateInfoKHR{
        .window = w,
    };
    const res = pfnCreateAndroid(instance, &android_create_info, null, out_surface);
    std.debug.print("[Z-GRAPHICS] createVkSurface: vkCreateAndroidSurfaceKHR result={}\n", .{res});
    return res == 0;
}

pub fn destroyWindow(window: ?*anyopaque) void {
    _ = window;
}

pub fn dispatchEvents(window: ?*anyopaque) void {
    _ = window;
}
