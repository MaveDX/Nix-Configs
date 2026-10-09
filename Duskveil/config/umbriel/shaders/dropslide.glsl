vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Quadratic acceleration downwards
    float drop = 1.0 - visible;
    float p = drop * drop;

    // Clear scale shrink down to 75%
    float scale = mix(1.0, 0.75, p);
    vec2 centered_uv = (uv - vec2(0.5)) / max(0.001, scale) + vec2(0.5);

    // Pronounced downward slide
    float y_offset = p * 0.35;
    vec2 target_uv = centered_uv - vec2(0.0, y_offset);

    // Linear fade-out towards exit
    float alpha = smoothstep(0.0, 0.8, visible);

    return umbriel_sample(target_uv) * alpha;
}