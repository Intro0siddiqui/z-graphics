#version 450

layout(location = 0) in vec2 in_texcoord;
layout(location = 0) out vec4 fragColor;

layout(binding = 0) uniform sampler2D mainSampler;
layout(binding = 1) uniform UniformBuffer {
    vec4 color_multiplier;
} ubo;

void main() {
    fragColor = texture(mainSampler, in_texcoord) * ubo.color_multiplier;
}
