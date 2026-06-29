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
    pub const VK_STRUCTURE_TYPE_IMPORT_MEMORY_FD_INFO_KHR = 1000074001;
    pub const VK_STRUCTURE_TYPE_MEMORY_FD_PROPERTIES_KHR = 1000074003;
    pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_DMA_BUF_BIT_EXT = 512;

    pub const VK_API_VERSION_1_0 = (1 << 22) | (0 << 12) | 0;
    pub fn VK_MAKE_VERSION(major: u32, minor: u32, patch: u32) u32 {
        return (major << 22) | (minor << 12) | patch;
    }

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

    pub const VkPhysicalDeviceLimits = extern struct {
        maxImageDimension1D: u32,
        maxImageDimension2D: u32,
        maxImageDimension3D: u32,
        maxImageArrayLayers: u32,
        maxTexelBufferElements: u32,
        maxUniformBufferRange: u32,
        maxStorageBufferRange: u32,
        maxPushConstantsSize: u32,
        maxMemoryAllocationCount: u32,
        maxSamplerAllocationCount: u32,
        bufferImageGranularity: u64,
        sparseAddressSpaceSize: u64,
        maxBoundDescriptorSets: u32,
        maxPerStageDescriptorSamplers: u32,
        maxPerStageDescriptorUniformBuffers: u32,
        maxPerStageDescriptorStorageBuffers: u32,
        maxPerStageDescriptorSampledImages: u32,
        maxPerStageDescriptorStorageImages: u32,
        maxPerStageDescriptorInputAttachments: u32,
        maxPerStageResources: u32,
        maxDescriptorSetSamplers: u32,
        maxDescriptorSetUniformBuffers: u32,
        maxDescriptorSetUniformBuffersDynamic: u32,
        maxDescriptorSetStorageBuffers: u32,
        maxDescriptorSetStorageBuffersDynamic: u32,
        maxDescriptorSetSampledImages: u32,
        maxDescriptorSetStorageImages: u32,
        maxDescriptorSetInputAttachments: u32,
        maxVertexInputAttributes: u32,
        maxVertexInputBindings: u32,
        maxVertexInputAttributeOffset: u32,
        maxVertexInputBindingStride: u32,
        maxVertexOutputComponents: u32,
        maxTessellationGenerationLevel: u32,
        maxTessellationPatchSize: u32,
        maxTessellationControlPerVertexInputComponents: u32,
        maxTessellationControlPerVertexOutputComponents: u32,
        maxTessellationControlPerPatchOutputComponents: u32,
        maxTessellationControlTotalOutputComponents: u32,
        maxTessellationEvaluationInputComponents: u32,
        maxTessellationEvaluationOutputComponents: u32,
        maxGeometryShaderInvocations: u32,
        maxGeometryInputComponents: u32,
        maxGeometryOutputComponents: u32,
        maxGeometryOutputVertices: u32,
        maxGeometryTotalOutputComponents: u32,
        maxFragmentInputComponents: u32,
        maxFragmentOutputAttachments: u32,
        maxFragmentDataSrcBlendAttachments: u32,
        maxFragmentDataDstBlendAttachments: u32,
        maxFragmentDualSrcAttachments: u32,
        maxFragmentCombinedInputOutputComponents: u32,
        maxComputeWorkGroupCount: [3]u32,
        maxComputeWorkGroupSize: [3]u32,
        maxComputeWorkGroupInvocations: u32,
        maxComputeFixedWorkGroupSize: [3]u32,
        subPixelPrecisionBits: u32,
        subTexelPrecisionBits: u32,
        mipmapPrecisionBits: u32,
        maxDrawIndexedIndexValue: u32,
        maxDrawIndirectCount: u32,
        maxSamplerLodBias: f32,
        maxSamplerAnisotropy: f32,
        maxViewports: u32,
        maxViewportDimensions: [2]u32,
        viewportBoundsRange: [2]f32,
        viewportSubPixelBits: u32,
        minMemoryMapAlignment: u64,
        minTexelBufferOffsetAlignment: u64,
        minUniformBufferOffsetAlignment: u64,
        minStorageBufferOffsetAlignment: u64,
        minTexelOffset: i32,
        maxTexelOffset: u32,
        minTexelGatherOffset: i32,
        maxTexelGatherOffset: u32,
        minInterpolationOffset: f32,
        maxInterpolationOffset: f32,
        subPixelOffsetFractionalBits: u32,
        maxFramebufferWidth: u32,
        maxFramebufferHeight: u32,
        maxFramebufferLayers: u32,
        framebufferColorSampleCounts: u32,
        framebufferDepthSampleCounts: u32,
        framebufferStencilSampleCounts: u32,
        framebufferNoAttachmentsSampleCounts: u32,
        maxColorAttachments: u32,
        sampledImageColorSampleCounts: u32,
        sampledImageIntegerSampleCounts: u32,
        sampledImageDepthSampleCounts: u32,
        sampledImageStencilSampleCounts: u32,
        storageImageSampleCounts: u32,
        maxSampleMaskWords: u32,
        timestampComputeAndGraphics: u32,
        timestampPeriod: f32,
        maxClipDistances: u32,
        maxCullDistances: u32,
        maxCombinedClipAndCullDistances: u32,
        discreteQueuePriorities: u32,
        pointSizeRange: [2]f32,
        lineWidthRange: [2]f32,
        pointSizeGranularity: f32,
        lineWidthGranularity: f32,
        strictLines: u32,
        standardSampleLocations: u32,
        optimalBufferCopyOffsetAlignment: u64,
        optimalBufferCopyRowPitchAlignment: u64,
        nonCoherentAtomSize: u64,
    };

    pub const VkPhysicalDeviceProperties = extern struct {
        apiVersion: u32,
        driverVersion: u32,
        vendorID: u32,
        deviceID: u32,
        deviceType: u32,
        deviceName: [256]u8,
        pipelineCacheUUID: [16]u8,
        limits: VkPhysicalDeviceLimits,
        sparseProperties: extern struct {
            residencyAlignedMipSize: u32,
            residencyNonResidentStrict: u32,
            residencyStandard2DBlockShape: u32,
            residencyStandard2DMultisampleBlockShape: u32,
            residencyStandard3DBlockShape: u32,
            residencyStandard3DMultisampleBlockShape: u32,
            residencyUnsupported64bitAtomics: u32,
            residencyUnsampledResidencyNonResidentStrict: u32,
        },
    };

    pub extern "vulkan" fn vkGetPhysicalDeviceProperties(physicalDevice: VkPhysicalDevice, pProperties: *VkPhysicalDeviceProperties) callconv(.c) void;

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

    pub const VkPushConstantRange = extern struct {
        stageFlags: u32,
        offset: u32,
        size: u32,
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
        pViewports: ?[*]const VkViewport,
        scissorCount: u32,
        pScissors: ?[*]const VkRect2D,
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

    pub const VkPipelineDynamicStateCreateInfo = extern struct {
        sType: u32 = 27, // VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        dynamicStateCount: u32,
        pDynamicStates: [*]const u32,
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
    pub const VkClearAttachment = extern struct {
        aspectMask: u32,
        colorAttachment: u32,
        clearValue: VkClearValue,
    };
    pub const VkClearRect = extern struct {
        rect: VkRect2D,
        baseArrayLayer: u32,
        layerCount: u32,
    };

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

    pub const VkImportMemoryFdInfoKHR = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_IMPORT_MEMORY_FD_INFO_KHR,
        pNext: ?*const anyopaque = null,
        handleType: u32,
        fd: i32,
    };

    pub const VkMemoryFdPropertiesKHR = extern struct {
        sType: VkStructureType = VK_STRUCTURE_TYPE_MEMORY_FD_PROPERTIES_KHR,
        pNext: ?*const anyopaque = null,
        memoryTypeBits: u32,
        fd: i32,
    };

    pub const PFN_vkCreateXlibSurfaceKHR = *const fn (VkInstance, *const VkXlibSurfaceCreateInfoKHR, ?*const anyopaque, *VkSurfaceKHR) callconv(.c) VkResult;
    pub const PFN_vkGetMemoryFdKHR = *const fn (VkDevice, ?*const anyopaque, *i32) callconv(.c) VkResult;
    pub const PFN_vkImportMemoryFdKHR = *const fn (VkDevice, *const VkImportMemoryFdInfoKHR, *VkDeviceMemory) callconv(.c) VkResult;
    pub const PFN_vkGetMemoryFdPropertiesKHR = *const fn (VkDevice, u32, i32, *VkMemoryFdPropertiesKHR) callconv(.c) VkResult;

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
    pub extern "vulkan" fn vkCmdSetViewport(commandBuffer: VkCommandBuffer, firstViewport: u32, viewportCount: u32, pViewports: [*]const VkViewport) callconv(.c) void;
    pub extern "vulkan" fn vkCmdSetScissor(commandBuffer: VkCommandBuffer, firstScissor: u32, scissorCount: u32, pScissors: [*]const VkRect2D) callconv(.c) void;
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
    pub extern "vulkan" fn vkCmdCopyImageToBuffer(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: u32, dstBuffer: VkBuffer, regionCount: u32, pRegions: [*]const VkBufferImageCopy) callconv(.c) void;
    pub extern "vulkan" fn vkCmdCopyImage(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: u32, dstImage: VkImage, dstImageLayout: u32, regionCount: u32, pRegions: [*]const VkImageCopy) callconv(.c) void;
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
    pub extern "vulkan" fn vkResetCommandPool(device: VkDevice, commandPool: VkCommandPool, flags: u32) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCreateDescriptorSetLayout(device: VkDevice, pCreateInfo: *const VkDescriptorSetLayoutCreateInfo, pAllocator: ?*const anyopaque, pSetLayout: *VkDescriptorSetLayout) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyDescriptorSetLayout(device: VkDevice, descriptorSetLayout: VkDescriptorSetLayout, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCreateDescriptorPool(device: VkDevice, pCreateInfo: *const VkDescriptorPoolCreateInfo, pAllocator: ?*const anyopaque, pDescriptorPool: *VkDescriptorPool) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyDescriptorPool(device: VkDevice, descriptorPool: VkDescriptorPool, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkAllocateDescriptorSets(device: VkDevice, pAllocateInfo: *const VkDescriptorSetAllocateInfo, pDescriptorSets: *VkDescriptorSet) callconv(.c) VkResult;
    pub extern "vulkan" fn vkFreeDescriptorSets(device: VkDevice, descriptorPool: VkDescriptorPool, descriptorSetCount: u32, pDescriptorSets: [*]const VkDescriptorSet) callconv(.c) VkResult;
    pub extern "vulkan" fn vkUpdateDescriptorSets(device: VkDevice, descriptorWriteCount: u32, pDescriptorWrites: [*]const VkWriteDescriptorSet, descriptorCopyCount: u32, pDescriptorCopies: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCmdBindDescriptorSets(commandBuffer: VkCommandBuffer, pipelineBindPoint: u32, layout: VkPipelineLayout, firstSet: u32, descriptorSetCount: u32, pDescriptorSets: [*]const VkDescriptorSet, dynamicOffsetCount: u32, pDynamicOffsets: ?[*]const u32) callconv(.c) void;
    pub extern "vulkan" fn vkCmdPushConstants(commandBuffer: VkCommandBuffer, layout: VkPipelineLayout, stageFlags: u32, offset: u32, size: u32, pValues: ?*const anyopaque) callconv(.c) void;
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
    pub const VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL = 6;
    pub const VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL = 7;
    pub const VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL = 5;
    pub const VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT = 16;
    pub const VK_IMAGE_USAGE_TRANSFER_SRC_BIT = 1;
    pub const VK_IMAGE_USAGE_TRANSFER_DST_BIT = 2;
    pub const VK_IMAGE_USAGE_SAMPLED_BIT = 1 << 2;
    pub const VK_IMAGE_ASPECT_COLOR_BIT = 1;
    pub const VK_IMAGE_ASPECT_PLANE_0_BIT = 0x00000010;
    pub const VK_IMAGE_ASPECT_PLANE_1_BIT = 0x00000020;
    pub const VK_IMAGE_ASPECT_PLANE_2_BIT = 0x00000040;

    pub const VK_FORMAT_B8G8R8A8_UNORM = 44;
    pub const VK_COLOR_SPACE_SRGB_NONLINEAR_KHR = 0;
    pub const VK_PRESENT_MODE_FIFO_KHR = 2;
    pub const VK_PRESENT_MODE_IMMEDIATE_KHR = 0;
    pub const VK_PRESENT_MODE_MAILBOX_KHR = 1;
    pub const VK_PRESENT_MODE_FIFO_RELAXED_KHR = 3;

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

    pub const VK_ACCESS_TRANSFER_READ_BIT = 8192;
    pub const VK_ACCESS_TRANSFER_WRITE_BIT = 4096;
    pub const VK_ACCESS_SHADER_READ_BIT = 32;
    pub const VK_PIPELINE_STAGE_TRANSFER_BIT = 4096;
    pub const VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT = 128;
    pub const VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT = 1;
    pub const VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT = 0x2000;
    pub const VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT = 1024;

    pub const VkBufferImageCopy = extern struct {
        bufferOffset: u64 = 0,
        bufferRowLength: u32 = 0,
        bufferImageHeight: u32 = 0,
        imageSubresource: VkImageSubresourceLayers,
        imageOffset: extern struct { x: i32 = 0, y: i32 = 0, z: i32 = 0 } = .{ .x = 0, .y = 0, .z = 0 },
        imageExtent: extern struct { width: u32, height: u32, depth: u32 } = .{ .width = 0, .height = 0, .depth = 0 },
    };

    pub const VkImageCopy = extern struct {
        srcSubresource: VkImageSubresourceLayers,
        srcOffset: extern struct { x: i32 = 0, y: i32 = 0, z: i32 = 0 },
        dstSubresource: VkImageSubresourceLayers,
        dstOffset: extern struct { x: i32 = 0, y: i32 = 0, z: i32 = 0 },
        extent: extern struct { width: u32, height: u32, depth: u32 },
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
    pub const VK_IMAGE_LAYOUT_PRESENT_SRC_KHR = 1000001002;
    pub const VK_IMAGE_LAYOUT_GENERAL = 1;
    pub const VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE = 2;
    pub const VK_DESCRIPTOR_TYPE_SAMPLER = 3;
    pub const VK_QUEUE_FAMILY_IGNORED = 4294967295;
    pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO = 37;
    pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO = 34;
    pub const VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET = 35;
    pub const VK_SHARING_MODE_EXCLUSIVE = 0;
    pub const VK_SAMPLE_COUNT_1_BIT = 1;
    pub const VK_SAMPLE_COUNT_2_BIT = 2;
    pub const VK_SAMPLE_COUNT_4_BIT = 4;
    pub const VK_SAMPLE_COUNT_8_BIT = 8;
    pub const VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT = 0x20;
    pub const VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT = 0x40;
    pub const VK_IMAGE_ASPECT_DEPTH_BIT = 0x2;
    pub const VK_FORMAT_D32_SFLOAT = 126;
    pub const VK_FORMAT_D24_UNORM_S8_UINT = 129;
    pub const VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT = 0x10;
    pub const VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL = 3;
    pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES2 = 1000087001;
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
    pub const VK_BUFFER_USAGE_TRANSFER_SRC_BIT = 1 << 0;
    pub const VK_BUFFER_USAGE_TRANSFER_DST_BIT = 1 << 1;
    pub const VK_BUFFER_USAGE_VERTEX_BUFFER_BIT = 1 << 7;
    pub const VK_BUFFER_USAGE_INDEX_BUFFER_BIT = 1 << 6;
    pub const VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT = 1 << 4;
    pub const VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT = 1 << 0;
    pub const VK_MEMORY_PROPERTY_HOST_COHERENT_BIT = 1 << 1;
    pub const VK_SUBPASS_CONTENTS_INLINE = 0;
    pub const VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT = 1 << 17;
    pub const VK_FORMAT_R32G32_SFLOAT = 101;
    pub const VK_VERTEX_INPUT_RATE_VERTEX = 0;
    pub const VK_VERTEX_INPUT_RATE_INSTANCE = 1;

    pub const VkSamplerYcbcrConversion = ?*anyopaque;

    pub const VkComponentMapping = extern struct {
        r: u32,
        g: u32,
        b: u32,
        a: u32,
    };

    pub const VkSamplerYcbcrConversionCreateInfo = extern struct {
        sType: VkStructureType,
        pNext: ?*const anyopaque,
        format: VkFormat,
        ycbcrModel: u32,
        ycbcrRange: u32,
        components: VkComponentMapping,
        xChromaOffset: u32,
        yChromaOffset: u32,
        chromaFilter: u32,
        forceExplicitReconstruction: u32,
    };

    pub const VkSamplerYcbcrConversionInfo = extern struct {
        sType: VkStructureType,
        pNext: ?*const anyopaque,
        conversion: VkSamplerYcbcrConversion,
    };

    pub const PFN_vkCreateSamplerYcbcrConversion = *const fn (VkDevice, *const VkSamplerYcbcrConversionCreateInfo, ?*const anyopaque, *VkSamplerYcbcrConversion) callconv(.c) VkResult;
    pub const PFN_vkDestroySamplerYcbcrConversion = *const fn (VkDevice, VkSamplerYcbcrConversion, ?*const anyopaque) callconv(.c) void;

    pub const VK_FORMAT_G8B8_R8_3PLANE_420_UNORM = 1000156000;
    pub const VK_FORMAT_G8_B8R8_2PLANE_420_UNORM = 1000156001;
    pub const VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16 = 1000156008;
    pub const VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_CREATE_INFO = 1000156000;
    pub const VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_INFO = 1000156001;
    pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_709 = 1;
    pub const VK_SAMPLER_YCBCR_RANGE_ITU_NARROW = 2;
    pub const VK_COMPONENT_SWIZZLE_IDENTITY = 0;
    pub const VK_CHROMA_LOCATION_COSITED_EVEN = 0;

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

    pub const VK_SHADER_STAGE_COMPUTE_BIT = 0x20;
    pub const VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER = 6;
    pub const VK_DESCRIPTOR_TYPE_STORAGE_BUFFER = 7;
    pub const VK_DESCRIPTOR_TYPE_STORAGE_IMAGE = 3;
    pub const VK_BUFFER_USAGE_STORAGE_BUFFER_BIT = 1 << 5;
    pub const VK_PIPELINE_BIND_POINT_COMPUTE = 1;
    pub const VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO = 29;
    pub const VK_ACCESS_SHADER_WRITE_BIT = 0x40;
    pub const VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT = 0x200;

    pub const VkComputePipelineCreateInfo = extern struct {
        sType: VkStructureType = 29,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        stage: VkPipelineShaderStageCreateInfo,
        layout: VkPipelineLayout,
        basePipelineHandle: VkPipeline = null,
        basePipelineIndex: i32 = -1,
    };

    pub const VkDescriptorBufferInfo = extern struct {
        buffer: VkBuffer,
        offset: u64 = 0,
        range: u64,
    };

    pub extern "vulkan" fn vkCreateComputePipelines(
        device: VkDevice,
        pipelineCache: VkPipeline,
        createInfoCount: u32,
        pCreateInfos: [*]const VkComputePipelineCreateInfo,
        pAllocator: ?*const anyopaque,
        pPipelines: [*]VkPipeline,
    ) callconv(.c) VkResult;

    pub extern "vulkan" fn vkCmdDispatch(
        commandBuffer: VkCommandBuffer,
        groupCountX: u32,
        groupCountY: u32,
        groupCountZ: u32,
    ) callconv(.c) void;

    pub const VK_QUERY_TYPE_TIMESTAMP = 0;
    pub const VK_PIPELINE_STAGE_TIMESTAMP_BIT = 0x10000;
    pub const VK_QUERY_RESULT_64_BIT = 0x1;
    pub const VK_QUERY_RESULT_WAIT_BIT = 0x2;
    pub const VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO = 42;

    pub const VkQueryPool = ?*anyopaque;

    pub const VkQueryPoolCreateInfo = extern struct {
        sType: VkStructureType = 42,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        queryType: u32,
        queryCount: u32,
        pipelineStatistics: u32 = 0,
    };

    pub extern "vulkan" fn vkCreateQueryPool(device: VkDevice, pCreateInfo: *const VkQueryPoolCreateInfo, pAllocator: ?*const anyopaque, pQueryPool: *VkQueryPool) callconv(.c) VkResult;
    pub extern "vulkan" fn vkDestroyQueryPool(device: VkDevice, queryPool: VkQueryPool, pAllocator: ?*const anyopaque) callconv(.c) void;
    pub extern "vulkan" fn vkCmdResetQueryPool(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32) callconv(.c) void;
    pub extern "vulkan" fn vkCmdWriteTimestamp(commandBuffer: VkCommandBuffer, pipelineStage: u32, queryPool: VkQueryPool, query: u32) callconv(.c) void;
    pub extern "vulkan" fn vkGetQueryPoolResults(device: VkDevice, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32, dataSize: usize, pData: ?*anyopaque, stride: u32, flags: u32) callconv(.c) VkResult;
    pub extern "vulkan" fn vkCmdCopyQueryPoolResults(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32, dstBuffer: VkBuffer, dstOffset: u64, stride: u32, flags: u32) callconv(.c) void;
    pub extern "vulkan" fn vkQueueWaitIdle(queue: VkQueue) callconv(.c) VkResult;

    pub const VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT = 0x100;
    pub const VK_STENCIL_OP_KEEP = 0;
    pub const VK_STENCIL_OP_ZERO = 1;
    pub const VK_STENCIL_OP_REPLACE = 2;
    pub const VK_STENCIL_OP_INCREMENT_AND_CLAMP = 3;
    pub const VK_STENCIL_OP_DECREMENT_AND_CLAMP = 4;
    pub const VK_STENCIL_OP_INVERT = 5;
    pub const VK_STENCIL_OP_INCREMENT_AND_WRAP = 6;
    pub const VK_STENCIL_OP_DECREMENT_AND_WRAP = 7;
    pub const VK_COMPARE_OP_NEVER = 0;
    pub const VK_COMPARE_OP_LESS = 1;
    pub const VK_COMPARE_OP_EQUAL = 2;
    pub const VK_COMPARE_OP_LESS_OR_EQUAL = 3;
    pub const VK_COMPARE_OP_GREATER = 4;
    pub const VK_COMPARE_OP_NOT_EQUAL = 5;
    pub const VK_COMPARE_OP_GREATER_OR_EQUAL = 6;
    pub const VK_COMPARE_OP_ALWAYS = 7;
    pub const VK_IMAGE_ASPECT_STENCIL_BIT = 0x4;
    pub const VK_FORMAT_D32_SFLOAT_S8_UINT = 130;
    pub const VK_DYNAMIC_STATE_VIEWPORT = 0;
    pub const VK_DYNAMIC_STATE_SCISSOR = 1;
    pub const VK_DYNAMIC_STATE_STENCIL_REFERENCE = 8;
    pub const VK_STENCIL_FACE_FRONT_AND_BACK = 0x3;
    pub const VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO = 25;

    pub const VkStencilOpState = extern struct {
        failOp: u32,
        passOp: u32,
        depthFailOp: u32,
        compareOp: u32,
        compareMask: u32,
        writeMask: u32,
        reference: u32,
    };

    pub const VkPipelineDepthStencilStateCreateInfo = extern struct {
        sType: VkStructureType = 25,
        pNext: ?*const anyopaque = null,
        flags: u32 = 0,
        depthTestEnable: u32,
        depthWriteEnable: u32,
        depthCompareOp: u32,
        depthBoundsTestEnable: u32,
        stencilTestEnable: u32,
        front: VkStencilOpState,
        back: VkStencilOpState,
        minDepthBounds: f32,
        maxDepthBounds: f32,
    };

    pub extern "vulkan" fn vkCmdSetStencilReference(commandBuffer: VkCommandBuffer, faceMask: u32, reference: u32) callconv(.c) void;
};

pub const VK_STENCIL_FACE_FRONT_AND_BACK = c.VK_STENCIL_FACE_FRONT_AND_BACK;

pub const VertexBinding = extern struct {
    binding: u32,
    stride: u32,
    input_rate: u32,
};

pub const VertexAttribute = extern struct {
    location: u32,
    binding: u32,
    format: u32,
    offset: u32,
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
    ycbcr_enabled: bool,
    window: ?*anyopaque, // X11 Window
    x_display: ?*Display, // X11 Display
    width: u32,
    height: u32,
    present_mode: u32 = 2, // VK_PRESENT_MODE_FIFO_KHR default
    descriptor_pool: c.VkDescriptorPool = null,
    descriptor_set_layout: c.VkDescriptorSetLayout = null,
    render_pool: c.VkCommandPool = null,
    render_cmd: c.VkCommandBuffer = null,
    transfer_pool: c.VkCommandPool = null,
    transfer_cmd: c.VkCommandBuffer = null,
    current_cmd: VulkanCommandBuffer = undefined,
    msaa_samples: u32 = 1,
    msaa_color_image: c.VkImage = null,
    msaa_color_memory: c.VkDeviceMemory = null,
    msaa_color_view: c.VkImageView = null,
    msaa_depth_image: c.VkImage = null,
    msaa_depth_memory: c.VkDeviceMemory = null,
    msaa_depth_view: c.VkImageView = null,
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

fn getMaxMSAASamples(physical_device: c.VkPhysicalDevice) u32 {
    var props: c.VkPhysicalDeviceProperties = std.mem.zeroes(c.VkPhysicalDeviceProperties);
    c.vkGetPhysicalDeviceProperties(physical_device, &props);
    const color_counts = props.limits.framebufferColorSampleCounts;
    if (color_counts & c.VK_SAMPLE_COUNT_4_BIT != 0) return 4;
    if (color_counts & c.VK_SAMPLE_COUNT_2_BIT != 0) return 2;
    return 1;
}

pub fn getDeviceProperty(handle: *VulkanSurface, name: u32) u32 {
    if (name == 0) { // MAX_TEXTURE_SIZE
        var props: c.VkPhysicalDeviceProperties = std.mem.zeroes(c.VkPhysicalDeviceProperties);
        c.vkGetPhysicalDeviceProperties(handle.physical_device, &props);
        return props.limits.maxImageDimension2D;
    }
    if (name == 1) return 1; // NPOT_SUPPORT
    if (name == 2) return 1; // UNPACK_SUBIMAGE_SUPPORT
    return 0;
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
            const fallback_extensions = [_][*:0]const u8{
                "VK_KHR_surface",
                "VK_KHR_xlib_surface",
            };
            const fallback_create_info = c.VkInstanceCreateInfo{
                .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
                .pApplicationInfo = &app_info,
                .enabledLayerCount = 0,
                .ppEnabledLayerNames = null,
                .enabledExtensionCount = fallback_extensions.len,
                .ppEnabledExtensionNames = @ptrCast(&fallback_extensions),
            };
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

        const max_msaa = getMaxMSAASamples(physical_device);
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createSurface: max MSAA samples={}\n", .{max_msaa});

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
            "VK_KHR_sampler_ycbcr_conversion",
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
        var ycbcr_enabled = true;
        if (c.vkCreateDevice(physical_device, &device_create_info, null, &device) != c.VK_SUCCESS) {
            external_memory_enabled = false;
            ycbcr_enabled = false;
            if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createSurface: full extension set failed, trying swapchain + ycbcr fallback\n", .{});
            const ycbcr_extensions = [_][*:0]const u8{
                "VK_KHR_swapchain",
                "VK_KHR_sampler_ycbcr_conversion",
            };
            const ycbcr_create_info = std.mem.zeroInit(c.VkDeviceCreateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
                .queueCreateInfoCount = 1,
                .pQueueCreateInfos = @as([*]const c.VkDeviceQueueCreateInfo, @ptrCast(&queue_create_info)),
                .pEnabledFeatures = &device_features,
                .enabledExtensionCount = ycbcr_extensions.len,
                .ppEnabledExtensionNames = @as([*]const [*:0]const u8, @ptrCast(&ycbcr_extensions)),
            });
            if (c.vkCreateDevice(physical_device, &ycbcr_create_info, null, &device) == c.VK_SUCCESS) {
                ycbcr_enabled = true;
            } else {
                if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createSurface: ycbcr fallback failed, trying no extensions\n", .{});
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
        }
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createSurface: external_memory={}, ycbcr={}\n", .{ external_memory_enabled, ycbcr_enabled });

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

        var swapchain_format: c.VkFormat = c.VK_FORMAT_B8G8R8A8_UNORM;

        var render_pass_format: c.VkFormat = c.VK_FORMAT_R8G8B8A8_UNORM;
        var render_pass_final_layout: u32 = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
        if (!external_memory_enabled and window != null) {
            var format_count_pre: u32 = 0;
            _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count_pre, null);
            var surface_formats_pre: [16]c.VkSurfaceFormatKHR = undefined;
            if (format_count_pre > 16) format_count_pre = 16;
            _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count_pre, &surface_formats_pre);
            for (0..format_count_pre) |i| {
                if (surface_formats_pre[i].format == c.VK_FORMAT_B8G8R8A8_UNORM) {
                    swapchain_format = c.VK_FORMAT_B8G8R8A8_UNORM;
                    break;
                }
            }
            render_pass_format = swapchain_format;
            render_pass_final_layout = c.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
        }

        var surface_msaa_samples: u32 = if (window != null) max_msaa else 1;

        var msaa_color_image: c.VkImage = null;
        var msaa_color_memory: c.VkDeviceMemory = null;
        var msaa_color_view: c.VkImageView = null;
        var msaa_depth_image: c.VkImage = null;
        var msaa_depth_memory: c.VkDeviceMemory = null;
        var msaa_depth_view: c.VkImageView = null;

        if (surface_msaa_samples > 1) {
            {
                const msaa_color_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
                    .imageType = c.VK_IMAGE_TYPE_2D,
                    .format = render_pass_format,
                    .extent = .{ .width = width, .height = height, .depth = 1 },
                    .mipLevels = 1,
                    .arrayLayers = 1,
                    .samples = surface_msaa_samples,
                    .tiling = c.VK_IMAGE_TILING_OPTIMAL,
                    .usage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT,
                    .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
                    .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
                });
                if (c.vkCreateImage(device, &msaa_color_info, null, &msaa_color_image) != c.VK_SUCCESS) {
                    surface_msaa_samples = 1;
                }
            }
            if (msaa_color_image != null) {
                var mem_reqs: c.VkMemoryRequirements = undefined;
                c.vkGetImageMemoryRequirements(device, msaa_color_image, &mem_reqs);
                const alloc_idx = findMemoryType(physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT | c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse
                    findMemoryType(physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse 0;
                const msaa_alloc = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
                    .allocationSize = mem_reqs.size,
                    .memoryTypeIndex = alloc_idx,
                });
                if (c.vkAllocateMemory(device, &msaa_alloc, null, &msaa_color_memory) == c.VK_SUCCESS) {
                    _ = c.vkBindImageMemory(device, msaa_color_image, msaa_color_memory, 0);
                }
                const msaa_view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
                    .image = msaa_color_image,
                    .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
                    .format = render_pass_format,
                    .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
                });
                _ = c.vkCreateImageView(device, &msaa_view_info, null, &msaa_color_view);
            }
            {
                const msaa_depth_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
                    .imageType = c.VK_IMAGE_TYPE_2D,
                    .format = c.VK_FORMAT_D32_SFLOAT,
                    .extent = .{ .width = width, .height = height, .depth = 1 },
                    .mipLevels = 1,
                    .arrayLayers = 1,
                    .samples = surface_msaa_samples,
                    .tiling = c.VK_IMAGE_TILING_OPTIMAL,
                    .usage = c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT,
                    .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
                    .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
                });
                if (c.vkCreateImage(device, &msaa_depth_info, null, &msaa_depth_image) == c.VK_SUCCESS) {
                    var mem_reqs: c.VkMemoryRequirements = undefined;
                    c.vkGetImageMemoryRequirements(device, msaa_depth_image, &mem_reqs);
                    const alloc_idx = findMemoryType(physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT | c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse
                        findMemoryType(physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse 0;
                    const msaa_alloc = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
                        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
                        .allocationSize = mem_reqs.size,
                        .memoryTypeIndex = alloc_idx,
                    });
                    if (c.vkAllocateMemory(device, &msaa_alloc, null, &msaa_depth_memory) == c.VK_SUCCESS) {
                        _ = c.vkBindImageMemory(device, msaa_depth_image, msaa_depth_memory, 0);
                    }
                    const depth_view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
                        .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
                        .image = msaa_depth_image,
                        .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
                        .format = c.VK_FORMAT_D32_SFLOAT,
                        .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_DEPTH_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
                    });
                    _ = c.vkCreateImageView(device, &depth_view_info, null, &msaa_depth_view);
                }
            }
            if (msaa_color_view == null) {
                surface_msaa_samples = 1;
            }
            if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createSurface: MSAA samples={}, color_view={any}, depth_view={any}\n", .{ surface_msaa_samples, msaa_color_view, msaa_depth_view });
        }

        var render_attachments: [3]c.VkAttachmentDescription = undefined;
        var render_attachment_count: u32 = undefined;
        var subpass: c.VkSubpassDescription = undefined;
        var color_attachment_ref: c.VkAttachmentReference = undefined;
        var depth_attachment_ref: c.VkAttachmentReference = undefined;
        var resolve_attachment_ref: c.VkAttachmentReference = undefined;

        if (surface_msaa_samples > 1) {
            render_attachment_count = 3;
            render_attachments[0] = std.mem.zeroInit(c.VkAttachmentDescription, .{
                .format = render_pass_format,
                .samples = surface_msaa_samples,
                .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
                .storeOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
                .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
                .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
                .finalLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
            });
            render_attachments[1] = std.mem.zeroInit(c.VkAttachmentDescription, .{
                .format = render_pass_format,
                .samples = 1,
                .loadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,
                .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
                .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
                .finalLayout = render_pass_final_layout,
            });
            render_attachments[2] = std.mem.zeroInit(c.VkAttachmentDescription, .{
                .format = c.VK_FORMAT_D32_SFLOAT,
                .samples = surface_msaa_samples,
                .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
                .storeOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
                .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
                .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
                .finalLayout = c.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
            });

            color_attachment_ref = .{ .attachment = 0, .layout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL };
            resolve_attachment_ref = .{ .attachment = 1, .layout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL };
            depth_attachment_ref = .{ .attachment = 2, .layout = c.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL };
            subpass = std.mem.zeroInit(c.VkSubpassDescription, .{
                .pipelineBindPoint = c.VK_PIPELINE_BIND_POINT_GRAPHICS,
                .colorAttachmentCount = 1,
                .pColorAttachments = @as([*]const c.VkAttachmentReference, @ptrCast(&color_attachment_ref)),
                .pResolveAttachments = @as(?*const c.VkAttachmentReference, @ptrCast(&resolve_attachment_ref)),
                .pDepthStencilAttachment = @as(?*const c.VkAttachmentReference, @ptrCast(&depth_attachment_ref)),
            });
        } else {
            render_attachment_count = 1;
            render_attachments[0] = std.mem.zeroInit(c.VkAttachmentDescription, .{
                .format = render_pass_format,
                .samples = 1,
                .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
                .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,
                .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
                .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
                .finalLayout = render_pass_final_layout,
            });
            color_attachment_ref = .{ .attachment = 0, .layout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL };
            subpass = std.mem.zeroInit(c.VkSubpassDescription, .{
                .pipelineBindPoint = c.VK_PIPELINE_BIND_POINT_GRAPHICS,
                .colorAttachmentCount = 1,
                .pColorAttachments = @as([*]const c.VkAttachmentReference, @ptrCast(&color_attachment_ref)),
            });
        }

        const render_pass_info = std.mem.zeroInit(c.VkRenderPassCreateInfo, .{
            .sType = 38,
            .attachmentCount = render_attachment_count,
            .pAttachments = @as([*]const c.VkAttachmentDescription, @ptrCast(&render_attachments)),
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

        var offscreen_attachments: [3]c.VkImageView = undefined;
        var offscreen_attachment_count: u32 = undefined;
        if (surface_msaa_samples > 1) {
            offscreen_attachments[0] = msaa_color_view;
            offscreen_attachments[1] = image_view;
            offscreen_attachments[2] = msaa_depth_view;
            offscreen_attachment_count = 3;
        } else {
            offscreen_attachments[0] = image_view;
            offscreen_attachment_count = 1;
        }
        const framebuffer_info = std.mem.zeroInit(c.VkFramebufferCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
            .renderPass = render_pass,
            .attachmentCount = offscreen_attachment_count,
            .pAttachments = @as([*]const c.VkImageView, @ptrCast(&offscreen_attachments)),
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

            const swapchain_info = std.mem.zeroInit(c.VkSwapchainCreateInfoKHR, .{
                .sType = 1000001000, // VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
                .surface = surface,
                .minImageCount = if (surface_caps.minImageCount > 0) surface_caps.minImageCount else 2,
                .imageFormat = swapchain_format,
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
            .{ .type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, .descriptorCount = 100 },
            .{ .type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, .descriptorCount = 100 },
        };
        const pool_info = std.mem.zeroInit(c.VkDescriptorPoolCreateInfo, .{
            .sType = 33, // VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO
            .flags = 0x2, // VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT
            .maxSets = 100,
            .poolSizeCount = pool_sizes.len,
            .pPoolSizes = &pool_sizes,
        });
        var descriptor_pool: c.VkDescriptorPool = null;
        if (c.vkCreateDescriptorPool(device, &pool_info, null, &descriptor_pool) != c.VK_SUCCESS) {
            std.debug.print("[Z-GRAPHICS] createSurface: Warning - failed to create descriptor pool\n", .{});
        }

        var render_pool: c.VkCommandPool = null;
        var render_cmd: c.VkCommandBuffer = null;
        {
            const render_pool_info = std.mem.zeroInit(c.VkCommandPoolCreateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
                .queueFamilyIndex = graphics_family.?,
                .flags = 0x2, // VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
            });
            if (c.vkCreateCommandPool(device, &render_pool_info, null, &render_pool) == c.VK_SUCCESS) {
                const render_alloc_info = std.mem.zeroInit(c.VkCommandBufferAllocateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
                    .commandPool = render_pool,
                    .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY,
                    .commandBufferCount = 1,
                });
                _ = c.vkAllocateCommandBuffers(device, &render_alloc_info, @ptrCast(&render_cmd));
            }
        }

        var transfer_pool: c.VkCommandPool = null;
        var transfer_cmd: c.VkCommandBuffer = null;
        {
            const transfer_pool_info = std.mem.zeroInit(c.VkCommandPoolCreateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
                .queueFamilyIndex = graphics_family.?,
                .flags = 0x2, // VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
            });
            if (c.vkCreateCommandPool(device, &transfer_pool_info, null, &transfer_pool) == c.VK_SUCCESS) {
                const transfer_alloc_info = std.mem.zeroInit(c.VkCommandBufferAllocateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
                    .commandPool = transfer_pool,
                    .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY,
                    .commandBufferCount = 1,
                });
                _ = c.vkAllocateCommandBuffers(device, &transfer_alloc_info, @ptrCast(&transfer_cmd));
            }
        }

        const surface_obj = std.heap.page_allocator.create(VulkanSurface) catch {
            if (render_pool != null) c.vkDestroyCommandPool(device, render_pool, null);
            if (transfer_pool != null) c.vkDestroyCommandPool(device, transfer_pool, null);
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
                    .format = swapchain_format,
                    .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
                });
                _ = c.vkCreateImageView(device, &sc_view_info, null, &swapchain_image_views[i]);

                var sc_attachments: [3]c.VkImageView = undefined;
                var sc_attachment_count: u32 = undefined;
                if (surface_msaa_samples > 1) {
                    sc_attachments[0] = msaa_color_view;
                    sc_attachments[1] = swapchain_image_views[i];
                    sc_attachments[2] = msaa_depth_view;
                    sc_attachment_count = 3;
                } else {
                    sc_attachments[0] = swapchain_image_views[i];
                    sc_attachment_count = 1;
                }
                const fb_info = std.mem.zeroInit(c.VkFramebufferCreateInfo, .{
                    .sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
                    .renderPass = render_pass,
                    .attachmentCount = sc_attachment_count,
                    .pAttachments = @as([*]const c.VkImageView, @ptrCast(&sc_attachments)),
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
            .ycbcr_enabled = ycbcr_enabled,
            .window = window,
            .x_display = x_display,
            .width = width,
            .height = height,
            .descriptor_pool = descriptor_pool,
            .render_pool = render_pool,
            .render_cmd = render_cmd,
            .transfer_pool = transfer_pool,
            .transfer_cmd = transfer_cmd,
            .current_cmd = .{ .cmd = null, .pool = null, .surface = undefined, .render_pass_began = false },
            .msaa_samples = surface_msaa_samples,
            .msaa_color_image = msaa_color_image,
            .msaa_color_memory = msaa_color_memory,
            .msaa_color_view = msaa_color_view,
            .msaa_depth_image = msaa_depth_image,
            .msaa_depth_memory = msaa_depth_memory,
            .msaa_depth_view = msaa_depth_view,
        };
        surface_obj.current_cmd.surface = surface_obj;

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
    if (surface.msaa_depth_view != null) c.vkDestroyImageView(surface.device, surface.msaa_depth_view, null);
    if (surface.msaa_depth_image != null) c.vkDestroyImage(surface.device, surface.msaa_depth_image, null);
    if (surface.msaa_depth_memory != null) c.vkFreeMemory(surface.device, surface.msaa_depth_memory, null);
    if (surface.msaa_color_view != null) c.vkDestroyImageView(surface.device, surface.msaa_color_view, null);
    if (surface.msaa_color_image != null) c.vkDestroyImage(surface.device, surface.msaa_color_image, null);
    if (surface.msaa_color_memory != null) c.vkFreeMemory(surface.device, surface.msaa_color_memory, null);
    if (surface.x_display) |dpy| _ = XCloseDisplay(dpy);
    if (surface.framebuffer != null) c.vkDestroyFramebuffer(surface.device, surface.framebuffer, null);
    if (surface.render_pass != null) c.vkDestroyRenderPass(surface.device, surface.render_pass, null);
    if (surface.image_view != null) c.vkDestroyImageView(surface.device, surface.image_view, null);
    if (surface.image != null) c.vkDestroyImage(surface.device, surface.image, null);
    if (surface.image_memory != null) c.vkFreeMemory(surface.device, surface.image_memory, null);
    if (surface.fence != null) c.vkDestroyFence(surface.device, surface.fence, null);
    if (surface.render_pool != null) c.vkDestroyCommandPool(surface.device, surface.render_pool, null);
    if (surface.transfer_pool != null) c.vkDestroyCommandPool(surface.device, surface.transfer_pool, null);
    if (surface.descriptor_pool != null) c.vkDestroyDescriptorPool(surface.device, surface.descriptor_pool, null);
    if (surface.descriptor_set_layout != null) c.vkDestroyDescriptorSetLayout(surface.device, surface.descriptor_set_layout, null);
    if (surface.device != null) c.vkDestroyDevice(surface.device, null);
    if (surface.instance != null) c.vkDestroyInstance(surface.instance, null);
    std.heap.page_allocator.destroy(surface);
}

pub fn swapBuffers(surface: *VulkanSurface) void {
    if (builtin.os.tag != .linux) return;
    if (surface.swapchain != null) {
        const wait_semaphore = surface.render_finished_semaphore;
        var present_info = std.mem.zeroInit(c.VkPresentInfoKHR, .{
            .sType = c.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
            .swapchainCount = 1,
            .pSwapchains = @as([*]const c.VkSwapchainKHR, @ptrCast(&surface.swapchain)),
            .pImageIndices = @as([*]const u32, @ptrCast(&surface.image_index)),
        });
        if (!surface.external_memory_enabled) {
            present_info.waitSemaphoreCount = 1;
            present_info.pWaitSemaphores = @as(?*const anyopaque, @ptrCast(&wait_semaphore));
        }
        const present_result = c.vkQueuePresentKHR(surface.graphics_queue, &present_info);
        std.debug.print("[ZG-DIAG] swapBuffers: vkQueuePresentKHR={d} image_index={d}\n", .{ present_result, surface.image_index });
        if (present_result == 1000001003 or present_result == -1000001000) { // VK_SUBOPTIMAL_KHR or VK_ERROR_OUT_OF_DATE_KHR
            recreateSwapchain(surface, surface.width, surface.height);
        }
    }
}

pub fn present(surface: *VulkanSurface) void {
    swapBuffers(surface);
}

pub fn recreateSwapchain(surface: *VulkanSurface, new_width: u32, new_height: u32) void {
    if (builtin.os.tag != .linux) return;
    if (surface.device == null or surface.swapchain == null) return;

    var surface_caps: c.VkSurfaceCapabilitiesKHR = undefined;
    _ = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(surface.physical_device, surface.surface, &surface_caps);

    var width = new_width;
    var height = new_height;
    if (surface_caps.currentExtent.width != std.math.maxInt(u32)) {
        width = surface_caps.currentExtent.width;
        height = surface_caps.currentExtent.height;
    }
    width = @max(surface_caps.minImageExtent.width, @min(surface_caps.maxImageExtent.width, width));
    height = @max(surface_caps.minImageExtent.height, @min(surface_caps.maxImageExtent.height, height));

    var swapchain_format: c.VkFormat = c.VK_FORMAT_B8G8R8A8_UNORM;
    var format_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(surface.physical_device, surface.surface, &format_count, null);
    if (format_count > 0) {
        var formats: [16]c.VkSurfaceFormatKHR = undefined;
        var count: u32 = @min(format_count, @as(u32, 16));
        _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(surface.physical_device, surface.surface, &count, @ptrCast(&formats));
        for (0..count) |i| {
            if (formats[i].format == c.VK_FORMAT_B8G8R8A8_UNORM) {
                swapchain_format = c.VK_FORMAT_B8G8R8A8_UNORM;
                break;
            }
        }
    }

    const old_swapchain = surface.swapchain;
    const old_image_count = surface.image_count;

    const swapchain_info = std.mem.zeroInit(c.VkSwapchainCreateInfoKHR, .{
        .sType = 1000001000,
        .surface = surface.surface,
        .minImageCount = if (surface_caps.minImageCount > 0) surface_caps.minImageCount else 2,
        .imageFormat = swapchain_format,
        .imageColorSpace = c.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR,
        .imageExtent = .{ .width = width, .height = height },
        .imageArrayLayers = 1,
        .imageUsage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .imageSharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .preTransform = surface_caps.currentTransform,
        .compositeAlpha = 1,
        .presentMode = surface.present_mode,
        .clipped = 1,
        .oldSwapchain = old_swapchain,
    });

    var new_swapchain: c.VkSwapchainKHR = null;
    if (c.vkCreateSwapchainKHR(surface.device, &swapchain_info, null, &new_swapchain) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] recreateSwapchain: vkCreateSwapchainKHR failed\n", .{});
        return;
    }

    for (0..old_image_count) |i| {
        if (surface.swapchain_framebuffers[i] != null)
            c.vkDestroyFramebuffer(surface.device, surface.swapchain_framebuffers[i], null);
        if (surface.swapchain_image_views[i] != null)
            c.vkDestroyImageView(surface.device, surface.swapchain_image_views[i], null);
    }

    if (surface.msaa_samples > 1) {
        if (surface.msaa_color_view != null) c.vkDestroyImageView(surface.device, surface.msaa_color_view, null);
        if (surface.msaa_color_memory != null) c.vkFreeMemory(surface.device, surface.msaa_color_memory, null);
        if (surface.msaa_color_image != null) c.vkDestroyImage(surface.device, surface.msaa_color_image, null);

        if (surface.msaa_depth_view != null) c.vkDestroyImageView(surface.device, surface.msaa_depth_view, null);
        if (surface.msaa_depth_memory != null) c.vkFreeMemory(surface.device, surface.msaa_depth_memory, null);
        if (surface.msaa_depth_image != null) c.vkDestroyImage(surface.device, surface.msaa_depth_image, null);

        const msaa_color_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
            .imageType = c.VK_IMAGE_TYPE_2D,
            .format = swapchain_format,
            .extent = .{ .width = width, .height = height, .depth = 1 },
            .mipLevels = 1,
            .arrayLayers = 1,
            .samples = surface.msaa_samples,
            .tiling = c.VK_IMAGE_TILING_OPTIMAL,
            .usage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT,
            .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
            .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        });
        if (c.vkCreateImage(surface.device, &msaa_color_info, null, &surface.msaa_color_image) == c.VK_SUCCESS) {
            var mem_reqs: c.VkMemoryRequirements = undefined;
            c.vkGetImageMemoryRequirements(surface.device, surface.msaa_color_image, &mem_reqs);
            const alloc_idx = findMemoryType(surface.physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT | c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse
                findMemoryType(surface.physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse 0;
            const msaa_alloc = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
                .allocationSize = mem_reqs.size,
                .memoryTypeIndex = alloc_idx,
            });
            if (c.vkAllocateMemory(surface.device, &msaa_alloc, null, &surface.msaa_color_memory) == c.VK_SUCCESS) {
                _ = c.vkBindImageMemory(surface.device, surface.msaa_color_image, surface.msaa_color_memory, 0);
            }
            const msaa_view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
                .image = surface.msaa_color_image,
                .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
                .format = swapchain_format,
                .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
            });
            _ = c.vkCreateImageView(surface.device, &msaa_view_info, null, &surface.msaa_color_view);
        }

        const msaa_depth_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
            .imageType = c.VK_IMAGE_TYPE_2D,
            .format = c.VK_FORMAT_D32_SFLOAT,
            .extent = .{ .width = width, .height = height, .depth = 1 },
            .mipLevels = 1,
            .arrayLayers = 1,
            .samples = surface.msaa_samples,
            .tiling = c.VK_IMAGE_TILING_OPTIMAL,
            .usage = c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT,
            .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
            .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        });
        if (c.vkCreateImage(surface.device, &msaa_depth_info, null, &surface.msaa_depth_image) == c.VK_SUCCESS) {
            var mem_reqs: c.VkMemoryRequirements = undefined;
            c.vkGetImageMemoryRequirements(surface.device, surface.msaa_depth_image, &mem_reqs);
            const alloc_idx = findMemoryType(surface.physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT | c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse
                findMemoryType(surface.physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse 0;
            const msaa_alloc = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
                .allocationSize = mem_reqs.size,
                .memoryTypeIndex = alloc_idx,
            });
            if (c.vkAllocateMemory(surface.device, &msaa_alloc, null, &surface.msaa_depth_memory) == c.VK_SUCCESS) {
                _ = c.vkBindImageMemory(surface.device, surface.msaa_depth_image, surface.msaa_depth_memory, 0);
            }
            const msaa_view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
                .image = surface.msaa_depth_image,
                .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
                .format = c.VK_FORMAT_D32_SFLOAT,
                .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_DEPTH_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
            });
            _ = c.vkCreateImageView(surface.device, &msaa_view_info, null, &surface.msaa_depth_view);
        }
    }

    c.vkDestroySwapchainKHR(surface.device, old_swapchain, null);

    surface.swapchain_images = .{ null, null, null };
    surface.swapchain_image_views = .{ null, null, null };
    surface.swapchain_framebuffers = .{ null, null, null };

    var new_image_count: u32 = 0;
    _ = c.vkGetSwapchainImagesKHR(surface.device, new_swapchain, &new_image_count, null);
    if (new_image_count > 3) new_image_count = 3;

    surface.swapchain = new_swapchain;
    surface.image_count = new_image_count;
    surface.width = width;
    surface.height = height;

    _ = c.vkGetSwapchainImagesKHR(surface.device, new_swapchain, &new_image_count, @ptrCast(&surface.swapchain_images));

    for (0..new_image_count) |i| {
        const view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
            .image = surface.swapchain_images[i],
            .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
            .format = swapchain_format,
            .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
        });
        _ = c.vkCreateImageView(surface.device, &view_info, null, &surface.swapchain_image_views[i]);

        var sc_attachments: [3]c.VkImageView = undefined;
        var sc_attachment_count: u32 = undefined;
        if (surface.msaa_samples > 1) {
            sc_attachments[0] = surface.msaa_color_view;
            sc_attachments[1] = surface.swapchain_image_views[i];
            sc_attachments[2] = surface.msaa_depth_view;
            sc_attachment_count = 3;
        } else {
            sc_attachments[0] = surface.swapchain_image_views[i];
            sc_attachment_count = 1;
        }
        const fb_info = std.mem.zeroInit(c.VkFramebufferCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
            .renderPass = surface.render_pass,
            .attachmentCount = sc_attachment_count,
            .pAttachments = @as([*]const c.VkImageView, @ptrCast(&sc_attachments)),
            .width = width,
            .height = height,
            .layers = 1,
        });
        _ = c.vkCreateFramebuffer(surface.device, &fb_info, null, &surface.swapchain_framebuffers[i]);
    }

    std.debug.print("[Z-GRAPHICS] recreateSwapchain: {}x{} image_count={}\n", .{ width, height, new_image_count });
}

pub fn setPresentMode(surface: *VulkanSurface, mode: u32) void {
    if (builtin.os.tag != .linux) return;
    surface.present_mode = mode;
    recreateSwapchain(surface, surface.width, surface.height);
}

pub fn getSupportedPresentModes(surface: *VulkanSurface, modes: []u32) u32 {
    if (builtin.os.tag != .linux) return 0;
    var mode_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(surface.physical_device, surface.surface, &mode_count, null);
    if (mode_count == 0) return 0;
    var fill_count = @min(mode_count, @as(u32, @intCast(modes.len)));
    _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(surface.physical_device, surface.surface, &fill_count, @ptrCast(modes.ptr));
    return fill_count;
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

pub const LayerState = struct {
    layer_id: u32 = 0,
    x: f32 = 0,
    y: f32 = 0,
    width: f32 = 0,
    height: f32 = 0,
    opacity: f32 = 1.0,
    active: bool = false,
};

pub const LayerPushConstants = extern struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    opacity: f32,
    _pad: [3]f32 = .{ 0, 0, 0 },
};

pub const VulkanCommandBuffer = struct {
    cmd: c.VkCommandBuffer,
    pool: c.VkCommandPool,
    surface: *VulkanSurface,
    render_pass_began: bool,
    pipeline_layout: c.VkPipelineLayout = null,
    current_layer: LayerState = .{},
    current_descriptor_set: c.VkDescriptorSet = null,
    last_descriptor_set: c.VkDescriptorSet = null,
    last_bound_buffers: [16]?*VulkanBuffer = [_]?*VulkanBuffer{null} ** 16,
    last_bound_offsets: [16]u64 = [_]u64{0} ** 16,
};
pub fn beginCommandBuffer(surface: *VulkanSurface) ?*VulkanCommandBuffer {
    if (builtin.os.tag != .linux) return null;
    if (surface.render_pool == null or surface.render_cmd == null) return null;

    _ = c.vkResetCommandPool(surface.device, surface.render_pool, 0);

    if (!surface.external_memory_enabled and surface.swapchain != null) {
        var acquire_result = c.vkAcquireNextImageKHR(surface.device, surface.swapchain, std.math.maxInt(u64), surface.image_available_semaphore, null, &surface.image_index);
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] vkAcquireNextImageKHR result={} image_index={}\n", .{ acquire_result, surface.image_index });
        if (acquire_result == 1000001003 or acquire_result == -1000001000) { // VK_SUBOPTIMAL_KHR or VK_ERROR_OUT_OF_DATE_KHR
            recreateSwapchain(surface, surface.width, surface.height);
            acquire_result = c.vkAcquireNextImageKHR(surface.device, surface.swapchain, std.math.maxInt(u64), surface.image_available_semaphore, null, &surface.image_index);
            if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] vkAcquireNextImageKHR retry result={} image_index={}\n", .{ acquire_result, surface.image_index });
        }
    }

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 0 });
    if (c.vkBeginCommandBuffer(surface.render_cmd, &begin_info) != c.VK_SUCCESS) return null;

    surface.current_cmd.cmd = surface.render_cmd;
    surface.current_cmd.pool = surface.render_pool;
    surface.current_cmd.render_pass_began = false;
    surface.current_cmd.pipeline_layout = null;
    surface.current_cmd.current_descriptor_set = null;
    surface.current_cmd.last_descriptor_set = null;
    inline for (0..16) |i| {
        surface.current_cmd.last_bound_buffers[i] = null;
        surface.current_cmd.last_bound_offsets[i] = 0;
    }
    std.debug.print("[ZG-DIAG] beginCommandBuffer OK: image_index={d} cmd={any}\n", .{ surface.image_index, surface.render_cmd });
    return &surface.current_cmd;
}

pub fn cmdClearColor(cmd: *VulkanCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .linux) return;
    if (cmd.render_pass_began) return;
    const surface = cmd.surface;

    var fb = surface.framebuffer;
    if (!surface.external_memory_enabled and surface.swapchain != null) {
        fb = surface.swapchain_framebuffers[surface.image_index];
    }

    if (surface.msaa_samples > 1) {
        const clear_values = [_]c.VkClearValue{
            .{ .color = .{ .float32 = .{ r, g, b, a } } },
            .{ .color = .{ .float32 = .{ 0, 0, 0, 0 } } },
            .{ .depthStencil = .{ .depth = 1.0, .stencil = 0 } },
        };
        const begin_info = std.mem.zeroInit(c.VkRenderPassBeginInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
            .renderPass = surface.render_pass,
            .framebuffer = fb,
            .renderArea = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } },
            .clearValueCount = 3,
            .pClearValues = @as([*]const c.VkClearValue, @ptrCast(&clear_values)),
        });
        c.vkCmdBeginRenderPass(cmd.cmd, &begin_info, c.VK_SUBPASS_CONTENTS_INLINE);
    } else {
        const clear_value: c.VkClearValue = .{ .color = .{ .float32 = .{ r, g, b, a } } };
        const begin_info = std.mem.zeroInit(c.VkRenderPassBeginInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
            .renderPass = surface.render_pass,
            .framebuffer = fb,
            .renderArea = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } },
            .clearValueCount = 1,
            .pClearValues = @as([*]const c.VkClearValue, @ptrCast(&clear_value)),
        });
        c.vkCmdBeginRenderPass(cmd.cmd, &begin_info, c.VK_SUBPASS_CONTENTS_INLINE);
    }
    cmd.render_pass_began = true;

    const viewport = c.VkViewport{ .x = 0, .y = 0, .width = @floatFromInt(surface.width), .height = @floatFromInt(surface.height), .minDepth = 0, .maxDepth = 1 };
    c.vkCmdSetViewport(cmd.cmd, 0, 1, @as([*]const c.VkViewport, @ptrCast(&viewport)));
    const scissor = c.VkRect2D{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } };
    c.vkCmdSetScissor(cmd.cmd, 0, 1, @as([*]const c.VkRect2D, @ptrCast(&scissor)));
    std.debug.print("[ZG-DIAG] cmdClearColor OK: w={d} h={d} fb={any} msaa={d} clear=({d},{d},{d},{d})\n", .{ surface.width, surface.height, fb, surface.msaa_samples, r, g, b, a });
}

pub fn cmdClearAttachments(cmd: *VulkanCommandBuffer, color: bool, depth: bool, stencil: bool, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .linux) return;
    const surface = cmd.surface;
    if (!cmd.render_pass_began) {
        var fb = surface.framebuffer;
        if (!surface.external_memory_enabled and surface.swapchain != null) {
            fb = surface.swapchain_framebuffers[surface.image_index];
        }
        if (surface.msaa_samples > 1) {
            const clear_values = [_]c.VkClearValue{
                .{ .color = .{ .float32 = .{ r, g, b, a } } },
                .{ .color = .{ .float32 = .{ 0, 0, 0, 0 } } },
                .{ .depthStencil = .{ .depth = 1.0, .stencil = 0 } },
            };
            const begin_info = std.mem.zeroInit(c.VkRenderPassBeginInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
                .renderPass = surface.render_pass,
                .framebuffer = fb,
                .renderArea = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } },
                .clearValueCount = 3,
                .pClearValues = @as([*]const c.VkClearValue, @ptrCast(&clear_values)),
            });
            c.vkCmdBeginRenderPass(cmd.cmd, &begin_info, c.VK_SUBPASS_CONTENTS_INLINE);
        } else {
            const clear_value: c.VkClearValue = .{ .color = .{ .float32 = .{ r, g, b, a } } };
            const begin_info = std.mem.zeroInit(c.VkRenderPassBeginInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
                .renderPass = surface.render_pass,
                .framebuffer = fb,
                .renderArea = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } },
                .clearValueCount = 1,
                .pClearValues = @as([*]const c.VkClearValue, @ptrCast(&clear_value)),
            });
            c.vkCmdBeginRenderPass(cmd.cmd, &begin_info, c.VK_SUBPASS_CONTENTS_INLINE);
        }
        cmd.render_pass_began = true;

        const viewport = c.VkViewport{ .x = 0, .y = 0, .width = @floatFromInt(surface.width), .height = @floatFromInt(surface.height), .minDepth = 0, .maxDepth = 1 };
        c.vkCmdSetViewport(cmd.cmd, 0, 1, @as([*]const c.VkViewport, @ptrCast(&viewport)));
        const scissor = c.VkRect2D{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } };
        c.vkCmdSetScissor(cmd.cmd, 0, 1, @as([*]const c.VkRect2D, @ptrCast(&scissor)));
    }

    var attachments: [3]c.VkClearAttachment = undefined;
    var attachment_count: u32 = 0;

    if (color) {
        attachments[attachment_count] = .{
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .colorAttachment = 0,
            .clearValue = .{ .color = .{ .float32 = .{ r, g, b, a } } },
        };
        attachment_count += 1;
    }

    if (depth and stencil) {
        attachments[attachment_count] = .{
            .aspectMask = c.VK_IMAGE_ASPECT_DEPTH_BIT | c.VK_IMAGE_ASPECT_STENCIL_BIT,
            .colorAttachment = 0,
            .clearValue = .{ .depthStencil = .{ .depth = 1.0, .stencil = 0 } },
        };
        attachment_count += 1;
    } else {
        if (depth) {
            attachments[attachment_count] = .{
                .aspectMask = c.VK_IMAGE_ASPECT_DEPTH_BIT,
                .colorAttachment = 0,
                .clearValue = .{ .depthStencil = .{ .depth = 1.0, .stencil = 0 } },
            };
            attachment_count += 1;
        }
        if (stencil) {
            attachments[attachment_count] = .{
                .aspectMask = c.VK_IMAGE_ASPECT_STENCIL_BIT,
                .colorAttachment = 0,
                .clearValue = .{ .depthStencil = .{ .depth = 1.0, .stencil = 0 } },
            };
            attachment_count += 1;
        }
    }

    if (attachment_count == 0) return;

    const clear_rect = c.VkClearRect{
        .rect = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = surface.width, .height = surface.height } },
        .baseArrayLayer = 0,
        .layerCount = 1,
    };

    c.vkCmdClearAttachments(cmd.cmd, attachment_count, @as([*]const c.VkClearAttachment, @ptrCast(&attachments)), 1, @as([*]const c.VkClearRect, @ptrCast(&clear_rect)));
}

pub fn cmdSetViewport(cmd: *VulkanCommandBuffer, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
    if (builtin.os.tag != .linux) return;
    const viewport = c.VkViewport{ .x = x, .y = y, .width = width, .height = height, .minDepth = min_depth, .maxDepth = max_depth };
    c.vkCmdSetViewport(cmd.cmd, 0, 1, @as([*]const c.VkViewport, @ptrCast(&viewport)));
}

pub fn cmdSetScissor(cmd: *VulkanCommandBuffer, x: i32, y: i32, width: u32, height: u32) void {
    if (builtin.os.tag != .linux) return;
    const scissor = c.VkRect2D{ .offset = .{ .x = x, .y = y }, .extent = .{ .width = width, .height = height } };
    c.vkCmdSetScissor(cmd.cmd, 0, 1, @as([*]const c.VkRect2D, @ptrCast(&scissor)));
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

    const submit_result = c.vkQueueSubmit(surface.graphics_queue, 1, @as([*]const c.VkSubmitInfo, @ptrCast(&submit_info)), surface.fence);
    std.debug.print("[ZG-DIAG] submitCommandBuffer: vkQueueSubmit={d}\n", .{submit_result});
    _ = c.vkWaitForFences(surface.device, 1, @as([*]const c.VkFence, @ptrCast(&surface.fence)), c.VK_TRUE, std.math.maxInt(u64));
    _ = c.vkResetFences(surface.device, 1, @as([*]const c.VkFence, @ptrCast(&surface.fence)));
    std.debug.print("[ZG-DIAG] submitCommandBuffer OK: fence signaled+reset\n", .{});
}

pub const VulkanPipeline = struct { pipeline: c.VkPipeline, layout: c.VkPipelineLayout };

pub const StorageBinding = extern struct {
    binding: u32,
    descriptor_type: u32,
};

pub const VulkanComputePipeline = struct {
    pipeline: c.VkPipeline,
    layout: c.VkPipelineLayout,
    descriptor_set_layout: c.VkDescriptorSetLayout,
    descriptor_set: c.VkDescriptorSet,
    surface: *VulkanSurface,
};
fn createShaderModule(device: c.VkDevice, code: []const u8) ?c.VkShaderModule {
    const aligned_count = (code.len + 3) / 4;
    const aligned_code = std.heap.page_allocator.alloc(u32, aligned_count) catch return null;
    defer std.heap.page_allocator.free(aligned_code);
    @memcpy(std.mem.sliceAsBytes(aligned_code)[0..code.len], code);

    const info = c.VkShaderModuleCreateInfo{
        .sType = 16, // VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
        .pNext = null,
        .flags = 0,
        .codeSize = code.len,
        .pCode = aligned_code.ptr,
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
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_VERTEX_BIT, .module = vert_module, .pName = "main" },
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_FRAGMENT_BIT, .module = frag_module, .pName = "main" },
    };

    var vertex_input_info: c.VkPipelineVertexInputStateCreateInfo = undefined;
    vertex_input_info.sType = 19;
    vertex_input_info.pNext = null;
    vertex_input_info.flags = 0;
    vertex_input_info.vertexBindingDescriptionCount = 0;
    vertex_input_info.vertexAttributeDescriptionCount = 0;
    vertex_input_info.pVertexBindingDescriptions = null;
    vertex_input_info.pVertexAttributeDescriptions = null;

    const input_assembly = std.mem.zeroInit(c.VkPipelineInputAssemblyStateCreateInfo, .{ .sType = 20, .topology = c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, .primitiveRestartEnable = 0 });
    const dynamic_states = [_]u32{ c.VK_DYNAMIC_STATE_VIEWPORT, c.VK_DYNAMIC_STATE_SCISSOR };
    var dynamic_state_info = c.VkPipelineDynamicStateCreateInfo{
        .sType = 27,
        .dynamicStateCount = 2,
        .pDynamicStates = @as([*]const u32, @ptrCast(&dynamic_states)),
    };
    const viewport_state = std.mem.zeroInit(c.VkPipelineViewportStateCreateInfo, .{ .sType = 22, .viewportCount = 1, .scissorCount = 1 });
    const rasterizer = std.mem.zeroInit(c.VkPipelineRasterizationStateCreateInfo, .{ .sType = 23, .depthClampEnable = 0, .rasterizerDiscardEnable = 0, .polygonMode = c.VK_POLYGON_MODE_FILL, .lineWidth = 1, .cullMode = c.VK_CULL_MODE_NONE, .frontFace = c.VK_FRONT_FACE_CLOCKWISE, .depthBiasEnable = 0 });
    const msaa_rasterization_samples: u32 = surface.msaa_samples;
    const msaa_sample_shading_enable: u32 = if (surface.msaa_samples > 1) @as(u32, 1) else 0;
    const msaa_min_sample_shading: f32 = if (surface.msaa_samples > 1) 0.25 else 0;
    const multisampling = std.mem.zeroInit(c.VkPipelineMultisampleStateCreateInfo, .{ .sType = 24, .sampleShadingEnable = msaa_sample_shading_enable, .minSampleShading = msaa_min_sample_shading, .rasterizationSamples = msaa_rasterization_samples });
    const color_blend_attachment = std.mem.zeroInit(c.VkPipelineColorBlendAttachmentState, .{
        .colorWriteMask = 0xF,
        .blendEnable = desc.blend_enable,
        .srcColorBlendFactor = desc.src_color_blend_factor,
        .dstColorBlendFactor = desc.dst_color_blend_factor,
        .colorBlendOp = desc.color_blend_op,
        .srcAlphaBlendFactor = desc.src_alpha_blend_factor,
        .dstAlphaBlendFactor = desc.dst_alpha_blend_factor,
        .alphaBlendOp = desc.alpha_blend_op,
    });
    const color_blending = std.mem.zeroInit(c.VkPipelineColorBlendStateCreateInfo, .{ .sType = 26, .logicOpEnable = 0, .attachmentCount = 1, .pAttachments = @as([*]const c.VkPipelineColorBlendAttachmentState, @ptrCast(&color_blend_attachment)) });

    const descriptor_set_layout_bindings = [_]c.VkDescriptorSetLayoutBinding{
        .{
            .binding = 0,
            .descriptorType = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            .descriptorCount = 1,
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        },
        .{
            .binding = 1,
            .descriptorType = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            .descriptorCount = 1,
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        },
    };
    const descriptor_set_layout_info = c.VkDescriptorSetLayoutCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .bindingCount = descriptor_set_layout_bindings.len,
        .pBindings = @as([*]const c.VkDescriptorSetLayoutBinding, @ptrCast(&descriptor_set_layout_bindings)),
    };
    var descriptor_set_layout: c.VkDescriptorSetLayout = null;
    if (c.vkCreateDescriptorSetLayout(surface.device, &descriptor_set_layout_info, null, &descriptor_set_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipeline: vkCreateDescriptorSetLayout failed\n", .{});
        return null;
    }

    const layer_push_constant_range = c.VkPushConstantRange{
        .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        .offset = 0,
        .size = @sizeOf(LayerPushConstants),
    };

    const pipeline_layout_info = c.VkPipelineLayoutCreateInfo{
        .sType = 30,
        .pNext = null,
        .flags = 0,
        .setLayoutCount = 1,
        .pSetLayouts = @as(?*const anyopaque, @ptrCast(&descriptor_set_layout)),
        .pushConstantRangeCount = 1,
        .pPushConstantRanges = @as(?*const anyopaque, @ptrCast(&layer_push_constant_range)),
    };
    surface.descriptor_set_layout = descriptor_set_layout;

    var pipeline_layout: c.VkPipelineLayout = null;

    if (c.vkCreatePipelineLayout(surface.device, &pipeline_layout_info, null, &pipeline_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipeline: vkCreatePipelineLayout failed\n", .{});
        return null;
    }

    const pipeline_info = c.VkGraphicsPipelineCreateInfo{
        .sType = 28, // VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
        .pNext = null,
        .flags = 0,
        .stageCount = 2,
        .pStages = @as([*]const c.VkPipelineShaderStageCreateInfo, @ptrCast(&shader_stages)),
        .pVertexInputState = &vertex_input_info,
        .pInputAssemblyState = &input_assembly,
        .pViewportState = &viewport_state,
        .pRasterizationState = &rasterizer,
        .pMultisampleState = &multisampling,
        .pColorBlendState = &color_blending,
        .pDynamicState = &dynamic_state_info,
        .layout = pipeline_layout,
        .renderPass = surface.render_pass,
        .subpass = 0,
    };
    var graphics_pipeline: c.VkPipeline = null;
    if (c.vkCreateGraphicsPipelines(surface.device, null, 1, @as([*]const c.VkGraphicsPipelineCreateInfo, @ptrCast(&pipeline_info)), null, &graphics_pipeline) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipeline: vkCreateGraphicsPipelines failed\n", .{});
        return null;
    }

    const vulkan_pipeline = std.heap.page_allocator.create(VulkanPipeline) catch return null;
    vulkan_pipeline.* = .{ .pipeline = graphics_pipeline, .layout = pipeline_layout };
    std.debug.print("[ZG-DIAG] createPipeline OK: pipeline={any} layout={any} msaa={d} dyn_states=2\n", .{ graphics_pipeline, pipeline_layout, surface.msaa_samples });
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
    cmd.pipeline_layout = pipeline.layout;
    std.debug.print("[ZG-DIAG] cmdBindPipeline OK: pipeline={any} layout={any}\n", .{ pipeline.pipeline, pipeline.layout });
}

pub fn createComputePipeline(
    surface: *VulkanSurface,
    comp_module: c.VkShaderModule,
    storage_bindings: []const StorageBinding,
) ?*VulkanComputePipeline {
    if (builtin.os.tag != .linux) return null;

    var vk_bindings: [16]c.VkDescriptorSetLayoutBinding = undefined;
    const binding_count = @min(storage_bindings.len, @as(usize, 16));
    for (storage_bindings[0..binding_count], 0..) |sb, i| {
        vk_bindings[i] = .{
            .binding = sb.binding,
            .descriptorType = sb.descriptor_type,
            .descriptorCount = 1,
            .stageFlags = c.VK_SHADER_STAGE_COMPUTE_BIT,
        };
    }

    const descriptor_set_layout_info = c.VkDescriptorSetLayoutCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .bindingCount = @intCast(binding_count),
        .pBindings = @as([*]const c.VkDescriptorSetLayoutBinding, @ptrCast(&vk_bindings)),
    };
    var descriptor_set_layout: c.VkDescriptorSetLayout = null;
    if (c.vkCreateDescriptorSetLayout(surface.device, &descriptor_set_layout_info, null, &descriptor_set_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createComputePipeline: vkCreateDescriptorSetLayout failed\n", .{});
        return null;
    }

    const pipeline_layout_info = c.VkPipelineLayoutCreateInfo{
        .sType = 30,
        .pNext = null,
        .flags = 0,
        .setLayoutCount = 1,
        .pSetLayouts = @as(?*const anyopaque, @ptrCast(&descriptor_set_layout)),
        .pushConstantRangeCount = 0,
        .pPushConstantRanges = null,
    };
    var pipeline_layout: c.VkPipelineLayout = null;
    if (c.vkCreatePipelineLayout(surface.device, &pipeline_layout_info, null, &pipeline_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createComputePipeline: vkCreatePipelineLayout failed\n", .{});
        c.vkDestroyDescriptorSetLayout(surface.device, descriptor_set_layout, null);
        return null;
    }

    const stage_info = c.VkPipelineShaderStageCreateInfo{
        .sType = 18,
        .pNext = null,
        .flags = 0,
        .stage = c.VK_SHADER_STAGE_COMPUTE_BIT,
        .module = comp_module,
        .pName = "main",
    };

    const compute_info = c.VkComputePipelineCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .stage = stage_info,
        .layout = pipeline_layout,
    };

    var compute_pipeline: c.VkPipeline = null;
    if (c.vkCreateComputePipelines(surface.device, null, 1, @as([*]const c.VkComputePipelineCreateInfo, @ptrCast(&compute_info)), null, @ptrCast(&compute_pipeline)) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createComputePipeline: vkCreateComputePipelines failed\n", .{});
        c.vkDestroyPipelineLayout(surface.device, pipeline_layout, null);
        c.vkDestroyDescriptorSetLayout(surface.device, descriptor_set_layout, null);
        return null;
    }

    var descriptor_set: c.VkDescriptorSet = null;
    const alloc_info = c.VkDescriptorSetAllocateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .pNext = null,
        .descriptorPool = surface.descriptor_pool,
        .descriptorSetCount = 1,
        .pSetLayouts = @as([*]const c.VkDescriptorSetLayout, @ptrCast(&descriptor_set_layout)),
    };
    _ = c.vkAllocateDescriptorSets(surface.device, &alloc_info, &descriptor_set);

    const pipeline = std.heap.page_allocator.create(VulkanComputePipeline) catch {
        c.vkDestroyPipeline(surface.device, compute_pipeline, null);
        c.vkDestroyPipelineLayout(surface.device, pipeline_layout, null);
        c.vkDestroyDescriptorSetLayout(surface.device, descriptor_set_layout, null);
        return null;
    };
    pipeline.* = .{
        .pipeline = compute_pipeline,
        .layout = pipeline_layout,
        .descriptor_set_layout = descriptor_set_layout,
        .descriptor_set = descriptor_set,
        .surface = surface,
    };
    return pipeline;
}

pub fn destroyComputePipeline(surface: *VulkanSurface, pipeline: *VulkanComputePipeline) void {
    if (builtin.os.tag != .linux) return;
    if (pipeline.pipeline != null) c.vkDestroyPipeline(surface.device, pipeline.pipeline, null);
    if (pipeline.layout != null) c.vkDestroyPipelineLayout(surface.device, pipeline.layout, null);
    if (pipeline.descriptor_set_layout != null) c.vkDestroyDescriptorSetLayout(surface.device, pipeline.descriptor_set_layout, null);
    std.heap.page_allocator.destroy(pipeline);
}

pub fn cmdBindComputePipeline(cmd: *VulkanCommandBuffer, pipeline: *VulkanComputePipeline) void {
    if (builtin.os.tag != .linux) return;
    c.vkCmdBindPipeline(cmd.cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, pipeline.pipeline);
    if (pipeline.descriptor_set != null) {
        const sets = [_]c.VkDescriptorSet{pipeline.descriptor_set};
        c.vkCmdBindDescriptorSets(cmd.cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, pipeline.layout, 0, 1, @as([*]const c.VkDescriptorSet, @ptrCast(&sets)), 0, null);
    }
}

pub fn cmdDispatch(cmd: *VulkanCommandBuffer, x: u32, y: u32, z: u32) void {
    if (builtin.os.tag != .linux) return;
    c.vkCmdDispatch(cmd.cmd, x, y, z);
}

pub fn createStorageBuffer(surface: *VulkanSurface, size: u32) ?*VulkanBuffer {
    if (builtin.os.tag != .linux) return null;

    const buffer_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = @as(u64, size),
        .usage = c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT | c.VK_BUFFER_USAGE_TRANSFER_DST_BIT,
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

pub fn bindStorageBuffer(cmd: *VulkanCommandBuffer, pipeline: *VulkanComputePipeline, buffer: *VulkanBuffer, binding: u32) void {
    if (builtin.os.tag != .linux) return;
    if (pipeline.descriptor_set == null) return;

    const buffer_info = c.VkDescriptorBufferInfo{
        .buffer = buffer.buffer,
        .offset = 0,
        .range = buffer.size,
    };
    const write_info = c.VkWriteDescriptorSet{
        .sType = c.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
        .pNext = null,
        .dstSet = pipeline.descriptor_set,
        .dstBinding = binding,
        .dstArrayElement = 0,
        .descriptorCount = 1,
        .descriptorType = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
        .pImageInfo = null,
        .pBufferInfo = @as(?*const anyopaque, @ptrCast(&buffer_info)),
        .pTexelBufferView = null,
    };
    c.vkUpdateDescriptorSets(pipeline.surface.device, 1, @as([*]const c.VkWriteDescriptorSet, @ptrCast(&write_info)), 0, null);

    const sets = [_]c.VkDescriptorSet{pipeline.descriptor_set};
    c.vkCmdBindDescriptorSets(cmd.cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, pipeline.layout, 0, 1, @as([*]const c.VkDescriptorSet, @ptrCast(&sets)), 0, null);
}

pub fn cmdBindTexture(cmd: *VulkanCommandBuffer, texture: *VulkanTexture, binding: u32) void {
    if (builtin.os.tag != .linux) return;
    if (cmd.pipeline_layout == null) {
        std.debug.print("[ZG-DIAG] cmdBindTexture SKIPPED: pipeline_layout is null!\n", .{});
        return;
    }
    cmd.current_descriptor_set = texture.descriptor_set;
    const sets = [_]c.VkDescriptorSet{texture.descriptor_set};
    std.debug.print("[ZG-DIAG] cmdBindTexture OK: binding={d} set={any} layout={any}\n", .{ binding, texture.descriptor_set, cmd.pipeline_layout });
    c.vkCmdBindDescriptorSets(cmd.cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, cmd.pipeline_layout.?, binding, 1, @as([*]const c.VkDescriptorSet, @ptrCast(&sets)), 0, null);
}

pub fn cmdBindVertexBuffer(cmd: *VulkanCommandBuffer, buffer: *VulkanBuffer, offset: u64) void {
    if (builtin.os.tag != .linux) return;
    c.vkCmdBindVertexBuffers(cmd.cmd, 0, 1, @as([*]const c.VkBuffer, @ptrCast(&buffer.buffer)), @as([*]const u64, @ptrCast(&offset)));
}

pub fn cmdDraw(cmd: *VulkanCommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag != .linux) return;
    std.debug.print("[ZG-DIAG] cmdDraw: verts={d} instances={d} first_v={d} first_i={d}\n", .{ vertex_count, instance_count, first_vertex, first_instance });
    c.vkCmdDraw(cmd.cmd, vertex_count, instance_count, first_vertex, first_instance);
}

pub fn cmdBindVertexBuffers(cmd: *VulkanCommandBuffer, first_binding: u32, buffers: []const *VulkanBuffer, offsets: []const u64) void {
    if (builtin.os.tag != .linux) return;
    var vk_buffers: [16]c.VkBuffer = undefined;
    const count = @min(buffers.len, 16);
    for (buffers[0..count], 0..) |buf, i| {
        vk_buffers[i] = buf.buffer;
    }
    c.vkCmdBindVertexBuffers(cmd.cmd, first_binding, @intCast(count), @as([*]const c.VkBuffer, @ptrCast(&vk_buffers)), offsets.ptr);
}

pub fn cmdDrawInstanced(cmd: *VulkanCommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag != .linux) return;
    c.vkCmdDraw(cmd.cmd, vertex_count, instance_count, first_vertex, first_instance);
}

pub fn cmdCopyTexture(cmd: *VulkanCommandBuffer, src: *VulkanTexture, dst: *VulkanTexture) void {
    if (builtin.os.tag != .linux) return;

    // Transition src: GENERAL → TRANSFER_SRC_OPTIMAL
    var src_barrier: c.VkImageMemoryBarrier = .{
        .sType = 45,
        .srcAccessMask = c.VK_ACCESS_SHADER_READ_BIT,
        .dstAccessMask = c.VK_ACCESS_TRANSFER_READ_BIT,
        .oldLayout = c.VK_IMAGE_LAYOUT_GENERAL,
        .newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
        .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .image = src.image,
        .subresourceRange = .{
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .baseMipLevel = 0,
            .levelCount = 1,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
    };
    c.vkCmdPipelineBarrier(cmd.cmd, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&src_barrier));

    // Transition dst: GENERAL → TRANSFER_DST_OPTIMAL
    var dst_barrier: c.VkImageMemoryBarrier = .{
        .sType = 45,
        .srcAccessMask = c.VK_ACCESS_SHADER_READ_BIT,
        .dstAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT,
        .oldLayout = c.VK_IMAGE_LAYOUT_GENERAL,
        .newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
        .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .image = dst.image,
        .subresourceRange = .{
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .baseMipLevel = 0,
            .levelCount = 1,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
    };
    c.vkCmdPipelineBarrier(cmd.cmd, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&dst_barrier));

    // Copy image
    const copy_region = c.VkImageCopy{
        .srcSubresource = .{
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .mipLevel = 0,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
        .srcOffset = .{},
        .dstSubresource = .{
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .mipLevel = 0,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
        .dstOffset = .{},
        .extent = .{ .width = src.width, .height = src.height, .depth = 1 },
    };
    c.vkCmdCopyImage(cmd.cmd, src.image, c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, dst.image, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, @as([*]const c.VkImageCopy, @ptrCast(&copy_region)));

    // Transition src back: TRANSFER_SRC_OPTIMAL → GENERAL
    src_barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
    src_barrier.newLayout = c.VK_IMAGE_LAYOUT_GENERAL;
    src_barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_READ_BIT;
    src_barrier.dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT;
    c.vkCmdPipelineBarrier(cmd.cmd, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&src_barrier));

    // Transition dst back: TRANSFER_DST_OPTIMAL → GENERAL
    dst_barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
    dst_barrier.newLayout = c.VK_IMAGE_LAYOUT_GENERAL;
    dst_barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT;
    dst_barrier.dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT;
    c.vkCmdPipelineBarrier(cmd.cmd, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&dst_barrier));
}

pub fn beginLayer(cmd: *VulkanCommandBuffer, layer_id: u32, x: f32, y: f32, width: f32, height: f32, opacity: f32) void {
    if (builtin.os.tag != .linux) return;
    cmd.current_layer = .{
        .layer_id = layer_id,
        .x = x,
        .y = y,
        .width = width,
        .height = height,
        .opacity = opacity,
        .active = true,
    };
    if (cmd.pipeline_layout) |layout| {
        const pc = LayerPushConstants{ .x = x, .y = y, .width = width, .height = height, .opacity = opacity };
        c.vkCmdPushConstants(cmd.cmd, layout, c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT, 0, @sizeOf(LayerPushConstants), &pc);
    }
}

pub fn endLayer(cmd: *VulkanCommandBuffer) void {
    if (builtin.os.tag != .linux) return;
    cmd.current_layer = .{};
}

var global_layer_order: [64]u32 = undefined;
var global_layer_count: u32 = 0;

pub fn setLayerOrder(order: [*]const u32, count: u32) void {
    const cpy_count = @min(count, 64);
    @memcpy(global_layer_order[0..cpy_count], order[0..cpy_count]);
    global_layer_count = cpy_count;
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

    if (surface.transfer_pool == null or surface.transfer_cmd == null) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    _ = c.vkResetCommandPool(surface.device, surface.transfer_pool, 0);

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 1 }); // VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    _ = c.vkBeginCommandBuffer(surface.transfer_cmd, &begin_info);
    c.vkCmdCopyBuffer(surface.transfer_cmd, staging, buffer.buffer, 1, @as([*]const c.VkBufferCopy, @ptrCast(&copy_region)));
    _ = c.vkEndCommandBuffer(surface.transfer_cmd);

    const submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&surface.transfer_cmd)) });
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

    const log = builtin.mode == .Debug;
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: data ptr={any} len={} tex={}x{}\n", .{ data, dataLen, texture.width, texture.height });

    const is_yuv_upload = texture.format == .YUV420_3Plane or texture.format == .NV12_2Plane or texture.format == .P010_10bit;
    const staging_size = if (is_yuv_upload) @as(u64, texture.width) * @as(u64, texture.height) * 4 else dataLen;
    const staging_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = staging_size,
        .usage = c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
    });

    var staging: c.VkBuffer = null;
    var r = c.vkCreateBuffer(surface.device, &staging_info, null, &staging);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkCreateBuffer staging result={} handle={any}\n", .{ r, staging });
    if (r != c.VK_SUCCESS) return false;

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(surface.device, staging, &mem_reqs);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: staging memReqs size={} alignment={} bits=0x{x}\n", .{ mem_reqs.size, mem_reqs.alignment, mem_reqs.memoryTypeBits });

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
        if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: ERROR no HOST_VISIBLE|HOST_COHERENT mem type found\n", .{});
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    };
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: staging memTypeIndex={}\n", .{alloc_info.memoryTypeIndex});

    var staging_mem: c.VkDeviceMemory = null;
    r = c.vkAllocateMemory(surface.device, &alloc_info, null, &staging_mem);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkAllocateMemory staging result={} handle={any}\n", .{ r, staging_mem });
    if (r != c.VK_SUCCESS) {
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }
    r = c.vkBindBufferMemory(surface.device, staging, staging_mem, 0);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkBindBufferMemory staging result={}\n", .{r});

    var data_ptr: ?*anyopaque = null;
    r = c.vkMapMemory(surface.device, staging_mem, 0, staging_size, 0, &data_ptr);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkMapMemory result={} ptr={any}\n", .{ r, data_ptr });
    if (r != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }
    const early_is_yuv = texture.format == .YUV420_3Plane or texture.format == .NV12_2Plane or texture.format == .P010_10bit;
    if (!early_is_yuv) {
        @memcpy(@as([*]u8, @ptrCast(@alignCast(data_ptr)))[0..dataLen], @as([*]const u8, @ptrCast(@alignCast(data)))[0..dataLen]);
    }
    if (log) {
        const check_ptr = @as([*]const u8, @ptrCast(@alignCast(data_ptr)));
        std.debug.print("[Z-GRAPHICS] uploadTexture: staging[0..4] = 0x{x} 0x{x} 0x{x} 0x{x}\n", .{ check_ptr[0], check_ptr[1], check_ptr[2], check_ptr[3] });
    }
    c.vkUnmapMemory(surface.device, staging_mem);

    if (surface.transfer_pool == null or surface.transfer_cmd == null) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    _ = c.vkResetCommandPool(surface.device, surface.transfer_pool, 0);

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 1 }); // VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    r = c.vkBeginCommandBuffer(surface.transfer_cmd, &begin_info);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkBeginCommandBuffer result={}\n", .{r});

    const is_yuv_3plane = texture.format == .YUV420_3Plane;
    const is_nv12 = texture.format == .NV12_2Plane;
    const is_p010 = texture.format == .P010_10bit;
    const is_multiplane = is_yuv_3plane or is_nv12 or is_p010;

    if (is_multiplane) {
        const w = texture.width;
        const h = texture.height;
        const y_size = @as(u64, w) * @as(u64, h);
        const uv_size = @as(u64, w / 2) * @as(u64, h / 2);
        const rgba_size = y_size * 4;

        var rgba_buf = std.heap.page_allocator.alloc(u8, rgba_size) catch {
            c.vkFreeMemory(surface.device, staging_mem, null);
            c.vkDestroyBuffer(surface.device, staging, null);
            return false;
        };
        defer std.heap.page_allocator.free(rgba_buf);

        const src = @as([*]const u8, @ptrCast(@alignCast(data)));

        if (is_yuv_3plane) {
            const y_plane = src;
            const u_plane = y_plane + y_size;
            const v_plane = u_plane + uv_size;

            var row: u32 = 0;
            while (row < h) : (row += 1) {
                var col: u32 = 0;
                while (col < w) : (col += 1) {
                    const y_val = y_plane[row * w + col];
                    const u_val = u_plane[(row / 2) * (w / 2) + (col / 2)];
                    const v_val = v_plane[(row / 2) * (w / 2) + (col / 2)];
                    const y_f = @as(f32, @floatFromInt(y_val)) - 16.0;
                    const u_f = @as(f32, @floatFromInt(u_val)) - 128.0;
                    const v_f = @as(f32, @floatFromInt(v_val)) - 128.0;
                    const r_clamped: u8 = @intCast(@max(0, @min(255, @as(i32, @intFromFloat(1.164 * y_f + 1.596 * v_f)))));
                    const g_clamped: u8 = @intCast(@max(0, @min(255, @as(i32, @intFromFloat(1.164 * y_f - 0.392 * u_f - 0.813 * v_f)))));
                    const b_clamped: u8 = @intCast(@max(0, @min(255, @as(i32, @intFromFloat(1.164 * y_f + 2.017 * u_f)))));
                    const idx = (row * w + col) * 4;
                    rgba_buf[idx] = r_clamped;
                    rgba_buf[idx + 1] = g_clamped;
                    rgba_buf[idx + 2] = b_clamped;
                    rgba_buf[idx + 3] = 255;
                }
            }
        } else {
            @memcpy(rgba_buf[0..dataLen], src[0..dataLen]);
        }

        if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: YUV→RGBA converted {} bytes to {} bytes\n", .{ dataLen, rgba_size });

        var mapped_ptr: ?*anyopaque = null;
        r = c.vkMapMemory(surface.device, staging_mem, 0, rgba_size, 0, &mapped_ptr);
        if (r != c.VK_SUCCESS) {
            c.vkFreeMemory(surface.device, staging_mem, null);
            c.vkDestroyBuffer(surface.device, staging, null);
            return false;
        }
        @memcpy(@as([*]u8, @ptrCast(@alignCast(mapped_ptr)))[0..rgba_size], rgba_buf[0..rgba_size]);
        c.vkUnmapMemory(surface.device, staging_mem);

        var barrier: c.VkImageMemoryBarrier = undefined;
        barrier.sType = 45;
        barrier.pNext = null;
        barrier.srcAccessMask = 0;
        barrier.dstAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT;
        barrier.oldLayout = c.VK_IMAGE_LAYOUT_UNDEFINED;
        barrier.newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        barrier.srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED;
        barrier.dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED;
        barrier.image = texture.image;
        barrier.subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 };

        c.vkCmdPipelineBarrier(surface.transfer_cmd, c.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

        var region: c.VkBufferImageCopy = std.mem.zeroes(c.VkBufferImageCopy);
        region.bufferOffset = 0;
        region.imageSubresource.aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT;
        region.imageSubresource.mipLevel = 0;
        region.imageSubresource.baseArrayLayer = 0;
        region.imageSubresource.layerCount = 1;
        region.imageOffset = .{ .x = 0, .y = 0, .z = 0 };
        region.imageExtent = .{ .width = w, .height = h, .depth = 1 };

        c.vkCmdCopyBufferToImage(surface.transfer_cmd, staging, texture.image, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, @ptrCast(&region));

        barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        barrier.newLayout = c.VK_IMAGE_LAYOUT_GENERAL;
        barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT;
        barrier.dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT;
        c.vkCmdPipelineBarrier(surface.transfer_cmd, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));
    } else {
        var barrier: c.VkImageMemoryBarrier = undefined;
        barrier.sType = 45;
        if (barrier.sType != 45) @panic("VkImageMemoryBarrier sType must be 45");
        barrier.pNext = null;
        barrier.srcAccessMask = 0;
        barrier.dstAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT;
        barrier.oldLayout = c.VK_IMAGE_LAYOUT_UNDEFINED;
        barrier.newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        barrier.srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED;
        barrier.dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED;
        barrier.image = texture.image;
        barrier.subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 };

        if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: barrier1 oldLayout={} newLayout={} image={any}\n", .{ barrier.oldLayout, barrier.newLayout, barrier.image });
        c.vkCmdPipelineBarrier(surface.transfer_cmd, c.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

        var region: c.VkBufferImageCopy = std.mem.zeroes(c.VkBufferImageCopy);
        region.bufferOffset = 0;
        region.bufferRowLength = 0;
        region.bufferImageHeight = 0;
        region.imageSubresource.aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT;
        region.imageSubresource.mipLevel = 0;
        region.imageSubresource.baseArrayLayer = 0;
        region.imageSubresource.layerCount = 1;
        region.imageOffset = .{ .x = 0, .y = 0, .z = 0 };
        region.imageExtent = .{ .width = texture.width, .height = texture.height, .depth = 1 };

        if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: CopyBufferToImage staging={any} image={any} extent={}x{}x{} layerCount={}\n", .{ staging, texture.image, region.imageExtent.width, region.imageExtent.height, region.imageExtent.depth, region.imageSubresource.layerCount });
        c.vkCmdCopyBufferToImage(surface.transfer_cmd, staging, texture.image, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, @ptrCast(&region));

        barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        barrier.newLayout = c.VK_IMAGE_LAYOUT_GENERAL;
        barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT;
        barrier.dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT;

        if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: barrier2 oldLayout={} newLayout={}\n", .{ barrier.oldLayout, barrier.newLayout });
        c.vkCmdPipelineBarrier(surface.transfer_cmd, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));
    }

    r = c.vkEndCommandBuffer(surface.transfer_cmd);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkEndCommandBuffer result={}\n", .{r});

    const submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&surface.transfer_cmd)) });
    r = c.vkQueueSubmit(surface.graphics_queue, 1, @ptrCast(&submit_info), surface.fence);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkQueueSubmit result={}\n", .{r});
    r = c.vkWaitForFences(surface.device, 1, @ptrCast(&surface.fence), c.VK_TRUE, std.math.maxInt(u64));
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkWaitForFences result={}\n", .{r});
    r = c.vkResetFences(surface.device, 1, @ptrCast(&surface.fence));
    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: vkResetFences result={}\n", .{r});

    if (log) std.debug.print("[Z-GRAPHICS] uploadTexture: upload complete, image={any}\n", .{texture.image});

    c.vkFreeMemory(surface.device, staging_mem, null);
    c.vkDestroyBuffer(surface.device, staging, null);

    return true;
}

pub fn getBufferSize(buffer: *VulkanBuffer) usize {
    return buffer.size;
}

pub fn createUniformBuffer(surface: *VulkanSurface, size: usize) ?*VulkanBuffer {
    if (builtin.os.tag != .linux) return null;

    const buffer_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = @as(u64, size),
        .usage = c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,
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

pub fn uploadUniformBuffer(surface: *VulkanSurface, buffer: *VulkanBuffer, data: ?[*]const u8, len: usize) bool {
    if (builtin.os.tag != .linux) return false;
    if (data == null or len == 0) return false;
    if (len > buffer.size) return false;

    var data_ptr: ?*anyopaque = null;
    if (c.vkMapMemory(surface.device, buffer.memory, 0, @as(u64, len), 0, @ptrCast(&data_ptr)) != c.VK_SUCCESS) return false;

    @memcpy(@as([*]u8, @ptrCast(@alignCast(data_ptr)))[0..len], data.?[0..len]);

    const mapped_range = std.mem.zeroInit(c.VkMappedMemoryRange, .{
        .sType = c.VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE,
        .memory = buffer.memory,
        .offset = 0,
        .size = @as(u64, len),
    });
    _ = c.vkFlushMappedMemoryRanges(surface.device, 1, @as([*]const c.VkMappedMemoryRange, @ptrCast(&mapped_range)));
    c.vkUnmapMemory(surface.device, buffer.memory);
    return true;
}

pub fn cmdBindUniformBuffer(cmd: *VulkanCommandBuffer, buffer: *VulkanBuffer, binding: u32, offset: u64) void {
    if (builtin.os.tag != .linux) return;
    if (cmd.pipeline_layout == null) return;
    const desc_set = cmd.current_descriptor_set orelse return;

    var props: c.VkPhysicalDeviceProperties = undefined;
    c.vkGetPhysicalDeviceProperties(cmd.surface.physical_device, &props);
    const alignment = props.limits.minUniformBufferOffsetAlignment;
    const aligned_offset = (offset / alignment) * alignment;
    if (aligned_offset != offset) {
        std.debug.print("[Z-GRAPHICS] cmdBindUniformBuffer: WARNING offset={d} is not aligned to minUniformBufferOffsetAlignment={d}. Using aligned offset {d}.\n", .{ offset, alignment, aligned_offset });
    }

    if (cmd.last_descriptor_set != desc_set) {
        cmd.last_descriptor_set = desc_set;
        inline for (0..16) |i| {
            cmd.last_bound_buffers[i] = null;
            cmd.last_bound_offsets[i] = 0;
        }
    }

    if (binding < 16 and cmd.last_bound_buffers[binding] == buffer and cmd.last_bound_offsets[binding] == aligned_offset) {
        const sets = [_]c.VkDescriptorSet{desc_set};
        c.vkCmdBindDescriptorSets(cmd.cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, cmd.pipeline_layout.?, 0, 1, @as([*]const c.VkDescriptorSet, @ptrCast(&sets)), 0, null);
        return;
    }

    const buffer_info = c.VkDescriptorBufferInfo{
        .buffer = buffer.buffer,
        .offset = aligned_offset,
        .range = buffer.size - aligned_offset,
    };
    const write_info = c.VkWriteDescriptorSet{
        .sType = c.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
        .pNext = null,
        .dstSet = desc_set,
        .dstBinding = binding,
        .dstArrayElement = 0,
        .descriptorCount = 1,
        .descriptorType = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
        .pImageInfo = null,
        .pBufferInfo = @as([*]const c.VkDescriptorBufferInfo, @ptrCast(&buffer_info)),
        .pTexelBufferView = null,
    };
    c.vkUpdateDescriptorSets(cmd.surface.device, 1, @as([*]const c.VkWriteDescriptorSet, @ptrCast(&write_info)), 0, null);

    if (binding < 16) {
        cmd.last_bound_buffers[binding] = buffer;
        cmd.last_bound_offsets[binding] = aligned_offset;
    }

    const sets = [_]c.VkDescriptorSet{desc_set};
    c.vkCmdBindDescriptorSets(cmd.cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, cmd.pipeline_layout.?, 0, 1, @as([*]const c.VkDescriptorSet, @ptrCast(&sets)), 0, null);
}

pub const VulkanTexture = struct { image: c.VkImage, memory: c.VkDeviceMemory, view: c.VkImageView, width: u32, height: u32, sampler: c.VkSampler, descriptor_set: c.VkDescriptorSet, ycbcr_conversion: c.VkSamplerYcbcrConversion = null, format: zgraphics.ZawraGraphicsTextureFormat = .R8G8B8A8_Unorm };

fn mapYUVFormat(format: zgraphics.ZawraGraphicsTextureFormat) c.VkFormat {
    return switch (format) {
        .YUV420_3Plane => c.VK_FORMAT_R8G8B8A8_UNORM,
        .NV12_2Plane => c.VK_FORMAT_R8G8B8A8_UNORM,
        .P010_10bit => c.VK_FORMAT_R8G8B8A8_UNORM,
        else => c.VK_FORMAT_R8G8B8A8_UNORM,
    };
}

fn allocateDescriptorSet(surface: *VulkanSurface, sampler: c.VkSampler, image_view: c.VkImageView) ?c.VkDescriptorSet {
    var descriptor_set: c.VkDescriptorSet = null;
    const alloc_info = c.VkDescriptorSetAllocateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .pNext = null,
        .descriptorPool = surface.descriptor_pool,
        .descriptorSetCount = 1,
        .pSetLayouts = @as([*]const c.VkDescriptorSetLayout, @ptrCast(&surface.descriptor_set_layout)),
    };
    const result = c.vkAllocateDescriptorSets(surface.device, &alloc_info, &descriptor_set);
    if (result != 0) {
        std.debug.print("[ZG-DIAG] allocateDescriptorSet FAILED: result={d} pool={any} layout={any}\n", .{ result, surface.descriptor_pool, surface.descriptor_set_layout });
        return null;
    }

    const image_info = c.VkDescriptorImageInfo{
        .sampler = sampler,
        .imageView = image_view,
        .imageLayout = c.VK_IMAGE_LAYOUT_GENERAL,
    };
    const write_info = c.VkWriteDescriptorSet{
        .sType = c.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
        .pNext = null,
        .dstSet = descriptor_set,
        .dstBinding = 0,
        .dstArrayElement = 0,
        .descriptorCount = 1,
        .descriptorType = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
        .pImageInfo = @as([*]const c.VkDescriptorImageInfo, @ptrCast(&image_info)),
    };
    c.vkUpdateDescriptorSets(surface.device, 1, @as([*]const c.VkWriteDescriptorSet, @ptrCast(&write_info)), 0, null);
    return descriptor_set;
}

fn createYUVTexture(surface: *VulkanSurface, desc: *const zgraphics.ZawraGraphicsTextureDesc) ?*VulkanTexture {
    if (builtin.os.tag != .linux) return null;

    const vk_format = c.VK_FORMAT_R8G8B8A8_UNORM;

    const image_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .imageType = c.VK_IMAGE_TYPE_2D,
        .extent = .{ .width = desc.width, .height = desc.height, .depth = 1 },
        .mipLevels = 1,
        .arrayLayers = 1,
        .format = vk_format,
        .tiling = c.VK_IMAGE_TILING_OPTIMAL,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .usage = c.VK_IMAGE_USAGE_TRANSFER_DST_BIT | c.VK_IMAGE_USAGE_SAMPLED_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
    });

    var image: c.VkImage = null;
    if (c.vkCreateImage(surface.device, &image_info, null, &image) != c.VK_SUCCESS) {
        return null;
    }

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

    const sampler_info = std.mem.zeroInit(c.VkSamplerCreateInfo, .{
        .sType = 35,
        .magFilter = 1,
        .minFilter = 1,
        .addressModeU = 1,
        .addressModeV = 1,
        .addressModeW = 1,
        .anisotropyEnable = 0,
        .unnormalizedCoordinates = 0,
        .compareEnable = 0,
        .compareOp = 0,
        .mipmapMode = 0,
    });
    var sampler: c.VkSampler = null;
    if (c.vkCreateSampler(surface.device, &sampler_info, null, &sampler) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        .image = image,
        .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
        .format = vk_format,
        .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
    });

    var view: c.VkImageView = null;
    if (c.vkCreateImageView(surface.device, &view_info, null, &view) != c.VK_SUCCESS) {
        c.vkDestroySampler(surface.device, sampler, null);
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const tex = std.heap.page_allocator.create(VulkanTexture) catch {
        c.vkDestroyImageView(surface.device, view, null);
        c.vkDestroySampler(surface.device, sampler, null);
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    };
    tex.* = .{ .image = image, .memory = memory, .view = view, .width = desc.width, .height = desc.height, .sampler = sampler, .descriptor_set = null, .ycbcr_conversion = null, .format = desc.format };

    if (surface.descriptor_set_layout != null and surface.descriptor_pool != null) {
        tex.descriptor_set = allocateDescriptorSet(surface, sampler, view) orelse tex.descriptor_set;
    }

    if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createYUVTexture: success, format={} {}x{}\n", .{ vk_format, desc.width, desc.height });
    return tex;
}

pub fn createTexture(surface: *VulkanSurface, desc: *const zgraphics.ZawraGraphicsTextureDesc) ?*VulkanTexture {
    if (builtin.os.tag != .linux) return null;

    const is_yuv = switch (desc.format) {
        .YUV420_3Plane, .NV12_2Plane, .P010_10bit => true,
        else => false,
    };
    if (is_yuv) return createYUVTexture(surface, desc);

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
        .sType = 35, // VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO
        .magFilter = 1, // VK_FILTER_LINEAR
        .minFilter = 1, // VK_FILTER_LINEAR
        .addressModeU = 1, // VK_SAMPLER_ADDRESS_MODE_REPEAT
        .addressModeV = 1, // VK_SAMPLER_ADDRESS_MODE_REPEAT
        .addressModeW = 1, // VK_SAMPLER_ADDRESS_MODE_REPEAT
        .anisotropyEnable = 0,
        .unnormalizedCoordinates = 0,
        .compareEnable = 0,
        .compareOp = 0, // VK_COMPARE_OP_NEVER
        .mipmapMode = 0, // VK_SAMPLER_MIPMAP_MODE_NEAREST
    });
    var sampler: c.VkSampler = null;
    if (c.vkCreateSampler(surface.device, &sampler_info, null, &sampler) != c.VK_SUCCESS) {
        c.vkDestroyImageView(surface.device, view, null);
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const tex = std.heap.page_allocator.create(VulkanTexture) catch return null;
    tex.* = .{ .image = image, .memory = memory, .view = view, .width = desc.width, .height = desc.height, .sampler = sampler, .descriptor_set = null, .ycbcr_conversion = null, .format = desc.format };

    if (surface.descriptor_set_layout != null and surface.descriptor_pool != null) {
        tex.descriptor_set = allocateDescriptorSet(surface, sampler, view) orelse tex.descriptor_set;
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createTexture: descriptor_set={any}\n", .{tex.descriptor_set});
    } else {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createTexture: WARNING - descriptor_set_layout={any} descriptor_pool={any}\n", .{ surface.descriptor_set_layout, surface.descriptor_pool });
    }
    return tex;
}

pub fn importTextureFD(surface: *VulkanSurface, fd: i32, desc: *const zgraphics.ZawraGraphicsTextureDesc) ?*VulkanTexture {
    if (builtin.os.tag != .linux) return null;
    if (fd < 0) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] importTextureFD: invalid fd={d}\n", .{fd});
        return null;
    }
    if (!surface.external_memory_enabled) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] importTextureFD: external memory not enabled\n", .{});
        return null;
    }

    var external_image_info = std.mem.zeroInit(c.VkExternalMemoryImageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO,
        .handleTypes = c.VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT,
    });

    const image_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .pNext = &external_image_info,
        .imageType = c.VK_IMAGE_TYPE_2D,
        .extent = .{ .width = desc.width, .height = desc.height, .depth = 1 },
        .mipLevels = 1,
        .arrayLayers = 1,
        .format = c.VK_FORMAT_R8G8B8A8_UNORM,
        .tiling = c.VK_IMAGE_TILING_OPTIMAL,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .usage = c.VK_IMAGE_USAGE_TRANSFER_DST_BIT | c.VK_IMAGE_USAGE_SAMPLED_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
    });

    var image: c.VkImage = null;
    if (c.vkCreateImage(surface.device, &image_info, null, &image) != c.VK_SUCCESS) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] importTextureFD: vkCreateImage failed\n", .{});
        return null;
    }

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetImageMemoryRequirements(surface.device, image, &mem_reqs);

    var fd_props = std.mem.zeroInit(c.VkMemoryFdPropertiesKHR, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_FD_PROPERTIES_KHR,
        .memoryTypeBits = 0,
        .fd = fd,
    });

    const pfnGetMemoryFdProperties = @as(?c.PFN_vkGetMemoryFdPropertiesKHR, @ptrCast(c.vkGetDeviceProcAddr(surface.device, "vkGetMemoryFdPropertiesKHR")));
    if (pfnGetMemoryFdProperties == null) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] importTextureFD: vkGetMemoryFdPropertiesKHR not found\n", .{});
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }
    _ = pfnGetMemoryFdProperties.?(surface.device, c.VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT, fd, &fd_props);

    var mem_type_index: ?u32 = null;
    for (0..32) |i| {
        if ((fd_props.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0) {
            var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
            c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
            if (i < mem_props.memoryTypeCount) {
                mem_type_index = @intCast(i);
                break;
            }
        }
    }
    const memory_type_index = mem_type_index orelse {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] importTextureFD: no compatible memory type found\n", .{});
        c.vkDestroyImage(surface.device, image, null);
        return null;
    };

    var import_fd_info = std.mem.zeroInit(c.VkImportMemoryFdInfoKHR, .{
        .sType = c.VK_STRUCTURE_TYPE_IMPORT_MEMORY_FD_INFO_KHR,
        .handleType = c.VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT,
        .fd = fd,
    });

    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .pNext = &import_fd_info,
        .allocationSize = mem_reqs.size,
        .memoryTypeIndex = memory_type_index,
    });

    var memory: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(surface.device, &alloc_info, null, &memory) != c.VK_SUCCESS) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] importTextureFD: vkAllocateMemory failed\n", .{});
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }
    if (c.vkBindImageMemory(surface.device, image, memory, 0) != c.VK_SUCCESS) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] importTextureFD: vkBindImageMemory failed\n", .{});
        c.vkFreeMemory(surface.device, memory, null);
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
        .sType = 35,
        .magFilter = 1,
        .minFilter = 1,
        .addressModeU = 1,
        .addressModeV = 1,
        .addressModeW = 1,
        .anisotropyEnable = 0,
        .unnormalizedCoordinates = 0,
        .compareEnable = 0,
        .compareOp = 0,
        .mipmapMode = 0,
    });
    var sampler: c.VkSampler = null;
    if (c.vkCreateSampler(surface.device, &sampler_info, null, &sampler) != c.VK_SUCCESS) {
        c.vkDestroyImageView(surface.device, view, null);
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const tex = std.heap.page_allocator.create(VulkanTexture) catch return null;
    tex.* = .{ .image = image, .memory = memory, .view = view, .width = desc.width, .height = desc.height, .sampler = sampler, .descriptor_set = null, .ycbcr_conversion = null, .format = desc.format };

    if (surface.descriptor_set_layout != null and surface.descriptor_pool != null) {
        tex.descriptor_set = allocateDescriptorSet(surface, sampler, view) orelse tex.descriptor_set;
    }

    if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] importTextureFD: success, fd={d} {}x{}\n", .{ fd, desc.width, desc.height });
    return tex;
}

pub const VulkanShaderModule = struct {
    module: c.VkShaderModule,
};

pub fn createShaderModulePublic(surface: *VulkanSurface, spirv: [*]const u8, spirv_len: usize) ?*VulkanShaderModule {
    if (builtin.os.tag != .linux) return null;
    const code = spirv[0..spirv_len];
    const vk_module = createShaderModule(surface.device, code) orelse return null;
    const sm = std.heap.page_allocator.create(VulkanShaderModule) catch {
        c.vkDestroyShaderModule(surface.device, vk_module, null);
        return null;
    };
    sm.* = .{ .module = vk_module };
    return sm;
}

pub fn destroyShaderModulePublic(surface: *VulkanSurface, module: *VulkanShaderModule) void {
    if (builtin.os.tag != .linux) return;
    if (module.module != null) c.vkDestroyShaderModule(surface.device, module.module, null);
    std.heap.page_allocator.destroy(module);
}

pub fn createPipelineFromShadersPublic(surface: *VulkanSurface, vert: *VulkanShaderModule, frag: *VulkanShaderModule, desc: ?*const @import("lib.zig").PipelineDesc) ?*VulkanPipeline {
    if (builtin.os.tag != .linux) return null;

    const shader_stages = [_]c.VkPipelineShaderStageCreateInfo{
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_VERTEX_BIT, .module = vert.module, .pName = "main" },
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_FRAGMENT_BIT, .module = frag.module, .pName = "main" },
    };

    var vertex_input_info: c.VkPipelineVertexInputStateCreateInfo = undefined;
    vertex_input_info.sType = 19;
    vertex_input_info.pNext = null;
    vertex_input_info.flags = 0;
    vertex_input_info.vertexBindingDescriptionCount = 0;
    vertex_input_info.vertexAttributeDescriptionCount = 0;
    vertex_input_info.pVertexBindingDescriptions = null;
    vertex_input_info.pVertexAttributeDescriptions = null;

    const input_assembly = std.mem.zeroInit(c.VkPipelineInputAssemblyStateCreateInfo, .{ .sType = 20, .topology = c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, .primitiveRestartEnable = 0 });
    const dynamic_states = [_]u32{ c.VK_DYNAMIC_STATE_VIEWPORT, c.VK_DYNAMIC_STATE_SCISSOR };
    var dynamic_state_info = c.VkPipelineDynamicStateCreateInfo{
        .sType = 27,
        .dynamicStateCount = 2,
        .pDynamicStates = @as([*]const u32, @ptrCast(&dynamic_states)),
    };
    const viewport_state = std.mem.zeroInit(c.VkPipelineViewportStateCreateInfo, .{ .sType = 22, .viewportCount = 1, .scissorCount = 1 });
    const rasterizer = std.mem.zeroInit(c.VkPipelineRasterizationStateCreateInfo, .{ .sType = 23, .depthClampEnable = 0, .rasterizerDiscardEnable = 0, .polygonMode = c.VK_POLYGON_MODE_FILL, .lineWidth = 1, .cullMode = c.VK_CULL_MODE_NONE, .frontFace = c.VK_FRONT_FACE_CLOCKWISE, .depthBiasEnable = 0 });
    const msaa_rasterization_samples: u32 = surface.msaa_samples;
    const msaa_sample_shading_enable: u32 = if (surface.msaa_samples > 1) @as(u32, 1) else 0;
    const msaa_min_sample_shading: f32 = if (surface.msaa_samples > 1) 0.25 else 0;
    const multisampling = std.mem.zeroInit(c.VkPipelineMultisampleStateCreateInfo, .{ .sType = 24, .sampleShadingEnable = msaa_sample_shading_enable, .minSampleShading = msaa_min_sample_shading, .rasterizationSamples = msaa_rasterization_samples });
    const color_blend_attachment = std.mem.zeroInit(c.VkPipelineColorBlendAttachmentState, .{
        .colorWriteMask = 0xF,
        .blendEnable = if (desc) |d| d.blend_enable else 0,
        .srcColorBlendFactor = if (desc) |d| d.src_color_blend_factor else 0,
        .dstColorBlendFactor = if (desc) |d| d.dst_color_blend_factor else 0,
        .colorBlendOp = if (desc) |d| d.color_blend_op else 0,
        .srcAlphaBlendFactor = if (desc) |d| d.src_alpha_blend_factor else 0,
        .dstAlphaBlendFactor = if (desc) |d| d.dst_alpha_blend_factor else 0,
        .alphaBlendOp = if (desc) |d| d.alpha_blend_op else 0,
    });
    const color_blending = std.mem.zeroInit(c.VkPipelineColorBlendStateCreateInfo, .{ .sType = 26, .logicOpEnable = 0, .attachmentCount = 1, .pAttachments = @as([*]const c.VkPipelineColorBlendAttachmentState, @ptrCast(&color_blend_attachment)) });

    const descriptor_set_layout_bindings = [_]c.VkDescriptorSetLayoutBinding{
        .{
            .binding = 0,
            .descriptorType = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            .descriptorCount = 1,
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        },
        .{
            .binding = 1,
            .descriptorType = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            .descriptorCount = 1,
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        },
    };
    const descriptor_set_layout_info = c.VkDescriptorSetLayoutCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .bindingCount = descriptor_set_layout_bindings.len,
        .pBindings = @as([*]const c.VkDescriptorSetLayoutBinding, @ptrCast(&descriptor_set_layout_bindings)),
    };
    var descriptor_set_layout: c.VkDescriptorSetLayout = null;
    if (c.vkCreateDescriptorSetLayout(surface.device, &descriptor_set_layout_info, null, &descriptor_set_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipelineFromShaders: vkCreateDescriptorSetLayout failed\n", .{});
        return null;
    }

    const layer_push_constant_range = c.VkPushConstantRange{
        .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        .offset = 0,
        .size = @sizeOf(LayerPushConstants),
    };

    const pipeline_layout_info = c.VkPipelineLayoutCreateInfo{
        .sType = 30,
        .pNext = null,
        .flags = 0,
        .setLayoutCount = 1,
        .pSetLayouts = @as(?*const anyopaque, @ptrCast(&descriptor_set_layout)),
        .pushConstantRangeCount = 1,
        .pPushConstantRanges = @as(?*const anyopaque, @ptrCast(&layer_push_constant_range)),
    };

    surface.descriptor_set_layout = descriptor_set_layout;

    var pipeline_layout: c.VkPipelineLayout = null;
    if (c.vkCreatePipelineLayout(surface.device, &pipeline_layout_info, null, &pipeline_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipelineFromShaders: vkCreatePipelineLayout failed\n", .{});
        surface.descriptor_set_layout = null;
        c.vkDestroyDescriptorSetLayout(surface.device, descriptor_set_layout, null);
        return null;
    }

    const pipeline_info = c.VkGraphicsPipelineCreateInfo{
        .sType = 28,
        .pNext = null,
        .flags = 0,
        .stageCount = 2,
        .pStages = @as([*]const c.VkPipelineShaderStageCreateInfo, @ptrCast(&shader_stages)),
        .pVertexInputState = &vertex_input_info,
        .pInputAssemblyState = &input_assembly,
        .pViewportState = &viewport_state,
        .pRasterizationState = &rasterizer,
        .pMultisampleState = &multisampling,
        .pColorBlendState = &color_blending,
        .pDynamicState = &dynamic_state_info,
        .layout = pipeline_layout,
        .renderPass = surface.render_pass,
        .subpass = 0,
    };
    var graphics_pipeline: c.VkPipeline = null;
    if (c.vkCreateGraphicsPipelines(surface.device, null, 1, @as([*]const c.VkGraphicsPipelineCreateInfo, @ptrCast(&pipeline_info)), null, &graphics_pipeline) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipelineFromShaders: vkCreateGraphicsPipelines failed\n", .{});
        c.vkDestroyPipelineLayout(surface.device, pipeline_layout, null);
        surface.descriptor_set_layout = null;
        c.vkDestroyDescriptorSetLayout(surface.device, descriptor_set_layout, null);
        return null;
    }

    const vulkan_pipeline = std.heap.page_allocator.create(VulkanPipeline) catch return null;
    vulkan_pipeline.* = .{ .pipeline = graphics_pipeline, .layout = pipeline_layout };
    return vulkan_pipeline;
}
pub fn createPipelineFromShadersWithLayout(
    surface: *VulkanSurface,
    vert: *VulkanShaderModule,
    frag: *VulkanShaderModule,
    bindings: ?[]const VertexBinding,
    attributes: ?[]const VertexAttribute,
    desc: ?*const @import("lib.zig").PipelineDesc,
) ?*VulkanPipeline {
    if (builtin.os.tag != .linux) return null;

    const shader_stages = [_]c.VkPipelineShaderStageCreateInfo{
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_VERTEX_BIT, .module = vert.module, .pName = "main" },
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_FRAGMENT_BIT, .module = frag.module, .pName = "main" },
    };

    var vk_bindings_buf: [16]c.VkVertexInputBindingDescription = undefined;
    var vk_attrs_buf: [16]c.VkVertexInputAttributeDescription = undefined;
    var binding_count: u32 = 0;
    var attr_count: u32 = 0;

    if (bindings) |b| {
        for (b, 0..) |vb, i| {
            vk_bindings_buf[i] = .{
                .binding = vb.binding,
                .stride = vb.stride,
                .inputRate = vb.input_rate,
            };
        }
        binding_count = @intCast(@min(b.len, 16));
    }
    if (attributes) |a| {
        for (a, 0..) |va, i| {
            vk_attrs_buf[i] = .{
                .location = va.location,
                .binding = va.binding,
                .format = va.format,
                .offset = va.offset,
            };
        }
        attr_count = @intCast(@min(a.len, 16));
    }

    var vertex_input_info: c.VkPipelineVertexInputStateCreateInfo = undefined;
    vertex_input_info.sType = 19;
    vertex_input_info.pNext = null;
    vertex_input_info.flags = 0;
    vertex_input_info.vertexBindingDescriptionCount = binding_count;
    vertex_input_info.vertexAttributeDescriptionCount = attr_count;
    vertex_input_info.pVertexBindingDescriptions = if (binding_count > 0) @ptrCast(&vk_bindings_buf) else null;
    vertex_input_info.pVertexAttributeDescriptions = if (attr_count > 0) @ptrCast(&vk_attrs_buf) else null;

    const input_assembly = std.mem.zeroInit(c.VkPipelineInputAssemblyStateCreateInfo, .{ .sType = 20, .topology = c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, .primitiveRestartEnable = 0 });
    const dynamic_states = [_]u32{ 9, 10 };
    var dynamic_state_info = c.VkPipelineDynamicStateCreateInfo{
        .sType = 27,
        .dynamicStateCount = 2,
        .pDynamicStates = @as([*]const u32, @ptrCast(&dynamic_states)),
    };
    const viewport_state = std.mem.zeroInit(c.VkPipelineViewportStateCreateInfo, .{ .sType = 22, .viewportCount = 1, .scissorCount = 1 });
    const rasterizer = std.mem.zeroInit(c.VkPipelineRasterizationStateCreateInfo, .{ .sType = 23, .depthClampEnable = 0, .rasterizerDiscardEnable = 0, .polygonMode = c.VK_POLYGON_MODE_FILL, .lineWidth = 1, .cullMode = c.VK_CULL_MODE_NONE, .frontFace = c.VK_FRONT_FACE_CLOCKWISE, .depthBiasEnable = 0 });
    const msaa_rasterization_samples: u32 = surface.msaa_samples;
    const msaa_sample_shading_enable: u32 = if (surface.msaa_samples > 1) @as(u32, 1) else 0;
    const msaa_min_sample_shading: f32 = if (surface.msaa_samples > 1) 0.25 else 0;
    const multisampling = std.mem.zeroInit(c.VkPipelineMultisampleStateCreateInfo, .{ .sType = 24, .sampleShadingEnable = msaa_sample_shading_enable, .minSampleShading = msaa_min_sample_shading, .rasterizationSamples = msaa_rasterization_samples });
    const color_blend_attachment = std.mem.zeroInit(c.VkPipelineColorBlendAttachmentState, .{
        .colorWriteMask = 0xF,
        .blendEnable = if (desc) |d| d.blend_enable else 0,
        .srcColorBlendFactor = if (desc) |d| d.src_color_blend_factor else 0,
        .dstColorBlendFactor = if (desc) |d| d.dst_color_blend_factor else 0,
        .colorBlendOp = if (desc) |d| d.color_blend_op else 0,
        .srcAlphaBlendFactor = if (desc) |d| d.src_alpha_blend_factor else 0,
        .dstAlphaBlendFactor = if (desc) |d| d.dst_alpha_blend_factor else 0,
        .alphaBlendOp = if (desc) |d| d.alpha_blend_op else 0,
    });
    const color_blending = std.mem.zeroInit(c.VkPipelineColorBlendStateCreateInfo, .{ .sType = 26, .logicOpEnable = 0, .attachmentCount = 1, .pAttachments = @as([*]const c.VkPipelineColorBlendAttachmentState, @ptrCast(&color_blend_attachment)) });

    const descriptor_set_layout_bindings = [_]c.VkDescriptorSetLayoutBinding{
        .{
            .binding = 0,
            .descriptorType = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            .descriptorCount = 1,
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        },
        .{
            .binding = 1,
            .descriptorType = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            .descriptorCount = 1,
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        },
    };
    const descriptor_set_layout_info = c.VkDescriptorSetLayoutCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .bindingCount = descriptor_set_layout_bindings.len,
        .pBindings = @as([*]const c.VkDescriptorSetLayoutBinding, @ptrCast(&descriptor_set_layout_bindings)),
    };
    var descriptor_set_layout: c.VkDescriptorSetLayout = null;
    if (c.vkCreateDescriptorSetLayout(surface.device, &descriptor_set_layout_info, null, &descriptor_set_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipelineWithLayout: vkCreateDescriptorSetLayout failed\n", .{});
        return null;
    }

    const layer_push_constant_range = c.VkPushConstantRange{
        .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT,
        .offset = 0,
        .size = @sizeOf(LayerPushConstants),
    };

    const pipeline_layout_info = c.VkPipelineLayoutCreateInfo{
        .sType = 30,
        .pNext = null,
        .flags = 0,
        .setLayoutCount = 1,
        .pSetLayouts = @as(?*const anyopaque, @ptrCast(&descriptor_set_layout)),
        .pushConstantRangeCount = 1,
        .pPushConstantRanges = @as(?*const anyopaque, @ptrCast(&layer_push_constant_range)),
    };

    surface.descriptor_set_layout = descriptor_set_layout;

    var pipeline_layout: c.VkPipelineLayout = null;
    if (c.vkCreatePipelineLayout(surface.device, &pipeline_layout_info, null, &pipeline_layout) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipelineWithLayout: vkCreatePipelineLayout failed\n", .{});
        surface.descriptor_set_layout = null;
        c.vkDestroyDescriptorSetLayout(surface.device, descriptor_set_layout, null);
        return null;
    }

    const pipeline_info = c.VkGraphicsPipelineCreateInfo{
        .sType = 28,
        .pNext = null,
        .flags = 0,
        .stageCount = 2,
        .pStages = @as([*]const c.VkPipelineShaderStageCreateInfo, @ptrCast(&shader_stages)),
        .pVertexInputState = &vertex_input_info,
        .pInputAssemblyState = &input_assembly,
        .pViewportState = &viewport_state,
        .pRasterizationState = &rasterizer,
        .pMultisampleState = &multisampling,
        .pColorBlendState = &color_blending,
        .pDynamicState = &dynamic_state_info,
        .layout = pipeline_layout,
        .renderPass = surface.render_pass,
        .subpass = 0,
    };
    var graphics_pipeline: c.VkPipeline = null;
    if (c.vkCreateGraphicsPipelines(surface.device, null, 1, @as([*]const c.VkGraphicsPipelineCreateInfo, @ptrCast(&pipeline_info)), null, &graphics_pipeline) != c.VK_SUCCESS) {
        std.debug.print("[Z-GRAPHICS] createPipelineWithLayout: vkCreateGraphicsPipelines failed\n", .{});
        c.vkDestroyPipelineLayout(surface.device, pipeline_layout, null);
        surface.descriptor_set_layout = null;
        c.vkDestroyDescriptorSetLayout(surface.device, descriptor_set_layout, null);
        return null;
    }

    const vulkan_pipeline = std.heap.page_allocator.create(VulkanPipeline) catch return null;
    vulkan_pipeline.* = .{ .pipeline = graphics_pipeline, .layout = pipeline_layout };
    return vulkan_pipeline;
}

pub fn destroyTexture(surface: *VulkanSurface, texture: *VulkanTexture) void {
    if (texture.descriptor_set != null and surface.descriptor_pool != null) {
        _ = c.vkFreeDescriptorSets(surface.device, surface.descriptor_pool, 1, @as([*]const c.VkDescriptorSet, @ptrCast(&texture.descriptor_set)));
    }
    if (texture.sampler != null) c.vkDestroySampler(surface.device, texture.sampler, null);
    if (texture.ycbcr_conversion != null) {
        var pfnDestroy = @as(?c.PFN_vkDestroySamplerYcbcrConversion, @ptrCast(c.vkGetDeviceProcAddr(surface.device, "vkDestroySamplerYcbcrConversion")));
        if (pfnDestroy == null) pfnDestroy = @as(?c.PFN_vkDestroySamplerYcbcrConversion, @ptrCast(c.vkGetDeviceProcAddr(surface.device, "vkDestroySamplerYcbcrConversionKHR")));
        if (pfnDestroy) |fn_destroy| fn_destroy(surface.device, texture.ycbcr_conversion, null);
    }
    if (texture.view != null) c.vkDestroyImageView(surface.device, texture.view, null);
    if (texture.memory != null) c.vkFreeMemory(surface.device, texture.memory, null);
    if (texture.image != null) c.vkDestroyImage(surface.device, texture.image, null);
    std.heap.page_allocator.destroy(texture);
}

pub fn setTextureParams(
    surface: *VulkanSurface,
    texture: *VulkanTexture,
    minFilter: u32,
    magFilter: u32,
    wrapS: u32,
    wrapT: u32,
) bool {
    if (builtin.os.tag != .linux) return false;

    const vk_min_filter: u32 = switch (minFilter) {
        0, 2 => 0,
        1, 3 => 1,
        else => return false,
    };
    const vk_mag_filter: u32 = switch (magFilter) {
        0 => 0,
        1 => 1,
        else => return false,
    };
    const vk_mipmap_mode: u32 = switch (minFilter) {
        0, 1 => 0,
        2 => 0,
        3 => 1,
        else => 0,
    };
    const vk_wrap_u: u32 = switch (wrapS) {
        0 => 0,
        1 => 1,
        2 => 2,
        else => return false,
    };
    const vk_wrap_v: u32 = switch (wrapT) {
        0 => 0,
        1 => 1,
        2 => 2,
        else => return false,
    };

    if (texture.sampler != null) {
        c.vkDestroySampler(surface.device, texture.sampler, null);
        texture.sampler = null;
    }

    const sampler_info = std.mem.zeroInit(c.VkSamplerCreateInfo, .{
        .sType = 31,
        .magFilter = vk_mag_filter,
        .minFilter = vk_min_filter,
        .addressModeU = vk_wrap_u,
        .addressModeV = vk_wrap_v,
        .addressModeW = vk_wrap_u,
        .anisotropyEnable = 0,
        .unnormalizedCoordinates = 0,
        .compareEnable = 0,
        .compareOp = 0,
        .mipmapMode = vk_mipmap_mode,
        .minLod = 0,
        .maxLod = 1000,
    });
    var new_sampler: c.VkSampler = null;
    if (c.vkCreateSampler(surface.device, &sampler_info, null, &new_sampler) != c.VK_SUCCESS) {
        return false;
    }
    texture.sampler = new_sampler;

    if (texture.descriptor_set != null) {
        const image_info = c.VkDescriptorImageInfo{
            .sampler = new_sampler,
            .imageView = texture.view,
            .imageLayout = 1,
        };
        const write_info = c.VkWriteDescriptorSet{
            .sType = 35,
            .pNext = null,
            .dstSet = texture.descriptor_set,
            .dstBinding = 0,
            .dstArrayElement = 0,
            .descriptorCount = 1,
            .descriptorType = 1,
            .pImageInfo = @as([*]const c.VkDescriptorImageInfo, @ptrCast(&image_info)),
        };
        c.vkUpdateDescriptorSets(surface.device, 1, @as([*]const c.VkWriteDescriptorSet, @ptrCast(&write_info)), 0, null);
    }

    return true;
}

pub fn readbackTexture(surface: *VulkanSurface, texture: *VulkanTexture, out_buf: ?[*]u8, len: usize) bool {
    if (builtin.os.tag != .linux) return false;
    if (out_buf == null or len == 0) return false;
    if (texture.image == null) return false;

    const log = builtin.mode == .Debug;
    const image_size: usize = @as(usize, texture.width) * @as(usize, texture.height) * 4;
    if (len < image_size) return false;

    const staging_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = @as(u64, image_size),
        .usage = c.VK_BUFFER_USAGE_TRANSFER_DST_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
    });

    var staging: c.VkBuffer = null;
    var r = c.vkCreateBuffer(surface.device, &staging_info, null, &staging);
    if (log) std.debug.print("[Z-GRAPHICS] readbackTexture: vkCreateBuffer staging result={} handle={any}\n", .{ r, staging });
    if (r != c.VK_SUCCESS) return false;

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(surface.device, staging, &mem_reqs);

    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_reqs.size,
        .memoryTypeIndex = 0,
    });

    const props = c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
    c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
    var found: ?u32 = null;
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
    r = c.vkAllocateMemory(surface.device, &alloc_info, null, &staging_mem);
    if (r != c.VK_SUCCESS) {
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }
    r = c.vkBindBufferMemory(surface.device, staging, staging_mem, 0);
    if (r != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    if (surface.transfer_pool == null or surface.transfer_cmd == null) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    _ = c.vkResetCommandPool(surface.device, surface.transfer_pool, 0);

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .flags = 1,
    });
    r = c.vkBeginCommandBuffer(surface.transfer_cmd, &begin_info);
    if (log) std.debug.print("[Z-GRAPHICS] readbackTexture: vkBeginCommandBuffer result={}\n", .{r});

    var barrier: c.VkImageMemoryBarrier = .{
        .sType = 45,
        .srcAccessMask = c.VK_ACCESS_SHADER_READ_BIT,
        .dstAccessMask = c.VK_ACCESS_TRANSFER_READ_BIT,
        .oldLayout = c.VK_IMAGE_LAYOUT_GENERAL,
        .newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
        .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .image = texture.image,
        .subresourceRange = .{
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .baseMipLevel = 0,
            .levelCount = 1,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
    };
    c.vkCmdPipelineBarrier(surface.transfer_cmd, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    var region: c.VkBufferImageCopy = std.mem.zeroes(c.VkBufferImageCopy);
    region.bufferOffset = 0;
    region.bufferRowLength = 0;
    region.bufferImageHeight = 0;
    region.imageSubresource.aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT;
    region.imageSubresource.mipLevel = 0;
    region.imageSubresource.baseArrayLayer = 0;
    region.imageSubresource.layerCount = 1;
    region.imageOffset = .{ .x = 0, .y = 0, .z = 0 };
    region.imageExtent = .{ .width = texture.width, .height = texture.height, .depth = 1 };

    c.vkCmdCopyImageToBuffer(surface.transfer_cmd, texture.image, c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, staging, 1, @ptrCast(&region));

    barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
    barrier.newLayout = c.VK_IMAGE_LAYOUT_GENERAL;
    barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_READ_BIT;
    barrier.dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT;
    c.vkCmdPipelineBarrier(surface.transfer_cmd, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    r = c.vkEndCommandBuffer(surface.transfer_cmd);
    if (log) std.debug.print("[Z-GRAPHICS] readbackTexture: vkEndCommandBuffer result={}\n", .{r});

    const submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO,
        .commandBufferCount = 1,
        .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&surface.transfer_cmd)),
    });
    r = c.vkQueueSubmit(surface.graphics_queue, 1, @ptrCast(&submit_info), surface.fence);
    if (log) std.debug.print("[Z-GRAPHICS] readbackTexture: vkQueueSubmit result={}\n", .{r});
    r = c.vkWaitForFences(surface.device, 1, @ptrCast(&surface.fence), c.VK_TRUE, std.math.maxInt(u64));
    if (log) std.debug.print("[Z-GRAPHICS] readbackTexture: vkWaitForFences result={}\n", .{r});
    _ = c.vkResetFences(surface.device, 1, @ptrCast(&surface.fence));

    var data_ptr: ?*anyopaque = null;
    r = c.vkMapMemory(surface.device, staging_mem, 0, @as(u64, image_size), 0, &data_ptr);
    if (log) std.debug.print("[Z-GRAPHICS] readbackTexture: vkMapMemory result={} ptr={any}\n", .{ r, data_ptr });
    if (r != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    const copy_len = @min(len, image_size);
    @memcpy(out_buf.?[0..copy_len], @as([*]const u8, @ptrCast(@alignCast(data_ptr.?)))[0..copy_len]);
    c.vkUnmapMemory(surface.device, staging_mem);

    c.vkFreeMemory(surface.device, staging_mem, null);
    c.vkDestroyBuffer(surface.device, staging, null);

    if (log) std.debug.print("[Z-GRAPHICS] readbackTexture: complete, {} bytes copied\n", .{copy_len});
    return true;
}

pub const VulkanTimerQuery = struct {
    query_pool: c.VkQueryPool,
    timestamp_period_ns: f64,
    timestamp_valid_bits: u32,
    result_buffer: c.VkBuffer,
    result_memory: c.VkDeviceMemory,
};

pub fn createTimerQuery(surface: *VulkanSurface) ?*VulkanTimerQuery {
    if (builtin.os.tag != .linux) return null;

    var props: c.VkPhysicalDeviceProperties = std.mem.zeroes(c.VkPhysicalDeviceProperties);
    c.vkGetPhysicalDeviceProperties(surface.physical_device, &props);

    const raw_limits = @as([*]const u8, @ptrCast(&props.limits));
    const real_timestamp_period_offset: usize = 424;
    const period_ns = @as(*const f32, @ptrCast(@alignCast(@constCast(&raw_limits[real_timestamp_period_offset])))).*;

    var queue_count: u32 = 0;
    c.vkGetPhysicalDeviceQueueFamilyProperties(surface.physical_device, &queue_count, null);
    var queue_props: [1]c.VkQueueFamilyProperties = undefined;
    c.vkGetPhysicalDeviceQueueFamilyProperties(surface.physical_device, &queue_count, &queue_props);
    const valid_bits = if (queue_count > 0) queue_props[0].timestampValidBits else 0;

    if (valid_bits == 0) {
        std.debug.print("[Z-GRAPHICS] createTimerQuery: timestamp not supported (valid_bits=0)\n", .{});
        return null;
    }

    const pool_info = std.mem.zeroInit(c.VkQueryPoolCreateInfo, .{
        .sType = 42,
        .queryType = 0,
        .queryCount = 2,
    });
    var query_pool: c.VkQueryPool = null;
    const result = c.vkCreateQueryPool(surface.device, &pool_info, null, &query_pool);
    if (result != 0) {
        std.debug.print("[Z-GRAPHICS] createTimerQuery: vkCreateQueryPool failed result={d}\n", .{result});
        return null;
    }

    const buf_size: u64 = @sizeOf(u64) * 2;
    const buf_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = buf_size,
        .usage = c.VK_BUFFER_USAGE_TRANSFER_DST_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
    });
    var result_buffer: c.VkBuffer = null;
    if (c.vkCreateBuffer(surface.device, &buf_info, null, &result_buffer) != c.VK_SUCCESS) {
        c.vkDestroyQueryPool(surface.device, query_pool, null);
        return null;
    }

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(surface.device, result_buffer, &mem_reqs);
    const props2 = c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    var mem_type: ?u32 = null;
    var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
    c.vkGetPhysicalDeviceMemoryProperties(surface.physical_device, &mem_props);
    for (0..mem_props.memoryTypeCount) |i| {
        if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0) {
            if ((mem_props.memoryTypes[i].propertyFlags & props2) == props2) {
                mem_type = @intCast(i);
                break;
            }
        }
    }
    const mem_type_idx = mem_type orelse {
        c.vkDestroyBuffer(surface.device, result_buffer, null);
        c.vkDestroyQueryPool(surface.device, query_pool, null);
        return null;
    };
    var result_memory: c.VkDeviceMemory = null;
    const alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_reqs.size,
        .memoryTypeIndex = mem_type_idx,
    });
    if (c.vkAllocateMemory(surface.device, &alloc_info, null, &result_memory) != c.VK_SUCCESS) {
        c.vkDestroyBuffer(surface.device, result_buffer, null);
        c.vkDestroyQueryPool(surface.device, query_pool, null);
        return null;
    }
    _ = c.vkBindBufferMemory(surface.device, result_buffer, result_memory, 0);

    const period_f64: f64 = if (period_ns > 0.0) @floatCast(period_ns) else 1.0;
    const query = std.heap.page_allocator.create(VulkanTimerQuery) catch {
        c.vkFreeMemory(surface.device, result_memory, null);
        c.vkDestroyBuffer(surface.device, result_buffer, null);
        c.vkDestroyQueryPool(surface.device, query_pool, null);
        return null;
    };
    query.* = .{
        .query_pool = query_pool,
        .timestamp_period_ns = period_f64,
        .timestamp_valid_bits = valid_bits,
        .result_buffer = result_buffer,
        .result_memory = result_memory,
    };
    std.debug.print("[Z-GRAPHICS] createTimerQuery: period_ns={d:.6} valid_bits={d}\n", .{ period_f64, valid_bits });
    return query;
}

pub fn destroyTimerQuery(surface: *VulkanSurface, query: *VulkanTimerQuery) void {
    if (query.result_memory != null) c.vkFreeMemory(surface.device, query.result_memory, null);
    if (query.result_buffer != null) c.vkDestroyBuffer(surface.device, query.result_buffer, null);
    if (query.query_pool != null) c.vkDestroyQueryPool(surface.device, query.query_pool, null);
    std.heap.page_allocator.destroy(query);
}

pub fn cmdResetQueryPool(cmd: *VulkanCommandBuffer, query: *VulkanTimerQuery) void {
    c.vkCmdResetQueryPool(cmd.cmd, query.query_pool, 0, 2);
    c.vkCmdWriteTimestamp(cmd.cmd, c.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, query.query_pool, 0);
}

pub fn cmdWriteTimestamp(cmd: *VulkanCommandBuffer, query: *VulkanTimerQuery, stage: u32, query_index: u32) void {
    c.vkCmdWriteTimestamp(cmd.cmd, stage, query.query_pool, query_index);
}

pub fn cmdWriteTimestampEnd(cmd: *VulkanCommandBuffer, query: *VulkanTimerQuery) void {
    c.vkCmdWriteTimestamp(cmd.cmd, c.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, query.query_pool, 1);
}

pub fn getTimerQueryResults(surface: *VulkanSurface, query: *VulkanTimerQuery) ?f64 {
    _ = c.vkQueueWaitIdle(surface.graphics_queue);

    var timestamps: [2]u64 = undefined;
    const result = c.vkGetQueryPoolResults(
        surface.device,
        query.query_pool,
        0,
        2,
        @sizeOf(u64) * 2,
        @ptrCast(&timestamps),
        @sizeOf(u64),
        0x1,
    );
    if (result != 0) {
        std.debug.print("[Z-GRAPHICS] getTimerQueryResults: vkGetQueryPoolResults result={d} (queries may not be supported by GPU driver)\n", .{result});
        return null;
    }

    std.debug.print("[Z-GRAPHICS] getTimerQueryResults: begin={d} end={d} period={d:.6}\n", .{ timestamps[0], timestamps[1], query.timestamp_period_ns });

    if (timestamps[1] == 0 or timestamps[1] <= timestamps[0]) {
        std.debug.print("[Z-GRAPHICS] getTimerQueryResults: timestamps not ready or invalid\n", .{});
        return null;
    }

    const delta = @as(f64, @floatFromInt(timestamps[1] - timestamps[0]));
    return delta * query.timestamp_period_ns;
}

pub const MRTSurface = struct {
    surface: *VulkanSurface,
    render_pass: c.VkRenderPass,
    framebuffer: c.VkFramebuffer,
    color_images: [8]c.VkImage,
    color_memories: [8]c.VkDeviceMemory,
    color_views: [8]c.VkImageView,
    depth_image: c.VkImage,
    depth_memory: c.VkDeviceMemory,
    depth_view: c.VkImageView,
    attachment_count: u32,
    width: u32,
    height: u32,
    cmd_pool: c.VkCommandPool,
    cmd_buffer: c.VkCommandBuffer,
    began: bool,
};

pub fn createMRTSurface(surface: *VulkanSurface, width: u32, height: u32, attachment_count: u32) ?*MRTSurface {
    if (builtin.os.tag != .linux) return null;
    const count = @min(attachment_count, @as(u32, 8));
    if (count == 0) return null;

    var color_images: [8]c.VkImage = .{null} ** 8;
    var color_memories: [8]c.VkDeviceMemory = .{null} ** 8;
    var color_views: [8]c.VkImageView = .{null} ** 8;

    for (0..count) |i| {
        const image_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
            .imageType = c.VK_IMAGE_TYPE_2D,
            .format = c.VK_FORMAT_R8G8B8A8_UNORM,
            .extent = .{ .width = width, .height = height, .depth = 1 },
            .mipLevels = 1,
            .arrayLayers = 1,
            .samples = c.VK_SAMPLE_COUNT_1_BIT,
            .tiling = c.VK_IMAGE_TILING_OPTIMAL,
            .usage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
            .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
            .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        });
        if (c.vkCreateImage(surface.device, &image_info, null, &color_images[i]) != c.VK_SUCCESS) return null;

        var mem_reqs: c.VkMemoryRequirements = undefined;
        c.vkGetImageMemoryRequirements(surface.device, color_images[i], &mem_reqs);
        const mem_type = findMemoryType(surface.physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse return null;
        const alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = mem_reqs.size, .memoryTypeIndex = mem_type });
        if (c.vkAllocateMemory(surface.device, &alloc_info, null, &color_memories[i]) != c.VK_SUCCESS) return null;
        _ = c.vkBindImageMemory(surface.device, color_images[i], color_memories[i], 0);

        const view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
            .image = color_images[i],
            .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
            .format = c.VK_FORMAT_R8G8B8A8_UNORM,
            .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
        });
        if (c.vkCreateImageView(surface.device, &view_info, null, &color_views[i]) != c.VK_SUCCESS) return null;
    }

    const depth_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .imageType = c.VK_IMAGE_TYPE_2D,
        .format = c.VK_FORMAT_D32_SFLOAT,
        .extent = .{ .width = width, .height = height, .depth = 1 },
        .mipLevels = 1,
        .arrayLayers = 1,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
        .tiling = c.VK_IMAGE_TILING_OPTIMAL,
        .usage = c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
    });
    var depth_image: c.VkImage = null;
    if (c.vkCreateImage(surface.device, &depth_info, null, &depth_image) != c.VK_SUCCESS) return null;
    var d_mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetImageMemoryRequirements(surface.device, depth_image, &d_mem_reqs);
    const d_mem_type = findMemoryType(surface.physical_device, d_mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse return null;
    var depth_memory: c.VkDeviceMemory = null;
    {
        const d_alloc = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = d_mem_reqs.size, .memoryTypeIndex = d_mem_type });
        if (c.vkAllocateMemory(surface.device, &d_alloc, null, &depth_memory) != c.VK_SUCCESS) return null;
        _ = c.vkBindImageMemory(surface.device, depth_image, depth_memory, 0);
    }
    var depth_view: c.VkImageView = null;
    {
        const dv_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
            .image = depth_image,
            .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
            .format = c.VK_FORMAT_D32_SFLOAT,
            .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_DEPTH_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
        });
        if (c.vkCreateImageView(surface.device, &dv_info, null, &depth_view) != c.VK_SUCCESS) return null;
    }

    var attachments: [9]c.VkAttachmentDescription = undefined;
    var color_refs: [8]c.VkAttachmentReference = undefined;
    for (0..count) |i| {
        attachments[i] = std.mem.zeroInit(c.VkAttachmentDescription, .{
            .format = c.VK_FORMAT_R8G8B8A8_UNORM,
            .samples = c.VK_SAMPLE_COUNT_1_BIT,
            .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
            .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,
            .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
            .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
            .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
            .finalLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
        });
        color_refs[i] = .{ .attachment = @intCast(i), .layout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL };
    }
    const depth_idx = count;
    attachments[depth_idx] = std.mem.zeroInit(c.VkAttachmentDescription, .{
        .format = c.VK_FORMAT_D32_SFLOAT,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
        .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
        .storeOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
        .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .finalLayout = c.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    });
    const depth_ref = c.VkAttachmentReference{ .attachment = depth_idx, .layout = c.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL };

    var subpass = std.mem.zeroInit(c.VkSubpassDescription, .{
        .pipelineBindPoint = c.VK_PIPELINE_BIND_POINT_GRAPHICS,
        .colorAttachmentCount = count,
        .pColorAttachments = @as([*]const c.VkAttachmentReference, @ptrCast(&color_refs)),
        .pDepthStencilAttachment = @as(?*const c.VkAttachmentReference, @ptrCast(&depth_ref)),
    });

    const rp_info = c.VkRenderPassCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
        .attachmentCount = count + 1,
        .pAttachments = @as([*]const c.VkAttachmentDescription, @ptrCast(&attachments)),
        .subpassCount = 1,
        .pSubpasses = @as([*]const c.VkSubpassDescription, @ptrCast(&subpass)),
    };
    var render_pass: c.VkRenderPass = null;
    if (c.vkCreateRenderPass(surface.device, &rp_info, null, &render_pass) != c.VK_SUCCESS) return null;

    var fb_attachments: [9]c.VkImageView = undefined;
    for (0..count) |i| fb_attachments[i] = color_views[i];
    fb_attachments[depth_idx] = depth_view;
    const fb_info = c.VkFramebufferCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
        .renderPass = render_pass,
        .attachmentCount = count + 1,
        .pAttachments = @as([*]const c.VkImageView, @ptrCast(&fb_attachments)),
        .width = width,
        .height = height,
        .layers = 1,
    };
    var framebuffer: c.VkFramebuffer = null;
    if (c.vkCreateFramebuffer(surface.device, &fb_info, null, &framebuffer) != c.VK_SUCCESS) return null;

    var cmd_pool: c.VkCommandPool = null;
    var cmd_buffer: c.VkCommandBuffer = null;
    {
        const pool_info = std.mem.zeroInit(c.VkCommandPoolCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO, .queueFamilyIndex = surface.queue_family, .flags = 0x2 });
        if (c.vkCreateCommandPool(surface.device, &pool_info, null, &cmd_pool) == c.VK_SUCCESS) {
            const cb_info = std.mem.zeroInit(c.VkCommandBufferAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = cmd_pool, .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY, .commandBufferCount = 1 });
            _ = c.vkAllocateCommandBuffers(surface.device, &cb_info, @ptrCast(&cmd_buffer));
        }
    }

    const mrt = std.heap.page_allocator.create(MRTSurface) catch return null;
    mrt.* = .{
        .surface = surface,
        .render_pass = render_pass,
        .framebuffer = framebuffer,
        .color_images = color_images,
        .color_memories = color_memories,
        .color_views = color_views,
        .depth_image = depth_image,
        .depth_memory = depth_memory,
        .depth_view = depth_view,
        .attachment_count = count,
        .width = width,
        .height = height,
        .cmd_pool = cmd_pool,
        .cmd_buffer = cmd_buffer,
        .began = false,
    };
    std.debug.print("[Z-GRAPHICS] createMRTSurface: {}x{} attachments={}\n", .{ width, height, count });
    return mrt;
}

pub fn destroyMRTSurface(mrt: *MRTSurface) void {
    if (mrt.cmd_pool != null) c.vkDestroyCommandPool(mrt.surface.device, mrt.cmd_pool, null);
    if (mrt.framebuffer != null) c.vkDestroyFramebuffer(mrt.surface.device, mrt.framebuffer, null);
    if (mrt.render_pass != null) c.vkDestroyRenderPass(mrt.surface.device, mrt.render_pass, null);
    for (0..mrt.attachment_count) |i| {
        if (mrt.color_views[i] != null) c.vkDestroyImageView(mrt.surface.device, mrt.color_views[i], null);
        if (mrt.color_images[i] != null) c.vkDestroyImage(mrt.surface.device, mrt.color_images[i], null);
        if (mrt.color_memories[i] != null) c.vkFreeMemory(mrt.surface.device, mrt.color_memories[i], null);
    }
    if (mrt.depth_view != null) c.vkDestroyImageView(mrt.surface.device, mrt.depth_view, null);
    if (mrt.depth_image != null) c.vkDestroyImage(mrt.surface.device, mrt.depth_image, null);
    if (mrt.depth_memory != null) c.vkFreeMemory(mrt.surface.device, mrt.depth_memory, null);
    std.heap.page_allocator.destroy(mrt);
}

pub fn beginMRTCommandBuffer(mrt: *MRTSurface) ?*VulkanCommandBuffer {
    if (mrt.cmd_pool == null or mrt.cmd_buffer == null) return null;
    _ = c.vkResetCommandPool(mrt.surface.device, mrt.cmd_pool, 0);

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 0 });
    if (c.vkBeginCommandBuffer(mrt.cmd_buffer, &begin_info) != c.VK_SUCCESS) return null;

    const default_colors = [_][4]f32{
        .{ 1.0, 0.0, 0.0, 1.0 },
        .{ 0.0, 1.0, 0.0, 1.0 },
        .{ 0.0, 0.0, 1.0, 1.0 },
        .{ 1.0, 1.0, 0.0, 1.0 },
        .{ 0.0, 1.0, 1.0, 1.0 },
        .{ 1.0, 0.0, 1.0, 1.0 },
        .{ 1.0, 1.0, 1.0, 1.0 },
        .{ 0.5, 0.5, 0.5, 1.0 },
    };
    var clear_values: [9]c.VkClearValue = undefined;
    for (0..mrt.attachment_count) |i| {
        const ci = if (i < default_colors.len) i else 0;
        clear_values[i] = .{ .color = .{ .float32 = default_colors[ci] } };
    }
    clear_values[mrt.attachment_count] = .{ .depthStencil = .{ .depth = 1.0, .stencil = 0 } };

    const rp_begin = std.mem.zeroInit(c.VkRenderPassBeginInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        .renderPass = mrt.render_pass,
        .framebuffer = mrt.framebuffer,
        .renderArea = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = mrt.width, .height = mrt.height } },
        .clearValueCount = mrt.attachment_count + 1,
        .pClearValues = @as([*]const c.VkClearValue, @ptrCast(&clear_values)),
    });
    c.vkCmdBeginRenderPass(mrt.cmd_buffer, &rp_begin, c.VK_SUBPASS_CONTENTS_INLINE);

    const viewport = c.VkViewport{ .x = 0, .y = 0, .width = @floatFromInt(mrt.width), .height = @floatFromInt(mrt.height), .minDepth = 0, .maxDepth = 1 };
    c.vkCmdSetViewport(mrt.cmd_buffer, 0, 1, @as([*]const c.VkViewport, @ptrCast(&viewport)));
    const scissor = c.VkRect2D{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = mrt.width, .height = mrt.height } };
    c.vkCmdSetScissor(mrt.cmd_buffer, 0, 1, @as([*]const c.VkRect2D, @ptrCast(&scissor)));

    mrt.began = true;

    mrt.surface.current_cmd.cmd = mrt.cmd_buffer;
    mrt.surface.current_cmd.pool = mrt.cmd_pool;
    mrt.surface.current_cmd.render_pass_began = true;
    mrt.surface.current_cmd.surface = mrt.surface;
    return &mrt.surface.current_cmd;
}

pub fn endMRTSurface(mrt: *MRTSurface) void {
    if (!mrt.began) return;
    c.vkCmdEndRenderPass(mrt.cmd_buffer);
    mrt.began = false;
    mrt.surface.current_cmd.render_pass_began = false;
    _ = c.vkEndCommandBuffer(mrt.cmd_buffer);

    var submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&mrt.cmd_buffer)) });
    _ = c.vkQueueSubmit(mrt.surface.graphics_queue, 1, @as([*]const c.VkSubmitInfo, @ptrCast(&submit_info)), mrt.surface.fence);
    _ = c.vkWaitForFences(mrt.surface.device, 1, @as([*]const c.VkFence, @ptrCast(&mrt.surface.fence)), c.VK_TRUE, std.math.maxInt(u64));
    _ = c.vkResetFences(mrt.surface.device, 1, @as([*]const c.VkFence, @ptrCast(&mrt.surface.fence)));
}

pub fn readMRTTexture(mrt: *MRTSurface, index: u32, out_buf: ?[*]u8, len: usize) bool {
    if (out_buf == null or len == 0 or index >= mrt.attachment_count) return false;
    const image_size: usize = @as(usize, mrt.width) * @as(usize, mrt.height) * 4;
    if (len < image_size) return false;

    _ = c.vkResetCommandPool(mrt.surface.device, mrt.cmd_pool, 0);
    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 1 });
    _ = c.vkBeginCommandBuffer(mrt.cmd_buffer, &begin_info);

    var barrier: c.VkImageMemoryBarrier = .{
        .sType = 45,
        .srcAccessMask = c.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
        .dstAccessMask = c.VK_ACCESS_TRANSFER_READ_BIT,
        .oldLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
        .newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
        .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .image = mrt.color_images[index],
        .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
    };
    c.vkCmdPipelineBarrier(mrt.cmd_buffer, c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    const staging_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .size = @as(u64, image_size), .usage = c.VK_BUFFER_USAGE_TRANSFER_DST_BIT, .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE });
    var staging: c.VkBuffer = null;
    if (c.vkCreateBuffer(mrt.surface.device, &staging_info, null, &staging) != c.VK_SUCCESS) return false;

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(mrt.surface.device, staging, &mem_reqs);
    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = mem_reqs.size, .memoryTypeIndex = 0 });
    const props = c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    var mem_type: ?u32 = null;
    var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
    c.vkGetPhysicalDeviceMemoryProperties(mrt.surface.physical_device, &mem_props);
    for (0..mem_props.memoryTypeCount) |i| {
        if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0 and (mem_props.memoryTypes[i].propertyFlags & props) == props) {
            mem_type = @intCast(i);
            break;
        }
    }
    alloc_info.memoryTypeIndex = mem_type orelse {
        c.vkDestroyBuffer(mrt.surface.device, staging, null);
        return false;
    };
    var staging_mem: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(mrt.surface.device, &alloc_info, null, &staging_mem) != c.VK_SUCCESS) {
        c.vkDestroyBuffer(mrt.surface.device, staging, null);
        return false;
    }
    _ = c.vkBindBufferMemory(mrt.surface.device, staging, staging_mem, 0);

    var region: c.VkBufferImageCopy = std.mem.zeroes(c.VkBufferImageCopy);
    region.imageSubresource.aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT;
    region.imageSubresource.layerCount = 1;
    region.imageExtent = .{ .width = mrt.width, .height = mrt.height, .depth = 1 };
    c.vkCmdCopyImageToBuffer(mrt.cmd_buffer, mrt.color_images[index], c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, staging, 1, @ptrCast(&region));

    barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
    barrier.newLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
    barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_READ_BIT;
    barrier.dstAccessMask = c.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
    c.vkCmdPipelineBarrier(mrt.cmd_buffer, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    _ = c.vkEndCommandBuffer(mrt.cmd_buffer);
    var submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&mrt.cmd_buffer)) });
    _ = c.vkQueueSubmit(mrt.surface.graphics_queue, 1, @as([*]const c.VkSubmitInfo, @ptrCast(&submit_info)), mrt.surface.fence);
    _ = c.vkWaitForFences(mrt.surface.device, 1, @as([*]const c.VkFence, @ptrCast(&mrt.surface.fence)), c.VK_TRUE, std.math.maxInt(u64));
    _ = c.vkResetFences(mrt.surface.device, 1, @as([*]const c.VkFence, @ptrCast(&mrt.surface.fence)));

    var data_ptr: ?*anyopaque = null;
    _ = c.vkMapMemory(mrt.surface.device, staging_mem, 0, @as(u64, image_size), 0, &data_ptr);
    if (data_ptr) |ptr| {
        @memcpy(out_buf.?[0..image_size], @as([*]const u8, @ptrCast(@alignCast(ptr)))[0..image_size]);
    }
    c.vkUnmapMemory(mrt.surface.device, staging_mem);
    c.vkFreeMemory(mrt.surface.device, staging_mem, null);
    c.vkDestroyBuffer(mrt.surface.device, staging, null);
    return true;
}

pub const StencilSurface = struct {
    surface: *VulkanSurface,
    render_pass: c.VkRenderPass,
    framebuffer: c.VkFramebuffer,
    color_image: c.VkImage,
    color_memory: c.VkDeviceMemory,
    color_view: c.VkImageView,
    depth_image: c.VkImage,
    depth_memory: c.VkDeviceMemory,
    depth_view: c.VkImageView,
    write_pipeline: c.VkPipeline,
    write_pipeline_layout: c.VkPipelineLayout,
    write_dsl: c.VkDescriptorSetLayout,
    test_pipeline: c.VkPipeline,
    test_pipeline_layout: c.VkPipelineLayout,
    test_dsl: c.VkDescriptorSetLayout,
    width: u32,
    height: u32,
    cmd_pool: c.VkCommandPool,
    cmd_buffer: c.VkCommandBuffer,
    sampler: c.VkSampler,
    descriptor_set: c.VkDescriptorSet,
    began: bool,
};
fn createStencilPipelineWithState(
    surface: *VulkanSurface,
    render_pass: c.VkRenderPass,
    vert_module: c.VkShaderModule,
    frag_module: c.VkShaderModule,
    compare_op: u32,
    pass_op: u32,
    fail_op: u32,
    depth_fail_op: u32,
    reference: u32,
    write_mask: u32,
    compare_mask: u32,
    desc: ?*const @import("lib.zig").PipelineDesc,
) ?struct { pipeline: c.VkPipeline, layout: c.VkPipelineLayout, dsl: c.VkDescriptorSetLayout } {
    const shader_stages = [_]c.VkPipelineShaderStageCreateInfo{
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_VERTEX_BIT, .module = vert_module, .pName = "main" },
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_FRAGMENT_BIT, .module = frag_module, .pName = "main" },
    };

    var vertex_input_info: c.VkPipelineVertexInputStateCreateInfo = undefined;
    vertex_input_info.sType = 19;
    vertex_input_info.pNext = null;
    vertex_input_info.flags = 0;
    vertex_input_info.vertexBindingDescriptionCount = 0;
    vertex_input_info.vertexAttributeDescriptionCount = 0;
    vertex_input_info.pVertexBindingDescriptions = null;
    vertex_input_info.pVertexAttributeDescriptions = null;

    const input_assembly = std.mem.zeroInit(c.VkPipelineInputAssemblyStateCreateInfo, .{ .sType = 20, .topology = c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, .primitiveRestartEnable = 0 });
    const dynamic_states = [_]u32{ c.VK_DYNAMIC_STATE_VIEWPORT, c.VK_DYNAMIC_STATE_SCISSOR, c.VK_DYNAMIC_STATE_STENCIL_REFERENCE };
    var dynamic_state_info = c.VkPipelineDynamicStateCreateInfo{ .sType = 27, .dynamicStateCount = 3, .pDynamicStates = @as([*]const u32, @ptrCast(&dynamic_states)) };
    const viewport_state = std.mem.zeroInit(c.VkPipelineViewportStateCreateInfo, .{ .sType = 22, .viewportCount = 1, .scissorCount = 1 });
    const rasterizer = std.mem.zeroInit(c.VkPipelineRasterizationStateCreateInfo, .{ .sType = 23, .depthClampEnable = 0, .rasterizerDiscardEnable = 0, .polygonMode = c.VK_POLYGON_MODE_FILL, .lineWidth = 1, .cullMode = c.VK_CULL_MODE_NONE, .frontFace = c.VK_FRONT_FACE_CLOCKWISE, .depthBiasEnable = 0 });
    const multisampling = std.mem.zeroInit(c.VkPipelineMultisampleStateCreateInfo, .{ .sType = 24, .rasterizationSamples = c.VK_SAMPLE_COUNT_1_BIT });
    const color_blend_attachment = std.mem.zeroInit(c.VkPipelineColorBlendAttachmentState, .{
        .colorWriteMask = 0xF,
        .blendEnable = if (desc) |d| d.blend_enable else 0,
        .srcColorBlendFactor = if (desc) |d| d.src_color_blend_factor else 0,
        .dstColorBlendFactor = if (desc) |d| d.dst_color_blend_factor else 0,
        .colorBlendOp = if (desc) |d| d.color_blend_op else 0,
        .srcAlphaBlendFactor = if (desc) |d| d.src_alpha_blend_factor else 0,
        .dstAlphaBlendFactor = if (desc) |d| d.dst_alpha_blend_factor else 0,
        .alphaBlendOp = if (desc) |d| d.alpha_blend_op else 0,
    });
    const color_blending = std.mem.zeroInit(c.VkPipelineColorBlendStateCreateInfo, .{ .sType = 26, .logicOpEnable = 0, .attachmentCount = 1, .pAttachments = @as([*]const c.VkPipelineColorBlendAttachmentState, @ptrCast(&color_blend_attachment)) });

    const depth_stencil = c.VkPipelineDepthStencilStateCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
        .depthTestEnable = 0,
        .depthWriteEnable = 0,
        .depthCompareOp = c.VK_COMPARE_OP_ALWAYS,
        .depthBoundsTestEnable = 0,
        .stencilTestEnable = 1,
        .front = .{ .failOp = fail_op, .passOp = pass_op, .depthFailOp = depth_fail_op, .compareOp = compare_op, .compareMask = compare_mask, .writeMask = write_mask, .reference = reference },
        .back = .{ .failOp = fail_op, .passOp = pass_op, .depthFailOp = depth_fail_op, .compareOp = compare_op, .compareMask = compare_mask, .writeMask = write_mask, .reference = reference },
        .minDepthBounds = 0,
        .maxDepthBounds = 1,
    };

    const dsl_bindings = [_]c.VkDescriptorSetLayoutBinding{
        .{ .binding = 0, .descriptorType = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, .descriptorCount = 1, .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT },
        .{ .binding = 1, .descriptorType = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, .descriptorCount = 1, .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT },
    };
    const dsl_info = c.VkDescriptorSetLayoutCreateInfo{ .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO, .bindingCount = dsl_bindings.len, .pBindings = @as([*]const c.VkDescriptorSetLayoutBinding, @ptrCast(&dsl_bindings)) };
    var dsl: c.VkDescriptorSetLayout = null;
    if (c.vkCreateDescriptorSetLayout(surface.device, &dsl_info, null, &dsl) != c.VK_SUCCESS) return null;

    const layout_info = c.VkPipelineLayoutCreateInfo{ .sType = 30, .setLayoutCount = 1, .pSetLayouts = @as(?*const anyopaque, @ptrCast(&dsl)) };
    var layout: c.VkPipelineLayout = null;
    if (c.vkCreatePipelineLayout(surface.device, &layout_info, null, &layout) != c.VK_SUCCESS) {
        c.vkDestroyDescriptorSetLayout(surface.device, dsl, null);
        return null;
    }

    const pipeline_info = c.VkGraphicsPipelineCreateInfo{
        .sType = 28,
        .stageCount = 2,
        .pStages = @as([*]const c.VkPipelineShaderStageCreateInfo, @ptrCast(&shader_stages)),
        .pVertexInputState = &vertex_input_info,
        .pInputAssemblyState = &input_assembly,
        .pViewportState = &viewport_state,
        .pRasterizationState = &rasterizer,
        .pMultisampleState = &multisampling,
        .pDepthStencilState = @as(?*const anyopaque, @ptrCast(&depth_stencil)),
        .pColorBlendState = &color_blending,
        .pDynamicState = &dynamic_state_info,
        .layout = layout,
        .renderPass = render_pass,
        .subpass = 0,
    };
    var pipeline: c.VkPipeline = null;
    if (c.vkCreateGraphicsPipelines(surface.device, null, 1, @as([*]const c.VkGraphicsPipelineCreateInfo, @ptrCast(&pipeline_info)), null, &pipeline) != c.VK_SUCCESS) {
        c.vkDestroyPipelineLayout(surface.device, layout, null);
        c.vkDestroyDescriptorSetLayout(surface.device, dsl, null);
        return null;
    }

    return .{ .pipeline = pipeline, .layout = layout, .dsl = dsl };
}

pub fn createStencilSurface(surface: *VulkanSurface, width: u32, height: u32) ?*StencilSurface {
    if (builtin.os.tag != .linux) return null;

    var color_image: c.VkImage = null;
    var color_memory: c.VkDeviceMemory = null;
    var color_view: c.VkImageView = null;
    {
        const info = std.mem.zeroInit(c.VkImageCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
            .imageType = c.VK_IMAGE_TYPE_2D,
            .format = c.VK_FORMAT_R8G8B8A8_UNORM,
            .extent = .{ .width = width, .height = height, .depth = 1 },
            .mipLevels = 1,
            .arrayLayers = 1,
            .samples = c.VK_SAMPLE_COUNT_1_BIT,
            .tiling = c.VK_IMAGE_TILING_OPTIMAL,
            .usage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
            .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
            .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        });
        if (c.vkCreateImage(surface.device, &info, null, &color_image) != c.VK_SUCCESS) return null;
        var mr: c.VkMemoryRequirements = undefined;
        c.vkGetImageMemoryRequirements(surface.device, color_image, &mr);
        const mt = findMemoryType(surface.physical_device, mr.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse return null;
        const ai = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = mr.size, .memoryTypeIndex = mt });
        if (c.vkAllocateMemory(surface.device, &ai, null, &color_memory) != c.VK_SUCCESS) return null;
        _ = c.vkBindImageMemory(surface.device, color_image, color_memory, 0);
        const vi = std.mem.zeroInit(c.VkImageViewCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, .image = color_image, .viewType = c.VK_IMAGE_VIEW_TYPE_2D, .format = c.VK_FORMAT_R8G8B8A8_UNORM, .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .levelCount = 1, .layerCount = 1 } });
        if (c.vkCreateImageView(surface.device, &vi, null, &color_view) != c.VK_SUCCESS) return null;
    }

    var depth_image: c.VkImage = null;
    var depth_memory: c.VkDeviceMemory = null;
    var depth_view: c.VkImageView = null;
    {
        const info = std.mem.zeroInit(c.VkImageCreateInfo, .{
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
            .imageType = c.VK_IMAGE_TYPE_2D,
            .format = c.VK_FORMAT_D32_SFLOAT_S8_UINT,
            .extent = .{ .width = width, .height = height, .depth = 1 },
            .mipLevels = 1,
            .arrayLayers = 1,
            .samples = c.VK_SAMPLE_COUNT_1_BIT,
            .tiling = c.VK_IMAGE_TILING_OPTIMAL,
            .usage = c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT,
            .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
            .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        });
        if (c.vkCreateImage(surface.device, &info, null, &depth_image) != c.VK_SUCCESS) {
            const info2 = std.mem.zeroInit(c.VkImageCreateInfo, .{
                .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
                .imageType = c.VK_IMAGE_TYPE_2D,
                .format = c.VK_FORMAT_D24_UNORM_S8_UINT,
                .extent = .{ .width = width, .height = height, .depth = 1 },
                .mipLevels = 1,
                .arrayLayers = 1,
                .samples = c.VK_SAMPLE_COUNT_1_BIT,
                .tiling = c.VK_IMAGE_TILING_OPTIMAL,
                .usage = c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT,
                .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
                .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
            });
            _ = c.vkCreateImage(surface.device, &info2, null, &depth_image);
        }
        if (depth_image == null) return null;
        var mr: c.VkMemoryRequirements = undefined;
        c.vkGetImageMemoryRequirements(surface.device, depth_image, &mr);
        const mt = findMemoryType(surface.physical_device, mr.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse return null;
        const ai = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = mr.size, .memoryTypeIndex = mt });
        if (c.vkAllocateMemory(surface.device, &ai, null, &depth_memory) != c.VK_SUCCESS) return null;
        _ = c.vkBindImageMemory(surface.device, depth_image, depth_memory, 0);
        const vi = std.mem.zeroInit(c.VkImageViewCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, .image = depth_image, .viewType = c.VK_IMAGE_VIEW_TYPE_2D, .format = c.VK_FORMAT_D32_SFLOAT_S8_UINT, .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_DEPTH_BIT | c.VK_IMAGE_ASPECT_STENCIL_BIT, .levelCount = 1, .layerCount = 1 } });
        _ = c.vkCreateImageView(surface.device, &vi, null, &depth_view);
    }

    var attachments: [2]c.VkAttachmentDescription = undefined;
    attachments[0] = std.mem.zeroInit(c.VkAttachmentDescription, .{
        .format = c.VK_FORMAT_R8G8B8A8_UNORM,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
        .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
        .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,
        .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .finalLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
    });
    attachments[1] = std.mem.zeroInit(c.VkAttachmentDescription, .{
        .format = c.VK_FORMAT_D32_SFLOAT_S8_UINT,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
        .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
        .storeOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
        .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
        .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_STORE,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .finalLayout = c.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    });
    const color_ref = c.VkAttachmentReference{ .attachment = 0, .layout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL };
    const depth_ref = c.VkAttachmentReference{ .attachment = 1, .layout = c.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL };
    var subpass = std.mem.zeroInit(c.VkSubpassDescription, .{
        .pipelineBindPoint = c.VK_PIPELINE_BIND_POINT_GRAPHICS,
        .colorAttachmentCount = 1,
        .pColorAttachments = @as([*]const c.VkAttachmentReference, @ptrCast(&color_ref)),
        .pDepthStencilAttachment = @as(?*const c.VkAttachmentReference, @ptrCast(&depth_ref)),
    });
    const rp_info = c.VkRenderPassCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
        .attachmentCount = 2,
        .pAttachments = @as([*]const c.VkAttachmentDescription, @ptrCast(&attachments)),
        .subpassCount = 1,
        .pSubpasses = @as([*]const c.VkSubpassDescription, @ptrCast(&subpass)),
    };
    var render_pass: c.VkRenderPass = null;
    if (c.vkCreateRenderPass(surface.device, &rp_info, null, &render_pass) != c.VK_SUCCESS) return null;

    const fb_attachments = [_]c.VkImageView{ color_view, depth_view };
    const fb_info = c.VkFramebufferCreateInfo{ .sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO, .renderPass = render_pass, .attachmentCount = 2, .pAttachments = @as([*]const c.VkImageView, @ptrCast(&fb_attachments)), .width = width, .height = height, .layers = 1 };
    var framebuffer: c.VkFramebuffer = null;
    if (c.vkCreateFramebuffer(surface.device, &fb_info, null, &framebuffer) != c.VK_SUCCESS) return null;

    const shaders = @import("shaders");
    const sv_module = createShaderModule(surface.device, shaders.vert) orelse return null;
    defer c.vkDestroyShaderModule(surface.device, sv_module, null);
    const sf_module = createShaderModule(surface.device, shaders.frag) orelse return null;
    defer c.vkDestroyShaderModule(surface.device, sf_module, null);

    const write_result = createStencilPipelineWithState(surface, render_pass, sv_module, sf_module, c.VK_COMPARE_OP_ALWAYS, c.VK_STENCIL_OP_REPLACE, c.VK_STENCIL_OP_KEEP, c.VK_STENCIL_OP_KEEP, 1, 0xFF, 0xFF, null) orelse return null;
    const test_result = createStencilPipelineWithState(surface, render_pass, sv_module, sf_module, c.VK_COMPARE_OP_EQUAL, c.VK_STENCIL_OP_KEEP, c.VK_STENCIL_OP_KEEP, c.VK_STENCIL_OP_KEEP, 1, 0x00, 0xFF, null) orelse return null;

    const sampler_info = std.mem.zeroInit(c.VkSamplerCreateInfo, .{
        .sType = 35, // VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO
        .magFilter = 1, // VK_FILTER_LINEAR
        .minFilter = 1, // VK_FILTER_LINEAR
        .addressModeU = 1, // VK_SAMPLER_ADDRESS_MODE_REPEAT
        .addressModeV = 1,
        .addressModeW = 1,
        .anisotropyEnable = 0,
        .unnormalizedCoordinates = 0,
        .compareEnable = 0,
        .compareOp = 0,
        .mipmapMode = 0,
    });
    var sampler: c.VkSampler = null;
    if (c.vkCreateSampler(surface.device, &sampler_info, null, &sampler) != c.VK_SUCCESS) return null;

    var descriptor_set: c.VkDescriptorSet = null;
    const alloc_info = c.VkDescriptorSetAllocateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .pNext = null,
        .descriptorPool = surface.descriptor_pool,
        .descriptorSetCount = 1,
        .pSetLayouts = @as([*]const c.VkDescriptorSetLayout, @ptrCast(&write_result.dsl)),
    };
    if (c.vkAllocateDescriptorSets(surface.device, &alloc_info, &descriptor_set) != 0) {
        c.vkDestroySampler(surface.device, sampler, null);
        return null;
    }

    const image_info = c.VkDescriptorImageInfo{
        .sampler = sampler,
        .imageView = color_view,
        .imageLayout = 1, // VK_IMAGE_LAYOUT_GENERAL
    };
    const write_info = c.VkWriteDescriptorSet{
        .sType = c.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
        .pNext = null,
        .dstSet = descriptor_set,
        .dstBinding = 0,
        .dstArrayElement = 0,
        .descriptorCount = 1,
        .descriptorType = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
        .pImageInfo = @as([*]const c.VkDescriptorImageInfo, @ptrCast(&image_info)),
    };
    c.vkUpdateDescriptorSets(surface.device, 1, @as([*]const c.VkWriteDescriptorSet, @ptrCast(&write_info)), 0, null);

    var cmd_pool: c.VkCommandPool = null;
    var cmd_buffer: c.VkCommandBuffer = null;
    {
        const pool_info = std.mem.zeroInit(c.VkCommandPoolCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO, .queueFamilyIndex = surface.queue_family, .flags = 0x2 });
        if (c.vkCreateCommandPool(surface.device, &pool_info, null, &cmd_pool) == c.VK_SUCCESS) {
            const cb_info = std.mem.zeroInit(c.VkCommandBufferAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = cmd_pool, .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY, .commandBufferCount = 1 });
            _ = c.vkAllocateCommandBuffers(surface.device, &cb_info, @ptrCast(&cmd_buffer));
        }
    }

    const stencil = std.heap.page_allocator.create(StencilSurface) catch return null;
    stencil.* = .{
        .surface = surface,
        .render_pass = render_pass,
        .framebuffer = framebuffer,
        .color_image = color_image,
        .color_memory = color_memory,
        .color_view = color_view,
        .depth_image = depth_image,
        .depth_memory = depth_memory,
        .depth_view = depth_view,
        .write_pipeline = write_result.pipeline,
        .write_pipeline_layout = write_result.layout,
        .write_dsl = write_result.dsl,
        .test_pipeline = test_result.pipeline,
        .test_pipeline_layout = test_result.layout,
        .test_dsl = test_result.dsl,
        .width = width,
        .height = height,
        .cmd_pool = cmd_pool,
        .cmd_buffer = cmd_buffer,
        .sampler = sampler,
        .descriptor_set = descriptor_set,
        .began = false,
    };
    std.debug.print("[Z-GRAPHICS] createStencilSurface: {}x{} OK\n", .{ width, height });
    return stencil;
}

pub fn destroyStencilSurface(stencil: *StencilSurface) void {
    if (stencil.cmd_pool != null) c.vkDestroyCommandPool(stencil.surface.device, stencil.cmd_pool, null);
    if (stencil.framebuffer != null) c.vkDestroyFramebuffer(stencil.surface.device, stencil.framebuffer, null);
    if (stencil.write_pipeline != null) c.vkDestroyPipeline(stencil.surface.device, stencil.write_pipeline, null);
    if (stencil.write_pipeline_layout != null) c.vkDestroyPipelineLayout(stencil.surface.device, stencil.write_pipeline_layout, null);
    if (stencil.write_dsl != null) c.vkDestroyDescriptorSetLayout(stencil.surface.device, stencil.write_dsl, null);
    if (stencil.test_pipeline != null) c.vkDestroyPipeline(stencil.surface.device, stencil.test_pipeline, null);
    if (stencil.test_pipeline_layout != null) c.vkDestroyPipelineLayout(stencil.surface.device, stencil.test_pipeline_layout, null);
    if (stencil.test_dsl != null) c.vkDestroyDescriptorSetLayout(stencil.surface.device, stencil.test_dsl, null);
    if (stencil.render_pass != null) c.vkDestroyRenderPass(stencil.surface.device, stencil.render_pass, null);
    if (stencil.descriptor_set != null and stencil.surface.descriptor_pool != null) {
        _ = c.vkFreeDescriptorSets(stencil.surface.device, stencil.surface.descriptor_pool, 1, @as([*]const c.VkDescriptorSet, @ptrCast(&stencil.descriptor_set)));
    }
    if (stencil.sampler != null) c.vkDestroySampler(stencil.surface.device, stencil.sampler, null);
    if (stencil.color_view != null) c.vkDestroyImageView(stencil.surface.device, stencil.color_view, null);
    if (stencil.color_image != null) c.vkDestroyImage(stencil.surface.device, stencil.color_image, null);
    if (stencil.color_memory != null) c.vkFreeMemory(stencil.surface.device, stencil.color_memory, null);
    if (stencil.depth_view != null) c.vkDestroyImageView(stencil.surface.device, stencil.depth_view, null);
    if (stencil.depth_image != null) c.vkDestroyImage(stencil.surface.device, stencil.depth_image, null);
    if (stencil.depth_memory != null) c.vkFreeMemory(stencil.surface.device, stencil.depth_memory, null);
    std.heap.page_allocator.destroy(stencil);
}

pub fn beginStencilCommandBuffer(stencil: *StencilSurface) ?*VulkanCommandBuffer {
    if (stencil.cmd_pool == null or stencil.cmd_buffer == null) return null;
    _ = c.vkResetCommandPool(stencil.surface.device, stencil.cmd_pool, 0);

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 0 });
    if (c.vkBeginCommandBuffer(stencil.cmd_buffer, &begin_info) != c.VK_SUCCESS) return null;

    const clear_values = [_]c.VkClearValue{
        .{ .color = .{ .float32 = .{ 0.0, 0.0, 0.0, 1.0 } } },
        .{ .depthStencil = .{ .depth = 1.0, .stencil = 0 } },
    };
    const rp_begin = std.mem.zeroInit(c.VkRenderPassBeginInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        .renderPass = stencil.render_pass,
        .framebuffer = stencil.framebuffer,
        .renderArea = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = stencil.width, .height = stencil.height } },
        .clearValueCount = 2,
        .pClearValues = @as([*]const c.VkClearValue, @ptrCast(&clear_values)),
    });
    c.vkCmdBeginRenderPass(stencil.cmd_buffer, &rp_begin, c.VK_SUBPASS_CONTENTS_INLINE);

    const viewport = c.VkViewport{ .x = 0, .y = 0, .width = @floatFromInt(stencil.width), .height = @floatFromInt(stencil.height), .minDepth = 0, .maxDepth = 1 };
    c.vkCmdSetViewport(stencil.cmd_buffer, 0, 1, @as([*]const c.VkViewport, @ptrCast(&viewport)));
    const scissor = c.VkRect2D{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = stencil.width, .height = stencil.height } };
    c.vkCmdSetScissor(stencil.cmd_buffer, 0, 1, @as([*]const c.VkRect2D, @ptrCast(&scissor)));

    stencil.began = true;
    stencil.surface.current_cmd.cmd = stencil.cmd_buffer;
    stencil.surface.current_cmd.pool = stencil.cmd_pool;
    stencil.surface.current_cmd.render_pass_began = true;
    stencil.surface.current_cmd.surface = stencil.surface;
    return &stencil.surface.current_cmd;
}

pub fn endStencilSurface(stencil: *StencilSurface) void {
    if (!stencil.began) return;
    c.vkCmdEndRenderPass(stencil.cmd_buffer);
    stencil.began = false;
    stencil.surface.current_cmd.render_pass_began = false;
    _ = c.vkEndCommandBuffer(stencil.cmd_buffer);

    var submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&stencil.cmd_buffer)) });
    _ = c.vkQueueSubmit(stencil.surface.graphics_queue, 1, @as([*]const c.VkSubmitInfo, @ptrCast(&submit_info)), stencil.surface.fence);
    _ = c.vkWaitForFences(stencil.surface.device, 1, @as([*]const c.VkFence, @ptrCast(&stencil.surface.fence)), c.VK_TRUE, std.math.maxInt(u64));
    _ = c.vkResetFences(stencil.surface.device, 1, @as([*]const c.VkFence, @ptrCast(&stencil.surface.fence)));
}

pub fn cmdBindStencilPipeline(cmd: *VulkanCommandBuffer, pipeline: c.VkPipeline, layout: c.VkPipelineLayout, descriptor_set: c.VkDescriptorSet) void {
    c.vkCmdBindPipeline(cmd.cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, pipeline);
    cmd.pipeline_layout = layout;
    if (descriptor_set != null) {
        c.vkCmdBindDescriptorSets(cmd.cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, layout, 0, 1, @as([*]const c.VkDescriptorSet, @ptrCast(&descriptor_set)), 0, null);
    }
}

pub fn cmdSetStencilMask(cmd: *VulkanCommandBuffer, face_mask: u32, reference: u32) void {
    c.vkCmdSetStencilReference(cmd.cmd, face_mask, reference);
}

pub fn readStencilColorTexture(stencil: *StencilSurface, out_buf: ?[*]u8, len: usize) bool {
    if (out_buf == null or len == 0) return false;
    const image_size: usize = @as(usize, stencil.width) * @as(usize, stencil.height) * 4;
    if (len < image_size) return false;

    _ = c.vkResetCommandPool(stencil.surface.device, stencil.cmd_pool, 0);
    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 1 });
    _ = c.vkBeginCommandBuffer(stencil.cmd_buffer, &begin_info);

    var barrier: c.VkImageMemoryBarrier = .{
        .sType = 45,
        .srcAccessMask = c.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
        .dstAccessMask = c.VK_ACCESS_TRANSFER_READ_BIT,
        .oldLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
        .newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
        .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
        .image = stencil.color_image,
        .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .levelCount = 1, .layerCount = 1 },
    };
    c.vkCmdPipelineBarrier(stencil.cmd_buffer, c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    const staging_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .size = @as(u64, image_size), .usage = c.VK_BUFFER_USAGE_TRANSFER_DST_BIT, .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE });
    var staging: c.VkBuffer = null;
    if (c.vkCreateBuffer(stencil.surface.device, &staging_info, null, &staging) != c.VK_SUCCESS) return false;

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetBufferMemoryRequirements(stencil.surface.device, staging, &mem_reqs);
    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{ .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = mem_reqs.size });
    const props = c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    var mem_type: ?u32 = null;
    var mem_props: c.VkPhysicalDeviceMemoryProperties = undefined;
    c.vkGetPhysicalDeviceMemoryProperties(stencil.surface.physical_device, &mem_props);
    for (0..mem_props.memoryTypeCount) |i| {
        if ((mem_reqs.memoryTypeBits & (@as(u32, 1) << @intCast(i))) != 0 and (mem_props.memoryTypes[i].propertyFlags & props) == props) {
            mem_type = @intCast(i);
            break;
        }
    }
    alloc_info.memoryTypeIndex = mem_type orelse {
        c.vkDestroyBuffer(stencil.surface.device, staging, null);
        return false;
    };
    var staging_mem: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(stencil.surface.device, &alloc_info, null, &staging_mem) != c.VK_SUCCESS) {
        c.vkDestroyBuffer(stencil.surface.device, staging, null);
        return false;
    }
    _ = c.vkBindBufferMemory(stencil.surface.device, staging, staging_mem, 0);

    var region: c.VkBufferImageCopy = std.mem.zeroes(c.VkBufferImageCopy);
    region.imageSubresource.aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT;
    region.imageSubresource.layerCount = 1;
    region.imageExtent = .{ .width = stencil.width, .height = stencil.height, .depth = 1 };
    c.vkCmdCopyImageToBuffer(stencil.cmd_buffer, stencil.color_image, c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, staging, 1, @ptrCast(&region));

    barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
    barrier.newLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
    barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_READ_BIT;
    barrier.dstAccessMask = c.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
    c.vkCmdPipelineBarrier(stencil.cmd_buffer, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    _ = c.vkEndCommandBuffer(stencil.cmd_buffer);
    var submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&stencil.cmd_buffer)) });
    _ = c.vkQueueSubmit(stencil.surface.graphics_queue, 1, @as([*]const c.VkSubmitInfo, @ptrCast(&submit_info)), stencil.surface.fence);
    _ = c.vkWaitForFences(stencil.surface.device, 1, @as([*]const c.VkFence, @ptrCast(&stencil.surface.fence)), c.VK_TRUE, std.math.maxInt(u64));
    _ = c.vkResetFences(stencil.surface.device, 1, @as([*]const c.VkFence, @ptrCast(&stencil.surface.fence)));

    var data_ptr: ?*anyopaque = null;
    _ = c.vkMapMemory(stencil.surface.device, staging_mem, 0, @as(u64, image_size), 0, &data_ptr);
    if (data_ptr) |ptr| {
        @memcpy(out_buf.?[0..image_size], @as([*]const u8, @ptrCast(@alignCast(ptr)))[0..image_size]);
    }
    c.vkUnmapMemory(stencil.surface.device, staging_mem);
    c.vkFreeMemory(stencil.surface.device, staging_mem, null);
    c.vkDestroyBuffer(stencil.surface.device, staging, null);
    return true;
}

pub fn createStencilPipeline(surface: *VulkanSurface, desc: *const @import("lib.zig").PipelineDesc) ?*VulkanPipeline {
    if (builtin.os.tag != .linux) return null;
    const vert_code = desc.vertex_shader.?[0..desc.vertex_shader_len];
    const frag_code = desc.pixel_shader.?[0..desc.pixel_shader_len];
    const vert_module = createShaderModule(surface.device, vert_code) orelse return null;
    defer c.vkDestroyShaderModule(surface.device, vert_module, null);
    const frag_module = createShaderModule(surface.device, frag_code) orelse return null;
    defer c.vkDestroyShaderModule(surface.device, frag_module, null);

    const shader_stages = [_]c.VkPipelineShaderStageCreateInfo{
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_VERTEX_BIT, .module = vert_module, .pName = "main" },
        .{ .sType = 18, .stage = c.VK_SHADER_STAGE_FRAGMENT_BIT, .module = frag_module, .pName = "main" },
    };

    var vertex_input_info: c.VkPipelineVertexInputStateCreateInfo = undefined;
    vertex_input_info.sType = 19;
    vertex_input_info.pNext = null;
    vertex_input_info.flags = 0;
    vertex_input_info.vertexBindingDescriptionCount = 0;
    vertex_input_info.vertexAttributeDescriptionCount = 0;
    vertex_input_info.pVertexBindingDescriptions = null;
    vertex_input_info.pVertexAttributeDescriptions = null;

    const input_assembly = std.mem.zeroInit(c.VkPipelineInputAssemblyStateCreateInfo, .{ .sType = 20, .topology = c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, .primitiveRestartEnable = 0 });
    const dynamic_states = [_]u32{ 9, 10 };
    var dynamic_state_info = c.VkPipelineDynamicStateCreateInfo{ .sType = 27, .dynamicStateCount = 2, .pDynamicStates = @as([*]const u32, @ptrCast(&dynamic_states)) };
    const viewport_state = std.mem.zeroInit(c.VkPipelineViewportStateCreateInfo, .{ .sType = 22, .viewportCount = 1, .scissorCount = 1 });
    const rasterizer = std.mem.zeroInit(c.VkPipelineRasterizationStateCreateInfo, .{ .sType = 23, .depthClampEnable = 0, .rasterizerDiscardEnable = 0, .polygonMode = c.VK_POLYGON_MODE_FILL, .lineWidth = 1, .cullMode = c.VK_CULL_MODE_NONE, .frontFace = c.VK_FRONT_FACE_CLOCKWISE, .depthBiasEnable = 0 });

    const multisampling = std.mem.zeroInit(c.VkPipelineMultisampleStateCreateInfo, .{ .sType = 24, .rasterizationSamples = c.VK_SAMPLE_COUNT_1_BIT });
    const color_blend_attachment = std.mem.zeroInit(c.VkPipelineColorBlendAttachmentState, .{
        .colorWriteMask = 0xF,
        .blendEnable = desc.blend_enable,
        .srcColorBlendFactor = desc.src_color_blend_factor,
        .dstColorBlendFactor = desc.dst_color_blend_factor,
        .colorBlendOp = desc.color_blend_op,
        .srcAlphaBlendFactor = desc.src_alpha_blend_factor,
        .dstAlphaBlendFactor = desc.dst_alpha_blend_factor,
        .alphaBlendOp = desc.alpha_blend_op,
    });
    const color_blending = std.mem.zeroInit(c.VkPipelineColorBlendStateCreateInfo, .{ .sType = 26, .logicOpEnable = 0, .attachmentCount = 1, .pAttachments = @as([*]const c.VkPipelineColorBlendAttachmentState, @ptrCast(&color_blend_attachment)) });

    const depth_stencil = c.VkPipelineDepthStencilStateCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
        .depthTestEnable = 0,
        .depthWriteEnable = 0,
        .depthCompareOp = c.VK_COMPARE_OP_ALWAYS,
        .depthBoundsTestEnable = 0,
        .stencilTestEnable = 1,
        .front = .{ .failOp = c.VK_STENCIL_OP_KEEP, .passOp = c.VK_STENCIL_OP_REPLACE, .depthFailOp = c.VK_STENCIL_OP_KEEP, .compareOp = c.VK_COMPARE_OP_ALWAYS, .compareMask = 0xFF, .writeMask = 0xFF, .reference = 1 },
        .back = .{ .failOp = c.VK_STENCIL_OP_KEEP, .passOp = c.VK_STENCIL_OP_REPLACE, .depthFailOp = c.VK_STENCIL_OP_KEEP, .compareOp = c.VK_COMPARE_OP_ALWAYS, .compareMask = 0xFF, .writeMask = 0xFF, .reference = 1 },
        .minDepthBounds = 0,
        .maxDepthBounds = 1,
    };

    const dsl_bindings = [_]c.VkDescriptorSetLayoutBinding{
        .{ .binding = 0, .descriptorType = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, .descriptorCount = 1, .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT },
        .{ .binding = 1, .descriptorType = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, .descriptorCount = 1, .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT },
    };
    const dsl_info = c.VkDescriptorSetLayoutCreateInfo{ .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO, .bindingCount = dsl_bindings.len, .pBindings = @as([*]const c.VkDescriptorSetLayoutBinding, @ptrCast(&dsl_bindings)) };
    var dsl: c.VkDescriptorSetLayout = null;
    if (c.vkCreateDescriptorSetLayout(surface.device, &dsl_info, null, &dsl) != c.VK_SUCCESS) return null;

    const layout_info = c.VkPipelineLayoutCreateInfo{ .sType = 30, .setLayoutCount = 1, .pSetLayouts = @as(?*const anyopaque, @ptrCast(&dsl)) };
    var layout: c.VkPipelineLayout = null;
    if (c.vkCreatePipelineLayout(surface.device, &layout_info, null, &layout) != c.VK_SUCCESS) {
        c.vkDestroyDescriptorSetLayout(surface.device, dsl, null);
        return null;
    }

    const pipeline_info = c.VkGraphicsPipelineCreateInfo{
        .sType = 28,
        .stageCount = 2,
        .pStages = @as([*]const c.VkPipelineShaderStageCreateInfo, @ptrCast(&shader_stages)),
        .pVertexInputState = &vertex_input_info,
        .pInputAssemblyState = &input_assembly,
        .pViewportState = &viewport_state,
        .pRasterizationState = &rasterizer,
        .pMultisampleState = &multisampling,
        .pDepthStencilState = @as(?*const anyopaque, @ptrCast(&depth_stencil)),
        .pColorBlendState = &color_blending,
        .pDynamicState = &dynamic_state_info,
        .layout = layout,
        .renderPass = surface.render_pass,
        .subpass = 0,
    };
    var pipeline: c.VkPipeline = null;
    if (c.vkCreateGraphicsPipelines(surface.device, null, 1, @as([*]const c.VkGraphicsPipelineCreateInfo, @ptrCast(&pipeline_info)), null, &pipeline) != c.VK_SUCCESS) {
        c.vkDestroyPipelineLayout(surface.device, layout, null);
        c.vkDestroyDescriptorSetLayout(surface.device, dsl, null);
        return null;
    }

    const vulkan_pipeline = std.heap.page_allocator.create(VulkanPipeline) catch return null;
    vulkan_pipeline.* = .{ .pipeline = pipeline, .layout = layout };
    return vulkan_pipeline;
}

// --- Renderbuffer ---

pub const Renderbuffer = struct {
    image: c.VkImage,
    memory: c.VkDeviceMemory,
    image_view: c.VkImageView,
    format: c.VkFormat,
    width: u32,
    height: u32,
};

pub fn createRenderbuffer(surface: *VulkanSurface, format: u32, width: u32, height: u32) ?*Renderbuffer {
    if (builtin.os.tag != .linux) return null;

    const image_info = std.mem.zeroInit(c.VkImageCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .imageType = c.VK_IMAGE_TYPE_2D,
        .extent = .{ .width = width, .height = height, .depth = 1 },
        .mipLevels = 1,
        .arrayLayers = 1,
        .format = format,
        .tiling = c.VK_IMAGE_TILING_OPTIMAL,
        .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
        .usage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_SAMPLED_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .samples = c.VK_SAMPLE_COUNT_1_BIT,
    });

    var image: c.VkImage = null;
    if (c.vkCreateImage(surface.device, &image_info, null, &image) != c.VK_SUCCESS) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createRenderbuffer: vkCreateImage failed\n", .{});
        return null;
    }

    var mem_reqs: c.VkMemoryRequirements = undefined;
    c.vkGetImageMemoryRequirements(surface.device, image, &mem_reqs);

    const mem_type_index = findMemoryType(surface.physical_device, mem_reqs.memoryTypeBits, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) orelse {
        c.vkDestroyImage(surface.device, image, null);
        return null;
    };

    var alloc_info = std.mem.zeroInit(c.VkMemoryAllocateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_reqs.size,
        .memoryTypeIndex = mem_type_index,
    });

    var memory: c.VkDeviceMemory = null;
    if (c.vkAllocateMemory(surface.device, &alloc_info, null, &memory) != c.VK_SUCCESS or c.vkBindImageMemory(surface.device, image, memory, 0) != c.VK_SUCCESS) {
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const view_info = std.mem.zeroInit(c.VkImageViewCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        .image = image,
        .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
        .format = format,
        .subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 },
    });

    var view: c.VkImageView = null;
    if (c.vkCreateImageView(surface.device, &view_info, null, &view) != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    }

    const rb = std.heap.page_allocator.create(Renderbuffer) catch {
        c.vkDestroyImageView(surface.device, view, null);
        c.vkFreeMemory(surface.device, memory, null);
        c.vkDestroyImage(surface.device, image, null);
        return null;
    };
    rb.* = .{ .image = image, .memory = memory, .image_view = view, .format = format, .width = width, .height = height };

    if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createRenderbuffer: {}x{} format={d}\n", .{ width, height, format });
    return rb;
}

pub fn destroyRenderbuffer(surface: *VulkanSurface, renderbuffer: *Renderbuffer) void {
    if (renderbuffer.image_view != null) c.vkDestroyImageView(surface.device, renderbuffer.image_view, null);
    if (renderbuffer.memory != null) c.vkFreeMemory(surface.device, renderbuffer.memory, null);
    if (renderbuffer.image != null) c.vkDestroyImage(surface.device, renderbuffer.image, null);
    std.heap.page_allocator.destroy(renderbuffer);
}

// --- Framebuffer ---

pub const Framebuffer = struct {
    framebuffer: c.VkFramebuffer,
    color_attachment: ?*VulkanTexture,
    depth_stencil_attachment: ?*Renderbuffer,
    width: u32,
    height: u32,
};

pub fn createFramebuffer(surface: *VulkanSurface, color_texture: ?*VulkanTexture, width: u32, height: u32, depth_stencil_rb: ?*Renderbuffer) ?*Framebuffer {
    if (builtin.os.tag != .linux) return null;

    var attachments: [2]c.VkImageView = undefined;
    var attachment_count: u32 = 0;

    if (color_texture) |tex| {
        attachments[attachment_count] = tex.view;
        attachment_count += 1;
    }
    if (depth_stencil_rb) |rb| {
        attachments[attachment_count] = rb.image_view;
        attachment_count += 1;
    }

    if (attachment_count == 0) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createFramebuffer: no attachments provided\n", .{});
        return null;
    }

    const fb_info = std.mem.zeroInit(c.VkFramebufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
        .renderPass = surface.render_pass,
        .attachmentCount = attachment_count,
        .pAttachments = @as([*]const c.VkImageView, @ptrCast(&attachments)),
        .width = width,
        .height = height,
        .layers = 1,
    });

    var framebuffer: c.VkFramebuffer = null;
    if (c.vkCreateFramebuffer(surface.device, &fb_info, null, &framebuffer) != c.VK_SUCCESS) {
        if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createFramebuffer: vkCreateFramebuffer failed\n", .{});
        return null;
    }

    const fb = std.heap.page_allocator.create(Framebuffer) catch {
        c.vkDestroyFramebuffer(surface.device, framebuffer, null);
        return null;
    };
    fb.* = .{ .framebuffer = framebuffer, .color_attachment = color_texture, .depth_stencil_attachment = depth_stencil_rb, .width = width, .height = height };

    if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] createFramebuffer: {}x{} attachments={d}\n", .{ width, height, attachment_count });
    return fb;
}

pub fn destroyFramebuffer(surface: *VulkanSurface, framebuffer: *Framebuffer) void {
    if (framebuffer.framebuffer != null) c.vkDestroyFramebuffer(surface.device, framebuffer.framebuffer, null);
    std.heap.page_allocator.destroy(framebuffer);
}

pub fn cmdBindFramebuffer(surface: *VulkanSurface, cmd: *VulkanCommandBuffer, framebuffer: *Framebuffer) void {
    if (builtin.os.tag != .linux) return;
    if (cmd.render_pass_began) {
        c.vkCmdEndRenderPass(cmd.cmd);
        cmd.render_pass_began = false;
    }

    const clear_value: c.VkClearValue = .{ .color = .{ .float32 = .{ 0, 0, 0, 0 } } };
    const begin_info = std.mem.zeroInit(c.VkRenderPassBeginInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        .renderPass = surface.render_pass,
        .framebuffer = framebuffer.framebuffer,
        .renderArea = .{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = framebuffer.width, .height = framebuffer.height } },
        .clearValueCount = 1,
        .pClearValues = @as([*]const c.VkClearValue, @ptrCast(&clear_value)),
    });
    c.vkCmdBeginRenderPass(cmd.cmd, &begin_info, c.VK_SUBPASS_CONTENTS_INLINE);
    cmd.render_pass_began = true;

    const viewport = c.VkViewport{ .x = 0, .y = 0, .width = @floatFromInt(framebuffer.width), .height = @floatFromInt(framebuffer.height), .minDepth = 0, .maxDepth = 1 };
    c.vkCmdSetViewport(cmd.cmd, 0, 1, @as([*]const c.VkViewport, @ptrCast(&viewport)));
    const scissor = c.VkRect2D{ .offset = .{ .x = 0, .y = 0 }, .extent = .{ .width = framebuffer.width, .height = framebuffer.height } };
    c.vkCmdSetScissor(cmd.cmd, 0, 1, @as([*]const c.VkRect2D, @ptrCast(&scissor)));

    if (builtin.mode == .Debug) std.debug.print("[Z-GRAPHICS] cmdBindFramebuffer: {}x{}\n", .{ framebuffer.width, framebuffer.height });
}

pub fn framebufferAttachTexture(surface: *VulkanSurface, framebuffer: *Framebuffer, attachment: u32, texture: *VulkanTexture, mip_level: u32) bool {
    _ = surface;
    _ = attachment;
    _ = mip_level;
    framebuffer.color_attachment = texture;
    return true;
}

pub fn framebufferAttachRenderbuffer(surface: *VulkanSurface, framebuffer: *Framebuffer, attachment: u32, renderbuffer: *Renderbuffer) bool {
    _ = surface;
    _ = attachment;
    framebuffer.depth_stencil_attachment = renderbuffer;
    return true;
}

pub fn uploadTextureRegion(
    surface: *VulkanSurface,
    texture: *VulkanTexture,
    x: i32,
    y: u32,
    width: u32,
    height: u32,
    data: []const u8,
    rowStride: u32,
    srcOffsetX: u32,
    srcOffsetY: u32,
) bool {
    if (builtin.os.tag != .linux) return false;
    if (data.len == 0 or width == 0 or height == 0) return false;

    const log = builtin.mode == .Debug;
    if (log) std.debug.print("[Z-GRAPHICS] uploadTextureRegion: x={} y={} w={} h={} dataLen={} rowStride={} srcOff=({},{})\n", .{ x, y, width, height, data.len, rowStride, srcOffsetX, srcOffsetY });

    const effective_row_stride = if (rowStride > 0) rowStride else width * 4;
    const bytes_per_row = effective_row_stride;
    const total_staging_size = @as(u64, bytes_per_row) * @as(u64, height);

    const staging_info = std.mem.zeroInit(c.VkBufferCreateInfo, .{
        .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = total_staging_size,
        .usage = c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
        .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
    });

    var staging: c.VkBuffer = null;
    var r = c.vkCreateBuffer(surface.device, &staging_info, null, &staging);
    if (log) std.debug.print("[Z-GRAPHICS] uploadTextureRegion: vkCreateBuffer staging result={} handle={any}\n", .{ r, staging });
    if (r != c.VK_SUCCESS) return false;

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
        if (log) std.debug.print("[Z-GRAPHICS] uploadTextureRegion: ERROR no HOST_VISIBLE|HOST_COHERENT mem type found\n", .{});
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    };

    var staging_mem: c.VkDeviceMemory = null;
    r = c.vkAllocateMemory(surface.device, &alloc_info, null, &staging_mem);
    if (r != c.VK_SUCCESS) {
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }
    r = c.vkBindBufferMemory(surface.device, staging, staging_mem, 0);
    if (r != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    var data_ptr: ?*anyopaque = null;
    r = c.vkMapMemory(surface.device, staging_mem, 0, total_staging_size, 0, &data_ptr);
    if (r != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    const dst = @as([*]u8, @ptrCast(@alignCast(data_ptr)));
    const src = data.ptr;

    var row: u32 = 0;
    while (row < height) : (row += 1) {
        const src_row_start = @as(u64, srcOffsetY + row) * @as(u64, effective_row_stride) + @as(u64, srcOffsetX * 4);
        const dst_row_start = @as(u64, row) * @as(u64, bytes_per_row);
        const copy_bytes = @as(u64, width) * 4;
        if (src_row_start + copy_bytes <= data.len and dst_row_start + copy_bytes <= total_staging_size) {
            @memcpy(dst[dst_row_start .. dst_row_start + copy_bytes], src[src_row_start .. src_row_start + copy_bytes]);
        }
    }

    if (log) {
        const check_ptr = @as([*]const u8, @ptrCast(@alignCast(data_ptr)));
        std.debug.print("[Z-GRAPHICS] uploadTextureRegion: staging[0..4] = 0x{x} 0x{x} 0x{x} 0x{x}\n", .{ check_ptr[0], check_ptr[1], check_ptr[2], check_ptr[3] });
    }
    c.vkUnmapMemory(surface.device, staging_mem);

    if (surface.transfer_pool == null or surface.transfer_cmd == null) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    _ = c.vkResetCommandPool(surface.device, surface.transfer_pool, 0);

    const begin_info = std.mem.zeroInit(c.VkCommandBufferBeginInfo, .{ .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, .flags = 1 }); // VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    r = c.vkBeginCommandBuffer(surface.transfer_cmd, &begin_info);
    if (r != c.VK_SUCCESS) {
        c.vkFreeMemory(surface.device, staging_mem, null);
        c.vkDestroyBuffer(surface.device, staging, null);
        return false;
    }

    var barrier: c.VkImageMemoryBarrier = undefined;
    barrier.sType = 45;
    barrier.pNext = null;
    barrier.srcAccessMask = 0;
    barrier.dstAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT;
    barrier.oldLayout = c.VK_IMAGE_LAYOUT_UNDEFINED;
    barrier.newLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
    barrier.srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED;
    barrier.dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED;
    barrier.image = texture.image;
    barrier.subresourceRange = .{ .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT, .baseMipLevel = 0, .levelCount = 1, .baseArrayLayer = 0, .layerCount = 1 };

    c.vkCmdPipelineBarrier(surface.transfer_cmd, c.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, c.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    var region: c.VkBufferImageCopy = std.mem.zeroes(c.VkBufferImageCopy);
    region.bufferOffset = 0;
    region.bufferRowLength = effective_row_stride / 4;
    region.bufferImageHeight = height;
    region.imageSubresource.aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT;
    region.imageSubresource.mipLevel = 0;
    region.imageSubresource.baseArrayLayer = 0;
    region.imageSubresource.layerCount = 1;
    region.imageOffset = .{ .x = x, .y = @as(i32, @intCast(y)), .z = 0 };
    region.imageExtent = .{ .width = width, .height = height, .depth = 1 };

    if (log) std.debug.print("[Z-GRAPHICS] uploadTextureRegion: CopyBufferToImage staging={any} image={any} extent={}x{} offset={}x{} bufRowLength={}\n", .{ staging, texture.image, width, height, x, y, region.bufferRowLength });
    c.vkCmdCopyBufferToImage(surface.transfer_cmd, staging, texture.image, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, @ptrCast(&region));

    barrier.oldLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
    barrier.newLayout = c.VK_IMAGE_LAYOUT_GENERAL;
    barrier.srcAccessMask = c.VK_ACCESS_TRANSFER_WRITE_BIT;
    barrier.dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT;
    c.vkCmdPipelineBarrier(surface.transfer_cmd, c.VK_PIPELINE_STAGE_TRANSFER_BIT, c.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0, null, 0, null, 1, @ptrCast(&barrier));

    r = c.vkEndCommandBuffer(surface.transfer_cmd);

    const submit_info = std.mem.zeroInit(c.VkSubmitInfo, .{ .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = @as([*]const c.VkCommandBuffer, @ptrCast(&surface.transfer_cmd)) });
    r = c.vkQueueSubmit(surface.graphics_queue, 1, @ptrCast(&submit_info), surface.fence);
    r = c.vkWaitForFences(surface.device, 1, @ptrCast(&surface.fence), c.VK_TRUE, std.math.maxInt(u64));
    r = c.vkResetFences(surface.device, 1, @ptrCast(&surface.fence));

    if (log) std.debug.print("[Z-GRAPHICS] uploadTextureRegion: upload complete, image={any}\n", .{texture.image});

    c.vkFreeMemory(surface.device, staging_mem, null);
    c.vkDestroyBuffer(surface.device, staging, null);

    return true;
}
