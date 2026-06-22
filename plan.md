# Z-Graphics — Implementation Plan & Roadmap

This document outlines the RHI implementation status and roadmap.

## 1. Linux (Vulkan Backend)
**Status:** 100% COMPLETE. 

All core RHI features (P0, P1, P2, and P3) are fully implemented, verified, and passing tests:
- **P0**: DMA-BUF Import, GPU-to-CPU Readback.
- **P1**: Multi-Layer Compositing (push constants), YUV Format Support (sampler conversion), Dynamic Shader Management, Uniform Buffers.
- **P2**: Command Buffer/Descriptor Reuse, Swapchain Recreation on Resize, V-Sync Control, MSAA, Instanced Rendering, Compute Shaders.
- **P3**: Multiple Render Targets (MRT), Stencil Buffer, Timer Queries.

---

## 2. Future Work: macOS (Metal Backend)
**Status:** STUBBED. The following stubs in `src/macos_metal.zig` need to be completed:
- **DMA-BUF Import Equivalent**: Implement IOSurface-based texture sharing.
- **Compute Shaders**: Implement Metal compute pipeline creation and storage buffers.
- **Advanced Rendering**: Implement multi-layer compositing, instanced rendering, MRT, stencil passes, and timer queries.

---

## 3. Future Work: Windows (D3D12 Backend)
**Status:** STUBBED. The following stubs in `src/windows_d3d12.zig` need to be completed:
- **DMA-BUF Import Equivalent**: Implement DXGI shared handle import.
- **Compute Shaders**: Implement D3D12 compute pipelines and storage buffers.
- **Advanced Rendering**: Implement multi-layer compositing, instanced rendering, MRT, stencil states, and query heaps (timer queries).
