# Zawra Graphics Abstraction (z-graphics) Design

## Overview
`z-graphics` provides a platform-agnostic Render Hardware Interface (RHI) for the Zawra browser. It abstracts platform-specific windowing and surface initialization to allow WebKit to render without hardcoded dependencies on Wayland, GBM, or Win32.

## Architectural Approach
We use a **Custom RHI** implemented in Zig, leveraging `comptime` to ensure zero-overhead, platform-specific backends.

### Backend Strategy
- **Linux/Android**: Native **Vulkan** (`VK_KHR_surface`).
- **Windows**: Native **DirectX 12 (D3D12)**.
- **macOS/iOS**: Native **Metal**.

### Shader Pipeline
- **Source**: All shaders authored in **HLSL**.
- **Compilation**: Compiled via **DirectXShaderCompiler (DXC)**.
  - Linux/Windows: Direct SPIR-V output.
  - macOS: SPIR-V -> **SPIRV-Cross** -> **MSL (Metal Shading Language)**.

## Implementation Roadmap
- **Linux**: Vulkan (Primary target, high priority).
- **Windows**: Vulkan (Short-term), D3D12 (Long-term).
- **macOS**: Metal.
