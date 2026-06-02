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
    image: c.VkImage,
    image_memory: c.VkDeviceMemory,
    image_view: c.VkImageView,
    render_pass: c.VkRenderPass,
    fence: c.VkFence,
    external_memory_enabled: bool,
    window: ?*anyopaque, // X11 Window
    x_display: ?*anyopaque, // X11 Display
    width: u32,
    height: u32,
};

// --- X11 FFI ---
extern fn XOpenDisplay(display_name: ?[*:0]const u8) ?*anyopaque;
extern fn XDefaultRootWindow(display: *anyopaque) usize;
extern fn XCreateSimpleWindow(
    display: *anyopaque,
    parent: usize,
    x: i32,
    y: i32,
    width: u32,
    height: u32,
    border_width: u32,
    border: usize,
    background: usize,
) usize;
extern fn XMapWindow(display: *anyopaque, window: usize) i32;
extern fn XStoreName(display: *anyopaque, window: usize, window_name: [*:0]const u8) i32;

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    if (builtin.os.tag != .linux) return null;

    const display = XOpenDisplay(null) orelse return null;
    const root = XDefaultRootWindow(display);
    const window = XCreateSimpleWindow(display, root, 100, 100, width, height, 1, 0, 0);

    _ = XStoreName(display, window, "Zawra Browser");
    _ = XMapWindow(display, window);

    // Return the window as an opaque handle. 
    // In X11, Window is typically a 'long' (usize), so we cast it to *anyopaque for FFI consistency.
    return @ptrFromInt(window);
}

fn findMemoryType(physical_device: c.VkPhysicalDevice, type_filter: u32, properties: c.VkMemoryPropertyFlags) ?u32 {
    var mem_properties: c.VkPhysicalDeviceMemoryProperties = undefined;
    c.vkGetPhysicalDeviceMemoryProperties(physical_device, &mem_properties);

    for (mem_properties.memoryTypes[0..mem_properties.memoryTypeCount], 0..) |mem_type, i| {
        if ((type_filter & (@as(u32, 1) << @intCast(i))) != 0 and (mem_type.propertyFlags & properties) == properties) {
            return @intCast(i);
        }
    }
    return null;
}

pub fn createSurface(window: ?*anyopaque, width: u32, height: u32) ?*VulkanSurface {
    if (builtin.os.tag != .linux) return null;

    // 1. Create Vulkan Instance
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

    const device_extensions = [_][*:0]const u8{
        "VK_KHR_external_memory",
        "VK_KHR_external_memory_fd",
    };

    const device_create_info = std.mem.zeroInit(c.VkDeviceCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .pQueueCreateInfos = &queue_create_info,
        .queueCreateInfoCount = 1,
        .pEnabledFeatures = &device_features,
        .enabledExtensionCount = device_extensions.len,
        .ppEnabledExtensionNames = @as([*]const [*:0]const u8, @ptrCast(&device_extensions)),
    });

    var device: c.VkDevice = null;
    var external_memory_enabled = true;
    if (c.vkCreateDevice(physical_device, &device_create_info, null, &device) != c.VK_SUCCESS) {
        // Fallback without external memory for strict environments/CI
        external_memory_enabled = false;
        const fallback_create_info = std.mem.zeroInit(c.VkDeviceCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            .pQueueCreateInfos = &queue_create_info,
            .queueCreateInfoCount = 1,
            .pEnabledFeatures = &device_features,
            .enabledExtensionCount = 0,
            .ppEnabledExtensionNames = null,
        });
        if (c.vkCreateDevice(physical_device, &fallback_create_info, null, &device) != c.VK_SUCCESS) {
            return null;
        }
    }

    // 5. Retrieve Graphics Queue
    var graphics_queue: c.VkQueue = null;
    c.vkGetDeviceQueue(device, graphics_family.?, 0, &graphics_queue);

    // 6. Create Headless Surface (if available)
    const surface: c.VkSurfaceKHR = null;
    // We will rely on offscreen image rendering (which is actually more standard for headless browsers)
    // rather than using a VK_EXT_headless_surface which might not be supported by all drivers.

    // 7. Create Offscreen Image Buffer (Swapchain Substitute)
    var external_image_info = std.mem.zeroInit(c.VkExternalMemoryImageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO,
        .handleTypes = c.VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT,
    });

    const image_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .pNext = if (external_memory_enabled) &external_image_info else null,
        .imageType = c.VK_IMAGE_TYPE_2D,
        .extent = .{ .width = width, .height = height, .depth = 1 },
        .mipLevels = 1,
        .arrayLayers = 1,
        .format = c.VK_FORMAT_R8G8B8A8_UNORM, // Standard web format
        .tiling = c.VK_IMAGE_TILING_OPTIMAL,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .usage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
    });

    var image: c.VkImage = null;
    if (c.vkCreateImage(device, &image_info, null, &image) != c.VK_SUCCESS) {
        c.vkDestroyDevice(device, null);
        c.vkDestroyInstance(instance, null);
        return null;
    }

    // 8. Allocate Memory for Image
    var mem_requirements: c.VkMemoryRequirements = undefined;
    c.vkGetImageMemoryRequirements(device, image, &mem_requirements);

    const mem_type_index = findMemoryType(
        physical_device,
        mem_requirements.memoryTypeBits,
        c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
    ) orelse {
        c.vkDestroyImage(device, image, null);
        c.vkDestroyDevice(device, null);
        c.vkDestroyInstance(instance, null);
        return null;
    };

    var export_alloc_info = std.mem.zeroInit(c.VkExportMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO,
        .handleTypes = c.VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT,
    });

    const alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .pNext = if (external_memory_enabled) &export_alloc_info else null,
        .allocationSize = mem_requirements.size,
        .memoryTypeIndex = mem_type_index,
    });

    var image_memory: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(device, &alloc_info, null, &image_memory) != c.VK_SUCCESS) {
        c.vkDestroyImage(device, image, null);
        c.vkDestroyDevice(device, null);
        c.vkDestroyInstance(instance, null);
        return null;
    }

    if (c.vkBindImageMemory(device, image, image_memory, 0) != c.VK_SUCCESS) {
        c.vkFreeMemory(device, image_memory, null);
        c.vkDestroyImage(device, image, null);
        c.vkDestroyDevice(device, null);
        c.vkDestroyInstance(instance, null);
        return null;
    }

    // 9. Create Image View
    const view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        .image = image,
        .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
        .format = c.VK_FORMAT_R8G8B8A8_UNORM,
        .subresourceRange = .{
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .baseMipLevel = 0,
            .levelCount = 1,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
    });

    var image_view: c.VkImageView = null;
    if (c.vkCreateImageView(device, &view_info, null, &image_view) != c.VK_SUCCESS) {
        c.vkFreeMemory(device, image_memory, null);
        c.vkDestroyImage(device, image, null);
        c.vkDestroyDevice(device, null);
        c.vkDestroyInstance(instance, null);
        return null;
    }

    // 10. Create Render Pass
    const color_attachment = std.mem.zeroInit(c.VkAttachmentDescription, .{
        .format = c.VK_FORMAT_R8G8B8A8_UNORM,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
        .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
        .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,
        .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .finalLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
    });

    const color_attachment_ref = std.mem.zeroInit(c.VkAttachmentReference, .{
        .attachment = 0,
        .layout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
    });

    const subpass = std.mem.zeroInit(c.VkSubpassDescription, .{
        .pipelineBindPoint = c.VK_PIPELINE_BIND_POINT_GRAPHICS,
        .colorAttachmentCount = 1,
        .pColorAttachments = &color_attachment_ref,
    });

    const render_pass_info = std.mem.zeroInit(c.VkRenderPassCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
        .attachmentCount = 1,
        .pAttachments = &color_attachment,
        .subpassCount = 1,
        .pSubpasses = &subpass,
    });

    var render_pass: c.VkRenderPass = null;
    if (c.vkCreateRenderPass(device, &render_pass_info, null, &render_pass) != c.VK_SUCCESS) {
        c.vkDestroyImageView(device, image_view, null);
        c.vkFreeMemory(device, image_memory, null);
        c.vkDestroyImage(device, image, null);
        c.vkDestroyDevice(device, null);
        c.vkDestroyInstance(instance, null);
        return null;
    }

    // 11. Create Fence for Synchronization
    const fence_info = std.mem.zeroInit(c.VkFenceCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
        .flags = c.VK_FENCE_CREATE_SIGNALED_BIT, // Start signaled so first wait doesn't block
    });

    var fence: c.VkFence = null;
    if (c.vkCreateFence(device, &fence_info, null, &fence) != c.VK_SUCCESS) {
        c.vkDestroyImageView(device, image_view, null);
        c.vkFreeMemory(device, image_memory, null);
        c.vkDestroyImage(device, image, null);
        c.vkDestroyDevice(device, null);
        c.vkDestroyInstance(instance, null);
        return null;
    }

    // 11. Create Surface object in memory (Backend state)
    var surface_obj = std.heap.page_allocator.create(VulkanSurface) catch return null;
    surface_obj.instance = instance;
    surface_obj.physical_device = physical_device;
    surface_obj.device = device;
    surface_obj.graphics_queue = graphics_queue;
    surface_obj.surface = surface;
    surface_obj.image = image;
    surface_obj.image_memory = image_memory;
    surface_obj.image_view = image_view;
    surface_obj.render_pass = render_pass;
    surface_obj.fence = fence;
    surface_obj.external_memory_enabled = external_memory_enabled;
    surface_obj.window = window;
    surface_obj.x_display = null; // Should be retrieved if window is present
    surface_obj.width = width;
    surface_obj.height = height;

    return surface_obj;
}

pub fn destroySurface(surface: *VulkanSurface) void {
    if (builtin.os.tag != .linux) return;
    
    if (surface.device != null) {
        if (surface.fence != null) c.vkDestroyFence(surface.device, surface.fence, null);
        if (surface.render_pass != null) c.vkDestroyRenderPass(surface.device, surface.render_pass, null);
        if (surface.image_view != null) c.vkDestroyImageView(surface.device, surface.image_view, null);
        if (surface.image != null) c.vkDestroyImage(surface.device, surface.image, null);
        if (surface.image_memory != null) c.vkFreeMemory(surface.device, surface.image_memory, null);
        
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
    if (surface.fence != null) {
        _ = c.vkWaitForFences(surface.device, 1, &surface.fence, c.VK_TRUE, std.math.maxInt(u64));
    }
}

pub fn exportSurfaceFD(surface: *VulkanSurface) i32 {
    if (builtin.os.tag != .linux) return -1;
    if (!surface.external_memory_enabled) return -1;

    const pfnGetMemoryFdKHR = @as(c.PFN_vkGetMemoryFdKHR, @ptrCast(c.vkGetDeviceProcAddr(surface.device, "vkGetMemoryFdKHR")));
    if (pfnGetMemoryFdKHR == null) return -1;

    const get_fd_info = std.mem.zeroInit(c.VkMemoryGetFdInfoKHR, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_GET_FD_INFO_KHR,
        .memory = surface.image_memory,
        .handleType = c.VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT,
    });

    // NOTE: The returned file descriptor is owned by the caller.
    // The caller is responsible for closing the FD to avoid resource leaks.
    var fd: i32 = -1;
    if (pfnGetMemoryFdKHR.?(surface.device, &get_fd_info, &fd) != c.VK_SUCCESS) {
        return -1;
    }

    return fd;
}

// ---------------------------------------------------------
// RESOURCE MANAGEMENT
// ---------------------------------------------------------

pub const VulkanBuffer = struct {
    buffer: c.VkBuffer,
    memory: c.VkDeviceMemory,
    size: usize,
};

pub fn createBuffer(surface: *VulkanSurface, size: usize, buffer_type: u32) ?*VulkanBuffer {
    if (builtin.os.tag != .linux) return null;

    var usage: c.VkBufferUsageFlags = 0;
    if (buffer_type == 1) usage = c.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT;
    if (buffer_type == 2) usage = c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT;
    if (buffer_type == 3) usage = c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;

    const buffer_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = size,
        .usage = usage,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
    });

    var buffer: c.VkBuffer = null;
    if (c.vkCreateBuffer(surface.device, &buffer_info, null, &buffer) != c.VK_SUCCESS) {
        return null;
    }

    var mem_requirements: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(surface.device, buffer, &mem_requirements);

    const mem_type_index = findMemoryType(
        surface.physical_device,
        mem_requirements.memoryTypeBits,
        c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
    ) orelse {
        c.vkDestroyBuffer(surface.device, buffer, null);
        return null;
    };

    const alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_requirements.size,
        .memoryTypeIndex = mem_type_index,
    });

    var buffer_memory: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(surface.device, &alloc_info, null, &buffer_memory) != c.VK_SUCCESS) {
        c.vkDestroyBuffer(surface.device, buffer, null);
        return null;
    }

    if (c.vkBindBufferMemory(surface.device, buffer, buffer_memory, 0) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, buffer_memory, null);
        c.vkDestroyBuffer(surface.device, buffer, null);
        return null;
    }

    var vulkan_buffer = std.heap.page_allocator.create(VulkanBuffer) catch return null;
    vulkan_buffer.buffer = buffer;
    vulkan_buffer.memory = buffer_memory;
    vulkan_buffer.size = size;

    return vulkan_buffer;
}

pub fn destroyBuffer(surface: *VulkanSurface, buffer: *VulkanBuffer) void {
    if (builtin.os.tag != .linux) return;
    
    if (buffer.buffer != null) c.vkDestroyBuffer(surface.device, buffer.buffer, null);
    if (buffer.memory != null) c.vkFreeMemory(surface.device, buffer.memory, null);
    
    std.heap.page_allocator.destroy(buffer);
}

// ---------------------------------------------------------
// COMMAND RECORDING
// ---------------------------------------------------------

pub const VulkanCommandBuffer = struct {
    cmd: c.VkCommandBuffer,
    pool: c.VkCommandPool,
};

pub fn beginCommandBuffer(surface: *VulkanSurface) ?*VulkanCommandBuffer {
    if (builtin.os.tag != .linux) return null;
    
    // Command Pool needs to be created first
    // In a real engine, we'd cache the command pool in the surface, but for simplicity we create one per cmd buffer for now
    const pool_info = std.mem.zeroInit(c.VkCommandPoolCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .flags = c.VK_COMMAND_POOL_CREATE_TRANSIENT_BIT,
        // Assuming queue family 0 is graphics, we should ideally store the graphics_family index in surface
        .queueFamilyIndex = 0, 
    });

    var command_pool: c.VkCommandPool = null;
    if (c.vkCreateCommandPool(surface.device, &pool_info, null, &command_pool) != c.VK_SUCCESS) {
        return null;
    }

    const alloc_info = std.mem.zeroInit(c.VkCommandBufferAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = command_pool,
        .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = 1,
    });

    var command_buffer: c.VkCommandBuffer = null;
    if (c.vkAllocateCommandBuffers(surface.device, &alloc_info, &command_buffer) != c.VK_SUCCESS) {
        c.vkDestroyCommandPool(surface.device, command_pool, null);
        return null;
    }

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
    });

    if (c.vkBeginCommandBuffer(command_buffer, &begin_info) != c.VK_SUCCESS) {
        c.vkDestroyCommandPool(surface.device, command_pool, null);
        return null;
    }

    var vulkan_cmd = std.heap.page_allocator.create(VulkanCommandBuffer) catch return null;
    vulkan_cmd.cmd = command_buffer;
    vulkan_cmd.pool = command_pool;

    return vulkan_cmd;
}

pub fn cmdClearColor(cmd: *VulkanCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .linux) return;
    
    // As mentioned, a true clear requires an image or render pass.
    // For now, this is a no-op placeholder that just consumes the arguments.
    _ = cmd; _ = r; _ = g; _ = b; _ = a;
}

pub fn submitCommandBuffer(surface: *VulkanSurface, cmd: *VulkanCommandBuffer) void {
    if (builtin.os.tag != .linux) return;
    
    _ = c.vkEndCommandBuffer(cmd.cmd);

    const submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO,
        .commandBufferCount = 1,
        .pCommandBuffers = &cmd.cmd,
    });

    _ = c.vkResetFences(surface.device, 1, &surface.fence);
    _ = c.vkQueueSubmit(surface.graphics_queue, 1, &submit_info, surface.fence);

    // We do NOT wait here anymore. `swapBuffers` will wait on the fence.
    // This allows the CPU to continue working while the GPU processes the command buffer.

    // Cleanup (in a real engine, we'd recycle these, but for this abstraction we free them after submission)
    // Note: We can't free the pool until the GPU is done, so for this simple API we block here just to safely free.
    // To truly be async, the `ZawraGraphicsCommandBuffer` would need to own its lifecycle.
    // For the sake of the FFI contract requested, we will wait here JUST for safety during cleanup.
    _ = c.vkWaitForFences(surface.device, 1, &surface.fence, c.VK_TRUE, std.math.maxInt(u64));
    
    c.vkDestroyCommandPool(surface.device, cmd.pool, null);
    std.heap.page_allocator.destroy(cmd);
}

// ---------------------------------------------------------
// PIPELINE MANAGEMENT
// ---------------------------------------------------------

pub const VulkanPipeline = struct {
    pipeline: c.VkPipeline,
    layout: c.VkPipelineLayout,
};

fn createShaderModule(device: c.VkDevice, code: []const u8) ?c.VkShaderModule {
    const create_info = std.mem.zeroInit(c.VkShaderModuleCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .codeSize = code.len,
        .pCode = @as([*]const u32, @ptrCast(@alignCast(code.ptr))),
    });

    var shader_module: c.VkShaderModule = null;
    if (c.vkCreateShaderModule(device, &create_info, null, &shader_module) != c.VK_SUCCESS) {
        return null;
    }
    return shader_module;
}

pub fn createPipeline(surface: *VulkanSurface, desc: *const @import("lib.zig").PipelineDesc) ?*VulkanPipeline {
    if (builtin.os.tag != .linux) return null;

    // 1. Create Shader Modules
    const vert_code = desc.vertex_shader.?[0..desc.vertex_shader_len];
    const frag_code = desc.pixel_shader.?[0..desc.pixel_shader_len];

    const vert_module = createShaderModule(surface.device, vert_code) orelse return null;
    defer c.vkDestroyShaderModule(surface.device, vert_module, null);

    const frag_module = createShaderModule(surface.device, frag_code) orelse {
        // We'll clean up properly in a real implementation, but for now we just return null
        return null;
    };
    defer c.vkDestroyShaderModule(surface.device, frag_module, null);

    // 2. Shader Stage Create Info
    const vert_stage_info = std.mem.zeroInit(c.VkPipelineShaderStageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
        .stage = c.VK_SHADER_STAGE_VERTEX_BIT,
        .module = vert_module,
        .pName = "VSMain", // HLSL entry point
    });

    const frag_stage_info = std.mem.zeroInit(c.VkPipelineShaderStageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
        .stage = c.VK_SHADER_STAGE_FRAGMENT_BIT,
        .module = frag_module,
        .pName = "PSMain", // HLSL entry point
    });

    const shader_stages = [_]c.VkPipelineShaderStageCreateInfo{ vert_stage_info, frag_stage_info };

    // 3. Pipeline Layout (Empty for now)
    const pipeline_layout_info = std.mem.zeroInit(c.VkPipelineLayoutCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
    });

    var pipeline_layout: c.VkPipelineLayout = null;
    if (c.vkCreatePipelineLayout(surface.device, &pipeline_layout_info, null, &pipeline_layout) != c.VK_SUCCESS) {
        return null;
    }

    // 4. Graphics Pipeline
    // This is the largest structure in Vulkan. We'll simplify with defaults.
    
    // Vertex Input
    const vertex_input_info = std.mem.zeroInit(c.VkPipelineVertexInputStateCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
    });

    // Input Assembly
    const input_assembly = std.mem.zeroInit(c.VkPipelineInputAssemblyStateCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        .topology = c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
        .primitiveRestartEnable = c.VK_FALSE,
    });

    // Viewport & Scissor
    const viewport = std.mem.zeroInit(c.VkViewport, .{
        .x = 0.0,
        .y = 0.0,
        .width = @as(f32, @floatFromInt(surface.width)),
        .height = @as(f32, @floatFromInt(surface.height)),
        .minDepth = 0.0,
        .maxDepth = 1.0,
    });

    const scissor = std.mem.zeroInit(c.VkRect2D, .{
        .offset = .{ .x = 0, .y = 0 },
        .extent = .{ .width = surface.width, .height = surface.height },
    });

    const viewport_state = std.mem.zeroInit(c.VkPipelineViewportStateCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        .viewportCount = 1,
        .pViewports = &viewport,
        .scissorCount = 1,
        .pScissors = &scissor,
    });

    // Rasterizer
    const rasterizer = std.mem.zeroInit(c.VkPipelineRasterizationStateCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        .depthClampEnable = c.VK_FALSE,
        .rasterizerDiscardEnable = c.VK_FALSE,
        .polygonMode = c.VK_POLYGON_MODE_FILL,
        .lineWidth = 1.0,
        .cullMode = c.VK_CULL_MODE_BACK_BIT,
        .frontFace = c.VK_FRONT_FACE_CLOCKWISE,
        .depthBiasEnable = c.VK_FALSE,
    });

    // Multisampling
    const multisampling = std.mem.zeroInit(c.VkPipelineMultisampleStateCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        .sampleShadingEnable = c.VK_FALSE,
        .rasterizationSamples = c.VK_SAMPLE_COUNT_1_BIT,
    });

    // Color Blending
    const color_blend_attachment = std.mem.zeroInit(c.VkPipelineColorBlendAttachmentState, .{
        .colorWriteMask = c.VK_COLOR_COMPONENT_R_BIT | c.VK_COLOR_COMPONENT_G_BIT | c.VK_COLOR_COMPONENT_B_BIT | c.VK_COLOR_COMPONENT_A_BIT,
        .blendEnable = c.VK_FALSE,
    });

    const color_blending = std.mem.zeroInit(c.VkPipelineColorBlendStateCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        .logicOpEnable = c.VK_FALSE,
        .attachmentCount = 1,
        .pAttachments = &color_blend_attachment,
    });

    // Finally, create the pipeline
    const pipeline_info = std.mem.zeroInit(c.VkGraphicsPipelineCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
        .stageCount = 2,
        .pStages = &shader_stages,
        .pVertexInputState = &vertex_input_info,
        .pInputAssemblyState = &input_assembly,
        .pViewportState = &viewport_state,
        .pRasterizationState = &rasterizer,
        .pMultisampleState = &multisampling,
        .pColorBlendState = &color_blending,
        .layout = pipeline_layout,
        .renderPass = surface.render_pass,
        .subpass = 0,
    });

    var graphics_pipeline: c.VkPipeline = null;
    if (c.vkCreateGraphicsPipelines(surface.device, null, 1, &pipeline_info, null, &graphics_pipeline) != c.VK_SUCCESS) {
        c.vkDestroyPipelineLayout(surface.device, pipeline_layout, null);
        return null;
    }

    var vulkan_pipeline = std.heap.page_allocator.create(VulkanPipeline) catch return null;
    vulkan_pipeline.pipeline = graphics_pipeline;
    vulkan_pipeline.layout = pipeline_layout;

    return vulkan_pipeline;
}

pub fn destroyPipeline(surface: *VulkanSurface, pipeline: *VulkanPipeline) void {
    if (builtin.os.tag != .linux) return;
    if (pipeline.pipeline != null) c.vkDestroyPipeline(surface.device, pipeline.pipeline, null);
    if (pipeline.layout != null) c.vkDestroyPipelineLayout(surface.device, pipeline.layout, null);
    std.heap.page_allocator.destroy(pipeline);
}

pub fn cmdBindPipeline(cmd: *VulkanCommandBuffer, pipeline: *VulkanPipeline) void {
    if (builtin.os.tag != .linux) return;
    c.vkCmdBindPipeline(cmd.cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, pipeline.pipeline);
}
