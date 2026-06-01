const std = @import("std");
const builtin = @import("builtin");
const c = if (builtin.os.tag == .linux) @cImport({
    @cInclude("vulkan/vulkan.h");
}) else struct {};

pub const VulkanSurface = struct {
    instance: c.VkInstance,
    physical_device: c.VkPhysicalDevice,
    device: c.VkDevice,
    surface: c.VkSurfaceKHR,
    width: u32,
    height: u32,
};

pub fn createSurface(width: u32, height: u32) ?*VulkanSurface {
    if (builtin.os.tag != .linux) return null;

    // 1. Initialize Vulkan Instance
    const app_info = std.mem.zeroInit(c.VkApplicationInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Zawra",
        .applicationVersion = c.VK_MAKE_VERSION(1, 0, 0),
        .pEngineName = "Zawra",
        .engineVersion = c.VK_MAKE_VERSION(1, 0, 0),
        .apiVersion = c.VK_API_VERSION_1_0,
    });

    const create_info = std.mem.zeroInit(c.VkInstanceCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app_info,
    });

    var instance: c.VkInstance = null;
    if (c.vkCreateInstance(&create_info, null, &instance) != c.VK_SUCCESS) {
        return null;
    }

    // 2. Select Physical Device
    var device_count: u32 = 0;
    _ = c.vkEnumeratePhysicalDevices(instance, &device_count, null);
    if (device_count == 0) return null;

    const devices = std.heap.page_allocator.alloc(c.VkPhysicalDevice, device_count) catch return null;
    defer std.heap.page_allocator.free(devices);
    _ = c.vkEnumeratePhysicalDevices(instance, &device_count, devices.ptr);
    
    // For now, just pick the first device. 
    // In production, we would score them based on VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU.
    const physical_device = devices[0];

    // 3. Create Surface object in memory (Backend state)
    var surface_obj = std.heap.page_allocator.create(VulkanSurface) catch return null;
    surface_obj.instance = instance;
    surface_obj.physical_device = physical_device;
    surface_obj.device = null; // To be created in next step
    surface_obj.surface = null; // To be created in next step
    surface_obj.width = width;
    surface_obj.height = height;

    return surface_obj;
}

pub fn destroySurface(surface: *VulkanSurface) void {
    if (builtin.os.tag != .linux) return;
    
    if (surface.device != null) {
        c.vkDestroyDevice(surface.device, null);
    }
    if (surface.instance != null) {
        c.vkDestroyInstance(surface.instance, null);
    }
    std.heap.page_allocator.destroy(surface);
}
