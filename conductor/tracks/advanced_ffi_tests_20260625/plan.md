# Implementation Plan: Advanced FFI Gaps Verification Tests

## Phase 1: Test Framework Setup
- [ ] Task: Create Shader and Pipeline Assets for Blending and Offsets
  - [ ] Write a fragment shader that utilizes a bound uniform buffer value to determine fragment color.
  - [ ] Configure pipelines in `src/smoke_test.zig` with varying blending descriptors and viewports.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Test Framework Setup' (Protocol in workflow.md)

## Phase 2: Implement Test Cases
- [ ] Task: Implement `testDynamicViewportAndScissor`
  - [ ] Set up a dynamic viewport and scissor test case that asserts clipping bounds via pixel readback.
- [ ] Task: Implement `testUniformBufferOffsets`
  - [ ] Add offsetted binding verification checks validating `minUniformBufferOffsetAlignment` behavior.
- [ ] Task: Implement `testAlphaBlendingCalculations`
  - [ ] Render a semi-transparent triangle and assert blending math correctness.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Implement Test Cases' (Protocol in workflow.md)

## Phase 3: Validation & Build Verification
- [ ] Task: Execute tests and assert clean pass
  - [ ] Run `zig build test` or `zig-out/bin/smoke-test --all` and verify all tests pass.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Validation & Build Verification' (Protocol in workflow.md)
