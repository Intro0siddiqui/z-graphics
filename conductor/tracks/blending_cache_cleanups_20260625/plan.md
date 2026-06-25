# Implementation Plan: Blending and Descriptor Caching Cleanups

## Phase 1: Pipeline Blend Configuration Alignment
- [ ] Task: Update Backend Pipeline Creators to Accept Blending Settings
  - [ ] Update `createPipelineFromShadersPublic` and `createPipelineFromShadersWithLayout` to map blend parameters from `PipelineDesc` to color blending attachment states.
  - [ ] Modify `createStencilPipelineWithState` and `createStencilPipeline` to pass through blend configuration.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Pipeline Blend Configuration Alignment' (Protocol in workflow.md)

## Phase 2: Descriptor Caching Optimization
- [ ] Task: Implement Multi-slot Descriptor Caching in Vulkan Command Buffer
  - [ ] Update `VulkanCommandBuffer` struct in `src/linux_vulkan.zig` to keep track of active bindings for each slot (e.g. tracking `last_bound_buffers[binding_slot]` and `offsets[binding_slot]`).
  - [ ] Modify `cmdBindUniformBuffer` to utilize the multi-slot tracking to bypass `vkUpdateDescriptorSets`.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Descriptor Caching Optimization' (Protocol in workflow.md)

## Phase 3: Verification & Smoke Test Updates
- [ ] Task: Verify Clean Smoke Tests Run
  - [ ] Run `zig build` and execute `smoke-test --all` to verify blending and descriptor caching modifications pass all compositor checks.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Verification & Smoke Test Updates' (Protocol in workflow.md)
