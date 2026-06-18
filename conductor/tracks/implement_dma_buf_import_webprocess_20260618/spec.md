# Track: implement_dma_buf_import_webprocess_20260618

## Overview
Enable the WebProcess to import DMA-BUF file descriptors (FDs) exported by the UIProcess. This is critical for zero-copy compositing, allowing the WebProcess to treat the UIProcess's framebuffers as local Vulkan textures.

## Requirements
- Introduce `ZG_ImportSurfaceFD(int fd)` to the `z-graphics` API.
- Implement the import logic in the Linux/Vulkan backend using `VK_KHR_external_memory_fd`.
- Maintain dual-FFI compatibility (`ZawraGraphics_...` and `ZG_...`).
- Ensure thread-safe texture usage between processes.
