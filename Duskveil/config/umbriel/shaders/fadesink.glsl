vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Quadratic ease-in for a natural departure
    float p = visible * visible;

    // Subtle scale contraction down to 96%
    float scale = mix(0.96, 1.0, p);
    vec2 centered_uv = (uv - vec2(0.5)) / scale + vec2(0.5);

    // Minor downward drift as it recedes
    float y_offset = (1.0 - p) * 0.03;
    vec2 target_uv = centered_uv - vec2(0.0, y_offset);

    // Smooth opacity drop-off
    float alpha = smoothstep(0.1, 1.0, visible);

    return umbriel_sample(target_uv) * alpha;
}