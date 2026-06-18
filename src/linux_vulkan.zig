const std = @import("std");
const zgraphics = @import("lib.zig");
const builtin = @import("builtin");

const c = struct {
    pub const VkInstance = ?*anyopaque;
    pub const VkPhysicalDevice = ?*anyopaque;
    pub const VkDevice = ?*anyopaque;
    pub const VkQueue = ?*anyopaque;
    pub const VkSurfaceKHR = ?*anyopaque;
    pub const VkImage = ?*anyopaque;
    pub const VkDeviceMemory = ?*anyopaque;
    pub const VkImageView = ?*anyopaque;
    pub const VkRenderPass = ?*anyopaque;
    pub const VkFence = ?*anyopaque;
    pub const VkSwapchainKHR = ?*anyopaque;
    pub const VkPipeline = ?*anyopaque;
    pub const VkPipelineLayout = ?*anyopaque;
    pub const VkCommandBuffer = ?*anyopaque;
    pub const VkBuffer = ?*anyopaque;
    pub const VkCommandPool = ?*anyopaque;
    pub const VkShaderModule = ?*anyopaque;
    pub const VkDescriptorSetLayout = ?*anyopaque;
    pub const VkDescriptorPool = ?*anyopaque;
    pub const VkDescriptorSet = ?*anyopaque;
    pub const VkSampler = ?*anyopaque;
    pub const VkFormat = u32;
    pub const VkResult = i32;
    pub const VkStructureType = u32;
    pub const VkBufferUsageFlags = u32;

    pub const VkSemaphore = ?*anyopaque;
    pub const VkSemaphoreCreateInfo = extern struct {
        sType: VkStructureType = 9, // VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
    };
    pub extern "vulkan" fn vkCreateSemaphore(device: VkDevice, pCreateInfo: *const VkSemaphoreCreateInfo, pAllocator: ?*const anyopaque, pSemaphore: *VkSemaphore) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroySemaphore(device: VkDevice, semaphore: VkSemaphore, pAllocator: ?*const anyopaque) callconv(.c) void;

    pub const VK_SUCCESS = 0;
    pub const VK_TRUE = 1;
    pub const VK_STRUCTURE_TYPE_APPLICATION_INFO = 0;
    pub const VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO = 1;
    pub const VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO = 2;
    pub const VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO = 3;
    pub const VK_STRUCTURE_TYPE_SUBMIT_INFO = 4;
    pub const VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO = 5;
    pub const VK_STRUCTURE_TYPE_FENCE_CREATE_INFO = 8;
    pub const VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO = 14;
    pub const VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO = 15;
    pub const VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR = 1000004000;
    pub const VK_STRUCTURE_TYPE_PRESENT_INFO_KHR = 1000001001;
    pub const VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO = 1000071000;
    pub const VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO = 1000071002;

    pub const VK_API_VERSION_1_0 = (1 << 22) | (0 << 12) | 0;
    pub fn VK_MAKE_VERSION(major: u32, minor: u32, patch: u32) u32 { return (major << 22) | (minor << 12) | patch; }

    pub const VkViewport = extern struct { x: f32, y: f32, width: f32, height: f32, minDepth: f32, maxDepth: f32 };
    pub const VkRect2D = extern struct { offset: extern struct { x: i32, y: i32 }, extent: extern struct { width: u32, height: u32 } };
    
    pub const VkPipelineColorBlendAttachmentState = extern struct {
        blendEnable: u32,
        srcColorBlendFactor: u32,
        dstColorBlendFactor: u32,
        colorBlendOp: u32,
        srcAlphaBlendFactor: u32,
        dstAlphaBlendFactor: u32,
        alphaBlendOp: u32,
        colorWriteMask: u32,
    };

    pub const VkApplicationInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
        pNext: ?*const anyopaque = null,
        pApplicationName: ?[*:0]const u8,
        applicationVersion: u32,
        pEngineName: ?[*:0]const u8,
        engineVersion: u32,
        apiVersion: u32,
    };

    pub const VkInstanceCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        pApplicationInfo: ?*const VkApplicationInfo,
        enabledLayerCount: u32 = 0,
        ppEnabledLayerNames: ?[*]const [*:0]const u8 = null,
        enabledExtensionCount: u32 = 0,
        ppEnabledExtensionNames: ?[*]const [*:0]const u8 = null,
    };

    pub const VkDeviceQueueCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        queueFamilyIndex: u32,
        queueCount: u32,
        pQueuePriorities: *const f32,
    };

    pub const VkPhysicalDeviceFeatures = extern struct {
        robustBufferAccess: u32 = 0,
        fullDrawIndexUint32: u32 = 0,
        imageCubeArray: u32 = 0,
        independentBlend: u32 = 0,
        geometryShader: u32 = 0,
        tessellationShader: u32 = 0,
        sampleRateShading: u32 = 0,
        dualSrcBlend: u32 = 0,
        logicOp: u32 = 0,
        multiDrawIndirect: u32 = 0,
        drawIndirectFirstInstance: u32 = 0,
        depthClamp: u32 = 0,
        depthBiasClamp: u32 = 0,
        fillModeNonSolid: u32 = 0,
        depthBounds: u32 = 0,
        wideLines: u32 = 0,
        largePoints: u32 = 0,
        alphaToOne: u32 = 0,
        multiViewport: u32 = 0,
        samplerAnisotropy: u32 = 0,
        textureCompressionETC2: u32 = 0,
        textureCompressionASTC_LDR: u32 = 0,
        textureCompressionBC: u32 = 0,
        occlusionQueryPrecise: u32 = 0,
        pipelineStatisticsQuery: u32 = 0,
        vertexPipelineStoresAndAtomics: u32 = 0,
        fragmentStoresAndAtomics: u32 = 0,
        shaderTessellationAndGeometryPointSize: u32 = 0,
        shaderImageGatherExtended: u32 = 0,
        shaderStorageImageExtendedFormats: u32 = 0,
        shaderStorageImageMultisample: u32 = 0,
        shaderStorageImageReadWithoutFormat: u32 = 0,
        shaderStorageImageWriteWithoutFormat: u32 = 0,
        shaderUniformBufferArrayDynamicIndexing: u32 = 0,
        shaderSampledImageArrayDynamicIndexing: u32 = 0,
        shaderStorageBufferArrayDynamicIndexing: u32 = 0,
        shaderStorageImageArrayDynamicIndexing: u32 = 0,
        shaderClipDistance: u32 = 0,
        shaderCullDistance: u32 = 0,
        shaderFloat64: u32 = 0,
        shaderInt64: u32 = 0,
        shaderInt16: u32 = 0,
        shaderResourceResidency: u32 = 0,
        shaderResourceMinLod: u32 = 0,
        sparseBinding: u32 = 0,
        sparseResidencyBuffer: u32 = 0,
        sparseResidencyImage2D: u32 = 0,
        sparseResidencyImage3D: u32 = 0,
        sparseResidency2Samples: u32 = 0,
        sparseResidency4Samples: u32 = 0,
        sparseResidency8Samples: u32 = 0,
        sparseResidency16Samples: u32 = 0,
        sparseResidencyAliased: u32 = 0,
        variableMultisampleRate: u32 = 0,
        inheritedQueries: u32 = 0,
    };

    pub const VkDeviceCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        queueCreateInfoCount: u32,
        pQueueCreateInfos: [*]const VkDeviceQueueCreateInfo,
        enabledLayerCount: u32 = 0,
        ppEnabledLayerNames: ?[*]const [*:0]const u8 = null,
        enabledExtensionCount: u32 = 0,
        ppEnabledExtensionNames: ?[*]const [*:0]const u8 = null,
        pEnabledFeatures: ?*const VkPhysicalDeviceFeatures = null,
    };

    pub const VkXlibSurfaceCreateInfoKHR = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        dpy: *anyopaque,
        window: usize,
    };

    pub const VkPresentInfoKHR = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
        pNext: ?*const anyopaque = null,
        waitSemaphoreCount: u32 = 0,
        pWaitSemaphores: ?*const anyopaque = null,
        swapchainCount: u32,
        pSwapchains: [*]const VkSwapchainKHR,
        pImageIndices: [*]const u32,
        pResults: ?*VkResult = null,
    };

    pub const VkQueueFamilyProperties = extern struct {
        queueFlags: u32,
        queueCount: u32,
        timestampValidBits: u32,
        minImageTransferGranularity: extern struct { width: u32, height: u32, depth: u32 },
    };

    pub const VkPhysicalDeviceMemoryProperties = extern struct {
        memoryTypeCount: u32,
        memoryTypes: [32]extern struct { propertyFlags: u32, heapIndex: u32 },
        memoryHeapCount: u32,
        memoryHeaps: [16]extern struct { size: u64, flags: u32 },
    };

    pub const VkMemoryRequirements = extern struct {
        size: u64,
        alignment: u64,
        memoryTypeBits: u32,
    };

    pub const VkMemoryAllocateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        pNext: ?*const anyopaque = null,
        allocationSize: u64,
        memoryTypeIndex: u32,
    };

    pub const VkImageCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        imageType: u32,
        format: VkFormat,
        extent: extern struct { width: u32, height: u32, depth: u32 },
        mipLevels: u32,
        arrayLayers: u32,
        samples: u32,
        tiling: u32,
        usage: u32,
        sharingMode: u32,
        queueFamilyIndexCount: u32 = 0,
        pQueueFamilyIndices: ?*const u32 = null,
        initialLayout: u32,
    };

    pub const VkExternalMemoryImageCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        handleTypes: u32,
    };

    pub const VkExportMemoryAllocateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO,
        pNext: ?*const anyopaque = null,
        handleTypes: u32,
    };

    pub const VkMemoryGetFdInfoKHR = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_MEMORY_GET_FD_INFO_KHR,
        pNext: ?*const anyopaque = null,
        memory: VkDeviceMemory,
        handleType: u32,
    };

    pub const VkImageViewCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        image: VkImage,
        viewType: u32,
        format: VkFormat,
        components: extern struct { r: u32, g: u32, b: u32, a: u32 },
        subresourceRange: extern struct { aspectMask: u32, baseMipLevel: u32, levelCount: u32, baseArrayLayer: u32, layerCount: u32 },
    };

    pub const VkAttachmentDescription = extern struct {
        flags: u32 = 0,
        format: VkFormat,
        samples: u32,
        loadOp: u32,
        storeOp: u32,
        stencilLoadOp: u32,
        stencilStoreOp: u32,
        initialLayout: u32,
        finalLayout: u32,
    };

    pub const VkAttachmentReference = extern struct {
        attachment: u32,
        layout: u32,
    };

    pub const VkSubpassDescription = extern struct {
        flags: u32 = 0,
        pipelineBindPoint: u32,
        inputAttachmentCount: u32 = 0,
        pInputAttachments: ?*const VkAttachmentReference = null,
        colorAttachmentCount: u32,
        pColorAttachments: [*]const VkAttachmentReference,
        pResolveAttachments: ?*const VkAttachmentReference = null,
        pDepthStencilAttachment: ?*const VkAttachmentReference = null,
        preserveAttachmentCount: u32 = 0,
        pPreserveAttachments: ?*const u32 = null,
    };

    pub const VkRenderPassCreateInfo = extern struct {
        sType: VkStructureType = 38, // VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        attachmentCount: u32,
        pAttachments: [*]const VkAttachmentDescription,
        subpassCount: u32,
        pSubpasses: [*]const VkSubpassDescription,
        dependencyCount: u32 = 0,
        pDependencies: ?*const anyopaque = null,
    };

    pub const VkFenceCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        flags: u32,
    };

    pub const VkVertexInputBindingDescription = extern struct {
        binding: u32,
        stride: u32,
        inputRate: u32,
    };

    pub const VkVertexInputAttributeDescription = extern struct {
        location: u32,
        binding: u32,
        format: u32,
        offset: u32,
    };

    pub const VkPipelineLayoutCreateInfo = extern struct {
        sType: VkStructureType = 30, // VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        setLayoutCount: u32 = 0,
        pSetLayouts: ?*const anyopaque = null,
        pushConstantRangeCount: u32 = 0,
        pPushConstantRanges: ?*const anyopaque = null,
    };

    pub const VkPipelineShaderStageCreateInfo = extern struct {
        sType: u32 = 18, // VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        stage: u32,
        module: VkShaderModule,
        pName: [*:0]const u8,
        pSpecializationInfo: ?*const anyopaque = null,
    };

    pub const VkPipelineVertexInputStateCreateInfo = extern struct {
        sType: u32 = 19, // VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        vertexBindingDescriptionCount: u32 = 0,
        pVertexBindingDescriptions: ?*const anyopaque = null,
        vertexAttributeDescriptionCount: u32 = 0,
        pVertexAttributeDescriptions: ?*const anyopaque = null,
    };

    pub const VkPipelineInputAssemblyStateCreateInfo = extern struct {
        sType: u32 = 20, // VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        topology: u32,
        primitiveRestartEnable: u32,
    };

    pub const VkPipelineViewportStateCreateInfo = extern struct {
        sType: u32 = 22, // VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        viewportCount: u32,
        pViewports: [*]const VkViewport,
        scissorCount: u32,
        pScissors: [*]const VkRect2D,
    };

    pub const VkPipelineRasterizationStateCreateInfo = extern struct {
        sType: u32 = 23, // VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        depthClampEnable: u32,
        rasterizerDiscardEnable: u32,
        polygonMode: u32,
        cullMode: u32,
        frontFace: u32,
        depthBiasEnable: u32,
        depthBiasConstantFactor: f32,
        depthBiasClamp: f32,
        depthBiasSlopeFactor: f32,
        lineWidth: f32,
    };

    pub const VkPipelineMultisampleStateCreateInfo = extern struct {
        sType: u32 = 24, // VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        rasterizationSamples: u32,
        sampleShadingEnable: u32,
        minSampleShading: f32,
        pSampleMask: ?*const u32 = null,
        alphaToCoverageEnable: u32,
        alphaToOneEnable: u32,
    };

    pub const VkPipelineColorBlendStateCreateInfo = extern struct {
        sType: u32 = 26, // VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        logicOpEnable: u32,
        logicOp: u32,
        attachmentCount: u32,
        pAttachments: [*]const VkPipelineColorBlendAttachmentState,
        blendConstants: [4]f32,
    };

    pub const VkGraphicsPipelineCreateInfo = extern struct {
        sType: u32 = 28, // VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        stageCount: u32,
        pStages: [*]const VkPipelineShaderStageCreateInfo,
        pVertexInputState: *const VkPipelineVertexInputStateCreateInfo,
        pInputAssemblyState: *const VkPipelineInputAssemblyStateCreateInfo,
        pTessellationState: ?*const anyopaque = null,
        pViewportState: *const VkPipelineViewportStateCreateInfo,
        pRasterizationState: *const VkPipelineRasterizationStateCreateInfo,
        pMultisampleState: *const VkPipelineMultisampleStateCreateInfo,
        pDepthStencilState: ?*const anyopaque = null,
        pColorBlendState: *const VkPipelineColorBlendStateCreateInfo,
        pDynamicState: ?*const anyopaque = null,
        layout: VkPipelineLayout,
        renderPass: VkRenderPass,
        subpass: u32,
        basePipelineHandle: VkPipeline = null,
        basePipelineIndex: i32 = -1,
    };

    pub const VkCommandBufferAllocateInfo = extern struct {
        sType: VkStructureType = 40, // VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
        pNext: ?*const anyopaque = null,
        commandPool: VkCommandPool,
        level: u32,
        commandBufferCount: u32,
    };

    pub const VkCommandBufferBeginInfo = extern struct {
        sType: VkStructureType = 42, // VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
        pNext: ?*const anyopaque = null,
        flags: u32,
        pInheritanceInfo: ?*const anyopaque = null,
    };

    pub const VkClearColorValue = extern union { float32: [4]f32, int32: [4]i32, uint32: [4]u32 };
    pub const VkClearValue = extern union { color: VkClearColorValue, depthStencil: extern struct { depth: f32, stencil: u32 } };

    pub const VkRenderPassBeginInfo = extern struct {
        sType: VkStructureType = 43, // VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO
        pNext: ?*const anyopaque = null,
        renderPass: VkRenderPass,
        framebuffer: ?*anyopaque,
        renderArea: VkRect2D,
        clearValueCount: u32,
        pClearValues: [*]const VkClearValue,
    };

    pub const VkSubmitInfo = extern struct {
        sType: VkStructureType = 4, // VK_STRUCTURE_TYPE_SUBMIT_INFO
        pNext: ?*const anyopaque = null,
        waitSemaphoreCount: u32 = 0,
        pWaitSemaphores: ?*const anyopaque = null,
        pWaitDstStageMask: ?*const u32 = null,
        commandBufferCount: u32,
        pCommandBuffers: [*]const VkCommandBuffer,
        signalSemaphoreCount: u32 = 0,
        pSignalSemaphores: ?*const anyopaque = null,
    };

    pub const VkCommandPoolCreateInfo = extern struct {
        sType: VkStructureType = 39, // VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        queueFamilyIndex: u32,
    };

    pub const PFN_vkCreateXlibSurfaceKHR = *const fn (VkInstance, *const VkXlibSurfaceCreateInfoKHR, ?*const anyopaque, *VkSurfaceKHR) callconv(.c) VkResult;
    pub const PFN_vkGetMemoryFdKHR = *const fn (VkDevice, ?*const anyopaque, *i32) callconv(.c) VkResult;

    pub extern "vulkan" fn vkCreateInstance(pCreateInfo: *const VkInstanceCreateInfo, pAllocator: ?*const anyopaque, pInstance: *VkInstance) callconv(.c) VkResult;
    pub extern "vulkan" fn vkEnumeratePhysicalDevices(instance: VkInstance, pPhysicalDeviceCount: *u32, pPhysicalDevices: ?[*]VkPhysicalDevice) callconv(.c) VkResult;
    pub extern "vulkan" fn vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice: VkPhysicalDevice, pQueueFamilyPropertyCount: *u32, pQueueFamilyProperties: ?[*]VkQueueFamilyProperties) callconv(.c) void;
    pub extern "vulkan" fn vkCreateDevice(physicalDevice: VkPhysicalDevice, pCreateInfo: *const VkDeviceCreateInfo, pAllocator: ?*const anyopaque, pDevice: *VkDevice) callconv(.c) VkResult;
    pub extern "vulkan" fn vkGetDeviceQueue(device: VkDevice, queueFamilyIndex: u32, queueIndex: u32, pQueue: *VkQueue) callconv(.c) void;
    pub extern "vulkan" fn vkGetInstanceProcAddr(instance: VkInstance, pName: [*:0]const u8) callconv(.c) ?*anyopaque;
    pub extern "vulkan" fn vkGetDeviceProcAddr(device: VkDevice, pName: [*:0]const u8) callconv(.c) ?*anyopaque;
    pub extern "vulkan" fn vkCreateImage(device: VkDevice, pCreateInfo: *const VkImageCreateInfo, pAllocator: ?*const anyopaque, pImage: *VkImage) callconv(.c) VkResult;
    pub extern "vulkan" fn vkGetImageMemoryRequirements(device: VkDevice, image: VkImage, pMemoryRequirements: *VkMemoryRequirements) callconv(.c) void;
    pub extern "vulkan" fn vkGetPhysicalDeviceMemoryProperties(physicalDevice: VkPhysicalDevice, pMemoryProperties: *VkPhysicalDeviceMemoryProperties) callconv(.c) void;
    pub extern "vulkan" fn vkAllocateMemory(device: VkDevice, pAllocateInfo: *const VkMemoryAllocateInfo, pAllocator: ?*const anyopaque, pMemory: *VkDeviceMemory) callconv(.c) VkResult;
    pub extern "vulkan" fn vkBindImageMemory(device: VkDevice, image: VkImage, memory: VkDeviceMemory, memoryOffset: u64) callconv(.c) VkResult;
    pub extern "vulkan" fn vkQueuePresentKHR(queue: VkQueue, pPresentInfo: *const VkPresentInfoKHR) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyDevice(device: VkDevice, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkDestroyInstance(instance: VkInstance, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkDestroyImage(device: VkDevice, image: VkImage, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkDestroyFence(device: VkDevice, fence: VkFence, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkFreeMemory(device: VkDevice, memory: VkDeviceMemory, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkWaitForFences(device: VkDevice, fenceCount: u32, pFences: [*]const VkFence, waitAll: u32, timeout: u64) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCreateImageView(device: VkDevice, pCreateInfo: *const VkImageViewCreateInfo, pAllocator: ?*const anyopaque, pView: *VkImageView) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCreateRenderPass(device: VkDevice, pCreateInfo: *const VkRenderPassCreateInfo, pAllocator: ?*const anyopaque, pRenderPass: *VkRenderPass) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCreateFence(device: VkDevice, pCreateInfo: *const VkFenceCreateInfo, pAllocator: ?*const anyopaque, pFence: *VkFence) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCreatePipelineLayout(device: VkDevice, pCreateInfo: *const VkPipelineLayoutCreateInfo, pAllocator: ?*const anyopaque, pPipelineLayout: *VkPipelineLayout) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCreateGraphicsPipelines(device: VkDevice, pipelineCache: ?*anyopaque, createInfoCount: u32, pCreateInfos: [*]const VkGraphicsPipelineCreateInfo, pAllocator: ?*const anyopaque, pPipelines: *VkPipeline) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyPipeline(device: VkDevice, pipeline: VkPipeline, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkDestroyRenderPass(device: VkDevice, renderPass: VkRenderPass, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkDestroyImageView(device: VkDevice, imageView: VkImageView, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkDestroyPipelineLayout(device: VkDevice, pipelineLayout: VkPipelineLayout, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCmdBindPipeline(commandBuffer: VkCommandBuffer, pipelineBindPoint: u32, pipeline: VkPipeline) callconv(.c) void;
    pub extern "vulkan" fn vkAllocateCommandBuffers(device: VkDevice, pAllocateInfo: *const VkCommandBufferAllocateInfo, pCommandBuffers: *VkCommandBuffer) callconv(.c) VkResult;
    pub extern "vulkan" fn vkBeginCommandBuffer(commandBuffer: VkCommandBuffer, pBeginInfo: *const VkCommandBufferBeginInfo) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCmdBeginRenderPass(commandBuffer: VkCommandBuffer, pRenderPassBegin: *const VkRenderPassBeginInfo, contents: u32) callconv(.c) void;
    pub extern "vulkan" fn vkCmdClearAttachments(commandBuffer: VkCommandBuffer, attachmentCount: u32, pAttachments: [*]const c.VkClearAttachment, rectCount: u32, pRects: [*]const c.VkClearRect) callconv(.c) void;
    pub extern "vulkan" fn vkCmdEndRenderPass(commandBuffer: VkCommandBuffer) callconv(.c) void;
    pub extern "vulkan" fn vkCmdClearColorImage(commandBuffer: VkCommandBuffer, image: VkImage, imageLayout: u32, pColor: *const VkClearColorValue, rangeCount: u32, pRanges: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkEndCommandBuffer(commandBuffer: VkCommandBuffer) callconv(.c) VkResult;
    pub extern "vulkan" fn vkQueueSubmit(queue: VkQueue, submitCount: u32, pSubmits: [*]const VkSubmitInfo, fence: VkFence) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCreateBuffer(device: VkDevice, pCreateInfo: *const VkBufferCreateInfo, pAllocator: ?*const anyopaque, pBuffer: *VkBuffer) callconv(.c) VkResult;
    pub extern "vulkan" fn vkGetBufferMemoryRequirements(device: VkDevice, buffer: VkBuffer, pMemoryRequirements: *VkMemoryRequirements) callconv(.c) void;
    pub extern "vulkan" fn vkBindBufferMemory(device: VkDevice, buffer: VkBuffer, memory: VkDeviceMemory, memoryOffset: u64) callconv(.c) VkResult;
    pub extern "vulkan" fn vkMapMemory(device: VkDevice, memory: VkDeviceMemory, offset: u64, size: u64, flags: u32, ppData: ?*?*anyopaque) callconv(.c) VkResult;
    pub extern "vulkan" fn vkUnmapMemory(device: VkDevice, memory: VkDeviceMemory) callconv(.c) void;
    pub extern "vulkan" fn vkFlushMappedMemoryRanges(device: VkDevice, memoryRangeCount: u32, pMemoryRanges: [*]const VkMappedMemoryRange) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyBuffer(device: VkDevice, buffer: VkBuffer, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCmdBindVertexBuffers(commandBuffer: VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: [*]const VkBuffer, pOffsets: [*]const u64) callconv(.c) void;
    pub extern "vulkan" fn vkCmdDraw(commandBuffer: VkCommandBuffer, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) callconv(.c) void;
    pub extern "vulkan" fn vkCmdCopyBuffer(commandBuffer: VkCommandBuffer, srcBuffer: VkBuffer, dstBuffer: VkBuffer, regionCount: u32, pRegions: [*]const VkBufferCopy) callconv(.c) void;
    pub extern "vulkan" fn vkCmdPipelineBarrier(commandBuffer: VkCommandBuffer, srcStageMask: u32, dstStageMask: u32, dependencyFlags: u32, memoryBarrierCount: u32, pMemoryBarriers: ?[*]const VkMemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: ?[*]const VkBufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: ?[*]const VkImageMemoryBarrier) callconv(.c) void;

    pub const VkMemoryBarrier = extern struct {
        sType: VkStructureType = 43,
        pNext: ?*const anyopaque = null,
        srcAccessMask: u32,
        dstAccessMask: u32,
    };

    pub const VkBufferMemoryBarrier = extern struct {
        sType: VkStructureType = 44,
        pNext: ?*const anyopaque = null,
        srcAccessMask: u32,
        dstAccessMask: u32,
        srcQueueFamilyIndex: u32 = 4294967295,
        dstQueueFamilyIndex: u32 = 4294967295,
        buffer: VkBuffer,
        offset: u64 = 0,
        size: u64 = 0,
    };
    pub extern "vulkan" fn vkCmdCopyBufferToImage(commandBuffer: VkCommandBuffer, srcBuffer: VkBuffer, dstImage: VkImage, dstImageLayout: u32, regionCount: u32, pRegions: [*]const VkBufferImageCopy) callconv(.c) void;
    pub extern "vulkan" fn vkCreateFramebuffer(device: VkDevice, pCreateInfo: *const VkFramebufferCreateInfo, pAllocator: ?*const anyopaque, pFramebuffer: *VkFramebuffer) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyFramebuffer(device: VkDevice, framebuffer: VkFramebuffer, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkResetFences(device: VkDevice, fenceCount: u32, pFences: [*]const VkFence) callconv(.c) VkResult;

    pub const VkShaderModuleCreateInfo = extern struct {
        sType: VkStructureType = 16, // VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        codeSize: usize,
        pCode: [*]const u32,
    };
    pub extern "vulkan" fn vkCreateShaderModule(device: VkDevice, pCreateInfo: *const VkShaderModuleCreateInfo, pAllocator: ?*const anyopaque, pShaderModule: *VkShaderModule) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyShaderModule(device: VkDevice, shaderModule: VkShaderModule, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCreateCommandPool(device: VkDevice, pCreateInfo: *const VkCommandPoolCreateInfo, pAllocator: ?*const anyopaque, pCommandPool: *VkCommandPool) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyCommandPool(device: VkDevice, commandPool: VkCommandPool, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCreateDescriptorSetLayout(device: VkDevice, pCreateInfo: *const VkDescriptorSetLayoutCreateInfo, pAllocator: ?*const anyopaque, pSetLayout: *VkDescriptorSetLayout) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyDescriptorSetLayout(device: VkDevice, descriptorSetLayout: VkDescriptorSetLayout, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCreateDescriptorPool(device: VkDevice, pCreateInfo: *const VkDescriptorPoolCreateInfo, pAllocator: ?*const anyopaque, pDescriptorPool: *VkDescriptorPool) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyDescriptorPool(device: VkDevice, descriptorPool: VkDescriptorPool, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkAllocateDescriptorSets(device: VkDevice, pAllocateInfo: *const VkDescriptorSetAllocateInfo, pDescriptorSets: *VkDescriptorSet) callconv(.c) VkResult;
    pub extern "vulkan" fn vkUpdateDescriptorSets(device: VkDevice, descriptorWriteCount: u32, pDescriptorWrites: [*]const VkWriteDescriptorSet, descriptorCopyCount: u32, pDescriptorCopies: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCmdBindDescriptorSets(commandBuffer: VkCommandBuffer, pipelineBindPoint: u32, layout: VkPipelineLayout, firstSet: u32, descriptorSetCount: u32, pDescriptorSets: [*]const VkDescriptorSet, dynamicOffsetCount: u32, pDynamicOffsets: ?[*]const u32) callconv(.c) void;
    pub extern "vulkan" fn vkCreateSampler(device: VkDevice, pCreateInfo: *const VkSamplerCreateInfo, pAllocator: ?*const anyopaque, pSampler: *VkSampler) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroySampler(device: VkDevice, sampler: VkSampler, pAllocator: ?*const anyopaque) callconv(.c) void;

    pub const VK_SHADER_STAGE_VERTEX_BIT = 1;
    pub const VK_SHADER_STAGE_FRAGMENT_BIT = 16;
    pub const VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST = 3;
    pub const VK_POLYGON_MODE_FILL = 0;
    pub const VK_CULL_MODE_NONE = 0;
    pub const VK_FRONT_FACE_CLOCKWISE = 1;
    pub const VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU = 2;
    pub const VK_QUEUE_GRAPHICS_BIT = 1;
    pub const VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT = 1;
    pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT = 1;
    pub const VK_IMAGE_TYPE_2D = 1;
    pub const VK_IMAGE_VIEW_TYPE_2D = 1;
    pub const VK_FORMAT_R8G8B8A8_UNORM = 37;
    pub const VK_IMAGE_TILING_OPTIMAL = 0;
    pub const VK_IMAGE_LAYOUT_UNDEFINED = 0;
    pub const VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL = 7;
    pub const VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL = 5;
    pub const VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT = 16;
    pub const VK_IMAGE_USAGE_TRANSFER_SRC_BIT = 1;
    pub const VK_IMAGE_USAGE_TRANSFER_DST_BIT = 2;
    pub const VK_IMAGE_USAGE_SAMPLED_BIT = 1 << 5;
    pub const VK_IMAGE_ASPECT_COLOR_BIT = 1;

    pub const VK_FORMAT_B8G8R8A8_UNORM = 44;
    pub const VK_COLOR_SPACE_SRGB_NONLINEAR_KHR = 0;
    pub const VK_PRESENT_MODE_FIFO_KHR = 2;

    pub const VkExtent2D = extern struct {
        width: u32,
        height: u32,
    };

    pub const VkSurfaceCapabilitiesKHR = extern struct {
        minImageCount: u32,
        maxImageCount: u32,
        currentExtent: VkExtent2D,
        minImageExtent: VkExtent2D,
        maxImageExtent: VkExtent2D,
        maxImageArrayLayers: u32,
        supportedTransforms: u32,
        currentTransform: u32,
        supportedCompositeAlpha: u32,
        supportedUsageFlags: u32,
    };

    pub const VkSurfaceFormatKHR = extern struct {
        format: VkFormat,
        colorSpace: u32,
    };

    pub const VkSwapchainCreateInfoKHR = extern struct {
        sType: VkStructureType = 1000001000, // VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        surface: VkSurfaceKHR,
        minImageCount: u32,
        imageFormat: VkFormat,
        imageColorSpace: u32,
        imageExtent: VkExtent2D,
        imageArrayLayers: u32,
        imageUsage: u32,
        imageSharingMode: u32,
        queueFamilyIndexCount: u32 = 0,
        pQueueFamilyIndices: ?[*]const u32 = null,
        preTransform: u32,
        compositeAlpha: u32,
        presentMode: u32,
        clipped: u32 = 1, // VK_TRUE
        oldSwapchain: VkSwapchainKHR = null,
    };

    pub extern "vulkan" fn vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice: VkPhysicalDevice, surface: VkSurfaceKHR, pSurfaceCapabilities: *VkSurfaceCapabilitiesKHR) callconv(.c) VkResult;
    pub extern "vulkan" fn vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice: VkPhysicalDevice, surface: VkSurfaceKHR, pSurfaceFormatCount: *u32, pSurfaceFormats: ?[*]VkSurfaceFormatKHR) callconv(.c) VkResult;
    pub extern "vulkan" fn vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice: VkPhysicalDevice, surface: VkSurfaceKHR, pPresentModeCount: *u32, pPresentModes: ?[*]u32) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCreateSwapchainKHR(device: VkDevice, pCreateInfo: *const VkSwapchainCreateInfoKHR, pAllocator: ?*const anyopaque, pSwapchain: *VkSwapchainKHR) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroySwapchainKHR(device: VkDevice, swapchain: VkSwapchainKHR, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkGetSwapchainImagesKHR(device: VkDevice, swapchain: VkSwapchainKHR, pSwapchainImageCount: *u32, pSwapchainImages: ?[*]VkImage) callconv(.c) VkResult;
    pub extern "vulkan" fn vkAcquireNextImageKHR(device: VkDevice, swapchain: VkSwapchainKHR, timeout: u64, semaphore: VkFence, fence: VkFence, pImageIndex: *u32) callconv(.c) VkResult;

    pub const VK_ACCESS_TRANSFER_WRITE_BIT = 4096;
    pub const VK_ACCESS_SHADER_READ_BIT = 32;
    pub const VK_PIPELINE_STAGE_TRANSFER_BIT = 4096;
    pub const VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT = 128;
    pub const VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT = 1;
    pub const VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT = 1024;

    pub const VkBufferImageCopy = extern struct {
        bufferOffset: u64 = 0,
        bufferRowLength: u32 = 0,
        bufferImageHeight: u32 = 0,
        imageSubresource: VkImageSubresourceLayers,
        imageOffset: extern struct { x: i32 = 0, y: i32 = 0, z: i32 = 0 } = .{ .x = 0, .y = 0, .z = 0 },
        imageExtent: extern struct { width: u32, height: u32, depth: u32 } = .{ .width = 0, .height = 0, .depth = 0 },
    };

    pub const VkImageSubresourceLayers = extern struct {
        aspectMask: u32,
        mipLevel: u32 = 0,
        baseArrayLayer: u32 = 0,
        layerCount: u32 = 1,
    };

    pub const VkImageMemoryBarrier = extern struct {
        sType: VkStructureType = 45, // VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER
        pNext: ?*const anyopaque = null,
        srcAccessMask: u32,
        dstAccessMask: u32,
        oldLayout: u32,
        newLayout: u32,
        srcQueueFamilyIndex: u32 = 4294967295, // VK_QUEUE_FAMILY_IGNORED
        dstQueueFamilyIndex: u32 = 4294967295, // VK_QUEUE_FAMILY_IGNORED
        image: VkImage,
        subresourceRange: VkImageSubresourceRange,
    };

    pub const VkImageSubresourceRange = extern struct {
        aspectMask: u32,
        baseMipLevel: u32 = 0,
        levelCount: u32 = 1,
        baseArrayLayer: u32 = 0,
        layerCount: u32 = 1,
    };

    pub const VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER = 1;

    pub const VkDescriptorSetLayoutBinding = extern struct {
        binding: u32,
        descriptorType: u32,
        descriptorCount: u32,
        stageFlags: u32,
        pImmutableSamplers: ?[*]const VkSampler = null,
    };

    pub const VkDescriptorSetLayoutCreateInfo = extern struct {
        sType: VkStructureType = 32,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        bindingCount: u32,
        pBindings: [*]const VkDescriptorSetLayoutBinding,
    };

    pub const VkDescriptorPoolSize = extern struct {
        type: u32,
        descriptorCount: u32,
    };

    pub const VkDescriptorPoolCreateInfo = extern struct {
        sType: VkStructureType = 33,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        maxSets: u32,
        poolSizeCount: u32,
        pPoolSizes: [*]const VkDescriptorPoolSize,
    };

    pub const VkDescriptorSetAllocateInfo = extern struct {
        sType: VkStructureType = 34,
        pNext: ?*const anyopaque = null,
        descriptorPool: VkDescriptorPool,
        descriptorSetCount: u32,
        pSetLayouts: [*]const VkDescriptorSetLayout,
    };

    pub const VkDescriptorImageInfo = extern struct {
        sampler: VkSampler,
        imageView: VkImageView,
        imageLayout: u32,
    };

    pub const VkWriteDescriptorSet = extern struct {
        sType: VkStructureType = 35,
        pNext: ?*const anyopaque = null,
        dstSet: VkDescriptorSet,
        dstBinding: u32,
        dstArrayElement: u32,
        descriptorCount: u32,
        descriptorType: u32,
        pImageInfo: ?[*]const VkDescriptorImageInfo = null,
        pBufferInfo: ?*const anyopaque = null,
        pTexelBufferView: ?*const anyopaque = null,
    };

    pub const VkSamplerCreateInfo = extern struct {
        sType: VkStructureType = 31,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        magFilter: u32,
        minFilter: u32,
        mipmapMode: u32,
        addressModeU: u32,
        addressModeV: u32,
        addressModeW: u32,
        mipLodBias: f32,
        anisotropyEnable: u32,
        maxAnisotropy: f32,
        compareEnable: u32,
        compareOp: u32,
        minLod: f32,
        maxLod: f32,
        borderColor: u32,
        unnormalizedCoordinates: u32,
    };
    pub const VK_ATTACHMENT_LOAD_OP_CLEAR = 1;
    pub const VK_ATTACHMENT_STORE_OP_STORE = 0;
    pub const VK_ATTACHMENT_LOAD_OP_DONT_CARE = 2;
    pub const VK_ATTACHMENT_STORE_OP_DONT_CARE = 1;
    pub const VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL = 2;
    pub const VK_SHARING_MODE_EXCLUSIVE = 0;
    pub const VK_SAMPLE_COUNT_1_BIT = 1;
    pub const VK_PIPELINE_BIND_POINT_GRAPHICS = 0;
    pub const VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO = 34;
    pub const VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE = 37;
    pub const VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO = 38;
    pub const VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO = 39;
    pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO = 40;
    pub const VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO = 43;
    pub const VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO = 50;
    pub const VK_STRUCTURE_TYPE_MEMORY_GET_FD_INFO_KHR = 1000074002;
    pub const VK_COMMAND_BUFFER_LEVEL_PRIMARY = 0;
    pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO = 42;
    pub const VK_BUFFER_USAGE_TRANSFER_SRC_BIT = 1 << 7;
    pub const VK_BUFFER_USAGE_TRANSFER_DST_BIT = 1 << 8;
    pub const VK_BUFFER_USAGE_VERTEX_BUFFER_BIT = 1 << 1;
    pub const VK_BUFFER_USAGE_INDEX_BUFFER_BIT = 1 << 2;
    pub const VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT = 1 << 6;
    pub const VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT = 1 << 0;
    pub const VK_MEMORY_PROPERTY_HOST_COHERENT_BIT = 1 << 1;
    pub const VK_SUBPASS_CONTENTS_INLINE = 0;
    pub const VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT = 1 << 17;
    pub const VK_FORMAT_R32G32_SFLOAT = 91;
    pub const VK_VERTEX_INPUT_RATE_VERTEX = 0;
    pub const VK_VERTEX_INPUT_RATE_INSTANCE = 1;

    pub const VkFramebuffer = ?*anyopaque;
    pub const VkFramebufferCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        renderPass: VkRenderPass,
        attachmentCount: u32,
        pAttachments: [*]const VkImageView,
        width: u32,
        height: u32,
        layers: u32,
    };

    pub const VkBufferCreateInfo = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        size: u64,
        usage: VkBufferUsageFlags,
        sharingMode: u32,
        queueFamilyIndexCount: u32 = 0,
        pQueueFamilyIndices: ?*const u32 = null,
    };

    pub const VkMappedMemoryRange = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE,
        pNext: ?*const anyopaque = null,
        memory: VkDeviceMemory,
        offset: u64,
        size: u64,
    };

    pub const VkBufferCopy = extern struct {
        srcOffset: u64,
        dstOffset: u64,
        size: u64,
    };
};

pub const VulkanSurface = struct {
    instance: c.VkInstance,
    physical_device: c.VkPhysicalDevice,
    device: c.VkDevice,
    graphics_queue: c.VkQueue,
    queue_family: u32,
    surface: c.VkSurfaceKHR,
    image: c.VkImage,
    image_memory: c.VkDeviceMemory,
    image_view: c.VkImageView,
    render_pass: c.VkRenderPass,
    framebuffer: c.VkFramebuffer,
    fence: c.VkFence,
    swapchain: c.VkSwapchainKHR,
    swapchain_images: [3]c.VkImage,
    swapchain_image_views: [3]c.VkImageView,
    swapchain_framebuffers: [3]c.VkFramebuffer,
    image_available_semaphore: c.VkFence, // Using VkFence alias for VkSemaphore temporarily as they are both opaque pointers
    render_finished_semaphore: c.VkFence,
    image_count: u32,
    image_index: u32,
    external_memory_enabled: bool,
    window: ?*anyopaque, // X11 Window
    x_display: ?*Display, // X11 Display
    width: u32,
    height: u32,
    descriptor_pool: c.VkDescriptorPool = null,
};

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

fn findMemoryType(physical_device: c.VkPhysicalDevice, type_filter: u32, properties: u32) ?u32 {
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
    return blk: {
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
            "VK_KHR_xlib_surface",
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
            const fallback_create_info = std.mem.zeroInit(c.VkInstanceCreateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
                .pApplicationInfo = &app_info,
                .enabledExtensionCount = 0,
                .ppEnabledExtensionNames = null,
            });
            if (c.vkCreateInstance(&fallback_create_info, null, &instance) != c.VK_SUCCESS) break :blk null;
        }

        var device_count: u32 = 0;
        _ = c.vkEnumeratePhysicalDevices(instance, &device_count, null);
        if (device_count == 0) {
            c.vkDestroyInstance(instance, null);
            break :blk null;
        }

        const devices = std.heap.page_allocator.alloc(c.VkPhysicalDevice, device_count) catch {
            c.vkDestroyInstance(instance, null);
            break :blk null;
        };
        defer std.heap.page_allocator.free(devices);
        _ = c.vkEnumeratePhysicalDevices(instance, &device_count, devices.ptr);
        const physical_device = devices[0];

        var queue_family_count: u32 = 0;
        c.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, null);
        const queue_families = std.heap.page_allocator.alloc(c.VkQueueFamilyProperties, queue_family_count) catch {
            c.vkDestroyInstance(instance, null);
            break :blk null;
        };
        defer std.heap.page_allocator.free(queue_families);
        c.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families.ptr);

        var graphics_family: ?u32 = null;
        for (queue_families, 0..) |family, i| {
            if ((family.queueFlags & c.VK_QUEUE_GRAPHICS_BIT) != 0) {
                graphics_family = @intCast(i);
                break;
            }
        }
        if (graphics_family == null) {
            c.vkDestroyInstance(instance, null);
            break :blk null;
        }

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
            "VK_KHR_swapchain",
        };

        const device_create_info = c.VkDeviceCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .queueCreateInfoCount = 1,
            .pQueueCreateInfos = @as([*]const c.VkDeviceQueueCreateInfo, @ptrCast(&queue_create_info)),
            .enabledLayerCount = 0,
            .ppEnabledLayerNames = null,
            .enabledExtensionCount = device_extensions.len,
            .ppEnabledExtensionNames = @ptrCast(&device_extensions),
            .pEnabledFeatures = &device_features,
        };

        var device: c.VkDevice = null;
        var external_memory_enabled = true;
        if (c.vkCreateDevice(physical_device, &device_create_info, null, &device) != c.VK_SUCCESS) {
            external_memory_enabled = false;
            const fallback_create_info = std.mem.zeroInit(c.VkDeviceCreateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
                .queueCreateInfoCount = 1,
                .pQueueCreateInfos = @as([*]const c.VkDeviceQueueCreateInfo, @ptrCast(&queue_create_info)),
                .pEnabledFeatures = &device_features,
                .enabledExtensionCount = 0,
                .ppEnabledExtensionNames = null,
            });
            if (c.vkCreateDevice(physical_device, &fallback_create_info, null, &device) != c.VK_SUCCESS) {
                c.vkDestroyInstance(instance, null);
                break :blk null;
            }
        }

        var graphics_queue: c.VkQueue = null;
        c.vkGetDeviceQueue(device, graphics_family.?, 0, &graphics_queue);

        var surface: c.VkSurfaceKHR = null;
        var x_display: ?*Display = null;
        if (window) |w| {
            external_memory_enabled = false; // Disable offscreen export if we have a window to render to
            const state = @as(*X11WindowState, @ptrCast(@alignCast(w)));
            const x_window: usize = state.window;
            x_display = state.display;
            std.debug.print("[Z-GRAPHICS] createSurface: extracting X11WindowState: display={any}, window={}\n", .{ x_display, x_window });
            const pfnCreateXlibSurfaceKHR = @as(?c.PFN_vkCreateXlibSurfaceKHR, @ptrCast(c.vkGetInstanceProcAddr(instance, "vkCreateXlibSurfaceKHR")));
            if (pfnCreateXlibSurfaceKHR) |createXlib| {
                if (x_display) |dpy| {
                    const x_create_info = std.mem.zeroInit(c.VkXlibSurfaceCreateInfoKHR, .{
                        .sType = c.VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR,
                        .dpy = @as(*anyopaque, @ptrCast(dpy)),
                        .window = x_window,
                    });
                    const result = createXlib(instance, &x_create_info, null, &surface);
                    std.debug.print("[Z-GRAPHICS] createSurface: vkCreateXlibSurfaceKHR result={}\n", .{result});
                } else {
                    std.debug.print("[Z-GRAPHICS] createSurface: x_display is null, cannot create Vulkan surface\n", .{});
                }
            } else {
                std.debug.print("[Z-GRAPHICS] createSurface: vkCreateXlibSurfaceKHR not found\n", .{});
            }
            std.heap.page_allocator.destroy(state);
        } else {
            std.debug.print("[Z-GRAPHICS] createSurface: no window provided, headless mode\n", .{});
        }

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
            .format = c.VK_FORMAT_R8G8B8A8_UNORM,
            .tiling = c.VK_IMAGE_TILING_OPTIMAL,
            .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
            .usage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_TRANSFER_SRC_BIT | c.VK_IMAGE_USAGE_SAMPLED_BIT,
            .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
            .samples = c.VK_SAMPLE_COUNT_1_BIT,
        });

        var image: c.VkImage = null;
        if (c.vkCreateImage(device, &image_info, null, &image) != c.VK_SUCCESS) {
            c.vkDestroyDevice(device, null);
            c.vkDestroyInstance(instance, null);
            break :blk null;
        }

        var mem_requirements: c.VkMemoryRequirements = undefined;
        c.vkGetImageMemoryRequirements(device, image, &mem_requirements);
        const mem_type_index = findMemoryType(physical_device, mem_requirements.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse {
            c.vkDestroyImage(device, image, null);
            c.vkDestroyDevice(device, null);
            c.vkDestroyInstance(instance, null);
            break :blk null;
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
            break :blk null;
        }
        if (c.vkBindImageMemory(device, image, image_memory, 0) != c.VK_SUCCESS) {
            c.vkFreeMemory(device, image_memory, null);
            c.vkDestroyImage(device, image, null);
            c.vkDestroyDevice(device, null);
            c.vkDestroyInstance(instance, null);
            break :blk null;
        }

        const view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
            .image = image,
            .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
            .format = c.VK_FORMAT_R8G8B8A8_UNORM,
            .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
        });

        var image_view: c.VkImageView = null;
        if (c.vkCreateImageView(device, &view_info, null, &image_view) != c.VK_SUCCESS) {
            c.vkFreeMemory(device, image_memory, null);
            c.vkDestroyImage(device, image, null);
            c.vkDestroyDevice(device, null);
            c.vkDestroyInstance(instance, null);
            break :blk null;
        }

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

        const color_attachment_ref = c.VkAttachmentReference{ .attachment = 0, .layout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL };
        const subpass = std.mem.zeroInit(c.VkSubpassDescription, .{
            .pipelineBindPoint = c.VK_PIPELINE_BIND_POINT_GRAPHICS,
            .colorAttachmentCount = 1,
            .pColorAttachments = @as([*]const c.VkAttachmentReference, @ptrCast(&color_attachment_ref)),
        });

        const render_pass_info = std.mem.zeroInit(c.VkRenderPassCreateInfo, .{
            .sType = 38,
            .attachmentCount = 1,
            .pAttachments = @as([*]const c.VkAttachmentDescription, @ptrCast(&color_attachment)),
            .subpassCount = 1,
            .pSubpasses = @as([*]const c.VkSubpassDescription, @ptrCast(&subpass)),
        });

        var render_pass: c.VkRenderPass = null;
        if (c.vkCreateRenderPass(device, &render_pass_info, null, &render_pass) != c.VK_SUCCESS) {
            c.vkDestroyImageView(device, image_view, null);
            c.vkFreeMemory(device, image_memory, null);
            c.vkDestroyImage(device, image, null);
            c.vkDestroyDevice(device, null);
            c.vkDestroyInstance(instance, null);
            break :blk null;
        }

        const framebuffer_info = std.mem.zeroInit(c.VkFramebufferCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
            .renderPass = render_pass,
            .attachmentCount = 1,
            .pAttachments = @as([*]const c.VkImageView, @ptrCast(&image_view)),
            .width = width,
            .height = height,
            .layers = 1,
        });

        var framebuffer: c.VkFramebuffer = null;
        if (c.vkCreateFramebuffer(device, &framebuffer_info, null, &framebuffer) != c.VK_SUCCESS) {
            c.vkDestroyRenderPass(device, render_pass, null);
            c.vkDestroyImageView(device, image_view, null);
            c.vkFreeMemory(device, image_memory, null);
            c.vkDestroyImage(device, image, null);
            c.vkDestroyDevice(device, null);
            c.vkDestroyInstance(instance, null);
            break :blk null;
        }

        const fence_info = std.mem.zeroInit(c.VkFenceCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO, .flags = 0 });
        var fence: c.VkFence = null;
        if (c.vkCreateFence(device, &fence_info, null, &fence) != c.VK_SUCCESS) {
            c.vkDestroyFramebuffer(device, framebuffer, null);
            c.vkDestroyRenderPass(device, render_pass, null);
            c.vkDestroyImageView(device, image_view, null);
            c.vkFreeMemory(device, image_memory, null);
            c.vkDestroyImage(device, image, null);
            c.vkDestroyDevice(device, null);
            c.vkDestroyInstance(instance, null);
            break :blk null;
        }

        var swapchain: c.VkSwapchainKHR = null;
        if (!external_memory_enabled and window != null) {
            var surface_caps: c.VkSurfaceCapabilitiesKHR = undefined;
            _ = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &surface_caps);

            var format_count: u32 = 0;
            _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count, null);
            // In a real app, query formats. Hardcoding B8G8R8A8_UNORM for simplicity in swapchain creation
            
            const swapchain_info = std.mem.zeroInit(c.VkSwapchainCreateInfoKHR, .{
                .sType = 1000001000, // VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
                .surface = surface,
                .minImageCount = if (surface_caps.minImageCount > 0) surface_caps.minImageCount else 2,
                .imageFormat = c.VK_FORMAT_B8G8R8A8_UNORM, // Usually optimal for swapchain
                .imageColorSpace = c.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR,
                .imageExtent = .{ .width = width, .height = height },
                .imageArrayLayers = 1,
                .imageUsage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
                .imageSharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
                .preTransform = surface_caps.currentTransform,
                .compositeAlpha = 1, // VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
                .presentMode = c.VK_PRESENT_MODE_FIFO_KHR,
                .clipped = 1,
                .oldSwapchain = null,
            });

            if (c.vkCreateSwapchainKHR(device, &swapchain_info, null, &swapchain) != c.VK_SUCCESS) {
                std.debug.print("[Z-GRAPHICS] createSurface: vkCreateSwapchainKHR failed\n", .{});
            } else {
                std.debug.print("[Z-GRAPHICS] createSurface: Swapchain created successfully\n", .{});
            }
        }

        const pool_sizes = [_]c.VkDescriptorPoolSize{
            .{ .type = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, .descriptorCount = 100 },
        };
        const pool_info = c.VkDescriptorPoolCreateInfo{
            .sType = 33, // VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO
            .maxSets = 100,
            .poolSizeCount = pool_sizes.len,
            .pPoolSizes = &pool_sizes,
        };
        var descriptor_pool: c.VkDescriptorPool = null;
        if (c.vkCreateDescriptorPool(device, &pool_info, null, &descriptor_pool) != c.VK_SUCCESS) {
            std.debug.print("[Z-GRAPHICS] createSurface: Warning - failed to create descriptor pool\n", .{});
        }

        const surface_obj = std.heap.page_allocator.create(VulkanSurface) catch {
            if (descriptor_pool != null) c.vkDestroyDescriptorPool(device, descriptor_pool, null);
            if (swapchain != null) c.vkDestroySwapchainKHR(device, swapchain, null);
            c.vkDestroyFence(device, fence, null);
            c.vkDestroyFramebuffer(device, framebuffer, null);
            c.vkDestroyRenderPass(device, render_pass, null);
            c.vkDestroyImageView(device, image_view, null);
            c.vkFreeMemory(device, image_memory, null);
            c.vkDestroyImage(device, image, null);
            c.vkDestroyDevice(device, null);
            c.vkDestroyInstance(instance, null);
            break :blk null;
        };

        var swapchain_images: [3]c.VkImage = undefined;
        var swapchain_image_views: [3]c.VkImageView = undefined;
        var swapchain_framebuffers: [3]c.VkFramebuffer = undefined;
        var image_count: u32 = 0;
        var image_available_semaphore: c.VkSemaphore = null;
        var render_finished_semaphore: c.VkSemaphore = null;

        if (swapchain != null) {
            _ = c.vkGetSwapchainImagesKHR(device, swapchain, &image_count, null);
            if (image_count > 3) image_count = 3;
            _ = c.vkGetSwapchainImagesKHR(device, swapchain, &image_count, @ptrCast(&swapchain_images));
            
            for (0..image_count) |i| {
                const sc_view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
                    .image = swapchain_images[i],
                    .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
                    .format = c.VK_FORMAT_B8G8R8A8_UNORM,
                    .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
                });
                _ = c.vkCreateImageView(device, &sc_view_info, null, &swapchain_image_views[i]);

                const fb_info = std.mem.zeroInit(c.VkFramebufferCreateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
                    .renderPass = render_pass,
                    .attachmentCount = 1,
                    .pAttachments = @as([*]const c.VkImageView, @ptrCast(&swapchain_image_views[i])),
                    .width = width,
                    .height = height,
                    .layers = 1,
                });
                _ = c.vkCreateFramebuffer(device, &fb_info, null, &swapchain_framebuffers[i]);
            }
            
            const sema_info = std.mem.zeroInit(c.VkSemaphoreCreateInfo, .{ .sType = 9 });
            _ = c.vkCreateSemaphore(device, &sema_info, null, &image_available_semaphore);
            _ = c.vkCreateSemaphore(device, &sema_info, null, &render_finished_semaphore);
        }

        surface_obj.* = .{
            .instance = instance,
            .physical_device = physical_device,
            .device = device,
            .graphics_queue = graphics_queue,
            .queue_family = graphics_family.?,
            .surface = surface,
            .image = image,
            .image_memory = image_memory,
            .image_view = image_view,
            .render_pass = render_pass,
            .framebuffer = framebuffer,
            .fence = fence,
            .swapchain = swapchain,
            .swapchain_images = swapchain_images,
            .swapchain_image_views = swapchain_image_views,
            .swapchain_framebuffers = swapchain_framebuffers,
            .image_available_semaphore = @ptrCast(image_available_semaphore),
            .render_finished_semaphore = @ptrCast(render_finished_semaphore),
            .image_count = image_count,
            .image_index = 0,
            .external_memory_enabled = external_memory_enabled,
            .window = window,
            .x_display = x_display,
            .width = width,
            .height = height,
            .descriptor_pool = descriptor_pool,
        };

        break :blk surface_obj;
    };
}

pub fn destroySurface(surface: *VulkanSurface) void {
    if (builtin.os.tag != .linux) return;
    if (surface.swapchain != null) {
        for (0..surface.image_count) |i| {
            c.vkDestroyFramebuffer(surface.device, surface.swapchain_framebuffers[i], null);
            c.vkDestroyImageView(surface.device, surface.swapchain_image_views[i], null);
        }
        c.vkDestroySemaphore(surface.device, @ptrCast(surface.image_available_semaphore), null);
        c.vkDestroySemaphore(surface.device, @ptrCast(surface.render_finished_semaphore), null);
        c.vkDestroySwapchainKHR(surface.device, surface.swapchain, null);
    }
    if (surface.x_display) |dpy| _ = XCloseDisplay(dpy);
    if (surface.framebuffer != null) c.vkDestroyFramebuffer(surface.device, surface.framebuffer, null);
    if (surface.render_pass != null) c.vkDestroyRenderPass(surface.device, surface.render_pass, null);
    if (surface.image_view != null) c.vkDestroyImageView(surface.device, surface.image_view, null);
    if (surface.image != null) c.vkDestroyImage(surface.device, surface.image, null);
    if (surface.image_memory != null) c.vkFreeMemory(surface.device, surface.image_memory, null);
    if (surface.fence != null) c.vkDestroyFence(surface.device, surface.fence, null);
    if (surface.descriptor_pool != null) c.vkDestroyDescriptorPool(surface.device, surface.descriptor_pool, null);
    if (surface.device != null) c.vkDestroyDevice(surface.device, null);
    if (surface.instance != null) c.vkDestroyInstance(surface.instance, null);
    std.heap.page_allocator.destroy(surface);
}

pub fn swapBuffers(surface: *VulkanSurface) void {
    if (builtin.os.tag != .linux) return;
    if (surface.swapchain != null) {
        const present_info = std.mem.zeroInit(c.VkPresentInfoKHR, .{
            .sType = c.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
            .swapchainCount = 1,
            .pSwapchains = @as([*]const c.VkSwapchainKHR, @ptrCast(&surface.swapchain)),
            .pImageIndices = @as([*]const u32, @ptrCast(&@as(u32, 0))),
        });
        _ = c.vkQueuePresentKHR(surface.graphics_queue, &present_info);
    }
}

pub fn exportSurfaceFD(surface: *VulkanSurface) i32 {
    if (builtin.os.tag != .linux) return -1;
    if (!surface.external_memory_enabled) {
        std.debug.print("[Z-GRAPHICS] exportSurfaceFD: external memory not enabled\n", .{});
        return -1;
    }
    if (surface.device == null or surface.image_memory == null) {
        std.debug.print("[Z-GRAPHICS] exportSurfaceFD: device or image_memory is null\n", .{});
        return -1;
    }
    const pfnGetMemoryFdKHR = @as(?c.PFN_vkGetMemoryFdKHR, @ptrCast(c.vkGetDeviceProcAddr(surface.device, "vkGetMemoryFdKHR")));
    if (pfnGetMemoryFdKHR) |getFd| {
        var fd: i32 = -1;
        const get_fd_info = c.VkMemoryGetFdInfoKHR{
            .sType = c.VK_STRUCTURE_TYPE_MEMORY_GET_FD_INFO_KHR,
            .pNext = null,
            .memory = surface.image_memory,
            .handleType = c.VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT,
        };
        const result = getFd(surface.device, &get_fd_info, &fd);
        if (result == c.VK_SUCCESS) {
            std.debug.print("[Z-GRAPHICS] exportSurfaceFD: exported fd={d}\n", .{fd});
            return fd;
        } else {
            std.debug.print("[Z-GRAPHICS] exportSurfaceFD: vkGetMemoryFdKHR failed result={d}\n", .{result});
        }
    } else {
        std.debug.print("[Z-GRAPHICS] exportSurfaceFD: vkGetMemoryFdKHR not found\n", .{});
    }
    return -1;
}

pub const VulkanBuffer = struct { buffer: c.VkBuffer, memory: c.VkDeviceMemory, size: usize };
pub fn createBuffer(surface: *VulkanSurface, size: usize, buffer_type: u32) ?*VulkanBuffer {
    const usage_flags = blk: {
        var flags: u32 = 0;
        if (buffer_type == @intFromEnum(zgraphics.BufferType.Vertex)) flags |= c.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | c.VK_BUFFER_USAGE_TRANSFER_DST_BIT;
        if (buffer_type == @intFromEnum(zgraphics.BufferType.Index)) flags |= c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT | c.VK_BUFFER_USAGE_TRANSFER_DST_BIT;
        if (buffer_type == @intFromEnum(zgraphics.BufferType.Uniform)) flags |= c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
        break :blk flags;
    };

    const buffer_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = @as(u64, size),
        .usage = usage_flags,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
    });

    var buffer: c.VkBuffer = null;
    if (c.vkCreateBuffer(surface.device, &buffer_info, null, &buffer) != c.VK_SUCCESS) return null;

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(surface.device, buffer, &mem_reqs);

    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_reqs.size,
        .memoryTypeIndex = undefined,
    });

    const props = c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    var found: ?u32 = null;
    for (0..32) |i| {
        if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0) {
            var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
            c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
            if ((mem_props.memoryTypes[i].propertyFlags & props) == props) {
                found = @intCast(i);
                break;
            }
        }
    }
    if (found == null) {
        for (0..32) |i| {
            if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0) {
                var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
                c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
                if ((mem_props.memoryTypes[i].propertyFlags & c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) != 0) {
                    found = @intCast(i);
                    break;
                }
            }
        }
    }
    if (found == null) {
        for (0..32) |i| {
            if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0) {
                var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
                c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
                if ((mem_props.memoryTypes[i].propertyFlags & c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) != 0) {
                    found = @intCast(i);
                    break;
                }
            }
        }
    }
    alloc_info.memoryTypeIndex = found orelse {
        c.vkDestroyBuffer(surface.device, buffer, null);
        return null;
    };

    var memory: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(surface.device, &alloc_info, null, &memory) != c.VK_SUCCESS) {
        c.vkDestroyBuffer(surface.device, buffer, null);
        return null;
    }
    if (c.vkBindBufferMemory(surface.device, buffer, memory, 0) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyBuffer(surface.device, buffer, null);
        return null;
    }

    const buf = std.heap.page_allocator.create(VulkanBuffer) catch return null;
    buf.* = .{ .buffer = buffer, .memory = memory, .size = size };
    return buf;
}
pub fn destroyBuffer(surface: *VulkanSurface, buffer: *VulkanBuffer) void {
    if (buffer.buffer != null) c.vkDestroyBuffer(surface.device, buffer.buffer, null);
    if (buffer.memory != null) c.vkFreeMemory(surface.device, buffer.memory, null);
    std.heap.page_allocator.destroy(buffer);
}

pub const VulkanCommandBuffer = struct { cmd: c.VkCommandBuffer, pool: c.VkCommandPool, surface: *VulkanSurface, render_pass_began: bool };
pub fn beginCommandBuffer(surface: *VulkanSurface) ?*VulkanCommandBuffer {
    if (builtin.os.tag != .linux) return null;
    const pool_info = std.mem.zeroInit(c.VkCommandPoolCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO, .queueFamilyIndex = surface.queue_family });
    var pool: c.VkCommandPool = null;
    if (c.vkCreateCommandPool(surface.device, &pool_info, null, &pool) != c.VK_SUCCESS) return null;
    const alloc_info = std.mem.zeroInit(c.VkCommandBufferAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = pool, .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY, .commandBufferCount = 1 });
    var cmd: c.VkCommandBuffer = null;
    if (c.vkAllocateCommandBuffers(surface.device, &alloc_info, @ptrCast(&cmd)) != c.VK_SUCCESS) {
        c.vkDestroyCommandPool(surface.device, pool, null);
        return null;
    }
    
    if (!surface.external_memory_enabled and surface.swapchain != null) {
        _ = c.vkAcquireNextImageKHR(surface.device, surface.swapchain, std.math.maxInt(u64), surface.image_available_semaphore, null, &surface.image_index);
    }
    
    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 0 });
    if (c.vkBeginCommandBuffer(cmd, &begin_info) != c.VK_SUCCESS) {
        c.vkDestroyCommandPool(surface.device, pool, null);
        return null;
    }
    const vulkan_cmd = std.heap.page_allocator.create(VulkanCommandBuffer) catch return null;
    vulkan_cmd.* = .{ .cmd = cmd, .pool = pool, .surface = surface, .render_pass_began = false };
    return vulkan_cmd;
}

pub fn cmdClearColor(cmd: *VulkanCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .linux) return;
    if (cmd.render_pass_began) return;
    const surface = cmd.surface;
    const clear_value: c.VkClearValue = .{ .color = .{ .float32 = .{ r, g, b, a } } };
    
    var fb = surface.framebuffer;
    if (!surface.external_memory_enabled and surface.swapchain != null) {
        fb = surface.swapchain_framebuffers[surface.image_index];
    }
    
    const begin_info = std.mem.zeroInit(c.VkRenderPassBeginInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        .renderPass = surface.render_pass,
        .framebuffer = fb,
        .renderArea = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } },
        .clearValueCount = 1,
        .pClearValues = @as([*]const c.VkClearValue, @ptrCast(&clear_value)),
    });
    c.vkCmdBeginRenderPass(cmd.cmd, &begin_info, c.VK_SUBPASS_CONTENTS_INLINE);
    cmd.render_pass_began = true;
}

pub fn submitCommandBuffer(surface: *VulkanSurface, cmd: *VulkanCommandBuffer) void {
    if (builtin.os.tag != .linux) return;
    if (cmd.render_pass_began) c.vkCmdEndRenderPass(cmd.cmd);
    _ = c.vkEndCommandBuffer(cmd.cmd);
    
    var submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&cmd.cmd)) });
    const wait_stage: u32 = c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
    var wait_semaphore = surface.image_available_semaphore;
    var signal_semaphore = surface.render_finished_semaphore;
    if (!surface.external_memory_enabled and surface.swapchain != null) {
        submit_info.waitSemaphoreCount = 1;
        submit_info.pWaitSemaphores = @as(?*const anyopaque, @ptrCast(&wait_semaphore));
        submit_info.pWaitDstStageMask = @as(*const u32, &wait_stage);
        submit_info.signalSemaphoreCount = 1;
        submit_info.pSignalSemaphores = @as(?*const anyopaque, @ptrCast(&signal_semaphore));
    }
    
    _ = c.vkQueueSubmit(surface.graphics_queue, 1, @as([*]const c.VkSubmitInfo, @ptrCast(&submit_info)), surface.fence);
    _ = c.vkWaitForFences(surface.device, 1, @as([*]const c.VkFence, @ptrCast(&surface.fence)), c.VK_TRUE, std.math.maxInt(u64));
    _ = c.vkResetFences(surface.device, 1, @as([*]const c.VkFence, @ptrCast(&surface.fence)));
    if (cmd.pool != null) c.vkDestroyCommandPool(surface.device, cmd.pool, null);
    std.heap.page_allocator.destroy(cmd);
}

pub const VulkanPipeline = struct { pipeline: c.VkPipeline, layout: c.VkPipelineLayout, descriptor_set_layout: c.VkDescriptorSetLayout };
fn createShaderModule(device: c.VkDevice, code: []const u8) ?c.VkShaderModule {
    const aligned_count = (code.len + 3) / 4;
    const aligned_code = std.heap.page_allocator.alloc(u32, aligned_count) catch return null;
    defer std.heap.page_allocator.free(aligned_code);
    @memcpy(std.mem.sliceAsBytes(aligned_code)[0..code.len], code);

    const info = c.VkShaderModuleCreateInfo{
        .sType = 16, // VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
        .pNext = null, .flags = 0, .codeSize = code.len, .pCode = aligned_code.ptr,
    };
    var module: c.VkShaderModule = null;
    if (c.vkCreateShaderModule(device, &info, null, &module) != c.VK_SUCCESS) return null;
    return module;
}

pub fn createPipeline(surface: *VulkanSurface, desc: *const @import("lib.zig").PipelineDesc) ?*VulkanPipeline {
    if (builtin.os.tag != .linux) return null;
    const vert_code = desc.vertex_shader.?[0..desc.vertex_shader_len];
    const frag_code = desc.pixel_shader.?[0..desc.pixel_shader_len];
    const vert_module = createShaderModule(surface.device, vert_code) orelse {
        std.debug.print("[Z-GRAPHICS] createPipeline: failed to create vert_module\n", .{});
        return null;
    };
    const frag_module = createShaderModule(surface.device, frag_code) orelse {
        std.debug.print("[Z-GRAPHICS] createPipeline: failed to create frag_module\n", .{});
        return null;
    };
    defer c.vkDestroyShaderModule(surface.device, vert_module, null);
    defer c.vkDestroyShaderModule(surface.device, frag_module, null);

    const shader_stages = [_]c.VkPipelineShaderStageCreateInfo{
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_VERTEX_BIT, .module = vert_module, .pName = "VSMain" },
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_FRAGMENT_BIT, .module = frag_module, .pName = "PSMain" },
    };

    const vb_desc = c.VkVertexInputBindingDescription{
        .binding = 0,
        .stride = 4 * @sizeOf(f32),
        .inputRate = c.VK_VERTEX_INPUT_RATE_VERTEX,
    };
    const va_desc = [_]c.VkVertexInputAttributeDescription{
        .{ .location = 0, .binding = 0, .format = c.VK_FORMAT_R32G32_SFLOAT, .offset = 0 },
        .{ .location = 1, .binding = 0, .format = c.VK_FORMAT_R32G32_SFLOAT, .offset = 2 * @sizeOf(f32) },
    };
    var vertex_input_info: c.VkPipelineVertexInputStateCreateInfo = undefined;
    vertex_input_info.sType = 19;
    vertex_input_info.pNext = null;
    vertex_input_info.flags = 0;
    vertex_input_info.vertexBindingDescriptionCount = 1;
    vertex_input_info.vertexAttributeDescriptionCount = 2;
    vertex_input_info.pVertexBindingDescriptions = &vb_desc;
    vertex_input_info.pVertexAttributeDescriptions = &va_desc;

    const input_assembly = std.mem.zeroInit(c.VkPipelineInputAssemblyStateCreateInfo, .{ .sType = 20, .topology = c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, .primitiveRestartEnable = 0 });
    const viewport = c.VkViewport{ .x = 0, .y = 0, .width = @floatFromInt(surface.width), .height = @floatFromInt(surface.height), .minDepth = 0, .maxDepth = 1 };
    const scissor = c.VkRect2D{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } };
    const viewport_state = std.mem.zeroInit(c.VkPipelineViewportStateCreateInfo, .{ .sType = 22, .viewportCount = 1, .pViewports = @as([*]const c.VkViewport, @ptrCast(&viewport)), .scissorCount = 1, .pScissors = @as([*]const c.VkRect2D, @ptrCast(&scissor)) });
    const rasterizer = std.mem.zeroInit(c.VkPipelineRasterizationStateCreateInfo, .{ .sType = 23, .depthClampEnable = 0, .rasterizerDiscardEnable = 0, .polygonMode = c.VK_POLYGON_MODE_FILL, .lineWidth = 1, .cullMode = c.VK_CULL_MODE_NONE, .frontFace = c.VK_FRONT_FACE_CLOCKWISE, .depthBiasEnable = 0 });
    const multisampling = std.mem.zeroInit(c.VkPipelineMultisampleStateCreateInfo, .{ .sType = 24, .sampleShadingEnable = 0, .rasterizationSamples = c.VK_SAMPLE_COUNT_1_BIT });
    const color_blend_attachment = std.mem.zeroInit(c.VkPipelineColorBlendAttachmentState, .{ .colorWriteMask = 0xF, .blendEnable = 0 });
    const color_blending = std.mem.zeroInit(c.VkPipelineColorBlendStateCreateInfo, .{ .sType = 26, .logicOpEnable = 0, .attachmentCount = 1, .pAttachments = @as([*]const c.VkPipelineColorBlendAttachmentState, @ptrCast(&color_blend_attachment)) });

    const pipeline_layout_info = std.mem.zeroInit(c.VkPipelineLayoutCreateInfo, .{
        .sType = 30,
        .setLayoutCount = 0,
        .pSetLayouts = null,
    });
    var pipeline_layout: c.VkPipelineLayout = null;
    if (c.vkCreatePipelineLayout(surface.device, &pipeline_layout_info, null, &pipeline_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipeline: vkCreatePipelineLayout failed\n", .{});
        return null;
    }

    const pipeline_info = c.VkGraphicsPipelineCreateInfo{
        .sType = 28, // VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
        .pNext = null, .flags = 0, .stageCount = 2, .pStages = @as([*]const c.VkPipelineShaderStageCreateInfo, @ptrCast(&shader_stages)),
        .pVertexInputState = &vertex_input_info, .pInputAssemblyState = &input_assembly,
        .pViewportState = &viewport_state, .pRasterizationState = &rasterizer,
        .pMultisampleState = &multisampling, .pColorBlendState = &color_blending,
        .layout = pipeline_layout, .renderPass = surface.render_pass, .subpass = 0,
    };
    var graphics_pipeline: c.VkPipeline = null;
    if (c.vkCreateGraphicsPipelines(surface.device, null, 1, @as([*]const c.VkGraphicsPipelineCreateInfo, @ptrCast(&pipeline_info)), null, &graphics_pipeline) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipeline: vkCreateGraphicsPipelines failed\n", .{});
        return null;
    }

    const vulkan_pipeline = std.heap.page_allocator.create(VulkanPipeline) catch return null;
    vulkan_pipeline.* = .{ .pipeline = graphics_pipeline, .layout = pipeline_layout, .descriptor_set_layout = null };
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

pub fn cmdBindVertexBuffer(cmd: *VulkanCommandBuffer, buffer: *VulkanBuffer, offset: u64) void {
    if (builtin.os.tag != .linux) return;
    c.vkCmdBindVertexBuffers(cmd.cmd, 0, 1, @as([*]const c.VkBuffer, @ptrCast(&buffer.buffer)), @as([*]const u64, @ptrCast(&offset)));
}

pub fn cmdDraw(cmd: *VulkanCommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag != .linux) return;
    c.vkCmdDraw(cmd.cmd, vertex_count, instance_count, first_vertex, first_instance);
}

pub fn uploadBuffer(surface: *VulkanSurface, buffer: *VulkanBuffer, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag != .linux) return false;
    if (data == null or dataLen == 0) return false;

    const staging_size = dataLen;
    const staging_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = staging_size,
        .usage = c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
    });

    var staging: c.VkBuffer = null;
    if (c.vkCreateBuffer(surface.device, &staging_info, null, &staging) != c.VK_SUCCESS) return false;

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(surface.device, staging, &mem_reqs);

    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_reqs.size,
        .memoryTypeIndex = undefined,
    });

    const props = c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    var found: ?u32 = null;
    for (0..32) |i| {
        if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0) {
            var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
            c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
            if ((mem_props.memoryTypes[i].propertyFlags & props) == props) {
                found = @intCast(i);
                break;
            }
        }
    }
    alloc_info.memoryTypeIndex = found orelse {
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    };

    var staging_mem: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(surface.device, &alloc_info, null, &staging_mem) != c.VK_SUCCESS) {
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }
    if (c.vkBindBufferMemory(surface.device, staging, staging_mem, 0) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    var data_ptr: ?*anyopaque = null;
    if (c.vkMapMemory(surface.device, staging_mem, 0, staging_size, 0, @ptrCast(&data_ptr)) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    @memcpy(@as([*]u8, @ptrCast(@alignCast(data_ptr)))[0..dataLen], @as([*]const u8, @ptrCast(@alignCast(data)))[0..dataLen]);

    const mapped_range = std.mem.zeroInit(c.VkMappedMemoryRange, .{
        .sType = c.VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE,
        .memory = staging_mem,
        .offset = 0,
        .size = staging_size,
    });
    _ = c.vkFlushMappedMemoryRanges(surface.device, 1, @as([*]const c.VkMappedMemoryRange, @ptrCast(&mapped_range)));
    c.vkUnmapMemory(surface.device, staging_mem);

    const copy_region = std.mem.zeroInit(c.VkBufferCopy, .{
        .srcOffset = 0,
        .dstOffset = 0,
        .size = staging_size,
    });

    const cmd_pool_info = std.mem.zeroInit(c.VkCommandPoolCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO, .queueFamilyIndex = surface.queue_family });
    var copy_pool: c.VkCommandPool = null;
    if (c.vkCreateCommandPool(surface.device, &cmd_pool_info, null, &copy_pool) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    const alloc_info2 = std.mem.zeroInit(c.VkCommandBufferAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = copy_pool, .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY, .commandBufferCount = 1 });
    var copy_cmd: c.VkCommandBuffer = null;
    if (c.vkAllocateCommandBuffers(surface.device, &alloc_info2, @ptrCast(&copy_cmd)) != c.VK_SUCCESS) {
        c.vkDestroyCommandPool(surface.device, copy_pool, null);
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 0 });
    _ = c.vkBeginCommandBuffer(copy_cmd, &begin_info);
    c.vkCmdCopyBuffer(copy_cmd, staging, buffer.buffer, 1, @as([*]const c.VkBufferCopy, @ptrCast(&copy_region)));
    _ = c.vkEndCommandBuffer(copy_cmd);

    const submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&copy_cmd)) });
    _ = c.vkQueueSubmit(surface.graphics_queue, 1, @as([*]const c.VkSubmitInfo, @ptrCast(&submit_info)), surface.fence);
    _ = c.vkWaitForFences(surface.device, 1, @as([*]const c.VkFence, @ptrCast(&surface.fence)), c.VK_TRUE, std.math.maxInt(u64));
    _ = c.vkResetFences(surface.device, 1, @as([*]const c.VkFence, @ptrCast(&surface.fence)));
    c.vkFreeMemory(surface.device, staging_mem, null);
    c.vkDestroyBuffer(surface.device, staging, null);

    return true;
}

pub fn uploadTexture(surface: *VulkanSurface, texture: *VulkanTexture, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag != .linux) return false;
    if (data == null or dataLen == 0) return false;

    const staging_size = dataLen;
    const staging_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = staging_size,
        .usage = c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
    });

    var staging: c.VkBuffer = null;
    if (c.vkCreateBuffer(surface.device, &staging_info, null, &staging) != c.VK_SUCCESS) return false;

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(surface.device, staging, &mem_reqs);

    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_reqs.size,
        .memoryTypeIndex = 0,
    });

    const props = c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    var found: ?u32 = null;
    var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
    c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
    for (0..mem_props.memoryTypeCount) |i| {
        if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0) {
            if ((mem_props.memoryTypes[i].propertyFlags & props) == props) {
                found = @intCast(i);
                break;
            }
        }
    }
    alloc_info.memoryTypeIndex = found orelse {
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    };

    var staging_mem: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(surface.device, &alloc_info, null, &staging_mem) != c.VK_SUCCESS) {
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }
    _ = c.vkBindBufferMemory(surface.device, staging, staging_mem, 0);

    var data_ptr: ?*anyopaque = null;
    if (c.vkMapMemory(surface.device, staging_mem, 0, staging_size, 0, &data_ptr) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }
    @memcpy(@as([*]u8, @ptrCast(@alignCast(data_ptr)))[0..dataLen], @as([*]const u8, @ptrCast(@alignCast(data)))[0..dataLen]);
    c.vkUnmapMemory(surface.device, staging_mem);

    const cmd_pool_info = std.mem.zeroInit(c.VkCommandPoolCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO, .queueFamilyIndex = surface.queue_family });
    var copy_pool: c.VkCommandPool = null;
    if (c.vkCreateCommandPool(surface.device, &cmd_pool_info, null, &copy_pool) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    const alloc_info2 = std.mem.zeroInit(c.VkCommandBufferAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = copy_pool, .level = 0, .commandBufferCount = 1 });
    var copy_cmd: c.VkCommandBuffer = null;
    if (c.vkAllocateCommandBuffers(surface.device, &alloc_info2, @ptrCast(&copy_cmd)) != c.VK_SUCCESS) {
        c.vkDestroyCommandPool(surface.device, copy_pool, null);
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 1 }); // VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    _ = c.vkBeginCommandBuffer(copy_cmd, &begin_info);

    var barrier = std.mem.zeroInit(c.VkImageMemoryBarrier, .{
        .sType = 45,
        .oldLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
        .srcAccessMask = 0,
        .dstAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT,
        .image = texture.image,
        .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
    });

    c.vkCmdPipelineBarrier(copy_cmd, c.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    const region = std.mem.zeroInit(c.VkBufferImageCopy, .{
        .imageSubresource = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT },
        .imageExtent = .{ .width = texture.width, .height = texture.height, .depth = 1 },
    });

    c.vkCmdCopyBufferToImage(copy_cmd, staging, texture.image, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, @ptrCast(&region));

    barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
    barrier.newLayout = c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
    barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT;
    barrier.dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT;

    c.vkCmdPipelineBarrier(copy_cmd, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    _ = c.vkEndCommandBuffer(copy_cmd);

    const submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&copy_cmd)) });
    _ = c.vkQueueSubmit(surface.graphics_queue, 1, @ptrCast(&submit_info), surface.fence);
    _ = c.vkWaitForFences(surface.device, 1, @ptrCast(&surface.fence), c.VK_TRUE, std.math.maxInt(u64));
    _ = c.vkResetFences(surface.device, 1, @ptrCast(&surface.fence));

    c.vkDestroyCommandPool(surface.device, copy_pool, null);
    c.vkFreeMemory(surface.device, staging_mem, null);
    c.vkDestroyBuffer(surface.device, staging, null);

    return true;
}

pub fn getBufferSize(buffer: *VulkanBuffer) usize {
    return buffer.size;
}

pub const VulkanTexture = struct { image: c.VkImage, memory: c.VkDeviceMemory, view: c.VkImageView, width: u32, height: u32, sampler: c.VkSampler, descriptor_set: c.VkDescriptorSet };

pub fn createTexture(surface: *VulkanSurface, desc: *const zgraphics.ZawraGraphicsTextureDesc) ?*VulkanTexture {
    if (builtin.os.tag != .linux) return null;
    _ = desc.external_handle;
    const image_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .imageType = c.VK_IMAGE_TYPE_2D,
        .extent = .{ .width = desc.width, .height = desc.height, .depth = 1 },
        .mipLevels = 1,
        .arrayLayers = 1,
        .format = c.VK_FORMAT_R8G8B8A8_UNORM,
        .tiling = c.VK_IMAGE_TILING_OPTIMAL,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .usage = c.VK_IMAGE_USAGE_TRANSFER_SRC_BIT | c.VK_IMAGE_USAGE_TRANSFER_DST_BIT | c.VK_IMAGE_USAGE_SAMPLED_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
    });

    var image: c.VkImage = null;
    if (c.vkCreateImage(surface.device, &image_info, null, &image) != c.VK_SUCCESS) return null;

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetImageMemoryRequirements(surface.device, image, &mem_reqs);

    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_reqs.size,
        .memoryTypeIndex = undefined,
    });

    const props = c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT;
    var found: ?u32 = null;
    for (0..32) |i| {
        if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0) {
            var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
            c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
            if ((mem_props.memoryTypes[i].propertyFlags & props) == props) {
                found = @intCast(i);
                break;
            }
        }
    }
    alloc_info.memoryTypeIndex = found orelse {
        c.vkDestroyImage(surface.device, image, null);
        return null;
    };

    var memory: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(surface.device, &alloc_info, null, &memory) != c.VK_SUCCESS or c.vkBindImageMemory(surface.device, image, memory, 0) != c.VK_SUCCESS) {
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        .image = image,
        .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
        .format = c.VK_FORMAT_R8G8B8A8_UNORM,
        .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
    });

    var view: c.VkImageView = null;
    if (c.vkCreateImageView(surface.device, &view_info, null, &view) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const sampler_info = std.mem.zeroInit(c.VkSamplerCreateInfo, .{
        .sType = 31, // VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO
        .magFilter = 1, // VK_FILTER_LINEAR
        .minFilter = 1, // VK_FILTER_LINEAR
        .addressModeU = 2, // VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE
        .addressModeV = 2,
        .addressModeW = 2,
        .anisotropyEnable = 0,
        .unnormalizedCoordinates = 0,
    });
    var sampler: c.VkSampler = null;
    if (c.vkCreateSampler(surface.device, &sampler_info, null, &sampler) != c.VK_SUCCESS) {
        c.vkDestroyImageView(surface.device, view, null);
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const tex = std.heap.page_allocator.create(VulkanTexture) catch return null;
    tex.* = .{ .image = image, .memory = memory, .view = view, .width = desc.width, .height = desc.height, .sampler = sampler, .descriptor_set = null };
    return tex;
}

pub fn destroyTexture(surface: *VulkanSurface, texture: *VulkanTexture) void {
    if (texture.sampler != null) c.vkDestroySampler(surface.device, texture.sampler, null);
    if (texture.view != null) c.vkDestroyImageView(surface.device, texture.view, null);
    if (texture.memory != null) c.vkFreeMemory(surface.device, texture.memory, null);
    if (texture.image != null) c.vkDestroyImage(surface.device, texture.image, null);
    std.heap.page_allocator.destroy(texture);
}
