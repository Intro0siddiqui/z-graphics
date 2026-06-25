# Specification: Advanced Tests for Uniform Buffer Binding, Blending, and Viewport/Scissor

## Overview
This track introduces advanced test coverage for recently implemented Vulkan RHI features. It ensures correctness of dynamic viewport adjustments, scissor clipping, uniform buffer binding with varying offsets, and alpha-blending operations.

## Functional Requirements
1. **Dynamic Viewport & Scissor Verification Test:**
   - Create a test case that renders to an offscreen render target (MRT or stencil/clear-color surface).
   - Set varying viewports (e.g., rendering only to the top-left quadrant) and verify that pixels outside the viewport are unaffected or cleared.
   - Set varying scissor rects (e.g., cutting off half the triangle) and read back the texture to verify that scissor clipping bounds are respected.

2. **Uniform Buffer Binding Offset Verification Test:**
   - Allocate a uniform buffer larger than the minimum alignment (e.g., 1024 bytes).
   - Upload different data vectors at different aligned offsets (e.g., offset 0, offset 256, offset 512).
   - In a test shader or render pass, bind the uniform buffer at these varying offsets and verify (via texture readback or render checks) that the correct parameters are fetched from the buffer.

3. **Alpha Blending Integration Test:**
   - Configure a pipeline with blending enabled (`blend_enable = 1`, source/destination factors set for alpha compositing).
   - Draw a partially transparent quad/triangle over a pre-cleared color.
   - Read back the color buffer and mathematically verify that the blend output matches standard alpha blending: `C_out = C_src * A_src + C_dst * (1 - A_src)`.

## Acceptance Criteria
- Smoke test compiles cleanly.
- Tests automatically assert pixel colors on readback to verify blending math, scissor clipping, and offsetted uniform buffer parameters.
- All test runs execute successfully with zero errors.
