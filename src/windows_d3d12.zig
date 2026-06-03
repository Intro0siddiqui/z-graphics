const std = @import("std");
const zgraphics = @import("lib.zig");
const builtin = @import("builtin");

pub const D3D12Surface = struct {
    device: ?*anyopaque,
    command_queue: ?*anyopaque,
    resource: ?*anyopaque,
    allocation: ?*anyopaque,
    hwnd: ?*anyopaque,
    swapchain: ?*anyopaque,
    width: u32,
    height: u32,
};

const HWND = *anyopaque;
const HINSTANCE = *anyopaque;
const WNDPROC = *const fn (HWND, u32, usize, isize) callconv(.c) isize;

const WNDCLASSEXA = extern struct {
    cbSize: u32 = @sizeOf(WNDCLASSEXA),
    style: u32,
    lpfnWndProc: WNDPROC,
    cbClsExtra: i32 = 0,
    cbWndExtra: i32 = 0,
    hInstance: HINSTANCE,
    hIcon: ?*anyopaque = null,
    hCursor: ?*anyopaque = null,
    hbrBackground: ?*anyopaque = null,
    lpszMenuName: ?[*:0]const u8 = null,
    lpszClassName: [*:0]const u8,
    hIconSm: ?*anyopaque = null,
};

extern "user32" fn RegisterClassExA(lpwcx: *const WNDCLASSEXA) callconv(.c) u16;
extern "user32" fn CreateWindowExA(
    dwExStyle: u32,
    lpClassName: [*:0]const u8,
    lpWindowName: [*:0]const u8,
    dwStyle: u32,
    x: i32,
    y: i32,
    nWidth: i32,
    nHeight: i32,
    hWndParent: ?HWND,
    hMenu: ?*anyopaque,
    hInstance: HINSTANCE,
    lpParam: ?*anyopaque,
) callconv(.c) ?HWND;
extern "user32" fn DefWindowProcA(hWnd: HWND, Msg: u32, wParam: usize, lParam: isize) callconv(.c) isize;
extern "kernel32" fn GetModuleHandleA(lpModuleName: ?[*:0]const u8) callconv(.c) HINSTANCE;

const WS_OVERLAPPEDWINDOW = 0x00CF0000;
const WS_VISIBLE = 0x10000000;

fn windowProc(hwnd: HWND, msg: u32, wparam: usize, lparam: isize) callconv(.c) isize {
    return DefWindowProcA(hwnd, msg, wparam, lparam);
}

pub fn createWindow(width: u32, height: u32) ?*anyopaque {
    if (builtin.os.tag != .windows) return null;

    const h_inst = GetModuleHandleA(null);
    const class_name = "ZawraWindowClass";

    const wc = WNDCLASSEXA{
        .style = 0,
        .lpfnWndProc = windowProc,
        .hInstance = h_inst,
        .lpszClassName = class_name,
    };

    _ = RegisterClassExA(&wc);

    const hwnd = CreateWindowExA(
        0,
        class_name,
        "Zawra Browser",
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        100, 100, @intCast(width), @intCast(height),
        null, null, h_inst, null,
    ) orelse return null;

    return hwnd;
}

const HRESULT = i32;
const D3D_FEATURE_LEVEL = i32;
const D3D_FEATURE_LEVEL_11_0: D3D_FEATURE_LEVEL = 0xb000;

const GUID = extern struct {
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
};

const IID_ID3D12Device = GUID{
    .Data1 = 0x189819f1,
    .Data2 = 0x1db6,
    .Data3 = 0x4b08,
    .Data4 = .{ 0x8e, 0x95, 0x95, 0x13, 0xa4, 0xac, 0x69, 0x24 },
};

const IID_ID3D12CommandQueue = GUID{
    .Data1 = 0x0ec870a6,
    .Data2 = 0x5d7e,
    .Data3 = 0x4c22,
    .Data4 = .{ 0x8c, 0xfc, 0x5b, 0xaa, 0xe0, 0x76, 0x16, 0xed },
};

const IID_ID3D12Resource = GUID{
    .Data1 = 0x696442be,
    .Data2 = 0xa72e,
    .Data3 = 0x4059,
    .Data4 = .{ 0xbc, 0x8f, 0x5b, 0x1a, 0xd2, 0xff, 0xbc, 0xa6 },
};

const D3D12_COMMAND_LIST_TYPE_DIRECT = 0;
const D3D12_COMMAND_QUEUE_DESC = extern struct {
    Type: u32,
    Priority: i32,
    Flags: u32,
    NodeMask: u32,
};

const D3D12_HEAP_TYPE_DEFAULT = 1;
const D3D12_HEAP_PROPERTIES = extern struct {
    Type: u32,
    CPUPageProperty: u32,
    MemoryPoolPreference: u32,
    CreationNodeMask: u32,
    VisibleNodeMask: u32,
};

const D3D12_RESOURCE_DIMENSION_TEXTURE2D = 3;
const D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET = 1;
const D3D12_RESOURCE_DESC = extern struct {
    Dimension: u32,
    Alignment: u64,
    Width: u64,
    Height: u32,
    DepthOrArraySize: u16,
    MipLevels: u16,
    Format: u32,
    SampleDesc: extern struct { Count: u32, Quality: u32 },
    Layout: u32,
    Flags: u32,
};

extern "d3d12" fn D3D12CreateDevice(
    pAdapter: ?*anyopaque,
    MinimumFeatureLevel: D3D_FEATURE_LEVEL,
    riid: *const GUID,
    ppDevice: ?*?*anyopaque,
) callconv(.c) HRESULT;

const DXGI_FORMAT_R8G8B8A8_UNORM = 28;
const DXGI_USAGE_RENDER_TARGET_OUTPUT = 1 << (1 + 4);
const DXGI_SWAP_EFFECT_FLIP_DISCARD = 4;
const DXGI_SWAP_CHAIN_DESC1 = extern struct {
    Width: u32,
    Height: u32,
    Format: u32,
    Stereo: i32,
    SampleDesc: extern struct { Count: u32, Quality: u32 },
    BufferUsage: u32,
    BufferCount: u32,
    Scaling: i32,
    SwapEffect: i32,
    AlphaMode: i32,
    Flags: u32,
};

const IID_IDXGIFactory4 = GUID{
    .Data1 = 0x1bc6ea02,
    .Data2 = 0xef36,
    .Data3 = 0x464f,
    .Data4 = .{ 0xbf, 0x0c, 0x21, 0xca, 0x39, 0xe5, 0x16, 0x8a },
};

extern "dxgi" fn CreateDXGIFactory2(Flags: u32, riid: *const GUID, ppFactory: ?*?*anyopaque) callconv(.c) HRESULT;

pub fn createSurface(window: ?*anyopaque, width: u32, height: u32) ?*D3D12Surface {
    if (builtin.os.tag != .windows) return null;

    var device_ptr: ?*anyopaque = null;
    if (D3D12CreateDevice(null, D3D_FEATURE_LEVEL_11_0, &IID_ID3D12Device, &device_ptr) < 0) return null;
    const device = device_ptr orelse return null;

    var surface_obj = std.heap.page_allocator.create(D3D12Surface) catch return null;
    surface_obj.device = device;
    surface_obj.hwnd = window;

    const vtbl = @as(*const [*]const *anyopaque, @ptrCast(@alignCast(device))).*;

    const queue_desc = D3D12_COMMAND_QUEUE_DESC{
        .Type = D3D12_COMMAND_LIST_TYPE_DIRECT,
        .Priority = 0,
        .Flags = 0,
        .NodeMask = 0,
    };

    const CreateCommandQueue = @as(*const fn (*anyopaque, *const D3D12_COMMAND_QUEUE_DESC, *const GUID, *?*anyopaque) callconv(.c) HRESULT, @ptrCast(vtbl[8]));
    _ = CreateCommandQueue(device, &queue_desc, &IID_ID3D12CommandQueue, &surface_obj.command_queue);

    const heap_props = D3D12_HEAP_PROPERTIES{
        .Type = D3D12_HEAP_TYPE_DEFAULT,
        .CPUPageProperty = 0,
        .MemoryPoolPreference = 0,
        .CreationNodeMask = 1,
        .VisibleNodeMask = 1,
    };

    const res_desc = D3D12_RESOURCE_DESC{
        .Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D,
        .Alignment = 0,
        .Width = width,
        .Height = height,
        .DepthOrArraySize = 1,
        .MipLevels = 1,
        .Format = DXGI_FORMAT_R8G8B8A8_UNORM,
        .SampleDesc = .{ .Count = 1, .Quality = 0 },
        .Layout = 0,
        .Flags = D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET,
    };

    var create_committed_resource: ?*const fn (*anyopaque, *const D3D12_HEAP_PROPERTIES, u32, *const D3D12_RESOURCE_DESC, u32, ?*const anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT = undefined;
    if (vtbl.len > 27) {
        create_committed_resource = @as(*const fn (*anyopaque, *const D3D12_HEAP_PROPERTIES, u32, *const D3D12_RESOURCE_DESC, u32, ?*const anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT, @ptrCast(vtbl[27]));
    }
    if (create_committed_resource) |fn_ptr| {
        _ = fn_ptr(device, &heap_props, 0, &res_desc, 4, null, &IID_ID3D12Resource, &surface_obj.resource);
    }

    surface_obj.allocation = null;
    surface_obj.swapchain = null;

    if (surface_obj.hwnd != null) {
        var factory: ?*anyopaque = null;
        if (CreateDXGIFactory2(0, &IID_IDXGIFactory4, &factory) >= 0 and factory != null) {
            const f_vtbl = @as(*const [*]const *anyopaque, @ptrCast(@alignCast(factory.?))).*;
            var create_swap: ?*const fn (*anyopaque, *anyopaque, HWND, *const DXGI_SWAP_CHAIN_DESC1, ?*const anyopaque, ?*anyopaque, *?*anyopaque) callconv(.c) HRESULT = undefined;
            if (f_vtbl.len > 15) create_swap = @as(@TypeOf(create_swap), @ptrCast(f_vtbl[15]));
            if (create_swap) |fn_ptr| {
                const sd = DXGI_SWAP_CHAIN_DESC1{
                    .Width = width,
                    .Height = height,
                    .Format = DXGI_FORMAT_R8G8B8A8_UNORM,
                    .Stereo = 0,
                    .SampleDesc = .{ .Count = 1, .Quality = 0 },
                    .BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT,
                    .BufferCount = 2,
                    .Scaling = 0,
                    .SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD,
                    .AlphaMode = 0,
                    .Flags = 0,
                };
                _ = fn_ptr(factory.?, surface_obj.command_queue.?, surface_obj.hwnd.?, &sd, null, null, &surface_obj.swapchain);
            }

            var release: ?*const fn (*anyopaque) callconv(.c) u32 = undefined;
            if (f_vtbl.len > 2) release = @as(*const fn (*anyopaque) callconv(.c) u32, @ptrCast(f_vtbl[2]));
            if (release) |fn_ptr| _ = fn_ptr(factory.?);
        }
    }

    surface_obj.width = width;
    surface_obj.height = height;

    return surface_obj;
}

pub fn destroySurface(surface: *D3D12Surface) void {
    if (builtin.os.tag != .windows) return;
    std.heap.page_allocator.destroy(surface);
}

pub fn swapBuffers(surface: *D3D12Surface) void {
    if (builtin.os.tag != .windows) return;

    if (surface.swapchain) |sc| {
        const vtbl = @as(*const [*]const *anyopaque, @ptrCast(@alignCast(sc))).*;
        var present: ?*const fn (*anyopaque, u32, u32) callconv(.c) HRESULT = undefined;
        if (vtbl.len > 8) present = @as(*const fn (*anyopaque, u32, u32) callconv(.c) HRESULT, @ptrCast(vtbl[8]));
        if (present) |fn_ptr| _ = fn_ptr(sc, 1, 0);
    }
}

pub fn exportSurfaceFD(surface: *D3D12Surface) i32 {
    if (builtin.os.tag != .windows) return -1;
    _ = surface;
    return -1;
}

pub const D3D12Buffer = struct { resource: ?*anyopaque, size: usize };

pub fn createBuffer(surface: *D3D12Surface, size: usize, buffer_type: u32) ?*D3D12Buffer {
    if (builtin.os.tag != .windows) return null;
    _ = buffer_type;
    const heap_props = D3D12_HEAP_PROPERTIES{
        .Type = D3D12_HEAP_TYPE_DEFAULT,
        .CPUPageProperty = 0,
        .MemoryPoolPreference = 0,
        .CreationNodeMask = 1,
        .VisibleNodeMask = 1,
    };
    const usage = 1 | 2 | 6;
    const res_desc = D3D12_RESOURCE_DESC{
        .Dimension = 3,
        .Alignment = 0,
        .Width = size,
        .Height = 1,
        .DepthOrArraySize = 1,
        .MipLevels = 1,
        .Format = 0,
        .SampleDesc = .{ .Count = 1, .Quality = 0 },
        .Layout = 1,
        .Flags = usage,
    };
    const vtbl = @as(*const [*]const *anyopaque, @ptrCast(@alignCast(surface.device.?))).*;
    var create_resource: ?*const fn (*anyopaque, *const D3D12_HEAP_PROPERTIES, u32, *const D3D12_RESOURCE_DESC, u32, ?*const anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT = undefined;
    if (vtbl.len > 27) create_resource = @as(*const fn (*anyopaque, *const D3D12_HEAP_PROPERTIES, u32, *const D3D12_RESOURCE_DESC, u32, ?*const anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT, @ptrCast(vtbl[27]));
    var resource: ?*anyopaque = null;
    if (create_resource) |fn_ptr| {
        _ = fn_ptr(surface.device.?, &heap_props, 0, &res_desc, 4, null, &IID_ID3D12Resource, &resource);
    }
    if (resource == null) return null;

    const upload_heap = D3D12_HEAP_PROPERTIES{
        .Type = 1,
        .CPUPageProperty = 2,
        .MemoryPoolPreference = 0,
        .CreationNodeMask = 1,
        .VisibleNodeMask = 1,
    };
    const upload_desc = D3D12_RESOURCE_DESC{
        .Dimension = 3,
        .Alignment = 0,
        .Width = size,
        .Height = 1,
        .DepthOrArraySize = 1,
        .MipLevels = 1,
        .Format = 0,
        .SampleDesc = .{ .Count = 1, .Quality = 0 },
        .Layout = 1,
        .Flags = 1,
    };
    var upload: ?*anyopaque = null;
    if (create_resource) |fn_ptr| {
        _ = fn_ptr(surface.device.?, &upload_heap, 0, &upload_desc, 1, null, &IID_ID3D12Resource, &upload);
    }

    const buf = std.heap.page_allocator.create(D3D12Buffer) catch return null;
    buf.* = .{ .resource = resource, .size = size };
    return buf;
}

pub fn destroyBuffer(surface: *D3D12Surface, buffer: *D3D12Buffer) void {
    if (builtin.os.tag != .windows) return;
    _ = surface;
    std.heap.page_allocator.destroy(buffer);
}

pub const D3D12CommandBuffer = struct { cmd_list: ?*anyopaque, allocator: ?*anyopaque };

pub fn beginCommandBuffer(surface: *D3D12Surface) ?*D3D12CommandBuffer {
    if (builtin.os.tag != .windows) return null;
    _ = surface;
    return null;
}

pub fn cmdClearColor(cmd: *D3D12CommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .windows) return;
    _ = cmd; _ = r; _ = g; _ = b; _ = a;
}

pub fn submitCommandBuffer(surface: *D3D12Surface, cmd: *D3D12CommandBuffer) void {
    if (builtin.os.tag != .windows) return;
    _ = surface; _ = cmd;
}

pub const D3D12Pipeline = struct { pipeline_state: ?*anyopaque, root_signature: ?*anyopaque };

pub fn createPipeline(surface: *D3D12Surface, desc: *const zgraphics.PipelineDesc) ?*D3D12Pipeline {
    if (builtin.os.tag != .windows) return null;
    _ = surface; _ = desc;
    return null;
}

pub fn destroyPipeline(surface: *D3D12Surface, pipeline: ?*D3D12Pipeline) void {
    if (builtin.os.tag != .windows or pipeline == null) return;
    _ = surface;
    std.heap.page_allocator.destroy(pipeline.?);
}

pub fn cmdBindPipeline(cmd: *D3D12CommandBuffer, pipeline: *D3D12Pipeline) void {
    if (builtin.os.tag != .windows) return;
    _ = cmd; _ = pipeline;
}

pub fn cmdBindVertexBuffer(cmd: *D3D12CommandBuffer, buffer: *D3D12Buffer, offset: usize) void {
    if (builtin.os.tag != .windows) return;
    _ = cmd; _ = buffer; _ = offset;
}

pub fn cmdDraw(cmd: *D3D12CommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
    if (builtin.os.tag != .windows) return;
    _ = cmd; _ = vertex_count; _ = instance_count; _ = first_vertex; _ = first_instance;
}

pub fn uploadBuffer(buffer: *D3D12Buffer, data: ?*const anyopaque, dataLen: usize) bool {
    if (builtin.os.tag != .windows) return false;
    if (data == null or dataLen == 0) return false;
    buffer.size = dataLen;
    return true;
}

pub fn getBufferSize(buffer: *D3D12Buffer) usize {
    return buffer.size;
}

pub const D3D12Texture = struct { resource: ?*anyopaque };

pub fn createTexture(surface: *D3D12Surface, desc: *const zgraphics.ZawraGraphicsTextureDesc) ?*D3D12Texture {
    if (builtin.os.tag != .windows) return null;
    const heap_props = D3D12_HEAP_PROPERTIES{
        .Type = D3D12_HEAP_TYPE_DEFAULT,
        .CPUPageProperty = 0,
        .MemoryPoolPreference = 0,
        .CreationNodeMask = 1,
        .VisibleNodeMask = 1,
    };
    const res_desc = D3D12_RESOURCE_DESC{
        .Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D,
        .Alignment = 0,
        .Width = desc.width,
        .Height = desc.height,
        .DepthOrArraySize = 1,
        .MipLevels = 1,
        .Format = DXGI_FORMAT_R8G8B8A8_UNORM,
        .SampleDesc = .{ .Count = 1, .Quality = 0 },
        .Layout = 1,
        .Flags = 1,
    };
    const vtbl = @as(*const [*]const *anyopaque, @ptrCast(@alignCast(surface.device.?))).*;
    var create_resource: ?*const fn (*anyopaque, *const D3D12_HEAP_PROPERTIES, u32, *const D3D12_RESOURCE_DESC, u32, ?*const anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT = undefined;
    if (vtbl.len > 27) create_resource = @as(*const fn (*anyopaque, *const D3D12_HEAP_PROPERTIES, u32, *const D3D12_RESOURCE_DESC, u32, ?*const anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT, @ptrCast(vtbl[27]));
    var resource: ?*anyopaque = null;
    if (create_resource) |fn_ptr| {
        _ = fn_ptr(surface.device.?, &heap_props, 0, &res_desc, 4, null, &IID_ID3D12Resource, &resource);
    }
    if (resource == null) return null;
    const tex = std.heap.page_allocator.create(D3D12Texture) catch return null;
    tex.* = .{ .resource = resource };
    return tex;
}

pub fn destroyTexture(surface: *D3D12Surface, texture: ?*D3D12Texture) void {
    if (builtin.os.tag != .windows or texture == null) return;
    _ = surface;
    std.heap.page_allocator.destroy(texture.?);
}
