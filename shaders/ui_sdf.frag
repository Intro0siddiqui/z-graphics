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
    float radius = fragParams.x;
    float border_width = fragParams.y;
    float mode = fragParams.z;
    float extra = fragParams.w;

    if (mode > 0.5 && mode < 1.5) {
        // Mode 1: Font Glyph (Sharp Anti-Aliased Alpha Mask)
        vec4 texSample = texture(mainTexture, fragTexCoord);
        float glyphAlpha = max(texSample.r, texSample.a);
        float sharpAlpha = smoothstep(0.35, 0.65, glyphAlpha);
        outColor = vec4(fragColor.rgb, fragColor.a * sharpAlpha);
    } else if (mode > 1.5 && mode < 2.5) {
        // Mode 2: Textured Quad (e.g. circuit background, icons, hero emblem, WPE viewport)
        vec4 texSample = texture(mainTexture, fragTexCoord);
        if (extra > 0.5) {
            texSample.a = 1.0;
        }
        if (radius > 0.0) {
            float max_r = min(fragHalfSize.x, fragHalfSize.y);
            float r = clamp(radius, 0.0, max_r);
            float dist = sdRoundedBox(fragLocalPos, fragHalfSize, r);
            float aa = fwidth(dist);
            if (aa < 0.0001) aa = 0.7;
            float alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist);
            texSample.a *= alpha;
        }
        outColor = texSample * fragColor;
    } else if (mode > 2.5 && mode < 3.5) {
        // Mode 3: Soft Glowing Halo / Outer Drop Shadow (Active Tab Halo, Amber Glow, Drop Shadows)
        float glow_spread = extra > 0.0 ? extra : 8.0;
        vec2 inner_half_size = max(fragHalfSize - vec2(glow_spread), vec2(1.0));
        float max_r = min(inner_half_size.x, inner_half_size.y);
        float r = clamp(radius, 0.0, max_r);

        float dist = sdRoundedBox(fragLocalPos, inner_half_size, r);

        float aa = fwidth(dist);
        if (aa < 0.0001) aa = 0.7;

        // Inside fill
        float fill_mask = 1.0 - smoothstep(-border_width - aa * 0.5, -border_width + aa * 0.5, dist);
        // Border outline
        float box_mask = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist);
        float border_mask = clamp(box_mask - fill_mask, 0.0, 1.0);
        // Outer halo glow
        float glow_factor = clamp(1.0 - (dist / max(glow_spread, 0.001)), 0.0, 1.0);
        float halo_mask = (1.0 - box_mask) * pow(glow_factor, 1.4);

        float total_a = clamp(fill_mask * fragColor.a + border_mask * fragBorderColor.a + halo_mask * fragBorderColor.a * 0.85, 0.0, 1.0);
        vec3 rgb = fragColor.rgb * fill_mask * fragColor.a +
                   fragBorderColor.rgb * border_mask * fragBorderColor.a +
                   fragBorderColor.rgb * halo_mask * (fragBorderColor.a * 0.85);
        if (total_a > 0.001) rgb /= total_a;
        outColor = vec4(rgb, total_a);
    } else if (mode > 3.5 && mode < 4.5) {
        // Mode 4: Neumorphic Glassmorphic Card (Dual-Tone Rim Lighting & Frosted Glass Fill)
        float max_r = min(fragHalfSize.x, fragHalfSize.y);
        float r = clamp(radius, 0.0, max_r);

        float dist = sdRoundedBox(fragLocalPos, fragHalfSize, r);

        float aa = fwidth(dist);
        if (aa < 0.0001) aa = 0.7;

        // Direction from center for directional rim lighting
        vec2 normPos = fragLocalPos / max(fragHalfSize, vec2(1.0));
        vec2 dir = normalize(normPos);
        vec2 lightDir = normalize(vec2(-1.0, -1.0)); // Top-left illumination
        float rimCos = dot(dir, lightDir);

        // Specular highlight on top-left, shadow on bottom-right
        vec4 highlightRim = vec4(1.0, 1.0, 1.0, clamp(fragBorderColor.a * 2.0, 0.0, 1.0));
        vec4 shadowRim = vec4(0.0, 0.0, 0.0, clamp(fragBorderColor.a * 1.5, 0.0, 1.0));

        vec4 activeRimColor = fragBorderColor;
        if (rimCos > 0.0) {
            activeRimColor = mix(fragBorderColor, highlightRim, rimCos * 0.8);
        } else {
            activeRimColor = mix(fragBorderColor, shadowRim, -rimCos * 0.6);
        }

        // Frosted glass gradient across Y
        float glassGrad = 0.5 - 0.5 * normPos.y; // 1.0 at top, 0.0 at bottom
        vec3 glassRgb = fragColor.rgb + vec3(glassGrad * 0.04);

        if (border_width > 0.0) {
            float fill_alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist + border_width);
            float outer_alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist);
            float border_alpha = clamp(outer_alpha - fill_alpha, 0.0, 1.0);

            float total_a = clamp(fill_alpha * fragColor.a + border_alpha * activeRimColor.a, 0.0, 1.0);
            vec3 rgb = glassRgb * fill_alpha * fragColor.a + activeRimColor.rgb * border_alpha * activeRimColor.a;
            if (total_a > 0.001) rgb /= total_a;
            outColor = vec4(rgb, total_a);
        } else {
            float alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist);
            outColor = vec4(glassRgb, fragColor.a * alpha);
        }
    } else {
        // Mode 0: Standard 2D Signed Distance Field (SDF) Shape
        float max_r = min(fragHalfSize.x, fragHalfSize.y);
        float r = clamp(radius, 0.0, max_r);

        float dist = sdRoundedBox(fragLocalPos, fragHalfSize, r);

        float aa = fwidth(dist);
        if (aa < 0.0001) aa = 0.7;

        if (border_width > 0.0) {
            float fill_alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist + border_width);
            float outer_alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist);
            float border_alpha = clamp(outer_alpha - fill_alpha, 0.0, 1.0);

            float total_a = clamp(fill_alpha * fragColor.a + border_alpha * fragBorderColor.a, 0.0, 1.0);
            vec3 rgb = fragColor.rgb * fill_alpha * fragColor.a + fragBorderColor.rgb * border_alpha * fragBorderColor.a;
            if (total_a > 0.001) rgb /= total_a;
            outColor = vec4(rgb, total_a);
        } else {
            float alpha = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, dist);
            outColor = vec4(fragColor.rgb, fragColor.a * alpha);
        }
    }
}
