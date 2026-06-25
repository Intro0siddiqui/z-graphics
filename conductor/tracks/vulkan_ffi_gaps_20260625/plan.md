# Implementation Plan: Vulkan FFI Gaps Completion

## Phase 1: API Headers and FFI Declarations
- [ ] Task: Extend Public FFI Structs and Functions
    - [ ] Update `PipelineDesc` in `src/lib.zig` to include the new blend state fields.
    - [ ] Declare new exported FFI functions `ZawraGraphics_CmdSetViewport`, `ZawraGraphics_CmdSetScissor`, and `ZawraGraphics_CmdBindVertexBuffer` in `src/lib.zig`.
    - [ ] Bind these functions to their platform-specific backend hooks.

- [ ] Task: Conductor - User Manual Verification 'Phase 1: API Headers and FFI Declarations' (Protocol in workflow.md)

## Phase 2: Vulkan Backend Implementations (`linux_vulkan.zig`)
- [ ] Task: Update Descriptor Pool Sizing
    - [ ] Ensure the descriptor pool creation includes allocations/sizing for `VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER`.
- [ ] Task: Update Descriptor Set Layout & Stage Flags
    - [ ] Modify `VkDescriptorSetLayoutBinding` list to include Binding 1 (`VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER`).
    - [ ] Update stage flags of Binding 0 and Binding 1 to `VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT`.
- [ ] Task: Implement Blending State & Variant Pre-creation
    - [ ] Map the new `PipelineDesc` blend fields to `VkPipelineColorBlendAttachmentState` during Vulkan pipeline instantiation.
    - [ ] Pre-create standard pipeline blend variants (opaque, premultiplied, mask, alpha-multiply) during initialization to support hot switching.
- [ ] Task: Implement Dynamic Viewport and Scissor Commands
    - [ ] Implement `ZG_CmdSetViewport` / `ZG_CmdSetScissor` using `vkCmdSetViewport` and `vkCmdSetScissor`.
- [ ] Task: Implement Uniform Buffer Bind & Descriptor Write Cache
    - [ ] Implement uniform buffer alignment checks adhering to `minUniformBufferOffsetAlignment`.
    - [ ] Implement the `vkUpdateDescriptorSets` routine inside `ZG_CmdBindUniformBuffer` (or `ZawraGraphics_BindUniformBuffer`).
    - [ ] Implement a simple caching mechanism on the command buffer structure (`VulkanCommandBuffer`) to avoid redundant `vkUpdateDescriptorSets` if same buffer + offset is already bound.
- [ ] Task: Implement Vertex Buffer Binding hook
    - [ ] Implement `ZawraGraphics_CmdBindVertexBuffer` in `linux_vulkan.zig` using `vkCmdBindVertexBuffers`.

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Vulkan Backend Implementations' (Protocol in workflow.md)

## Phase 3: Verification & Integration Testing
- [ ] Task: Update Smoke Tests
    - [ ] Update `src/smoke_test.zig` to verify the new FFI calls:
        - Create a pipeline with blend enable / factors and verify drawing outputs.
        - Dynamically set viewport and scissor in a render loop and verify clipping.
        - Bind uniform buffer with coordinates/opacity, verify shader uses it.
- [ ] Task: Execution and Validation
    - [ ] Run `zig build` to compile the library and tests.
    - [ ] Run the smoke test suite locally and verify all tests pass.

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Verification & Integration Testing' (Protocol in workflow.md)
