vec4 animation(vec2 uv) {
    vec4 base = umbriel_sample(uv);[cite: 1]

    // Width of the glow band in normalized UV space
    // (Increase to 0.06 or 0.08 if borders still appear too thin)
    float edge_w = 0.04;

    // Direct edge distance calculation across all 4 boundaries
    float left   = uv.x;
    float right  = 1.0 - uv.x;
    float top    = uv.y;
    float bottom = 1.0 - uv.y;

    float min_dist = min(min(left, right), min(top, bottom));

    // Glow profile: 1.0 at edge down to 0.0 at edge_w
    float edge_factor = clamp(1.0 - (min_dist / edge_w), 0.0, 1.0);
    float glow_core   = pow(edge_factor, 1.8);

    // Wave position tracking along the edge perimeter
    vec2 centered = uv - vec2(0.5);
    float angle = atan(centered.y, centered.x);

    // Drives wave movement along progress during opening/closing
    float phase = (umbriel_clamped_progress * 12.56637) + (umbriel_random_seed.x * 6.28318);[cite: 1]
    float wave = 0.5 + 0.5 * sin(angle * 4.0 - phase);

    // Strong purple color palette
    vec3 deep_purple = vec3(0.58, 0.00, 1.00);
    vec3 neon_violet = vec3(0.95, 0.35, 1.00);
    vec3 purple_col  = mix(deep_purple, neon_violet, wave);

    // Combined glow intensity
    float glow_strength = glow_core * (2.0 + 1.5 * wave);

    // Blend onto base color and ensure the alpha is raised so it renders over dark/clear edges
    vec3 final_rgb = base.rgb + purple_col * glow_strength;
    float final_a  = max(base.a, glow_core);

    return vec4(final_rgb, final_a);
}
