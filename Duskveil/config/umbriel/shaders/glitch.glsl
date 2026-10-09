float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0 
        ? umbriel_clamped_progress 
        : 1.0 - umbriel_clamped_progress;

    float glitch_factor = 1.0 - smoothstep(0.0, 1.0, visible);

    // Slice UV vertically into horizontal bands
    float slice_count = 35.0;
    float slice_id = floor(uv.y * slice_count);
    float noise = hash(vec2(slice_id, floor(umbriel_linear_progress * 15.0)));

    // Apply random horizontal jitter to slices
    float jitter = (noise - 0.5) * glitch_factor * 0.4;
    vec2 sample_uv = vec2(uv.x + jitter, uv.y);

    // Channel chromatic aberration
    float split = glitch_factor * 0.04 * (noise - 0.5);
    float r = umbriel_sample(sample_uv + vec2(split, 0.0)).r;
    float g = umbriel_sample(sample_uv).g;
    float b = umbriel_sample(sample_uv - vec2(split, 0.0)).b;
    float a = umbriel_sample(sample_uv).a;

    return vec4(r, g, b, a) * visible;
}