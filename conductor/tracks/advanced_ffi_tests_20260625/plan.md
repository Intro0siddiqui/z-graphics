# Implementation Plan: Advanced FFI Gaps Verification Tests

## Phase 1: Test Framework Setup
- [x] Task: Create Shader and Pipeline Assets for Blending and Offsets
  - [x] Write a fragment shader that utilizes a bound uniform buffer value to determine fragment color.
  - [x] Configure pipelines in `src/smoke_test.zig` with varying blending descriptors and viewports.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Test Framework Setup' (Protocol in workflow.md)

## Phase 2: Implement Test Cases
- [x] Task: Implement `testDynamicViewportAndScissor`
  - [x] Set up a dynamic viewport and scissor test case that asserts clipping bounds via pixel readback.
- [x] Task: Implement `testUniformBufferOffsets`
  - [x] Add offsetted binding verification checks validating `minUniformBufferOffsetAlignment` behavior.
- [x] Task: Implement `testAlphaBlendingCalculations`
  - [x] Render a semi-transparent triangle and assert blending math correctness.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Implement Test Cases' (Protocol in workflow.md)

## Phase 3: Validation & Build Verification
- [x] Task: Execute tests and assert clean pass
  - [x] Run `zig build test` or `zig-out/bin/smoke-test --all` and verify all tests pass.
- [x] Task: Conductor - User Manual Verification 'Phase 3: Validation & Build Verification' (Protocol in workflow.md)
