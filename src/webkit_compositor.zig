const std = @import("std");
const builtin = @import("builtin");
const zg = @import("lib.zig");
const shaders = @import("shaders");

pub const CompositorState = struct {
    surface: ?zg.ZawraGraphicsHandle,
    pipeline: ?zg.ZawraGraphicsPipeline,
    vertex_buffer: ?zg.ZawraGraphicsBuffer,
    width: u32,
    height: u32,
};

const quad_vertices = [_]f32{
    -1.0, -1.0, 0.0, 0.0,
     1.0, -1.0, 1.0, 0.0,
    -1.0,  1.0, 0.0, 1.0,
     1.0,  1.0, 1.0, 1.0,
};

pub fn initializeState(surface: ?zg.ZawraGraphicsHandle, width: u32, height: u32) ?*CompositorState {
    if (surface == null) return null;

    const state = std.heap.page_allocator.create(CompositorState) catch return null;
    state.* = .{
        .surface = surface,
        .pipeline = null,
        .vertex_buffer = null,
        .width = width,
        .height = height,
    };

    const vert = shaders.vert;
    const frag = shaders.frag;
    const desc = zg.PipelineDesc{
        .vertex_shader = vert.ptr,
        .vertex_shader_len = vert.len,
        .pixel_shader = frag.ptr,
        .pixel_shader_len = frag.len,
    };

    state.pipeline = zg.ZawraGraphics_CreatePipeline(surface.?, &desc);

    const vb = zg.ZawraGraphics_CreateBuffer(surface.?, @sizeOf(@TypeOf(quad_vertices)), zg.BufferType.Vertex);
    state.vertex_buffer = vb;
    if (vb != null) {
        _ = zg.ZawraGraphics_UploadBuffer(surface.?, vb.?, &quad_vertices, @sizeOf(@TypeOf(quad_vertices)));
    }

    return state;
}

pub fn renderLayer(state: *CompositorState) bool {
    if (state.surface == null or state.pipeline == null or state.vertex_buffer == null) return false;

    const cmd = zg.ZawraGraphics_BeginCommandBuffer(state.surface.?) orelse return false;

    zg.ZawraGraphics_CmdBindPipeline(cmd, state.pipeline.?);
    zg.ZawraGraphics_CmdBindVertexBuffer(cmd, state.vertex_buffer.?, 0);
    zg.ZawraGraphics_CmdDraw(cmd, 4, 1, 0, 0);

    zg.ZawraGraphics_SubmitCommandBuffer(state.surface.?, cmd);
    zg.ZawraGraphics_SwapBuffers(state.surface.?);

    return true;
}

pub fn destroyState(state: *CompositorState) void {
    const surface_opt = state.surface;
    if (state.vertex_buffer != null and surface_opt != null) {
        zg.ZawraGraphics_DestroyBuffer(surface_opt.?, state.vertex_buffer.?);
    }
    if (state.pipeline != null and surface_opt != null) {
        zg.ZawraGraphics_DestroyPipeline(surface_opt.?, state.pipeline.?);
    }
    if (surface_opt != null) {
        zg.ZawraGraphics_DestroySurface(surface_opt.?);
    }
    std.heap.page_allocator.destroy(state);
}

pub fn resize(state: *CompositorState, new_width: u32, new_height: u32) bool {
    const old_surface = state.surface orelse return false;
    std.debug.assert(state.pipeline != null);
    const pipeline = state.pipeline;
    const vb = state.vertex_buffer.?;

    zg.ZawraGraphics_DestroyBuffer(old_surface, vb);
    zg.ZawraGraphics_DestroyPipeline(old_surface, pipeline);
    zg.ZawraGraphics_DestroySurface(old_surface);

    const new_surface = zg.ZawraGraphics_CreateSurface(null, new_width, new_height) orelse return false;
    state.surface = new_surface;
    state.width = new_width;
    state.height = new_height;

    const vert = shaders.vert;
    const frag = shaders.frag;
    const desc = zg.PipelineDesc{
        .vertex_shader = vert.ptr,
        .vertex_shader_len = vert.len,
        .pixel_shader = frag.ptr,
        .pixel_shader_len = frag.len,
    };
    state.pipeline = zg.ZawraGraphics_CreatePipeline(new_surface, &desc) orelse return false;

    const new_vb = zg.ZawraGraphics_CreateBuffer(new_surface, @sizeOf(@TypeOf(quad_vertices)), zg.BufferType.Vertex) orelse return false;
    state.vertex_buffer = new_vb;
    _ = zg.ZawraGraphics_UploadBuffer(new_surface, new_vb, &quad_vertices, @sizeOf(@TypeOf(quad_vertices)));

    return true;
}

// C-FFI Exports for WebKit C++ Integration
pub export fn ZawraGraphics_CompositorInitialize(surface: ?zg.ZawraGraphicsHandle, width: u32, height: u32) ?*CompositorState {
    return initializeState(surface, width, height);
}

pub export fn ZawraGraphics_CompositorRenderLayer(state: *CompositorState) bool {
    return renderLayer(state);
}

pub export fn ZawraGraphics_CompositorDestroy(state: *CompositorState) void {
    destroyState(state);
}

pub export fn ZawraGraphics_CompositorResize(state: *CompositorState, new_width: u32, new_height: u32) bool {
    return resize(state, new_width, new_height);
}
