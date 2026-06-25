# Initial Concept
Provide high-performance cross-platform rendering capabilities.

# Product Definition: Z-Graphics RHI

## Vision
Z-Graphics (z-graphics) is a high-performance, low-latency, cross-platform Render Hardware Interface (RHI). It abstracts Vulkan (Linux), Metal (macOS), and Direct3D 12 (Windows) behind a unified C-compatible FFI. The goal is to enable zero-copy compositing and ultra-low-latency web page rendering.

## Naming Conventions
- Prefer the short prefix `ZG_` or `ZG` for functions, types, and files where possible.
- E.g., Use `ZG_` in place of longer prefixes like `ZawraGraphics_`.

## High-Level Capabilities & Requirements
- Unified C FFI for cross-platform drawing pipelines.
- Multi-backend rendering support (Vulkan, Metal, D3D12).
- Zero-copy resource sharing: YUV/YCbCr formats, IOSurface (macOS), DMA-BUF (Linux).
- Low-overhead drawing APIs supporting blending, custom pipelines, stencil-based clipping/masking, and multiple render targets (MRT).
- Dynamic Viewport and Scissor adjustments at runtime.
- Uniform Buffer Binding with dynamic state descriptor set updates and caching.

## Key Development Gaps to Address
### Additional Gaps:
1. **Offscreen Render Targets:** Enable rendering to texture with sampled bit for MRT surfaces.
2. **Shader Compilation:** Pre-compile or support dynamic shader variants/modules.
3. **Sampler Configurations:** Support custom sampler parameters like clamping and filtering.
