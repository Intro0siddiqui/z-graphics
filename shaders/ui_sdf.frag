#version 450

layout(location = 0) in vec2 fragTexCoord;
layout(location = 1) in vec2 fragLocalPos;
layout(location = 2) in vec2 fragHalfSize;
layout(location = 3) in vec4 fragColor;
layout(location = 4) in vec4 fragBorderColor;
layout(location = 5) in vec4 fragParams;

layout(location = 0) out vec4 outColor;

layout(binding = 0) uniform sampler2D mainTexture;

// Inigo Quilez standard 2D rounded box SDF
float sdRoundedBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
    float mode = fragParams.z;
    float radius = fragParams.x;
    float border_width = fragParams.y;

    if (mode > 0.5 && mode < 1.5) {
        // Mode 1: Font Glyph (Alpha Mask from R8 or RGBA)
        vec4 texSample = texture(mainTexture, fragTexCoord);
        float glyphAlpha = max(texSample.r, texSample.a);
        outColor = vec4(fragColor.rgb, fragColor.a * glyphAlpha);
    } else if (mode > 1.5) {
        // Mode 2: Textured Quad (e.g. WPE DMA-BUF WebKit viewport, icons)
        vec4 texSample = texture(mainTexture, fragTexCoord);
        outColor = texSample * fragColor;
    } else {
        // Mode 0: Signed Distance Field (SDF) 2D Shape (Rounded Rect, Circle, Pill)
        float max_r = min(fragHalfSize.x, fragHalfSize.y);
        float r = clamp(radius, 0.0, max_r);

        float dist = sdRoundedBox(fragLocalPos, fragHalfSize, r);

        // Smooth antialiasing using derivative
        float aa = fwidth(dist);
        if (aa < 0.0001) aa = 0.7;

        if (border_width > 0.0) {
            // Inner fill alpha
            float fill_alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist + border_width);
            // Outer shape alpha
            float outer_alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist);
            float border_alpha = clamp(outer_alpha - fill_alpha, 0.0, 1.0);

            vec3 rgb = fragColor.rgb * fill_alpha * fragColor.a + fragBorderColor.rgb * border_alpha * fragBorderColor.a;
            float total_a = clamp(fill_alpha * fragColor.a + border_alpha * fragBorderColor.a, 0.0, 1.0);
            outColor = vec4(rgb, total_a);
        } else {
            // Pure fill
            float alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist);
            outColor = vec4(fragColor.rgb, fragColor.a * alpha);
        }
    }
}
