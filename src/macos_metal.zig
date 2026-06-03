const std = @import("std");
const zgraphics = @import("lib.zig");
const builtin = @import("builtin");

pub const MetalSurface = struct {
    device: ?*anyopaque,
    command_queue: ?*anyopaque,
    texture: ?*anyopaque,
    window: ?*anyopaque,
    view: ?*anyopaque,
    width: u32,
    height: u32,
};

extern fn objc_getClass(name: [*:0]const u8) ?*anyopaque;
extern fn sel_registerName(name: [*:0]const u8) ?*anyopaque;
extern fn objc_msgSend(self: ?*anyopaque, op: ?*anyopaque, ...) ?*anyopaque;

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    if (builtin.os.tag != .macos) return null;

    const NSWindow = objc_getClass("NSWindow") orelse return null;
    const alloc = sel_registerName("alloc");
    const init = sel_registerName("initWithContentRect:styleMask:backing:defer:");
    const makeKeyAndOrderFront = sel_registerName("makeKeyAndOrderFront:");
    const setTitle = sel_registerName("setTitle:");
    const NSString = objc_getClass("NSString");
    const stringWithUTF8String = sel_registerName("stringWithUTF8String:");

    const rect = [4]f64{ 100, 100, @floatFromInt(width), @floatFromInt(height) };
    const styleMask: usize = 1 | 2 | 4;
    const backing: usize = 2;

    const window_alloc = objc_msgSend(NSWindow, alloc);
    const window = objc_msgSend(window_alloc, init, &rect, styleMask, backing, @as(u8, 0));

    const title = objc_msgSend(NSString, stringWithUTF8String, @as([*:0]const u8, "Zawra Browser"));
    _ = objc_msgSend(window, setTitle, title);
    _ = objc_msgSend(window, makeKeyAndOrderFront, @as(?*anyopaque, null));

    return window;
}

extern fn MTLCreateSystemDefaultDevice() ?*anyopaque;

pub fn createSurface(window: ?*anyopaque, width: u32, height: u32) ?*MetalSurface {
    if (builtin.os.tag != .macos) return null;

    const device = MTLCreateSystemDefaultDevice() orelse return null;

    var surface_obj = std.heap.page_allocator.create(MetalSurface) catch return null;
    surface_obj.device = device;
    surface_obj.window = window;

    const newCommandQueue = sel_registerName("newCommandQueue");
    surface_obj.command_queue = objc_msgSend(device, newCommandQueue);

    const MTLTextureDescriptor = objc_getClass("MTLTextureDescriptor") orelse return null;
    const texture2DDescriptorWithPixelFormat = sel_registerName("texture2DDescriptorWithPixelFormat:width:height:mipmapped:");
    const newTextureWithDescriptor = sel_registerName("newTextureWithDescriptor:");

    const pixelFormat: usize = 70;
    const mipmapped: usize = 0;

    const descriptor = objc_msgSend(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        pixelFormat,
        @as(usize, width),
        @as(usize, height),
        mipmapped,
    );

    const setUsage = sel_registerName("setUsage:");
    _ = objc_msgSend(descriptor, setUsage, @as(usize, 1 | 2));

    surface_obj.texture = objc_msgSend(device, newTextureWithDescriptor, descriptor);

    if (surface_obj.window) |win| {
        const CAMetalLayer = objc_getClass("CAMetalLayer") orelse return null;
        const layer_alloc = objc_msgSend(CAMetalLayer, sel_registerName("alloc"));
        const layer = objc_msgSend(layer_alloc, sel_registerName("init"));

        const setDevice = sel_registerName("setDevice:");
        _ = objc_msgSend(layer, setDevice, device);

        const setPixelFormat = sel_registerName("setPixelFormat:");
        _ = objc_msgSend(layer, setPixelFormat, pixelFormat);

        const contentView = objc_msgSend(win, sel_registerName("contentView"));
        const setLayer = sel_registerName("setLayer:");
        const setWantsLayer = sel_registerName("setWantsLayer:");

        _ = objc_msgSend(contentView, setLayer, layer);
        _ = objc_msgSend(contentView, setWantsLayer, @as(u8, 1));

        surface_obj.view = layer;
    } else {
        surface_obj.view = null;
    }

    surface_obj.width = width;
    surface_obj.height = height;

    return surface_obj;
}

pub fn destroySurface(surface: *MetalSurface) void {
    if (builtin.os.tag != .macos) return;
    std.heap.page_allocator.destroy(surface);
}

pub fn swapBuffers(surface: *MetalSurface) void {
    if (builtin.os.tag != .macos) return;

    if (surface.view) |layer| {
        const nextDrawable = sel_registerName("nextDrawable");
        const drawable = objc_msgSend(layer, nextDrawable);
        if (drawable) |d| {
            const present = sel_registerName("present");
            _ = objc_msgSend(d, present);
        }
    }
}

pub fn exportSurfaceFD(surface: *MetalSurface) i32 {
    if (builtin.os.tag != .macos) return -1;
    if (surface.texture) |tex| {
        const iosurface = objc_msgSend(tex, sel_registerName("iosurface"));
        if (iosurface) |isurf| {
            const IOSurfaceGetID = sel_registerName("IOSurfaceGetID");
            _ = objc_msgSend(isurf, IOSurfaceGetID);
            return 0;
        }
    }
    return -1;
}

pub const MetalBuffer = struct { buffer: ?*anyopaque, size: usize };

pub fn createBuffer(surface: *MetalSurface, size: usize, buffer_type: u32) ?*MetalBuffer {
    if (builtin.os.tag != .macos) return null;
    _ = buffer_type;
    const MTLResourceStorageModeShared: usize = 0;
    const MTLResourceCPUCacheModeDefaultCache: usize = 0;
    const newBufferWithLength = sel_registerName("newBufferWithLength:options:");
    const buf = objc_msgSend(surface.device, newBufferWithLength, @as(usize, size), @as(usize, MTLResourceStorageModeShared | MTLResourceCPUCacheModeDefaultCache)) orelse return null;
    const mb = std.heap.page_allocator.create(MetalBuffer) catch return null;
    mb.* = .{ .buffer = buf, .size = size };
    return mb;
}

pub fn destroyBuffer(surface: *MetalSurface, buffer: *MetalBuffer) void {
    if (builtin.os.tag != .macos) return;
    _ = surface;
    std.heap.page_allocator.destroy(buffer);
}

pub const MetalCommandBuffer = struct { cmd_buffer: ?*anyopaque, render_encoder: ?*anyopaque };

pub fn beginCommandBuffer(surface: *MetalSurface) ?*MetalCommandBuffer {
    if (builtin.os.tag != .macos) return null;
    const commandBuffer = sel_registerName("commandBuffer");
    const cmd = objc_msgSend(surface.command_queue, commandBuffer) orelse return null;
    const MTLRenderPassDescriptor = objc_getClass("MTLRenderPassDescriptor") orelse return null;
    const renderPassDescriptor = sel_registerName("renderPassDescriptor");
    const pass_desc = objc_msgSend(MTLRenderPassDescriptor, renderPassDescriptor);
    const colorAttachments = sel_registerName("colorAttachments");
    const attachments = objc_msgSend(pass_desc, colorAttachments);
    const objectAtIndexedSubscript = sel_registerName("objectAtIndexedSubscript:");
    const attachment0 = objc_msgSend(attachments, objectAtIndexedSubscript, @as(usize, 0));
    const setTexture = sel_registerName("setTexture:");
    _ = objc_msgSend(attachment0, setTexture, surface.texture);
    const setStoreAction = sel_registerName("setStoreAction:");
    _ = objc_msgSend(attachment0, setStoreAction, @as(usize, 1));
    const setLoadAction = sel_registerName("setLoadAction:");
    _ = objc_msgSend(attachment0, setLoadAction, @as(usize, 0));
    const renderCommandEncoderWithDescriptor = sel_registerName("renderCommandEncoderWithDescriptor:");
    const render_encoder = objc_msgSend(cmd, renderCommandEncoderWithDescriptor, pass_desc);
    const mcb = std.heap.page_allocator.create(MetalCommandBuffer) catch return null;
    mcb.* = .{ .cmd_buffer = cmd, .render_encoder = render_encoder };
    return mcb;
}

pub fn cmdClearColor(cmd: *MetalCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .macos) return;
    const MTLRenderPassDescriptor = objc_getClass("MTLRenderPassDescriptor") orelse return;
    const renderPassDescriptor = sel_registerName("renderPassDescriptor");
    const pass_desc = objc_msgSend(MTLRenderPassDescriptor, renderPassDescriptor);
    const colorAttachments = sel_registerName("colorAttachments");
    const attachments = objc_msgSend(pass_desc, colorAttachments);
    const objectAtIndexedSubscript = sel_registerName("objectAtIndexedSubscript:");
    const attachment0 = objc_msgSend(attachments, objectAtIndexedSubscript, @as(usize, 0));
    const MTLClearColor = extern struct { r: f64, g: f64, b: f64, a: f64 };
    const clear_color = MTLClearColor{ .r = @floatCast(r), .g = @floatCast(g), .b = @floatCast(b), .a = @floatCast(a) };
    const setClearColor = sel_registerName("setClearColor:");
    _ = objc_msgSend(attachment0, setClearColor, clear_color);
    const setLoadAction = sel_registerName("setLoadAction:");
    _ = objc_msgSend(attachment0, setLoadAction, @as(usize, 2));
    const renderCommandEncoderWithDescriptor = sel_registerName("renderCommandEncoderWithDescriptor:");
    const encoder = objc_msgSend(cmd.cmd_buffer, renderCommandEncoderWithDescriptor, pass_desc);
    if (encoder) |enc| {
        const endEncoding = sel_registerName("endEncoding");
        _ = objc_msgSend(enc, endEncoding);
    }
}

pub fn submitCommandBuffer(surface: *MetalSurface, cmd: *MetalCommandBuffer) void {
    if (builtin.os.tag != .macos) return;
    _ = surface;
    const commit = sel_registerName("commit");
    _ = objc_msgSend(cmd.cmd_buffer, commit);
}

pub const MetalPipeline = struct { pipeline_state: ?*anyopaque };

pub fn createPipeline(surface: *MetalSurface, desc: *const zgraphics.PipelineDesc) ?*MetalPipeline {
    if (builtin.os.tag != .macos) return null;

    const MTLRenderPipelineDescriptor = objc_getClass("MTLRenderPipelineDescriptor") orelse return null;
    const alloc1 = sel_registerName("alloc");
    const init1 = sel_registerName("init");
    const pipeline_desc = objc_msgSend(MTLRenderPipelineDescriptor, alloc1);
    _ = objc_msgSend(pipeline_desc, init1);

    const setVertexFunction = sel_registerName("setVertexFunction:");
    const setFragmentFunction = sel_registerName("setFragmentFunction:");
    const setColorAttachments = sel_registerName("colorAttachments");
    const object = sel_registerName("objectAtIndexedSubscript:");
    const setPixelFormat = sel_registerName("setPixelFormat:");

    const NSString = objc_getClass("NSString") orelse return null;
    const initWithBytes = sel_registerName("initWithBytes:length:encoding:");
    const vs_alloc = objc_msgSend(NSString, sel_registerName("alloc"));
    const vs_str = objc_msgSend(vs_alloc, initWithBytes, desc.vertex_shader orelse return null, desc.vertex_shader_len, @as(usize, 4));
    const ps_alloc = objc_msgSend(NSString, sel_registerName("alloc"));
    const ps_str = objc_msgSend(ps_alloc, initWithBytes, desc.pixel_shader orelse return null, desc.pixel_shader_len, @as(usize, 4));
    const newLibraryWithSource = sel_registerName("newLibraryWithSource:options:error:");
    var err: ?*anyopaque = null;
    const vs_lib = objc_msgSend(surface.device, newLibraryWithSource, vs_str, @as(?*anyopaque, null), &err) orelse return null;
    const ps_lib = objc_msgSend(surface.device, newLibraryWithSource, ps_str, @as(?*anyopaque, null), &err) orelse return null;
    const newFunctionWithName = sel_registerName("newFunctionWithName:");
    const main_name = objc_msgSend(NSString, sel_registerName("stringWithUTF8String:"), @as([*:0]const u8, "main0"));
    const vertex_fn = objc_msgSend(vs_lib, newFunctionWithName, main_name) orelse return null;
    const fragment_fn = objc_msgSend(ps_lib, newFunctionWithName, main_name) orelse return null;

    _ = objc_msgSend(pipeline_desc, setVertexFunction, vertex_fn);
    _ = objc_msgSend(pipeline_desc, setFragmentFunction, fragment_fn);

    const attachments = objc_msgSend(pipeline_desc, setColorAttachments);
    const attachment0 = objc_msgSend(attachments, object, @as(usize, 0));
    _ = objc_msgSend(attachment0, setPixelFormat, @as(usize, 70));

    const newRenderPipelineStateWithDescriptor = sel_registerName("newRenderPipelineStateWithDescriptor:error:");
    var pipeline_error: ?*anyopaque = null;
    const state = @as(?*anyopaque, @ptrCast(objc_msgSend(surface.device, newRenderPipelineStateWithDescriptor, pipeline_desc, @as(?*?*anyopaque, &pipeline_error)))) orelse return null;
    const mp = std.heap.page_allocator.create(MetalPipeline) catch return null;
    mp.* = .{ .pipeline_state = state };
    return mp;
}

pub fn destroyPipeline(surface: *MetalSurface, pipeline: ?*MetalPipeline) void {
    if (builtin.os.tag != .macos or pipeline == null) return;
    _ = surface;
    std.heap.page_allocator.destroy(pipeline.?);
}

pub fn cmdBindPipeline(cmd: *MetalCommandBuffer, pipeline: *MetalPipeline) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd; _ = pipeline;
}

pub fn cmdBindVertexBuffer(cmd: *MetalCommandBuffer, buffer: *MetalBuffer, offset: usize) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd; _ = buffer; _ = offset;
}

pub fn cmdDraw(cmd: *MetalCommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd; _ = vertex_count; _ = instance_count; _ = first_vertex; _ = first_instance;
}

pub fn uploadBuffer(buffer: *MetalBuffer, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag != .macos) return false;
    if (data == null or dataLen == 0) return false;
    const didModifyRange = sel_registerName("didModifyRange:");
    const contents = sel_registerName("contents");
    const ptr = objc_msgSend(buffer.buffer, contents) orelse return false;
    @memcpy(@as([*]u8, @ptrCast(@alignCast(ptr)))[0..dataLen], @as([*]const u8, @ptrCast(@alignCast(data)))[0..dataLen]);
    const range = struct { location: usize, length: usize }{ .location = 0, .length = dataLen };
    _ = objc_msgSend(buffer.buffer, didModifyRange, &range);
    buffer.size = dataLen;
    return true;
}

pub fn getBufferSize(buffer: *MetalBuffer) usize {
    return buffer.size;
}

pub const MetalTexture = struct { texture: ?*anyopaque };

pub fn createTexture(surface: *MetalSurface, desc: *const zgraphics.ZawraGraphicsTextureDesc) ?*MetalTexture {
    if (builtin.os.tag != .macos) return null;
    const MTLTextureDescriptor = objc_getClass("MTLTextureDescriptor") orelse return null;
    const texture2DDescriptorWithPixelFormat = sel_registerName("texture2DDescriptorWithPixelFormat:width:height:mipmapped:");
    const newTextureWithDescriptor = sel_registerName("newTextureWithDescriptor:");
    const descriptor = objc_msgSend(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        @as(usize, @intFromEnum(desc.format)),
        desc.width,
        desc.height,
        @as(usize, 0),
    );
    const tex = objc_msgSend(surface.device, newTextureWithDescriptor, descriptor) orelse return null;
    const mt = std.heap.page_allocator.create(MetalTexture) catch return null;
    mt.* = .{ .texture = tex };
    return mt;
}

pub fn destroyTexture(surface: *MetalSurface, texture: ?*MetalTexture) void {
    if (builtin.os.tag != .macos or texture == null) return;
    _ = surface;
    std.heap.page_allocator.destroy(texture.?);
}
