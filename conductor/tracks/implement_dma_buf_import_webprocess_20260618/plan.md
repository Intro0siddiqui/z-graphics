# Implementation Plan: implement_dma_buf_import_webprocess_20260618

## Phase 1: API Scaffolding
- [ ] Task: Add `ZG_ImportSurfaceFD` and `ZawraGraphics_ImportSurfaceFD` to `lib.zig`
- [ ] Task: Add stub implementation to `linux_vulkan.zig`
- [ ] Task: Conductor - User Manual Verification 'Phase 1' (Protocol in workflow.md)

## Phase 2: Vulkan Implementation
- [ ] Task: Implement `importSurfaceFD` in `linux_vulkan.zig` using `vkImportMemoryFdKHR`
- [ ] Task: Exercise import in a new test case within `smoke_test.zig`
- [ ] Task: Conductor - User Manual Verification 'Phase 2' (Protocol in workflow.md)

## Phase 3: Verification
- [ ] Task: Run CI pipeline and verify across platforms
- [ ] Task: Conductor - User Manual Verification 'Phase 3' (Protocol in workflow.md)
