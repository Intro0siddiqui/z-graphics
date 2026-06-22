#version 450

layout(location = 0) in vec2 inPosition;
layout(location = 1) in vec2 inTexCoord;
layout(location = 2) in vec2 inInstancePos;
layout(location = 3) in vec2 inInstanceScale;

layout(push_constant) uniform PushConstants {
    float x;
    float y;
    float width;
    float height;
    float opacity;
} pc;

layout(location = 0) out vec2 fragTexCoord;

void main() {
    vec2 pos = inPosition * inInstanceScale + inInstancePos;
    pos = pos * vec2(pc.width, pc.height) + vec2(pc.x, pc.y);
    gl_Position = vec4(pos, 0.0, 1.0);
    fragTexCoord = inTexCoord;
}
