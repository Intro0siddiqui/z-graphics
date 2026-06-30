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
    -1.0, -1.0, 0.0, 1.0,
    1.0,  -1.0, 1.0, 1.0,
    -1.0, 1.0,  0.0, 0.0,
    1.0,  1.0,  1.0, 0.0,
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

    state.pipeline = zg.ZG_CreatePipeline(surface.?, &desc);

    const vb = zg.ZG_CreateBuffer(surface.?, @sizeOf(@TypeOf(quad_vertices)), zg.BufferType.Vertex);
    state.vertex_buffer = vb;
    if (vb != null) {
        _ = zg.ZG_UploadBuffer(surface.?, vb.?, &quad_vertices, @sizeOf(@TypeOf(quad_vertices)));
    }

    return state;
}

pub fn renderLayer(state: *CompositorState) bool {
    if (state.surface == null or state.pipeline == null or state.vertex_buffer == null) return false;

    const cmd = zg.ZG_BeginCommandBuffer(state.surface.?) orelse return false;

    zg.ZG_CmdBindPipeline(cmd, state.pipeline.?);
    zg.ZG_CmdBindVertexBuffer(cmd, state.vertex_buffer.?, 0);
    zg.ZG_CmdDraw(cmd, 4, 1, 0, 0);

    zg.ZG_SubmitCommandBuffer(state.surface.?, cmd);
    zg.ZG_SwapBuffers(state.surface.?);

    return true;
}

pub fn destroyState(state: *CompositorState) void {
    const surface_opt = state.surface;
    if (state.vertex_buffer != null and surface_opt != null) {
        zg.ZG_DestroyBuffer(surface_opt.?, state.vertex_buffer.?);
    }
    if (state.pipeline != null and surface_opt != null) {
        zg.ZG_DestroyPipeline(surface_opt.?, state.pipeline.?);
    }
    if (surface_opt != null) {
        zg.ZG_DestroySurface(surface_opt.?);
    }
    std.heap.page_allocator.destroy(state);
}

pub fn resize(state: *CompositorState, new_width: u32, new_height: u32) bool {
    const old_surface = state.surface orelse return false;
    std.debug.assert(state.pipeline != null);
    const pipeline = state.pipeline;
    const vb = state.vertex_buffer.?;

    zg.ZG_DestroyBuffer(old_surface, vb);
    zg.ZG_DestroyPipeline(old_surface, pipeline);
    zg.ZG_DestroySurface(old_surface);

    const new_surface = zg.ZG_CreateSurface(null, new_width, new_height) orelse return false;
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
    state.pipeline = zg.ZG_CreatePipeline(new_surface, &desc) orelse return false;

    const new_vb = zg.ZG_CreateBuffer(new_surface, @sizeOf(@TypeOf(quad_vertices)), zg.BufferType.Vertex) orelse return false;
    state.vertex_buffer = new_vb;
    _ = zg.ZG_UploadBuffer(new_surface, new_vb, &quad_vertices, @sizeOf(@TypeOf(quad_vertices)));

    return true;
}

// C-FFI Exports for Compositor Integration
pub export fn ZG_CompositorInitialize(surface: ?zg.ZawraGraphicsHandle, width: u32, height: u32) ?*CompositorState {
    return initializeState(surface, width, height);
}

pub export fn ZG_CompositorRenderLayer(state: *CompositorState) bool {
    return renderLayer(state);
}

pub export fn ZG_CompositorDestroy(state: *CompositorState) void {
    destroyState(state);
}

pub export fn ZG_CompositorResize(state: *CompositorState, new_width: u32, new_height: u32) bool {
    return resize(state, new_width, new_height);
}

pub export fn ZG_CompositorGetSurfaceHandle(state: *CompositorState) ?zg.ZawraGraphicsHandle {
    if (state.surface) |s| return s;
    return null;
}
