const std = @import("std");
const zgraphics = @import("lib.zig");
const builtin = @import("builtin");

pub const MetalSurface = struct {
    device: ?*anyopaque,
    command_queue: ?*anyopaque,
    texture: ?*anyopaque,
    window: ?*anyopaque,
    view: ?*anyopaque,
    iosurface: ?*anyopaque,
    width: u32,
    height: u32,
};

// Pure C-runtime / dlopen / dlsym dynamic dispatch to allow seamless
// cross-compilation on Linux/Windows hosts without Mach-O framework SDK stubs.
extern fn dlopen(path: ?[*:0]const u8, mode: c_int) ?*anyopaque;
extern fn dlsym(handle: ?*anyopaque, symbol: [*:0]const u8) ?*anyopaque;
const RTLD_LAZY: c_int = 0x1;

const Fn_objc_getClass = *const fn (name: [*:0]const u8) callconv(.c) ?*anyopaque;
const Fn_sel_registerName = *const fn (name: [*:0]const u8) callconv(.c) ?*anyopaque;
const Fn_objc_msgSend = *const fn (self: ?*anyopaque, op: ?*anyopaque, ...) callconv(.c) ?*anyopaque;
const Fn_MTLCreateSystemDefaultDevice = *const fn () callconv(.c) ?*anyopaque;

const Fn_IOSurfaceCreate = *const fn (properties: ?*anyopaque) callconv(.c) ?*anyopaque;
const Fn_IOSurfaceGetID = *const fn (buffer: ?*anyopaque) callconv(.c) u32;
const Fn_IOSurfaceLookup = *const fn (csid: u32) callconv(.c) ?*anyopaque;

var libs_initialized: bool = false;
var p_objc_getClass: ?Fn_objc_getClass = null;
var p_sel_registerName: ?Fn_sel_registerName = null;
var p_objc_msgSend: ?Fn_objc_msgSend = null;
var p_MTLCreateSystemDefaultDevice: ?Fn_MTLCreateSystemDefaultDevice = null;
var p_IOSurfaceCreate: ?Fn_IOSurfaceCreate = null;
var p_IOSurfaceGetID: ?Fn_IOSurfaceGetID = null;
var p_IOSurfaceLookup: ?Fn_IOSurfaceLookup = null;

fn initDynamicLibraries() bool {
    if (libs_initialized) return true;
    if (builtin.os.tag != .macos) return false;

    // Load Objective-C runtime
    var objc_lib = dlopen("/usr/lib/libobjc.A.dylib", RTLD_LAZY);
    if (objc_lib == null) {
        objc_lib = dlopen(null, RTLD_LAZY);
    }
    if (objc_lib) |lib| {
        if (dlsym(lib, "objc_getClass")) |sym| {
            p_objc_getClass = @ptrCast(@alignCast(sym));
        }
        if (dlsym(lib, "sel_registerName")) |sym| {
            p_sel_registerName = @ptrCast(@alignCast(sym));
        }
        if (dlsym(lib, "objc_msgSend")) |sym| {
            p_objc_msgSend = @ptrCast(@alignCast(sym));
        }
    }

    // Load AppKit and QuartzCore for UI / CAMetalLayer
    _ = dlopen("/System/Library/Frameworks/AppKit.framework/AppKit", RTLD_LAZY);
    _ = dlopen("/System/Library/Frameworks/QuartzCore.framework/QuartzCore", RTLD_LAZY);

    // Load Metal framework
    const metal_lib = dlopen("/System/Library/Frameworks/Metal.framework/Metal", RTLD_LAZY);
    if (metal_lib) |lib| {
        if (dlsym(lib, "MTLCreateSystemDefaultDevice")) |sym| {
            p_MTLCreateSystemDefaultDevice = @ptrCast(@alignCast(sym));
        }
    }

    // Load IOSurface framework for cross-process surface sharing (WebKit IPC)
    const iosurface_lib = dlopen("/System/Library/Frameworks/IOSurface.framework/IOSurface", RTLD_LAZY);
    if (iosurface_lib) |lib| {
        if (dlsym(lib, "IOSurfaceCreate")) |sym| {
            p_IOSurfaceCreate = @ptrCast(@alignCast(sym));
        }
        if (dlsym(lib, "IOSurfaceGetID")) |sym| {
            p_IOSurfaceGetID = @ptrCast(@alignCast(sym));
        }
        if (dlsym(lib, "IOSurfaceLookup")) |sym| {
            p_IOSurfaceLookup = @ptrCast(@alignCast(sym));
        }
    }

    libs_initialized = (p_objc_getClass != null and p_sel_registerName != null and p_objc_msgSend != null);
    return libs_initialized;
}

pub fn getClass(name: [*:0]const u8) ?*anyopaque {
    if (!initDynamicLibraries()) return null;
    return if (p_objc_getClass) |f| f(name) else null;
}

pub fn sel(name: [*:0]const u8) ?*anyopaque {
    if (!initDynamicLibraries()) return null;
    return if (p_sel_registerName) |f| f(name) else null;
}

pub fn msgSend(self: ?*anyopaque, op: ?*anyopaque, args: anytype) ?*anyopaque {
    if (!initDynamicLibraries()) return null;
    return if (p_objc_msgSend) |f| @call(.auto, f, .{ self, op } ++ args) else null;
}

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    if (builtin.os.tag != .macos) return null;
    if (!initDynamicLibraries()) return null;

    const NSWindow = getClass("NSWindow") orelse return null;
    const alloc = sel("alloc");
    const init = sel("initWithContentRect:styleMask:backing:defer:");
    const makeKeyAndOrderFront = sel("makeKeyAndOrderFront:");
    const setTitle = sel("setTitle:");
    const NSString = getClass("NSString");
    const stringWithUTF8String = sel("stringWithUTF8String:");

    const rect = [4]f64{ 100, 100, @floatFromInt(width), @floatFromInt(height) };
    const styleMask: usize = 1 | 2 | 4;
    const backing: usize = 2;

    const window_alloc = msgSend(NSWindow, alloc, .{});
    const window = msgSend(window_alloc, init, .{ &rect, styleMask, backing, @as(u8, 0) });

    const title = msgSend(NSString, stringWithUTF8String, .{@as([*:0]const u8, "Zawra Browser")});
    _ = msgSend(window, setTitle, .{title});
    _ = msgSend(window, makeKeyAndOrderFront, .{@as(?*anyopaque, null)});

    return window;
}

pub fn createSurface(window: ?*anyopaque, width: u32, height: u32) ?*MetalSurface {
    if (builtin.os.tag != .macos) return null;
    if (!initDynamicLibraries()) return null;

    const createDevice = p_MTLCreateSystemDefaultDevice orelse return null;
    const device = createDevice() orelse return null;

    var surface_obj = std.heap.page_allocator.create(MetalSurface) catch return null;
    surface_obj.device = device;
    surface_obj.window = window;
    surface_obj.iosurface = null;

    const newCommandQueue = sel("newCommandQueue");
    surface_obj.command_queue = msgSend(device, newCommandQueue, .{});

    const MTLTextureDescriptor = getClass("MTLTextureDescriptor") orelse return null;
    const texture2DDescriptorWithPixelFormat = sel("texture2DDescriptorWithPixelFormat:width:height:mipmapped:");

    const pixelFormat: usize = 70; // MTLPixelFormatBGRA8Unorm
    const mipmapped: usize = 0;

    const descriptor = msgSend(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        .{
            pixelFormat,
            @as(usize, width),
            @as(usize, height),
            mipmapped,
        },
    );

    const setUsage = sel("setUsage:");
    _ = msgSend(descriptor, setUsage, .{@as(usize, 1 | 2)}); // MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget

    // Attempt to allocate an IOSurface backing for WebKit zero-copy IPC sharing
    if (p_IOSurfaceCreate) |createIOSurface| {
        const NSDictionary = getClass("NSDictionary");
        const NSNumber = getClass("NSNumber");
        const NSString = getClass("NSString");
        if (NSDictionary != null and NSNumber != null and NSString != null) {
            const numberWithUnsignedInt = sel("numberWithUnsignedInt:");
            const stringWithUTF8String = sel("stringWithUTF8String:");
            const dictionaryWithObjects_forKeys_count = sel("dictionaryWithObjects:forKeys:count:");

            const keys = [_]?*anyopaque{
                msgSend(NSString, stringWithUTF8String, .{@as([*:0]const u8, "IOSurfaceWidth")}),
                msgSend(NSString, stringWithUTF8String, .{@as([*:0]const u8, "IOSurfaceHeight")}),
                msgSend(NSString, stringWithUTF8String, .{@as([*:0]const u8, "IOSurfaceBytesPerElement")}),
                msgSend(NSString, stringWithUTF8String, .{@as([*:0]const u8, "IOSurfacePixelFormat")}),
            };
            const values = [_]?*anyopaque{
                msgSend(NSNumber, numberWithUnsignedInt, .{width}),
                msgSend(NSNumber, numberWithUnsignedInt, .{height}),
                msgSend(NSNumber, numberWithUnsignedInt, .{@as(u32, 4)}),
                msgSend(NSNumber, numberWithUnsignedInt, .{@as(u32, 0x42475241)}), // 'BGRA'
            };

            const dict = msgSend(
                NSDictionary,
                dictionaryWithObjects_forKeys_count,
                .{ &values, &keys, @as(usize, 4) },
            );

            if (dict) |d| {
                surface_obj.iosurface = createIOSurface(d);
            }
        }
    }

    if (surface_obj.iosurface) |iosurf| {
        const newTextureWithDescriptor_iosurface_plane = sel("newTextureWithDescriptor:iosurface:plane:");
        surface_obj.texture = msgSend(device, newTextureWithDescriptor_iosurface_plane, .{ descriptor, iosurf, @as(usize, 0) });
    }

    if (surface_obj.texture == null) {
        const newTextureWithDescriptor = sel("newTextureWithDescriptor:");
        surface_obj.texture = msgSend(device, newTextureWithDescriptor, .{descriptor});
    }

    if (surface_obj.window) |win| {
        const CAMetalLayer = getClass("CAMetalLayer") orelse return null;
        const layer_alloc = msgSend(CAMetalLayer, sel("alloc"), .{});
        const layer = msgSend(layer_alloc, sel("init"), .{});

        const setDevice = sel("setDevice:");
        _ = msgSend(layer, setDevice, .{device});

        const setPixelFormat = sel("setPixelFormat:");
        _ = msgSend(layer, setPixelFormat, .{pixelFormat});

        const contentView = msgSend(win, sel("contentView"), .{});
        const setLayer = sel("setLayer:");
        const setWantsLayer = sel("setWantsLayer:");

        _ = msgSend(contentView, setLayer, .{layer});
        _ = msgSend(contentView, setWantsLayer, .{@as(u8, 1)});

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
        const nextDrawable = sel("nextDrawable");
        const drawable = msgSend(layer, nextDrawable, .{});
        if (drawable) |d| {
            const present_sel = sel("present");
            _ = msgSend(d, present_sel, .{});
        }
    }
}

pub fn createSwapchain(surface: *MetalSurface) bool {
    _ = surface;
    return true;
}

pub fn present(surface: *MetalSurface) void {
    swapBuffers(surface);
}

pub fn exportSurfaceIOSurface(surface: *MetalSurface) ?*anyopaque {
    if (builtin.os.tag != .macos) return null;
    if (surface.iosurface) |isurf| return isurf;
    if (surface.texture) |tex| {
        const iosurface = msgSend(tex, sel("iosurface"), .{});
        if (iosurface) |isurf| return isurf;
    }
    return null;
}

pub fn exportSurfaceFD(surface: *MetalSurface) i32 {
    if (builtin.os.tag != .macos) return -1;
    const isurf = exportSurfaceIOSurface(surface) orelse return -1;
    if (p_IOSurfaceGetID) |getIdFn| {
        const id = getIdFn(isurf);
        if (id != 0) {
            return @as(i32, @bitCast(id));
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
    const newBufferWithLength = sel("newBufferWithLength:options:");
    const buf = msgSend(surface.device, newBufferWithLength, .{ @as(usize, size), @as(usize, MTLResourceStorageModeShared | MTLResourceCPUCacheModeDefaultCache) }) orelse return null;
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
    const commandBuffer = sel("commandBuffer");
    const cmd = msgSend(surface.command_queue, commandBuffer, .{}) orelse return null;
    const MTLRenderPassDescriptor = getClass("MTLRenderPassDescriptor") orelse return null;
    const renderPassDescriptor = sel("renderPassDescriptor");
    const pass_desc = msgSend(MTLRenderPassDescriptor, renderPassDescriptor, .{});
    const colorAttachments = sel("colorAttachments");
    const attachments = msgSend(pass_desc, colorAttachments, .{});
    const objectAtIndexedSubscript = sel("objectAtIndexedSubscript:");
    const attachment0 = msgSend(attachments, objectAtIndexedSubscript, .{@as(usize, 0)});
    const setTexture = sel("setTexture:");
    _ = msgSend(attachment0, setTexture, .{surface.texture});
    const setStoreAction = sel("setStoreAction:");
    _ = msgSend(attachment0, setStoreAction, .{@as(usize, 1)});
    const setLoadAction = sel("setLoadAction:");
    _ = msgSend(attachment0, setLoadAction, .{@as(usize, 0)});
    const renderCommandEncoderWithDescriptor = sel("renderCommandEncoderWithDescriptor:");
    const render_encoder = msgSend(cmd, renderCommandEncoderWithDescriptor, .{pass_desc});
    const mcb = std.heap.page_allocator.create(MetalCommandBuffer) catch return null;
    mcb.* = .{ .cmd_buffer = cmd, .render_encoder = render_encoder };
    return mcb;
}

pub fn cmdClearAttachments(cmd: *MetalCommandBuffer, color: bool, depth: bool, stencil: bool, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd;
    _ = color;
    _ = depth;
    _ = stencil;
    _ = r;
    _ = g;
    _ = b;
    _ = a;
}

pub fn cmdClearColor(cmd: *MetalCommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .macos) return;
    const MTLRenderPassDescriptor = getClass("MTLRenderPassDescriptor") orelse return;
    const renderPassDescriptor = sel("renderPassDescriptor");
    const pass_desc = msgSend(MTLRenderPassDescriptor, renderPassDescriptor, .{});
    const colorAttachments = sel("colorAttachments");
    const attachments = msgSend(pass_desc, colorAttachments, .{});
    const objectAtIndexedSubscript = sel("objectAtIndexedSubscript:");
    const attachment0 = msgSend(attachments, objectAtIndexedSubscript, .{@as(usize, 0)});
    const MTLClearColor = extern struct { r: f64, g: f64, b: f64, a: f64 };
    const clear_color = MTLClearColor{ .r = @floatCast(r), .g = @floatCast(g), .b = @floatCast(b), .a = @floatCast(a) };
    const setClearColor = sel("setClearColor:");
    _ = msgSend(attachment0, setClearColor, .{clear_color});
    const setLoadAction = sel("setLoadAction:");
    _ = msgSend(attachment0, setLoadAction, .{@as(usize, 2)});
    const renderCommandEncoderWithDescriptor = sel("renderCommandEncoderWithDescriptor:");
    const encoder = msgSend(cmd.cmd_buffer, renderCommandEncoderWithDescriptor, .{pass_desc});
    if (encoder) |enc| {
        const endEncoding = sel("endEncoding");
        _ = msgSend(enc, endEncoding, .{});
    }
}

pub fn submitCommandBuffer(surface: *MetalSurface, cmd: *MetalCommandBuffer) void {
    if (builtin.os.tag != .macos) return;
    _ = surface;
    if (cmd.render_encoder) |enc| {
        const endEncoding = sel("endEncoding");
        _ = msgSend(enc, endEncoding, .{});
        cmd.render_encoder = null;
    }
    const commit = sel("commit");
    _ = msgSend(cmd.cmd_buffer, commit, .{});
}

pub const MetalPipeline = struct { pipeline_state: ?*anyopaque };

pub fn createPipeline(surface: *MetalSurface, desc: *const zgraphics.PipelineDesc) ?*MetalPipeline {
    if (builtin.os.tag != .macos) return null;
    _ = desc;

    const MTLRenderPipelineDescriptor = getClass("MTLRenderPipelineDescriptor") orelse return null;
    const alloc1 = sel("alloc");
    const init1 = sel("init");
    const pipeline_desc = msgSend(MTLRenderPipelineDescriptor, alloc1, .{});
    _ = msgSend(pipeline_desc, init1, .{});

    const setVertexFunction = sel("setVertexFunction:");
    const setFragmentFunction = sel("setFragmentFunction:");
    const setColorAttachments = sel("colorAttachments");
    const object = sel("objectAtIndexedSubscript:");
    const setPixelFormat = sel("setPixelFormat:");

    const NSString = getClass("NSString") orelse return null;
    const msl_source = "#include <metal_stdlib>\nusing namespace metal;\nvertex float4 vs_main(uint vid [[vertex_id]]) { return float4(0.0, 0.0, 0.0, 1.0); }\nfragment float4 fs_main() { return float4(1.0, 0.0, 0.0, 1.0); }";
    const msl_str = msgSend(NSString, sel("stringWithUTF8String:"), .{@as([*:0]const u8, msl_source)});
    const newLibraryWithSource = sel("newLibraryWithSource:options:error:");
    var err: ?*anyopaque = null;
    const lib = msgSend(surface.device, newLibraryWithSource, .{ msl_str, @as(?*anyopaque, null), &err }) orelse return null;

    const newFunctionWithName = sel("newFunctionWithName:");
    const vs_name = msgSend(NSString, sel("stringWithUTF8String:"), .{@as([*:0]const u8, "vs_main")});
    const ps_name = msgSend(NSString, sel("stringWithUTF8String:"), .{@as([*:0]const u8, "fs_main")});
    const vertex_fn = msgSend(lib, newFunctionWithName, .{vs_name}) orelse return null;
    const fragment_fn = msgSend(lib, newFunctionWithName, .{ps_name}) orelse return null;

    _ = msgSend(pipeline_desc, setVertexFunction, .{vertex_fn});
    _ = msgSend(pipeline_desc, setFragmentFunction, .{fragment_fn});

    const attachments = msgSend(pipeline_desc, setColorAttachments, .{});
    const attachment0 = msgSend(attachments, object, .{@as(usize, 0)});
    _ = msgSend(attachment0, setPixelFormat, .{@as(usize, 70)});

    const newRenderPipelineStateWithDescriptor = sel("newRenderPipelineStateWithDescriptor:error:");
    var pipeline_error: ?*anyopaque = null;
    const state = msgSend(surface.device, newRenderPipelineStateWithDescriptor, .{ pipeline_desc, @as(?*?*anyopaque, &pipeline_error) }) orelse return null;
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
    if (cmd.render_encoder) |enc| {
        const setRenderPipelineState = sel("setRenderPipelineState:");
        _ = msgSend(enc, setRenderPipelineState, .{pipeline.pipeline_state});
    }
}

pub fn cmdBindTexture(cmd: *MetalCommandBuffer, texture: *MetalTexture, binding: u32) void {
    if (builtin.os.tag != .macos) return;
    if (cmd.render_encoder) |enc| {
        const setFragmentTexture = sel("setFragmentTexture:atIndex:");
        _ = msgSend(enc, setFragmentTexture, .{ texture.texture, @as(usize, binding) });
    }
}

pub fn cmdBindVertexBuffer(cmd: *MetalCommandBuffer, buffer: *MetalBuffer, offset: usize) void {
    if (builtin.os.tag != .macos) return;
    if (cmd.render_encoder) |enc| {
        const p_msgSend = p_objc_msgSend orelse return;
        const setVertexBuffer_sel = sel("setVertexBuffer:offset:atIndex:") orelse return;
        const Fn_setVertexBuffer = *const fn (self: ?*anyopaque, op: ?*anyopaque, buf: ?*anyopaque, off: usize, index: usize) callconv(.c) void;
        const fn_call: Fn_setVertexBuffer = @ptrCast(@alignCast(p_msgSend));
        fn_call(enc, setVertexBuffer_sel, buffer.buffer, offset, 0);
    }
}

pub fn cmdDraw(cmd: *MetalCommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag != .macos) return;
    if (cmd.render_encoder) |enc| {
        const p_msgSend = p_objc_msgSend orelse return;
        const primitive_type: usize = if (vertex_count == 4) 4 else 3; // 4: TriangleStrip, 3: Triangle
        if (first_instance == 0) {
            const drawPrimitives_sel = sel("drawPrimitives:vertexStart:vertexCount:instanceCount:") orelse return;
            const Fn_drawPrimitives = *const fn (self: ?*anyopaque, op: ?*anyopaque, prim: usize, start: usize, count: usize, instances: usize) callconv(.c) void;
            const fn_call: Fn_drawPrimitives = @ptrCast(@alignCast(p_msgSend));
            fn_call(enc, drawPrimitives_sel, primitive_type, @as(usize, first_vertex), @as(usize, vertex_count), @as(usize, instance_count));
        } else {
            const drawPrimitivesBase_sel = sel("drawPrimitives:vertexStart:vertexCount:instanceCount:baseInstance:") orelse return;
            const Fn_drawPrimitivesBase = *const fn (self: ?*anyopaque, op: ?*anyopaque, prim: usize, start: usize, count: usize, instances: usize, base: usize) callconv(.c) void;
            const fn_call: Fn_drawPrimitivesBase = @ptrCast(@alignCast(p_msgSend));
            fn_call(enc, drawPrimitivesBase_sel, primitive_type, @as(usize, first_vertex), @as(usize, vertex_count), @as(usize, instance_count), @as(usize, first_instance));
        }
    }
}

pub fn uploadBuffer(buffer: *MetalBuffer, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag != .macos) return false;
    if (data == null or dataLen == 0) return false;
    const didModifyRange = sel("didModifyRange:");
    const contents = sel("contents");
    const ptr = msgSend(buffer.buffer, contents, .{}) orelse return false;
    @memcpy(@as([*]u8, @ptrCast(@alignCast(ptr)))[0..dataLen], @as([*]const u8, @ptrCast(@alignCast(data)))[0..dataLen]);
    const NSRange = extern struct { location: usize, length: usize };
    _ = msgSend(buffer.buffer, didModifyRange, .{NSRange{ .location = 0, .length = dataLen }});
    buffer.size = dataLen;
    return true;
}

pub fn getBufferSize(buffer: *MetalBuffer) usize {
    return buffer.size;
}

pub const MTLOrigin = extern struct { x: usize = 0, y: usize = 0, z: usize = 0 };
pub const MTLSize = extern struct { width: usize = 0, height: usize = 0, depth: usize = 1 };
pub const MTLRegion = extern struct { origin: MTLOrigin, size: MTLSize };

pub const MetalTexture = struct {
    texture: ?*anyopaque,
    width: u32 = 0,
    height: u32 = 0,
    format: zgraphics.ZawraGraphicsTextureFormat = .R8G8B8A8_Unorm,
};

pub fn setTextureParams(
    surface: *MetalSurface,
    texture: *MetalTexture,
    minFilter: u32,
    magFilter: u32,
    wrapS: u32,
    wrapT: u32,
) bool {
    _ = surface;
    _ = texture;
    _ = minFilter;
    _ = magFilter;
    _ = wrapS;
    _ = wrapT;
    return false;
}

pub fn createTexture(surface: *MetalSurface, desc: *const zgraphics.ZawraGraphicsTextureDesc) ?*MetalTexture {
    if (builtin.os.tag != .macos) return null;
    switch (desc.format) {
        .YUV420_3Plane, .NV12_2Plane, .P010_10bit => return null,
        else => {},
    }
    const MTLTextureDescriptor = getClass("MTLTextureDescriptor") orelse return null;
    const texture2DDescriptorWithPixelFormat = sel("texture2DDescriptorWithPixelFormat:width:height:mipmapped:");
    const newTextureWithDescriptor = sel("newTextureWithDescriptor:");
    const descriptor = msgSend(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        .{
            @as(usize, @intFromEnum(desc.format)),
            desc.width,
            desc.height,
            @as(usize, 0),
        },
    );
    const tex = msgSend(surface.device, newTextureWithDescriptor, .{descriptor}) orelse return null;
    const mt = std.heap.page_allocator.create(MetalTexture) catch return null;
    mt.* = .{
        .texture = tex,
        .width = desc.width,
        .height = desc.height,
        .format = desc.format,
    };
    return mt;
}

pub fn destroyTexture(surface: *MetalSurface, texture: ?*MetalTexture) void {
    if (builtin.os.tag != .macos or texture == null) return;
    _ = surface;
    std.heap.page_allocator.destroy(texture.?);
}

pub fn importTextureFD(surface: *MetalSurface, fd: i32, desc: *const zgraphics.ZawraGraphicsTextureDesc) ?*MetalTexture {
    if (builtin.os.tag != .macos) return null;
    if (fd < 0) return null;
    if (!initDynamicLibraries()) return null;

    const lookupFn = p_IOSurfaceLookup orelse return null;
    const iosurf = lookupFn(@as(u32, @bitCast(fd))) orelse return null;

    const MTLTextureDescriptor = getClass("MTLTextureDescriptor") orelse return null;
    const texture2DDescriptorWithPixelFormat = sel("texture2DDescriptorWithPixelFormat:width:height:mipmapped:");

    const pixelFormat: usize = 70; // MTLPixelFormatBGRA8Unorm
    const mipmapped: usize = 0;

    const descriptor = msgSend(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        .{
            pixelFormat,
            @as(usize, desc.width),
            @as(usize, desc.height),
            mipmapped,
        },
    ) orelse return null;

    const setUsage = sel("setUsage:");
    _ = msgSend(descriptor, setUsage, .{@as(usize, 1 | 2)});

    const newTextureWithDescriptor_iosurface_plane = sel("newTextureWithDescriptor:iosurface:plane:");
    const tex = msgSend(surface.device, newTextureWithDescriptor_iosurface_plane, .{ descriptor, iosurf, @as(usize, 0) }) orelse return null;

    const mt = std.heap.page_allocator.create(MetalTexture) catch return null;
    mt.* = .{
        .texture = tex,
        .width = desc.width,
        .height = desc.height,
        .format = desc.format,
    };
    return mt;
}

pub fn uploadTextureRegion(
    surface: *MetalSurface,
    texture: *MetalTexture,
    x: i32,
    y: u32,
    width: u32,
    height: u32,
    data: []const u8,
    rowStride: u32,
    srcOffsetX: u32,
    srcOffsetY: u32,
) bool {
    if (builtin.os.tag != .macos) return false;
    _ = surface;
    if (data.len == 0 or width == 0 or height == 0 or texture.texture == null) return false;
    if (!initDynamicLibraries()) return false;
    const p_msgSend = p_objc_msgSend orelse return false;
    const replaceRegion_sel = sel("replaceRegion:mipmapLevel:withBytes:bytesPerRow:") orelse return false;

    const effective_row_stride = if (rowStride > 0) rowStride else width * 4;
    const src_byte_offset = @as(usize, srcOffsetY) * @as(usize, effective_row_stride) + @as(usize, srcOffsetX) * 4;
    if (src_byte_offset >= data.len) return false;
    const src_ptr = data.ptr + src_byte_offset;

    const dst_x: usize = if (x >= 0) @as(usize, @intCast(x)) else 0;
    const region = MTLRegion{
        .origin = .{ .x = dst_x, .y = @as(usize, y), .z = 0 },
        .size = .{ .width = @as(usize, width), .height = @as(usize, height), .depth = 1 },
    };

    const Fn_replaceRegion = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        region: MTLRegion,
        level: usize,
        bytes: ?*const anyopaque,
        bytesPerRow: usize,
    ) callconv(.c) void;

    const fn_call: Fn_replaceRegion = @ptrCast(@alignCast(p_msgSend));
    fn_call(texture.texture, replaceRegion_sel, region, 0, src_ptr, effective_row_stride);
    return true;
}

pub fn uploadTexture(
    surface: *MetalSurface,
    texture: *MetalTexture,
    data: ?*const anyopaque,
    dataLen: usize,
) bool {
    if (data == null or dataLen == 0) return false;
    const slice = @as([*]const u8, @ptrCast(data.?))[0..dataLen];
    const stride = if (texture.width > 0) texture.width * 4 else @as(u32, @intCast(@min(dataLen, 4)));
    return uploadTextureRegion(surface, texture, 0, 0, texture.width, texture.height, slice, stride, 0, 0);
}

pub fn readbackTexture(
    surface: *MetalSurface,
    texture: *MetalTexture,
    out_buf: ?[*]u8,
    len: usize,
) bool {
    if (builtin.os.tag != .macos) return false;
    _ = surface;
    if (out_buf == null or len == 0 or texture.texture == null) return false;
    if (!initDynamicLibraries()) return false;
    const p_msgSend = p_objc_msgSend orelse return false;
    const getBytes_sel = sel("getBytes:bytesPerRow:fromRegion:mipmapLevel:") orelse return false;

    const bytesPerRow: usize = @as(usize, texture.width) * 4;
    const required_len: usize = bytesPerRow * @as(usize, texture.height);
    if (len < required_len) return false;

    const region = MTLRegion{
        .origin = .{ .x = 0, .y = 0, .z = 0 },
        .size = .{ .width = @as(usize, texture.width), .height = @as(usize, texture.height), .depth = 1 },
    };

    const Fn_getBytes = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        bytes: ?*anyopaque,
        bytesPerRow: usize,
        region: MTLRegion,
        level: usize,
    ) callconv(.c) void;

    const fn_call: Fn_getBytes = @ptrCast(@alignCast(p_msgSend));
    fn_call(texture.texture, getBytes_sel, out_buf.?, bytesPerRow, region, 0);
    return true;
}

pub fn beginLayer(cmd: *MetalCommandBuffer, layer_id: u32, x: f32, y: f32, width: f32, height: f32, opacity: f32) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd;
    _ = layer_id;
    _ = x;
    _ = y;
    _ = width;
    _ = height;
    _ = opacity;
}

pub fn endLayer(cmd: *MetalCommandBuffer) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd;
}

pub fn setLayerOrder(order: [*]const u32, count: u32) void {
    if (builtin.os.tag != .macos) return;
    _ = order;
    _ = count;
}

pub const MetalShaderModule = struct {
    library: ?*anyopaque,
};

pub fn createShaderModulePublic(surface: *MetalSurface, spirv: [*]const u8, spirv_len: usize) ?*MetalShaderModule {
    if (builtin.os.tag != .macos) return null;
    _ = surface;
    _ = spirv;
    _ = spirv_len;
    return null;
}

pub fn destroyShaderModulePublic(surface: *MetalSurface, module: *MetalShaderModule) void {
    if (builtin.os.tag != .macos) return;
    _ = surface;
    std.heap.page_allocator.destroy(module);
}

pub fn createPipelineFromShadersPublic(surface: *MetalSurface, vert: *MetalShaderModule, frag: *MetalShaderModule) ?*MetalPipeline {
    if (builtin.os.tag != .macos) return null;
    _ = surface;
    _ = vert;
    _ = frag;
    return null;
}

pub fn createUniformBuffer(surface: *MetalSurface, size: usize) ?*MetalBuffer {
    if (builtin.os.tag != .macos) return null;
    return createBuffer(surface, size, @intFromEnum(zgraphics.BufferType.Uniform));
}

pub fn uploadUniformBuffer(surface: *MetalSurface, buffer: *MetalBuffer, data: ?[*]const u8, len: usize) bool {
    if (builtin.os.tag != .macos) return false;
    _ = surface;
    return uploadBuffer(buffer, @ptrCast(@alignCast(data)), len);
}

pub fn cmdBindUniformBuffer(cmd: *MetalCommandBuffer, buffer: *MetalBuffer, binding: u32, offset: u64) void {
    if (builtin.os.tag != .macos) return;
    if (cmd.render_encoder) |enc| {
        const p_msgSend = p_objc_msgSend orelse return;
        const setVertexBuffer_sel = sel("setVertexBuffer:offset:atIndex:") orelse return;
        const setFragmentBuffer_sel = sel("setFragmentBuffer:offset:atIndex:") orelse return;
        const Fn_setBuffer = *const fn (self: ?*anyopaque, op: ?*anyopaque, buf: ?*anyopaque, off: usize, idx: usize) callconv(.c) void;
        const fn_call: Fn_setBuffer = @ptrCast(@alignCast(p_msgSend));
        fn_call(enc, setVertexBuffer_sel, buffer.buffer, @as(usize, @intCast(offset)), @as(usize, binding));
        fn_call(enc, setFragmentBuffer_sel, buffer.buffer, @as(usize, @intCast(offset)), @as(usize, binding));
    }
}

pub fn createMRTSurface(surface: *MetalSurface, width: u32, height: u32, attachment_count: u32) ?*anyopaque {
    _ = surface;
    _ = width;
    _ = height;
    _ = attachment_count;
    return null;
}

pub fn destroyMRTSurface(mrt: *anyopaque) void {
    _ = mrt;
}

pub fn beginMRTCommandBuffer(mrt: *anyopaque) ?*MetalCommandBuffer {
    _ = mrt;
    return null;
}

pub fn endMRTSurface(mrt: *anyopaque) void {
    _ = mrt;
}

pub fn readMRTTexture(mrt: *anyopaque, index: u32, out_buf: ?[*]u8, len: usize) bool {
    _ = mrt;
    _ = index;
    _ = out_buf;
    _ = len;
    return false;
}

pub fn createStencilSurface(surface: *MetalSurface, width: u32, height: u32) ?*anyopaque {
    _ = surface;
    _ = width;
    _ = height;
    return null;
}

pub fn destroyStencilSurface(stencil: *anyopaque) void {
    _ = stencil;
}

pub fn beginStencilCommandBuffer(stencil: *anyopaque) ?*MetalCommandBuffer {
    _ = stencil;
    return null;
}

pub fn endStencilSurface(stencil: *anyopaque) void {
    _ = stencil;
}

pub fn readStencilColorTexture(stencil: *anyopaque, out_buf: ?[*]u8, len: usize) bool {
    _ = stencil;
    _ = out_buf;
    _ = len;
    return false;
}

pub fn createStencilPipeline(surface: *MetalSurface, desc: *const zgraphics.PipelineDesc) ?*MetalPipeline {
    _ = surface;
    _ = desc;
    return null;
}

pub fn cmdSetStencilMask(cmd: *MetalCommandBuffer, face_mask: u32, reference: u32) void {
    _ = cmd;
    _ = face_mask;
    _ = reference;
}

pub fn cmdCopyTexture(cmd: *MetalCommandBuffer, src: *MetalTexture, dst: *MetalTexture) void {
    if (builtin.os.tag != .macos) return;
    _ = cmd;
    _ = src;
    _ = dst;
}

pub const MTLViewport = extern struct {
    originX: f64,
    originY: f64,
    width: f64,
    height: f64,
    znear: f64,
    zfar: f64,
};

pub const MTLScissorRect = extern struct {
    x: usize,
    y: usize,
    width: usize,
    height: usize,
};

pub fn cmdSetViewport(cmd: *MetalCommandBuffer, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
    if (builtin.os.tag != .macos) return;
    if (cmd.render_encoder) |enc| {
        const p_msgSend = p_objc_msgSend orelse return;
        const setViewport_sel = sel("setViewport:") orelse return;
        const vp = MTLViewport{
            .originX = @floatCast(x),
            .originY = @floatCast(y),
            .width = @floatCast(width),
            .height = @floatCast(height),
            .znear = @floatCast(min_depth),
            .zfar = @floatCast(max_depth),
        };
        const Fn_setViewport = *const fn (self: ?*anyopaque, op: ?*anyopaque, viewport: MTLViewport) callconv(.c) void;
        const fn_call: Fn_setViewport = @ptrCast(@alignCast(p_msgSend));
        fn_call(enc, setViewport_sel, vp);
    }
}

pub fn cmdSetScissor(cmd: *MetalCommandBuffer, x: i32, y: i32, width: u32, height: u32) void {
    if (builtin.os.tag != .macos) return;
    if (cmd.render_encoder) |enc| {
        const p_msgSend = p_objc_msgSend orelse return;
        const setScissorRect_sel = sel("setScissorRect:") orelse return;
        const sx: usize = if (x >= 0) @as(usize, @intCast(x)) else 0;
        const sy: usize = if (y >= 0) @as(usize, @intCast(y)) else 0;
        const sc = MTLScissorRect{
            .x = sx,
            .y = sy,
            .width = @as(usize, width),
            .height = @as(usize, height),
        };
        const Fn_setScissor = *const fn (self: ?*anyopaque, op: ?*anyopaque, rect: MTLScissorRect) callconv(.c) void;
        const fn_call: Fn_setScissor = @ptrCast(@alignCast(p_msgSend));
        fn_call(enc, setScissorRect_sel, sc);
    }
}

pub fn getDeviceProperty(handle: anytype, name: u32) u32 {
    _ = handle;
    _ = name;
    return 0;
}
