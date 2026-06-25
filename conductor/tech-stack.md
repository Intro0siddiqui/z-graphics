# Technology Stack: Z-Graphics RHI

## Core Language & Build Tools
- **Language:** Zig (version 0.16.0)
- **Build System:** `zig build` (integrated build manifest in `build.zig`)

## Shading Language
- **Source Language:** Slang (unified cross-platform shader language)
- **Compiler:** `slangc` compiler (offline compilation to target binaries)
- **Target Shader Formats:**
  - **Linux (Vulkan):** SPIR-V bytecode
  - **macOS (Metal):** Metal Shading Language (MSL) source strings
  - **Windows (D3D12):** DXIL (DirectX Intermediate Language) bytecode

## Platform Graphics Backends
- **Linux:** Vulkan API (via `X11` and `VK_KHR_surface`)
- **macOS:** Metal API (via `Cocoa`, `AppKit`, `CAMetalLayer` Objective-C Runtime FFI)
- **Windows:** Direct3D 12 (via `DXGI` and native D3D12 runtime libraries)
