# Specification: Pipeline Blending Cleanups and Descriptor Cache Improvements

## Overview
This track resolves partially implemented and missing pipeline blending features as well as descriptor set binding inefficiencies in the Vulkan RHI backend. It ensures all pipeline instantiation routines respect dynamic blend state parameters and implements robust caching for uniform buffer descriptors.

## Functional Requirements
1. **Dynamic Blending across all Pipeline Creator APIs:**
   - Modify Vulkan pipeline creation helper routines in `src/linux_vulkan.zig`:
     - `createPipelineFromShadersPublic`
     - `createPipelineFromShadersWithLayout`
     - `createStencilPipelineWithState`
     - `createStencilPipeline`
   - All these helper routines must accept a `PipelineDesc` containing the requested blend configuration (enable toggles and blending factors) rather than hardcoding `blendEnable = 0`.

2. **Vulkan Descriptor Set Caching:**
   - Enhance the command buffer descriptor binding logic (`cmdBindUniformBuffer`) in `src/linux_vulkan.zig` to check and cache bindings across multiple slots.
   - Avoid redundant calls to `vkUpdateDescriptorSets` when the same buffer structure, offset, and range are bound repeatedly to the same descriptor set layout binding slot.

## Acceptance Criteria
- Smoke test compiles cleanly.
- The pipeline creators correctly map color blending parameters to the pipeline configuration.
- The command buffer executes successfully with zero regressions.
