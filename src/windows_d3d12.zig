const std = @import("std");
const builtin = @import("builtin");

/// The internal structure representing a D3D12 graphics surface.
pub const D3D12Surface = struct {
    device: ?*anyopaque,
    command_queue: ?*anyopaque,
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
    surface_obj.command_queue = null; // Next steps: Create ID3D12CommandQueue
    surface_obj.width = width;
    surface_obj.height = height;

    return surface_obj;
}

pub fn destroySurface(surface: *D3D12Surface) void {
    if (builtin.os.tag != .windows) return;
    
    // Note: D3D12 uses COM objects which require ->Release()
    // For now, as an FFI stub, we just free our wrapper struct.
    
    std.heap.page_allocator.destroy(surface);
}

pub fn swapBuffers(surface: *D3D12Surface) void {
    if (builtin.os.tag != .windows) return;
    _ = surface;
    // Command Queue execution and IDXGISwapChain::Present would occur here.
}
