#version 450

layout(location = 0) in vec2 inPosition;      // Screen pixel position (x, y)
layout(location = 1) in vec2 inTexCoord;      // Texture coordinates (u, v) [0..1]
layout(location = 2) in vec2 inLocalPos;      // Local pixel coordinates centered at (0, 0)
layout(location = 3) in vec2 inHalfSize;      // Half-dimensions of the quad: (width / 2.0, height / 2.0)
layout(location = 4) in vec4 inColor;         // Fill RGBA color
layout(location = 5) in vec4 inBorderColor;   // Border RGBA color
layout(location = 6) in vec4 inParams;        // x: corner_radius, y: border_width, z: mode (0=SDF shape, 1=font glyph/mask, 2=textured quad), w: unused

layout(push_constant) uniform PushConstants {
    float screen_width;
    float screen_height;
    float unused1;
    float unused2;
    float opacity;
} pc;

layout(location = 0) out vec2 fragTexCoord;
layout(location = 1) out vec2 fragLocalPos;
layout(location = 2) out vec2 fragHalfSize;
layout(location = 3) out vec4 fragColor;
layout(location = 4) out vec4 fragBorderColor;
layout(location = 5) out vec4 fragParams;

void main() {
    float sw = pc.screen_width > 0.0 ? pc.screen_width : 1280.0;
    float sh = pc.screen_height > 0.0 ? pc.screen_height : 800.0;

    // Map screen pixel coordinates [0..sw] x [0..sh] to Vulkan NDC [-1..1]
    vec2 ndc = (inPosition / vec2(sw, sh)) * 2.0 - 1.0;
    gl_Position = vec4(ndc, 0.0, 1.0);

    fragTexCoord = inTexCoord;
    fragLocalPos = inLocalPos;
    fragHalfSize = inHalfSize;
    fragColor = inColor;
    fragBorderColor = inBorderColor;
    fragParams = inParams;
}
