const std = @import("std");
const builtin = @import("builtin");

/// The internal structure representing a D3D12 graphics surface.
pub const D3D12Surface = struct {
    device: ?*anyopaque,
    command_queue: ?*anyopaque,
    resource: ?*anyopaque, // ID3D12Resource used as the offscreen render target
    allocation: ?*anyopaque, // D3D12MA Allocation (if using an allocator) or heap pointer
    width: u32,
    height: u32,
};

// Minimal COM/D3D12 types for FFI without requiring the massive Windows SDK headers
const HRESULT = i32;
const D3D_FEATURE_LEVEL = i32;
const D3D_FEATURE_LEVEL_11_0: D3D_FEATURE_LEVEL = 0xb000;

const GUID = extern struct {
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
};

// IID_ID3D12Device: {189819f1-1db6-4b08-8e95-9513a4ac6924}
const IID_ID3D12Device = GUID{
    .Data1 = 0x189819f1,
    .Data2 = 0x1db6,
    .Data3 = 0x4b08,
    .Data4 = .{ 0x8e, 0x95, 0x95, 0x13, 0xa4, 0xac, 0x69, 0x24 },
};

extern "d3d12" fn D3D12CreateDevice(
    pAdapter: ?*anyopaque,
    MinimumFeatureLevel: D3D_FEATURE_LEVEL,
    riid: *const GUID,
    ppDevice: ?*?*anyopaque,
) callconv(.c) HRESULT;

pub fn createSurface(width: u32, height: u32) ?*D3D12Surface {
    if (builtin.os.tag != .windows) return null;

    // 1. Create the D3D12 Device (using the default adapter)
    var device: ?*anyopaque = null;
    const hr = D3D12CreateDevice(null, D3D_FEATURE_LEVEL_11_0, &IID_ID3D12Device, &device);
    
    // HRESULT is negative on failure
    if (hr < 0) return null;

    // 2. Allocate the surface state
    var surface_obj = std.heap.page_allocator.create(D3D12Surface) catch return null;
    surface_obj.device = device;
    
    // Next Steps:
    // 3. Create ID3D12CommandQueue (device->CreateCommandQueue)
    surface_obj.command_queue = null; 
    
    // 4. Create Offscreen Image Buffer (ID3D12Resource)
    // Next: Create D3D12_HEAP_PROPERTIES (type = DEFAULT)
    // Next: Create D3D12_RESOURCE_DESC (format = DXGI_FORMAT_R8G8B8A8_UNORM, flags = ALLOW_RENDER_TARGET)
    // Next: device->CreateCommittedResource(...)
    surface_obj.resource = null; 
    surface_obj.allocation = null;
    
    surface_obj.width = width;
    surface_obj.height = height;

    return surface_obj;
}

pub fn destroySurface(surface: *D3D12Surface) void {
    if (builtin.os.tag != .windows) return;
    
    // Note: D3D12 uses COM objects which require ->Release()
    // For now, as an FFI stub, we just free our wrapper struct.
    // Cleanup of surface.resource, surface.command_queue, surface.device would happen here.
    
    std.heap.page_allocator.destroy(surface);
}

pub fn swapBuffers(surface: *D3D12Surface) void {
    if (builtin.os.tag != .windows) return;
    _ = surface;
    // Command Queue execution would occur here.
    // ID3D12CommandQueue::ExecuteCommandLists(...)
    // ID3D12Fence::SetEventOnCompletion(...) // For headless sync
}

pub fn exportSurfaceFD(surface: *D3D12Surface) i32 {
    if (builtin.os.tag != .windows) return -1;
    _ = surface;
    // For Windows, we'd export a HANDLE (which is void*).
    // The i32 return type might need to be cast or we return an index.
    return -1; // Stub
}

// ---------------------------------------------------------
// RESOURCE MANAGEMENT
// ---------------------------------------------------------

pub const D3D12Buffer = struct {
    resource: ?*anyopaque, // ID3D12Resource
    size: usize,
};

pub fn createBuffer(surface: *D3D12Surface, size: usize, buffer_type: u32) ?*D3D12Buffer {
    if (builtin.os.tag != .windows) return null;
    _ = surface;
    _ = size;
    _ = buffer_type;
    return null;
}

pub fn destroyBuffer(surface: *D3D12Surface, buffer: *D3D12Buffer) void {
    if (builtin.os.tag != .windows) return;
    _ = surface;
    _ = buffer;
}

// ---------------------------------------------------------
// COMMAND RECORDING
// ---------------------------------------------------------

pub const D3D12CommandBuffer = struct {
    cmd_list: ?*anyopaque, // ID3D12GraphicsCommandList
    allocator: ?*anyopaque, // ID3D12CommandAllocator
};

pub fn beginCommandBuffer(surface: *D3D12Surface) ?*D3D12CommandBuffer {
    if (builtin.os.tag != .windows) return null;
    _ = surface;
    return null;
}

pub fn cmdClearColor(cmd: *D3D12CommandBuffer, r: f32, g: f32, b: f32, a: f32) void {
    if (builtin.os.tag != .windows) return;
    _ = cmd;
    _ = r; _ = g; _ = b; _ = a;
}

pub fn submitCommandBuffer(surface: *D3D12Surface, cmd: *D3D12CommandBuffer) void {
    if (builtin.os.tag != .windows) return;
    _ = surface;
    _ = cmd;
}

// ---------------------------------------------------------
// PIPELINE MANAGEMENT
// ---------------------------------------------------------

pub const D3D12Pipeline = struct {
    pipeline_state: ?*anyopaque, // ID3D12PipelineState
    root_signature: ?*anyopaque, // ID3D12RootSignature
};

pub fn createPipeline(surface: *D3D12Surface, desc: *const @import("lib.zig").PipelineDesc) ?*D3D12Pipeline {
    if (builtin.os.tag != .windows) return null;
    _ = surface;
    _ = desc;
    return null;
}

pub fn destroyPipeline(surface: *D3D12Surface, pipeline: ?*D3D12Pipeline) void {
    if (builtin.os.tag != .windows or pipeline == null) return;
    _ = surface;
    std.heap.page_allocator.destroy(pipeline.?);
}

pub fn cmdBindPipeline(cmd: *D3D12CommandBuffer, pipeline: *D3D12Pipeline) void {
    if (builtin.os.tag != .windows) return;
    _ = cmd;
    _ = pipeline;
}
