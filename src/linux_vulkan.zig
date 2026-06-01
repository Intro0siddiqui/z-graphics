const std = @import("std");
const builtin = @import("builtin");
const c = if (builtin.os.tag == .linux) @cImport({
    @cInclude("vulkan/vulkan.h");
}) else struct {};

pub const VulkanSurface = struct {
    instance: c.VkInstance,
    physical_device: c.VkPhysicalDevice,
    device: c.VkDevice,
    graphics_queue: c.VkQueue,
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

    const extensions = [_][*:0]const u8{
        "VK_KHR_surface",
        "VK_EXT_headless_surface",
    };

    const create_info = c.VkInstanceCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .pApplicationInfo = &app_info,
        .enabledLayerCount = 0,
        .ppEnabledLayerNames = null,
        .enabledExtensionCount = extensions.len,
        .ppEnabledExtensionNames = @ptrCast(&extensions),
    };

    var instance: c.VkInstance = null;
    if (c.vkCreateInstance(&create_info, null, &instance) != c.VK_SUCCESS) {
        // Fallback: If headless surface is not supported, try without it (for environments like basic CI)
        const fallback_create_info = std.mem.zeroInit(c.VkInstanceCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &app_info,
            .enabledExtensionCount = 0,
            .ppEnabledExtensionNames = null,
        });
        if (c.vkCreateInstance(&fallback_create_info, null, &instance) != c.VK_SUCCESS) {
            return null;
        }
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

    // 3. Find Graphics Queue Family
    var queue_family_count: u32 = 0;
    c.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, null);
    
    const queue_families = std.heap.page_allocator.alloc(c.VkQueueFamilyProperties, queue_family_count) catch return null;
    defer std.heap.page_allocator.free(queue_families);
    c.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families.ptr);

    var graphics_family: ?u32 = null;
    for (queue_families, 0..) |family, i| {
        if ((family.queueFlags & c.VK_QUEUE_GRAPHICS_BIT) != 0) {
            graphics_family = @intCast(i);
            break;
        }
    }

    if (graphics_family == null) return null;

    // 4. Create Logical Device
    const queue_priority: f32 = 1.0;
    const queue_create_info = std.mem.zeroInit(c.VkDeviceQueueCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = graphics_family.?,
        .queueCount = 1,
        .pQueuePriorities = &queue_priority,
    });

    const device_features = std.mem.zeroInit(c.VkPhysicalDeviceFeatures, .{});

    const device_create_info = std.mem.zeroInit(c.VkDeviceCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .pQueueCreateInfos = &queue_create_info,
        .queueCreateInfoCount = 1,
        .pEnabledFeatures = &device_features,
        .enabledExtensionCount = 0,
        .ppEnabledExtensionNames = null,
    });

    var device: c.VkDevice = null;
    if (c.vkCreateDevice(physical_device, &device_create_info, null, &device) != c.VK_SUCCESS) {
        return null;
    }

    // 5. Retrieve Graphics Queue
    var graphics_queue: c.VkQueue = null;
    c.vkGetDeviceQueue(device, graphics_family.?, 0, &graphics_queue);

    // 6. Create Headless Surface (if available)
    const surface: c.VkSurfaceKHR = null;
    // We will rely on offscreen image rendering (which is actually more standard for headless browsers)
    // rather than using a VK_EXT_headless_surface which might not be supported by all drivers.

    // 7. Create Surface object in memory (Backend state)
    var surface_obj = std.heap.page_allocator.create(VulkanSurface) catch return null;
    surface_obj.instance = instance;
    surface_obj.physical_device = physical_device;
    surface_obj.device = device;
    surface_obj.graphics_queue = graphics_queue;
    surface_obj.surface = surface; 
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

pub fn swapBuffers(surface: *VulkanSurface) void {
    if (builtin.os.tag != .linux) return;
    
    // In a headless environment, "swapping" usually means waiting for the rendering to finish
    // so the buffer can be safely read back or exported to zero-copy memory.
    if (surface.graphics_queue != null) {
        _ = c.vkQueueWaitIdle(surface.graphics_queue);
    }
}
