# z-graphics Implementation TODO

- [x] Initialize project structure and CI
- [x] Functional smoke test for FFI
- [x] Implement `z_graphics_create_surface`
    - [x] Define platform-agnostic surface struct
    - [x] Linux (Vulkan) implementation
        - [x] Structure definition
        - [x] Backend implementation (Offscreen buffers complete)
    - [x] Windows (D3D12/Vulkan) implementation
        - [x] Scaffolding/FFI Stubs
    - [x] macOS (Metal) implementation
        - [x] Scaffolding/FFI Stubs
- [x] Implement `z_graphics_swap_buffers`
- [x] Implement Basic Drawing API & Resource Buffers
- [ ] Integrate with WebKit compositor
