// src/lib.zig: Zawra Graphics OS Abstraction (RHI)
const std = @import("std");
const builtin = @import("builtin");

// Platform-specific backends
const linux_vulkan = if (builtin.os.tag == .linux) @import("linux_vulkan.zig") else struct {};
const macos_metal = if (builtin.os.tag == .macos) @import("macos_metal.zig") else struct {};
const windows_d3d12 = if (builtin.os.tag == .windows) @import("windows_d3d12.zig") else struct {};
const compositor = @import("webkit_compositor.zig");

export fn _force_zgraphics_exports() void {
    _ = compositor.ZawraGraphics_CompositorInitialize;
    _ = compositor.ZawraGraphics_CompositorRenderLayer;
    _ = compositor.ZawraGraphics_CompositorDestroy;
    _ = compositor.ZawraGraphics_CompositorResize;
}

/// The internal structure representing a graphics surface.
/// This is platform-dependent and opaque to the user (FFI).
pub const ZawraGraphicsSurface = if (builtin.os.tag == .linux)
    linux_vulkan.VulkanSurface
else if (builtin.os.tag == .macos)
    macos_metal.MetalSurface
else if (builtin.os.tag == .windows)
    windows_d3d12.D3D12Surface
else
    struct { dummy: u8 };

/// Opaque pointer to the graphics surface for C/C++ FFI.
pub const ZawraGraphicsHandle = *anyopaque;

/// Opaque pointer to a generic GPU Buffer (Vertex/Index/Uniform).
pub const ZawraGraphicsBuffer = *anyopaque;

/// Opaque pointer to a Command Buffer for recording drawing operations.
pub const ZawraGraphicsCommandBuffer = *anyopaque;

/// Opaque pointer to a Pipeline State Object (PSO).
pub const ZawraGraphicsPipeline = *anyopaque;

/// Buffer usage types
pub const BufferType = enum(u32) {
    Vertex = 1,
    Index = 2,
    Uniform = 3,
};

/// Pipeline description for PSO creation
pub const PipelineDesc = extern struct {
    vertex_shader: ?[*]const u8,
    vertex_shader_len: usize,
    pixel_shader: ?[*]const u8,
    pixel_shader_len: usize,
};

/// Initializes the global graphics state.
pub export fn ZawraGraphics_Initialize() bool {
    // Basic global initialization logic can go here.
    return true;
}

/// Creates a surface for rendering.
/// Returns an opaque handle to a platform-specific surface object.
pub export fn ZawraGraphics_CreateSurface(window: ?ZawraGraphicsHandle, width: u32, height: u32) ?ZawraGraphicsHandle {
    if (builtin.os.tag == .linux) {
        return @ptrCast(linux_vulkan.createSurface(window, width, height));
    } else if (builtin.os.tag == .macos) {
        return @ptrCast(macos_metal.createSurface(window, width, height));
    } else if (builtin.os.tag == .windows) {
        return @ptrCast(windows_d3d12.createSurface(window, width, height));
    }
    
    return null;
}

/// Destroys a graphics surface and frees its resources.
pub export fn ZawraGraphics_DestroySurface(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.destroySurface(@ptrCast(@alignCast(handle)));
    } else if (builtin.os.tag == .macos) {
        macos_metal.destroySurface(@ptrCast(@alignCast(handle)));
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.destroySurface(@ptrCast(@alignCast(handle)));
    }
}

/// Swaps the backbuffer to the frontbuffer, or flushes the offscreen render target
/// indicating the frame is complete.
pub export fn ZawraGraphics_SwapBuffers(handle: ZawraGraphicsHandle) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.swapBuffers(@ptrCast(@alignCast(handle)));
    } else if (builtin.os.tag == .macos) {
        macos_metal.swapBuffers(@ptrCast(@alignCast(handle)));
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.swapBuffers(@ptrCast(@alignCast(handle)));
    }
}

/// Exports the rendered surface memory as a file descriptor (Linux/DMA-BUF),
/// IOSurface handle (macOS), or shared handle (Windows).
/// Returns -1 on failure/unsupported. Note that 0 can be a valid file descriptor.
/// The caller owns the returned file descriptor and must close it.
pub export fn ZawraGraphics_ExportSurfaceFD(handle: ZawraGraphicsHandle) i32 {
    if (builtin.os.tag == .linux) {
        return linux_vulkan.exportSurfaceFD(@ptrCast(@alignCast(handle)));
    } else if (builtin.os.tag == .macos) {
        return macos_metal.exportSurfaceFD(@ptrCast(@alignCast(handle)));
    } else if (builtin.os.tag == .windows) {
        return windows_d3d12.exportSurfaceFD(@ptrCast(@alignCast(handle)));
    }
    return -1;
}

// ---------------------------------------------------------
// RESOURCE MANAGEMENT (Feature 2)
// ---------------------------------------------------------

/// Allocates a generic GPU buffer.
pub export fn ZawraGraphics_CreateBuffer(handle: ZawraGraphicsHandle, size: usize, buffer_type: BufferType) ?ZawraGraphicsBuffer {
    if (builtin.os.tag == .linux) {
        return @ptrCast(linux_vulkan.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    } else if (builtin.os.tag == .macos) {
        return @ptrCast(macos_metal.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    } else if (builtin.os.tag == .windows) {
        return @ptrCast(windows_d3d12.createBuffer(@ptrCast(@alignCast(handle)), size, @intFromEnum(buffer_type)));
    }
    return null;
}

pub export fn ZawraGraphics_DestroyBuffer(handle: ZawraGraphicsHandle, buffer: ZawraGraphicsBuffer) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
    } else if (builtin.os.tag == .macos) {
        macos_metal.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.destroyBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)));
    }
}

// ---------------------------------------------------------
// COMMAND RECORDING (Feature 1)
// ---------------------------------------------------------

/// Begins a new command buffer for recording.
pub export fn ZawraGraphics_BeginCommandBuffer(handle: ZawraGraphicsHandle) ?ZawraGraphicsCommandBuffer {
    if (builtin.os.tag == .linux) {
        return @ptrCast(linux_vulkan.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    } else if (builtin.os.tag == .macos) {
        return @ptrCast(macos_metal.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    } else if (builtin.os.tag == .windows) {
        return @ptrCast(windows_d3d12.beginCommandBuffer(@ptrCast(@alignCast(handle))));
    }
    return null;
}

/// Clears the current render target to a specific color.
pub export fn ZawraGraphics_CmdClearColor(cmd: ZawraGraphicsCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
    } else if (builtin.os.tag == .macos) {
        macos_metal.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.cmdClearColor(@ptrCast(@alignCast(cmd)), r, g, b, a);
    }
}

/// Submits the recorded command buffer to the GPU queue.
pub export fn ZawraGraphics_SubmitCommandBuffer(handle: ZawraGraphicsHandle, cmd: ZawraGraphicsCommandBuffer) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
    } else if (builtin.os.tag == .macos) {
        macos_metal.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.submitCommandBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(cmd)));
    }
}

// ---------------------------------------------------------
// PIPELINE MANAGEMENT (Feature 3)
// ---------------------------------------------------------

/// Creates a Pipeline State Object.
pub export fn ZawraGraphics_CreatePipeline(handle: ZawraGraphicsHandle, desc: *const PipelineDesc) ?ZawraGraphicsPipeline {
    if (builtin.os.tag == .linux) {
        return @ptrCast(linux_vulkan.createPipeline(@ptrCast(@alignCast(handle)), desc));
    } else if (builtin.os.tag == .macos) {
        return @ptrCast(macos_metal.createPipeline(@ptrCast(@alignCast(handle)), desc));
    } else if (builtin.os.tag == .windows) {
        return @ptrCast(windows_d3d12.createPipeline(@ptrCast(@alignCast(handle)), desc));
    }
    return null;
}

pub export fn ZawraGraphics_DestroyPipeline(handle: ZawraGraphicsHandle, pipeline: ?ZawraGraphicsPipeline) void {
    if (pipeline == null) return;
    if (builtin.os.tag == .linux) {
        linux_vulkan.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
    } else if (builtin.os.tag == .macos) {
        macos_metal.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.destroyPipeline(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(pipeline.?)));
    }
}

/// Binds a pipeline to a command buffer.
pub export fn ZawraGraphics_CmdBindPipeline(cmd: ZawraGraphicsCommandBuffer, pipeline: ZawraGraphicsPipeline) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
    } else if (builtin.os.tag == .macos) {
        macos_metal.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.cmdBindPipeline(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(pipeline)));
    }
}

/// Headfull window creation.
pub export fn ZawraGraphics_CreateWindow(width: u32, height: u32) ?ZawraGraphicsHandle {
    if (builtin.os.tag == .linux) {
        return @ptrCast(linux_vulkan.createWindow(width, height));
    } else if (builtin.os.tag == .macos) {
        return @ptrCast(macos_metal.createWindow(width, height));
    } else if (builtin.os.tag == .windows) {
        return @ptrCast(windows_d3d12.createWindow(width, height));
    }
    return null;
}

// ---------------------------------------------------------
// TEXTURE MANAGEMENT (Phase 1)
// ---------------------------------------------------------

pub const ZawraGraphicsTextureFormat = enum(u32) {
    R8G8B8A8_Unorm = 0,
};

pub const ZawraGraphicsTextureDesc = extern struct {
    format: ZawraGraphicsTextureFormat,
    width: u32,
    height: u32,
    external_handle: ?*anyopaque,
};

pub const ZawraGraphicsTexture = *anyopaque;

pub export fn ZawraGraphics_CreateTexture(handle: ZawraGraphicsHandle, desc: *const ZawraGraphicsTextureDesc) ?ZawraGraphicsTexture {
    if (builtin.os.tag == .linux) {
        return @ptrCast(linux_vulkan.createTexture(@ptrCast(@alignCast(handle)), desc));
    } else if (builtin.os.tag == .macos) {
        return @ptrCast(macos_metal.createTexture(@ptrCast(@alignCast(handle)), desc));
    } else if (builtin.os.tag == .windows) {
        return @ptrCast(windows_d3d12.createTexture(@ptrCast(@alignCast(handle)), desc));
    }
    return null;
}

pub export fn ZawraGraphics_DestroyTexture(handle: ZawraGraphicsHandle, texture: ?ZawraGraphicsTexture) void {
    if (texture == null) return;
    if (builtin.os.tag == .linux) {
        linux_vulkan.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
    } else if (builtin.os.tag == .macos) {
        macos_metal.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.destroyTexture(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(texture.?)));
    }
}

// ---------------------------------------------------------
// BUFFER UPLOAD / DRAW / BIND (Phase 1)
// ---------------------------------------------------------

pub export fn ZawraGraphics_UploadBuffer(handle: ZawraGraphicsHandle, buffer: ZawraGraphicsBuffer, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag == .linux) {
        return linux_vulkan.uploadBuffer(@ptrCast(@alignCast(handle)), @ptrCast(@alignCast(buffer)), data, dataLen);
    } else if (builtin.os.tag == .macos) {
        return macos_metal.uploadBuffer(@ptrCast(@alignCast(buffer)), data, dataLen);
    } else if (builtin.os.tag == .windows) {
        return windows_d3d12.uploadBuffer(@ptrCast(@alignCast(buffer)), data, dataLen);
    }
    return false;
}

pub export fn ZawraGraphics_GetBufferSize(buffer: ZawraGraphicsBuffer) usize {
    if (builtin.os.tag == .linux) {
        return linux_vulkan.getBufferSize(@ptrCast(@alignCast(buffer)));
    } else if (builtin.os.tag == .macos) {
        return macos_metal.getBufferSize(@ptrCast(@alignCast(buffer)));
    } else if (builtin.os.tag == .windows) {
        return windows_d3d12.getBufferSize(@ptrCast(@alignCast(buffer)));
    }
    return 0;
}

pub export fn ZawraGraphics_CmdBindVertexBuffer(cmd: ZawraGraphicsCommandBuffer, buffer: ZawraGraphicsBuffer, offset: usize) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
    } else if (builtin.os.tag == .macos) {
        macos_metal.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.cmdBindVertexBuffer(@ptrCast(@alignCast(cmd)), @ptrCast(@alignCast(buffer)), offset);
    }
}

pub export fn ZawraGraphics_CmdDraw(cmd: ZawraGraphicsCommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag == .linux) {
        linux_vulkan.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    } else if (builtin.os.tag == .macos) {
        macos_metal.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    } else if (builtin.os.tag == .windows) {
        windows_d3d12.cmdDraw(@ptrCast(@alignCast(cmd)), vertex_count, instance_count, first_vertex, first_instance);
    }
}
