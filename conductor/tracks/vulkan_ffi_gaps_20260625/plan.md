# Implementation Plan: Vulkan FFI Gaps Completion

## Phase 1: API Headers and FFI Declarations
- [x] Task: Extend Public FFI Structs and Functions
    - [x] Update `PipelineDesc` in `src/lib.zig` to include the new blend state fields.
    - [x] Declare new exported FFI functions `ZawraGraphics_CmdSetViewport`, `ZawraGraphics_CmdSetScissor`, and `ZawraGraphics_CmdBindVertexBuffer` in `src/lib.zig`.
    - [x] Bind these functions to their platform-specific backend hooks.

- [x] Task: Conductor - User Manual Verification 'Phase 1: API Headers and FFI Declarations' (Protocol in workflow.md)

## Phase 2: Vulkan Backend Implementations (`linux_vulkan.zig`)
- [x] Task: Update Descriptor Pool Sizing
    - [x] Ensure the descriptor pool creation includes allocations/sizing for `VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER`.
- [x] Task: Update Descriptor Set Layout & Stage Flags
    - [x] Modify `VkDescriptorSetLayoutBinding` list to include Binding 1 (`VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER`).
    - [x] Update stage flags of Binding 0 and Binding 1 to `VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT`.
- [x] Task: Implement Blending State & Variant Pre-creation
    - [x] Map the new `PipelineDesc` blend fields to `VkPipelineColorBlendAttachmentState` during Vulkan pipeline instantiation.
    - [x] Pre-create standard pipeline blend variants (opaque, premultiplied, mask, alpha-multiply) during initialization to support hot switching.
- [x] Task: Implement Dynamic Viewport and Scissor Commands
    - [x] Implement `ZG_CmdSetViewport` / `ZG_CmdSetScissor` using `vkCmdSetViewport` and `vkCmdSetScissor`.
- [x] Task: Implement Uniform Buffer Bind & Descriptor Write Cache
    - [x] Implement uniform buffer alignment checks adhering to `minUniformBufferOffsetAlignment`.
    - [x] Implement the `vkUpdateDescriptorSets` routine inside `ZG_CmdBindUniformBuffer` (or `ZawraGraphics_BindUniformBuffer`).
    - [x] Implement a simple caching mechanism on the command buffer structure (`VulkanCommandBuffer`) to avoid redundant `vkUpdateDescriptorSets` if same buffer + offset is already bound.
- [x] Task: Implement Vertex Buffer Binding hook
    - [x] Implement `ZawraGraphics_CmdBindVertexBuffer` in `linux_vulkan.zig` using `vkCmdBindVertexBuffers`.

- [x] Task: Conductor - User Manual Verification 'Phase 2: Vulkan Backend Implementations' (Protocol in workflow.md)

## Phase 3: Verification & Integration Testing
- [x] Task: Update Smoke Tests
    - [x] Update `src/smoke_test.zig` to verify the new FFI calls:
        - Create a pipeline with blend enable / factors and verify drawing outputs.
        - Dynamically set viewport and scissor in a render loop and verify clipping.
        - Bind uniform buffer with coordinates/opacity, verify shader uses it.
- [x] Task: Execution and Validation
    - [x] Run `zig build` to compile the library and tests.
    - [x] Run the smoke test suite locally and verify all tests pass.

- [x] Task: Conductor - User Manual Verification 'Phase 3: Verification & Integration Testing' (Protocol in workflow.md)
