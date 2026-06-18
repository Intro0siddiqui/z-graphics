# Track: implement_native_swapchain_20260618

## Overview
Refactor `z-graphics` to own the swapchain and presentation layer across all backends (Vulkan, Metal, D3D12), enabling native windowed presentation while maintaining existing DMA-BUF FD export as a legacy fallback.

## Requirements
- Add `ZG_CreateSwapchain` / `ZG_Present` FFI exports.
- Implement native swapchain creation in macOS (Metal) and Windows (D3D12) backends.
- Maintain dual-FFI compatibility (`ZawraGraphics_...` and `ZG_...`).
- Synchronize presentation using OS-native primitives (`MTLDrawable`, `IDXGISwapChain1`).
