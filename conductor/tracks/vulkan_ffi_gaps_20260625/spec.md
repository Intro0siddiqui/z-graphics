# Specification: Vulkan FFI Gaps Completion (Uniforms, Blending, Scissor/Viewport)

## Overview
This track addresses key feature gaps in the Linux Vulkan backend to support uniform buffers, blend states, dynamic scissor/viewport adjustments, and basic vertex buffer bindings. These additions are critical for running advanced compositing shaders.

## Functional Requirements
1. **Uniform Buffer Binding & Stage Coverage:**
   - Update Vulkan descriptor set layout stages:
     - **Binding 0:** `VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER` — Stage flag: `VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT`
     - **Binding 1:** `VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER` — Stage flag: `VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT`
   - Implement `ZG_CmdBindUniformBuffer(cmd, buffer, binding, offset)` (mapping to `ZawraGraphics_BindUniformBuffer`) to bind uniform buffers at runtime.
   - **Optimization:** Add a simple descriptor set cache / validation check: skip calling `vkUpdateDescriptorSets` if the bound uniform buffer and offset match the previously bound state on the command buffer.

2. **Blend State Configuration:**
   - Extend `ZG_PipelineDesc` (representing the public pipeline descriptor) to include blending parameters:
     - `blend_enable: u32` (1 for enabled, 0 for disabled)
     - `src_color_blend_factor: u32`
     - `dst_color_blend_factor: u32`
     - `color_blend_op: u32`
     - `src_alpha_blend_factor: u32`
     - `dst_alpha_blend_factor: u32`
     - `alpha_blend_op: u32`
   - Update Vulkan pipeline creation to apply these blend state parameters to the color blend attachment state (`VkPipelineColorBlendAttachmentState`).

3. **Dynamic Viewport and Scissor FFI:**
   - Export C FFI functions:
     - `ZG_CmdSetViewport(cmd: ZG_CommandBuffer, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void`
     - `ZG_CmdSetScissor(cmd: ZG_CommandBuffer, x: i32, y: i32, width: u32, height: u32) void`
   - Implement these in `linux_vulkan.zig` using `vkCmdSetViewport` and `vkCmdSetScissor`.

4. **Vertex Buffer Binding (Support for Indexed/Multi-Vertex Drawing):**
   - Export and verify FFI signature for `ZG_CmdBindVertexBuffer` (mapping to `ZawraGraphics_CmdBindVertexBuffer`).

## Acceptance Criteria
- Smoke test compiles and runs without issues.
- All Vulkan pipelines can be created with custom blending states.
- Uniform buffer binding successfully passes matrices or parameters to shaders.
- Scissor clipping and viewport adjustments successfully restrict/transform rendering output.
