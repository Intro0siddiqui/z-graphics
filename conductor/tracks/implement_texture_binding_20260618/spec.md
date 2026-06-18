# Track: implement_texture_binding_20260618

## Overview
Implement texture binding support in `z-graphics` to correctly utilize shaders that sample from textures. This is required for the new pipeline layout that includes descriptor sets.

## Requirements
- Add `ZG_BindTexture` FFI export.
- Implement texture descriptor set updates in Vulkan, Metal, and D3D12 backends.
- Ensure texture binding is tracked in the command buffer.
- Fix `smoke_test.zig` crash.
