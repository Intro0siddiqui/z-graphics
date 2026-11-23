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
const Fn_MTLCreateSystemDefaultDevice = *const fn () callconv(.c) ?*anyopaque;
const Fn_CFRelease = *const fn (cf: ?*const anyopaque) callconv(.c) void;

const Fn_IOSurfaceCreate = *const fn (properties: ?*anyopaque) callconv(.c) ?*anyopaque;
const Fn_IOSurfaceGetID = *const fn (buffer: ?*anyopaque) callconv(.c) u32;
const Fn_IOSurfaceLookup = *const fn (csid: u32) callconv(.c) ?*anyopaque;

const Fn_objc_msgSend_Raw = *const fn () callconv(.c) void;
var libs_initialized: bool = false;
var p_objc_getClass: ?Fn_objc_getClass = null;
var p_sel_registerName: ?Fn_sel_registerName = null;
var p_objc_msgSend: ?Fn_objc_msgSend_Raw = null;
var p_MTLCreateSystemDefaultDevice: ?Fn_MTLCreateSystemDefaultDevice = null;
var p_CFRelease: ?Fn_CFRelease = null;
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

    // Load CoreFoundation framework for CFRelease
    const cf_lib = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY);
    if (cf_lib) |lib| {
        if (dlsym(lib, "CFRelease")) |sym| {
            p_CFRelease = @ptrCast(@alignCast(sym));
        }
    }
    if (p_CFRelease == null and objc_lib != null) {
        if (dlsym(objc_lib.?, "CFRelease")) |sym| {
            p_CFRelease = @ptrCast(@alignCast(sym));
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

// Fixed-signature non-variadic dispatchers for Apple Silicon (ARM64) AAPCS64 ABI compliance.
// On ARM64 Darwin, variadic (...) arguments are passed on the stack, whereas Objective-C
// method implementations expect fixed parameters in registers (x0..x7 / d0..d7).
// Using variadic msgSend passes garbage into methods and crashes.
pub fn msgSend0(self: ?*anyopaque, op: ?*anyopaque) ?*anyopaque {
    const f: *const fn (?*anyopaque, ?*anyopaque) callconv(.c) ?*anyopaque = @ptrCast(p_objc_msgSend orelse return null);
    return f(self, op);
}

pub fn msgSend1Ptr(self: ?*anyopaque, op: ?*anyopaque, arg: ?*anyopaque) ?*anyopaque {
    const f: *const fn (?*anyopaque, ?*anyopaque, ?*anyopaque) callconv(.c) ?*anyopaque = @ptrCast(p_objc_msgSend orelse return null);
    return f(self, op, arg);
}

pub fn msgSend1Usize(self: ?*anyopaque, op: ?*anyopaque, arg: usize) ?*anyopaque {
    const f: *const fn (?*anyopaque, ?*anyopaque, usize) callconv(.c) ?*anyopaque = @ptrCast(p_objc_msgSend orelse return null);
    return f(self, op, arg);
}

pub fn msgSend1U32(self: ?*anyopaque, op: ?*anyopaque, arg: u32) ?*anyopaque {
    const f: *const fn (?*anyopaque, ?*anyopaque, u32) callconv(.c) ?*anyopaque = @ptrCast(p_objc_msgSend orelse return null);
    return f(self, op, arg);
}

pub fn msgSend1Bool(self: ?*anyopaque, op: ?*anyopaque, arg: u8) void {
    const f: *const fn (?*anyopaque, ?*anyopaque, u8) callconv(.c) void = @ptrCast(p_objc_msgSend orelse return);
    f(self, op, arg);
}

pub fn msgSend1F64(self: ?*anyopaque, op: ?*anyopaque, arg: f64) void {
    const f: *const fn (?*anyopaque, ?*anyopaque, f64) callconv(.c) void = @ptrCast(p_objc_msgSend orelse return);
    f(self, op, arg);
}

pub fn msgSendStr(self: ?*anyopaque, op: ?*anyopaque, str: [*:0]const u8) ?*anyopaque {
    const f: *const fn (?*anyopaque, ?*anyopaque, [*:0]const u8) callconv(.c) ?*anyopaque = @ptrCast(p_objc_msgSend orelse return null);
    return f(self, op, str);
}

pub const NSPoint = extern struct {
    x: f64,
    y: f64,
};

pub const NSSize = extern struct {
    width: f64,
    height: f64,
};

pub const NSRect = extern struct {
    origin: NSPoint,
    size: NSSize,
};

pub const NSRange = extern struct {
    location: usize,
    length: usize,
};

pub const MTLClearColor = extern struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};

pub fn msgSendNSSize(self: ?*anyopaque, op: ?*anyopaque, size: NSSize) void {
    const f: *const fn (?*anyopaque, ?*anyopaque, NSSize) callconv(.c) void = @ptrCast(p_objc_msgSend orelse return);
    f(self, op, size);
}

pub fn msgSendMTLClearColor(self: ?*anyopaque, op: ?*anyopaque, color: MTLClearColor) void {
    const f: *const fn (?*anyopaque, ?*anyopaque, MTLClearColor) callconv(.c) void = @ptrCast(p_objc_msgSend orelse return);
    f(self, op, color);
}

pub fn msgSendNSRange(self: ?*anyopaque, op: ?*anyopaque, range: NSRange) void {
    const f: *const fn (?*anyopaque, ?*anyopaque, NSRange) callconv(.c) void = @ptrCast(p_objc_msgSend orelse return);
    f(self, op, range);
}

pub const PointerEventFn = *const fn (event_type: u32, x: f32, y: f32, button: u32, state: u32) callconv(.c) void;
pub const KeyboardEventFn = *const fn (key: u32, state: u32, ctrl: bool) callconv(.c) void;

var global_pointer_callback: ?PointerEventFn = null;
var global_keyboard_callback: ?KeyboardEventFn = null;
var current_window_height: f64 = 720.0;

pub fn setPointerCallback(cb: ?PointerEventFn) void {
    global_pointer_callback = cb;
}

pub fn setKeyboardCallback(cb: ?KeyboardEventFn) void {
    global_keyboard_callback = cb;
}

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    if (builtin.os.tag != .macos) return null;
    if (!initDynamicLibraries()) return null;

    current_window_height = @floatFromInt(height);

    // Ensure NSApplication is initialized and activated
    const NSApplication = getClass("NSApplication");
    if (NSApplication) |app_cls| {
        const app = msgSend0(app_cls, sel("sharedApplication"));
        if (app) |a| {
            // NSApplicationActivationPolicyRegular = 0
            _ = msgSend1Usize(a, sel("setActivationPolicy:"), 0);
            _ = msgSend0(a, sel("finishLaunching"));
        }
    }

    const NSWindow = getClass("NSWindow") orelse return null;
    const alloc = sel("alloc");
    const init = sel("initWithContentRect:styleMask:backing:defer:");
    const makeKeyAndOrderFront = sel("makeKeyAndOrderFront:");
    const setTitle = sel("setTitle:");
    const NSString = getClass("NSString");
    const stringWithUTF8String = sel("stringWithUTF8String:");

    const rect = NSRect{
        .origin = .{ .x = 100.0, .y = 100.0 },
        .size = .{ .width = @floatFromInt(width), .height = @floatFromInt(height) },
    };
    const styleMask: usize = 1 | 2 | 4 | 8; // Titled, Closable, Miniaturizable, Resizable
    const backing: usize = 2; // NSBackingStoreBuffered

    const window_alloc = msgSend0(NSWindow, alloc);
    const Fn_initWithContentRect = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        rect: NSRect,
        styleMask: usize,
        backing: usize,
        defer_flag: u8,
    ) callconv(.c) ?*anyopaque;
    const init_fn: Fn_initWithContentRect = @ptrCast(p_objc_msgSend orelse return null);
    const window = init_fn(window_alloc, init, rect, styleMask, backing, 0);

    const title = msgSendStr(NSString, stringWithUTF8String, "Zawra Browser");
    _ = msgSend1Ptr(window, setTitle, title);
    _ = msgSend1Ptr(window, makeKeyAndOrderFront, null);

    return window;
}

pub fn destroyWindow(window: ?*anyopaque) void {
    if (builtin.os.tag != .macos) return;
    if (window) |win| {
        _ = msgSend0(win, sel("close"));
    }
}

pub fn dispatchEvents(window: ?*anyopaque) void {
    _ = window;
    if (builtin.os.tag != .macos) return;
    if (!initDynamicLibraries()) return;

    const NSApplication = getClass("NSApplication") orelse return;
    const app = msgSend0(NSApplication, sel("sharedApplication")) orelse return;
    const NSString = getClass("NSString") orelse return;
    const mode = msgSendStr(NSString, sel("stringWithUTF8String:"), "kCFRunLoopDefaultMode");

    const nextEvent = sel("nextEventMatchingMask:untilDate:inMode:dequeue:");
    const sendEvent = sel("sendEvent:");
    const updateWindows = sel("updateWindows");

    const mask: usize = std.math.maxInt(usize); // NSEventMaskAny
    const Fn_nextEvent = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        mask: usize,
        untilDate: ?*anyopaque,
        inMode: ?*anyopaque,
        dequeue: u8,
    ) callconv(.c) ?*anyopaque;
    const nextEvent_fn: Fn_nextEvent = @ptrCast(p_objc_msgSend orelse return);

    while (true) {
        const event = nextEvent_fn(app, nextEvent, mask, null, mode, 1);
        if (event == null) break;

        if (p_objc_msgSend) |f| {
            const Fn_msgSend_usize = *const fn (?*anyopaque, ?*anyopaque) callconv(.c) usize;
            const type_call: Fn_msgSend_usize = @ptrCast(f);
            const ev_type = type_call(event, sel("type"));

            if (global_pointer_callback) |ptr_cb| {
                const Fn_msgSend_point = *const fn (?*anyopaque, ?*anyopaque) callconv(.c) NSPoint;
                const loc_call: Fn_msgSend_point = @ptrCast(f);
                const loc = loc_call(event, sel("locationInWindow"));

                const sx: f32 = @floatCast(loc.x);
                const sy: f32 = @floatCast(if (current_window_height > loc.y) current_window_height - loc.y else 0.0);

                switch (ev_type) {
                    1 => ptr_cb(1, sx, sy, 0x110, 1), // LeftMouseDown
                    2 => ptr_cb(2, sx, sy, 0x110, 0), // LeftMouseUp
                    3 => ptr_cb(1, sx, sy, 0x111, 1), // RightMouseDown
                    4 => ptr_cb(2, sx, sy, 0x111, 0), // RightMouseUp
                    5, 6, 7 => ptr_cb(0, sx, sy, 0, 0), // MouseMoved, LeftMouseDragged, RightMouseDragged
                    22 => ptr_cb(3, sx, sy, 0, 0), // ScrollWheel
                    else => {},
                }
            }

            if (global_keyboard_callback) |kb_cb| {
                if (ev_type == 10 or ev_type == 11) { // KeyDown = 10, KeyUp = 11
                    const Fn_msgSend_u16 = *const fn (?*anyopaque, ?*anyopaque) callconv(.c) u16;
                    const key_call: Fn_msgSend_u16 = @ptrCast(f);
                    const key_code = key_call(event, sel("keyCode"));

                    const flags = type_call(event, sel("modifierFlags"));
                    const ctrl = (flags & ((1 << 18) | (1 << 20))) != 0; // Control (1<<18) or Command (1<<20)
                    const state: u32 = if (ev_type == 10) 1 else 0;

                    kb_cb(@as(u32, key_code), state, ctrl);
                }
            }
        }

        _ = msgSend1Ptr(app, sendEvent, event);
    }
    _ = msgSend0(app, updateWindows);
}

fn createSurfaceInternal(window: ?*anyopaque, width: u32, height: u32) !*MetalSurface {
    const createDevice = p_MTLCreateSystemDefaultDevice orelse return error.NoMetalDevice;
    const device = createDevice() orelse return error.NoMetalDevice;

    const surface_obj = try std.heap.page_allocator.create(MetalSurface);
    surface_obj.* = .{
        .device = device,
        .command_queue = null,
        .texture = null,
        .window = window,
        .view = null,
        .iosurface = null,
        .width = width,
        .height = height,
    };
    errdefer destroySurface(surface_obj);

    const newCommandQueue = sel("newCommandQueue");
    surface_obj.command_queue = msgSend0(device, newCommandQueue);
    if (surface_obj.command_queue == null) return error.CommandQueueFailed;

    const MTLTextureDescriptor = getClass("MTLTextureDescriptor") orelse return error.NoMTLTextureDescriptor;
    const texture2DDescriptorWithPixelFormat = sel("texture2DDescriptorWithPixelFormat:width:height:mipmapped:");

    const pixelFormat: usize = 70; // MTLPixelFormatBGRA8Unorm
    const mipmapped: usize = 0;

    const Fn_texDesc = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        pixelFormat: usize,
        width: usize,
        height: usize,
        mipmapped: usize,
    ) callconv(.c) ?*anyopaque;
    const texDesc_fn: Fn_texDesc = @ptrCast(p_objc_msgSend orelse return error.NullMsgSend);

    const descriptor = texDesc_fn(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        pixelFormat,
        @as(usize, width),
        @as(usize, height),
        mipmapped,
    ) orelse return error.DescriptorFailed;

    const setUsage = sel("setUsage:");
    _ = msgSend1Usize(descriptor, setUsage, 1 | 2); // MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget

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
                msgSendStr(NSString, stringWithUTF8String, "IOSurfaceWidth"),
                msgSendStr(NSString, stringWithUTF8String, "IOSurfaceHeight"),
                msgSendStr(NSString, stringWithUTF8String, "IOSurfaceBytesPerElement"),
                msgSendStr(NSString, stringWithUTF8String, "IOSurfacePixelFormat"),
            };
            const values = [_]?*anyopaque{
                msgSend1U32(NSNumber, numberWithUnsignedInt, width),
                msgSend1U32(NSNumber, numberWithUnsignedInt, height),
                msgSend1U32(NSNumber, numberWithUnsignedInt, 4),
                msgSend1U32(NSNumber, numberWithUnsignedInt, 0x42475241), // 'BGRA'
            };

            const Fn_dictWithObj = *const fn (
                self: ?*anyopaque,
                op: ?*anyopaque,
                objects: [*]const ?*anyopaque,
                keys: [*]const ?*anyopaque,
                count: usize,
            ) callconv(.c) ?*anyopaque;
            const dict_fn: Fn_dictWithObj = @ptrCast(p_objc_msgSend orelse return error.NullMsgSend);

            const dict = dict_fn(
                NSDictionary,
                dictionaryWithObjects_forKeys_count,
                &values,
                &keys,
                4,
            );

            if (dict) |d| {
                surface_obj.iosurface = createIOSurface(d);
            }
        }
    }

    if (surface_obj.iosurface) |iosurf| {
        const newTextureWithDescriptor_iosurface_plane = sel("newTextureWithDescriptor:iosurface:plane:");
        const Fn_newTexIOSurf = *const fn (
            self: ?*anyopaque,
            op: ?*anyopaque,
            desc: ?*anyopaque,
            iosurf: ?*anyopaque,
            plane: usize,
        ) callconv(.c) ?*anyopaque;
        const newTexIOSurf_fn: Fn_newTexIOSurf = @ptrCast(p_objc_msgSend orelse return error.NullMsgSend);
        surface_obj.texture = newTexIOSurf_fn(device, newTextureWithDescriptor_iosurface_plane, descriptor, iosurf, 0);
    }

    if (surface_obj.texture == null) {
        const newTextureWithDescriptor = sel("newTextureWithDescriptor:");
        surface_obj.texture = msgSend1Ptr(device, newTextureWithDescriptor, descriptor);
    }

    if (surface_obj.texture == null) return error.TextureCreationFailed;

    if (surface_obj.window) |win| {
        const CAMetalLayer = getClass("CAMetalLayer") orelse return error.NoCAMetalLayer;
        const layer_alloc = msgSend0(CAMetalLayer, sel("alloc"));
        const layer = msgSend0(layer_alloc, sel("init")) orelse return error.LayerInitFailed;

        const setDevice = sel("setDevice:");
        _ = msgSend1Ptr(layer, setDevice, device);

        const setPixelFormat = sel("setPixelFormat:");
        _ = msgSend1Usize(layer, setPixelFormat, pixelFormat);

        // Set backing scale factor for Retina displays
        const backingScaleFactor = sel("backingScaleFactor");
        var scale: f64 = 1.0;
        if (p_objc_msgSend) |f| {
            const scale_call: *const fn (?*anyopaque, ?*anyopaque) callconv(.c) f64 = @ptrCast(f);
            scale = scale_call(win, backingScaleFactor);
            if (scale < 1.0) scale = 1.0;
        }

        const setContentsScale = sel("setContentsScale:");
        msgSend1F64(layer, setContentsScale, scale);

        const setDrawableSize = sel("setDrawableSize:");
        msgSendNSSize(layer, setDrawableSize, NSSize{
            .width = @as(f64, @floatFromInt(width)) * scale,
            .height = @as(f64, @floatFromInt(height)) * scale,
        });

        const contentView = msgSend0(win, sel("contentView"));
        const setLayer = sel("setLayer:");
        const setWantsLayer = sel("setWantsLayer:");

        _ = msgSend1Ptr(contentView, setLayer, layer);
        msgSend1Bool(contentView, setWantsLayer, 1);

        surface_obj.view = layer;
    } else {
        surface_obj.view = null;
    }

    return surface_obj;
}

pub fn createSurface(window: ?*anyopaque, width: u32, height: u32) ?*MetalSurface {
    if (builtin.os.tag != .macos) return null;
    if (!initDynamicLibraries()) return null;
    return createSurfaceInternal(window, width, height) catch null;
}

pub fn destroySurface(surface: *MetalSurface) void {
    if (builtin.os.tag != .macos) return;
    if (surface.iosurface) |isurf| {
        if (p_CFRelease) |cfRelease| {
            cfRelease(isurf);
        }
        surface.iosurface = null;
    }
    std.heap.page_allocator.destroy(surface);
}

pub fn swapBuffers(surface: *MetalSurface) void {
    if (builtin.os.tag != .macos) return;

    if (surface.view) |layer| {
        const nextDrawable = sel("nextDrawable");
        const drawable = msgSend0(layer, nextDrawable);
        if (drawable) |d| {
            const present_sel = sel("present");
            _ = msgSend0(d, present_sel);
        }
    }
}

pub fn createSwapchain(surface: *MetalSurface) bool {
    _ = surface;
    return true;
}

pub fn recreateSwapchain(surface: *MetalSurface, width: u32, height: u32) void {
    if (builtin.os.tag != .macos) return;
    surface.width = width;
    surface.height = height;
    current_window_height = @floatFromInt(height);

    if (surface.window) |win| {
        if (surface.view) |layer| {
            var scale: f64 = 1.0;
            if (p_objc_msgSend) |f| {
                const scale_call: *const fn (?*anyopaque, ?*anyopaque) callconv(.c) f64 = @ptrCast(f);
                scale = scale_call(win, sel("backingScaleFactor"));
                if (scale < 1.0) scale = 1.0;
            }
            const setContentsScale = sel("setContentsScale:");
            msgSend1F64(layer, setContentsScale, scale);

            const setDrawableSize = sel("setDrawableSize:");
            msgSendNSSize(layer, setDrawableSize, NSSize{
                .width = @as(f64, @floatFromInt(width)) * scale,
                .height = @as(f64, @floatFromInt(height)) * scale,
            });
        }
    }
}

pub fn present(surface: *MetalSurface) void {
    swapBuffers(surface);
}

pub fn exportSurfaceIOSurface(surface: *MetalSurface) ?*anyopaque {
    if (builtin.os.tag != .macos) return null;
    if (surface.iosurface) |isurf| return isurf;
    if (surface.texture) |tex| {
        const iosurface = msgSend0(tex, sel("iosurface"));
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
    const Fn_newBuffer = *const fn (self: ?*anyopaque, op: ?*anyopaque, length: usize, options: usize) callconv(.c) ?*anyopaque;
    const newBuffer_fn: Fn_newBuffer = @ptrCast(p_objc_msgSend orelse return null);
    const buf = newBuffer_fn(surface.device, newBufferWithLength, size, MTLResourceStorageModeShared | MTLResourceCPUCacheModeDefaultCache) orelse return null;
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
    const cmd = msgSend0(surface.command_queue, commandBuffer) orelse return null;
    const MTLRenderPassDescriptor = getClass("MTLRenderPassDescriptor") orelse return null;
    const renderPassDescriptor = sel("renderPassDescriptor");
    const pass_desc = msgSend0(MTLRenderPassDescriptor, renderPassDescriptor);
    const colorAttachments = sel("colorAttachments");
    const attachments = msgSend0(pass_desc, colorAttachments);
    const objectAtIndexedSubscript = sel("objectAtIndexedSubscript:");
    const attachment0 = msgSend1Usize(attachments, objectAtIndexedSubscript, 0);
    const setTexture = sel("setTexture:");
    _ = msgSend1Ptr(attachment0, setTexture, surface.texture);
    const setStoreAction = sel("setStoreAction:");
    _ = msgSend1Usize(attachment0, setStoreAction, 1);
    const setLoadAction = sel("setLoadAction:");
    _ = msgSend1Usize(attachment0, setLoadAction, 0);
    const renderCommandEncoderWithDescriptor = sel("renderCommandEncoderWithDescriptor:");
    const render_encoder = msgSend1Ptr(cmd, renderCommandEncoderWithDescriptor, pass_desc);
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
    const pass_desc = msgSend0(MTLRenderPassDescriptor, renderPassDescriptor);
    const colorAttachments = sel("colorAttachments");
    const attachments = msgSend0(pass_desc, colorAttachments);
    const objectAtIndexedSubscript = sel("objectAtIndexedSubscript:");
    const attachment0 = msgSend1Usize(attachments, objectAtIndexedSubscript, 0);
    const clear_color = MTLClearColor{ .r = @floatCast(r), .g = @floatCast(g), .b = @floatCast(b), .a = @floatCast(a) };
    const setClearColor = sel("setClearColor:");
    msgSendMTLClearColor(attachment0, setClearColor, clear_color);
    const setLoadAction = sel("setLoadAction:");
    _ = msgSend1Usize(attachment0, setLoadAction, 2);
    const renderCommandEncoderWithDescriptor = sel("renderCommandEncoderWithDescriptor:");
    const encoder = msgSend1Ptr(cmd.cmd_buffer, renderCommandEncoderWithDescriptor, pass_desc);
    if (encoder) |enc| {
        const endEncoding = sel("endEncoding");
        _ = msgSend0(enc, endEncoding);
    }
}

pub fn submitCommandBuffer(surface: *MetalSurface, cmd: *MetalCommandBuffer) void {
    if (builtin.os.tag != .macos) return;
    _ = surface;
    if (cmd.render_encoder) |enc| {
        const endEncoding = sel("endEncoding");
        _ = msgSend0(enc, endEncoding);
        cmd.render_encoder = null;
    }
    const commit = sel("commit");
    _ = msgSend0(cmd.cmd_buffer, commit);
}

pub const MetalPipeline = struct { pipeline_state: ?*anyopaque };

pub fn createPipeline(surface: *MetalSurface, desc: *const zgraphics.PipelineDesc) ?*MetalPipeline {
    if (builtin.os.tag != .macos) return null;
    _ = desc;

    const MTLRenderPipelineDescriptor = getClass("MTLRenderPipelineDescriptor") orelse return null;
    const alloc1 = sel("alloc");
    const init1 = sel("init");
    const pipeline_desc = msgSend0(MTLRenderPipelineDescriptor, alloc1);
    _ = msgSend0(pipeline_desc, init1);

    const setVertexFunction = sel("setVertexFunction:");
    const setFragmentFunction = sel("setFragmentFunction:");
    const setColorAttachments = sel("colorAttachments");
    const object = sel("objectAtIndexedSubscript:");
    const setPixelFormat = sel("setPixelFormat:");

    const NSString = getClass("NSString") orelse return null;
    const msl_source = "#include <metal_stdlib>\nusing namespace metal;\nvertex float4 vs_main(uint vid [[vertex_id]]) { return float4(0.0, 0.0, 0.0, 1.0); }\nfragment float4 fs_main() { return float4(1.0, 0.0, 0.0, 1.0); }";
    const msl_str = msgSendStr(NSString, sel("stringWithUTF8String:"), msl_source);
    const newLibraryWithSource = sel("newLibraryWithSource:options:error:");
    var err: ?*anyopaque = null;
    const Fn_newLib = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        source: ?*anyopaque,
        options: ?*anyopaque,
        err: ?*?*anyopaque,
    ) callconv(.c) ?*anyopaque;
    const newLib_fn: Fn_newLib = @ptrCast(p_objc_msgSend orelse return null);
    const lib = newLib_fn(surface.device, newLibraryWithSource, msl_str, null, &err) orelse return null;

    const newFunctionWithName = sel("newFunctionWithName:");
    const vs_name = msgSendStr(NSString, sel("stringWithUTF8String:"), "vs_main");
    const ps_name = msgSendStr(NSString, sel("stringWithUTF8String:"), "fs_main");
    const vertex_fn = msgSend1Ptr(lib, newFunctionWithName, vs_name) orelse return null;
    const fragment_fn = msgSend1Ptr(lib, newFunctionWithName, ps_name) orelse return null;

    _ = msgSend1Ptr(pipeline_desc, setVertexFunction, vertex_fn);
    _ = msgSend1Ptr(pipeline_desc, setFragmentFunction, fragment_fn);

    const attachments = msgSend0(pipeline_desc, setColorAttachments);
    const attachment0 = msgSend1Usize(attachments, object, 0);
    _ = msgSend1Usize(attachment0, setPixelFormat, 70);

    const newRenderPipelineStateWithDescriptor = sel("newRenderPipelineStateWithDescriptor:error:");
    var pipeline_error: ?*anyopaque = null;
    const Fn_newPipeline = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        descriptor: ?*anyopaque,
        err: ?*?*anyopaque,
    ) callconv(.c) ?*anyopaque;
    const newPipeline_fn: Fn_newPipeline = @ptrCast(p_objc_msgSend orelse return null);
    const state = newPipeline_fn(surface.device, newRenderPipelineStateWithDescriptor, pipeline_desc, &pipeline_error) orelse return null;
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
        _ = msgSend1Ptr(enc, setRenderPipelineState, pipeline.pipeline_state);
    }
}

pub fn cmdBindTexture(cmd: *MetalCommandBuffer, texture: *MetalTexture, binding: u32) void {
    if (builtin.os.tag != .macos) return;
    if (cmd.render_encoder) |enc| {
        const setFragmentTexture = sel("setFragmentTexture:atIndex:");
        const Fn_setFragTex = *const fn (self: ?*anyopaque, op: ?*anyopaque, tex: ?*anyopaque, idx: usize) callconv(.c) void;
        const setFragTex_fn: Fn_setFragTex = @ptrCast(p_objc_msgSend orelse return);
        setFragTex_fn(enc, setFragmentTexture, texture.texture, @as(usize, binding));
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
    const ptr = msgSend0(buffer.buffer, contents) orelse return false;
    @memcpy(@as([*]u8, @ptrCast(@alignCast(ptr)))[0..dataLen], @as([*]const u8, @ptrCast(@alignCast(data)))[0..dataLen]);
    msgSendNSRange(buffer.buffer, didModifyRange, NSRange{ .location = 0, .length = dataLen });
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
    const Fn_texDesc = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        pixelFormat: usize,
        width: usize,
        height: usize,
        mipmapped: usize,
    ) callconv(.c) ?*anyopaque;
    const texDesc_fn: Fn_texDesc = @ptrCast(p_objc_msgSend orelse return null);
    const descriptor = texDesc_fn(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        @as(usize, @intFromEnum(desc.format)),
        desc.width,
        desc.height,
        0,
    ) orelse return null;
    const tex = msgSend1Ptr(surface.device, newTextureWithDescriptor, descriptor) orelse return null;
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
    defer {
        if (p_CFRelease) |releaseFn| {
            releaseFn(iosurf);
        }
    }

    const MTLTextureDescriptor = getClass("MTLTextureDescriptor") orelse return null;
    const texture2DDescriptorWithPixelFormat = sel("texture2DDescriptorWithPixelFormat:width:height:mipmapped:");

    const pixelFormat: usize = 70; // MTLPixelFormatBGRA8Unorm
    const mipmapped: usize = 0;

    const Fn_texDesc = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        pixelFormat: usize,
        width: usize,
        height: usize,
        mipmapped: usize,
    ) callconv(.c) ?*anyopaque;
    const texDesc_fn: Fn_texDesc = @ptrCast(p_objc_msgSend orelse return null);

    const descriptor = texDesc_fn(
        MTLTextureDescriptor,
        texture2DDescriptorWithPixelFormat,
        pixelFormat,
        @as(usize, desc.width),
        @as(usize, desc.height),
        mipmapped,
    ) orelse return null;

    const setUsage = sel("setUsage:");
    _ = msgSend1Usize(descriptor, setUsage, 1 | 2);

    const newTextureWithDescriptor_iosurface_plane = sel("newTextureWithDescriptor:iosurface:plane:");
    const Fn_newTexIOSurf = *const fn (
        self: ?*anyopaque,
        op: ?*anyopaque,
        desc: ?*anyopaque,
        iosurf: ?*anyopaque,
        plane: usize,
    ) callconv(.c) ?*anyopaque;
    const newTexIOSurf_fn: Fn_newTexIOSurf = @ptrCast(p_objc_msgSend orelse return null);
    const tex = newTexIOSurf_fn(surface.device, newTextureWithDescriptor_iosurface_plane, descriptor, iosurf, 0) orelse return null;

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
