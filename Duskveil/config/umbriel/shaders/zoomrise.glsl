vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Cubic ease-out curve
    float p = 1.0 - pow(1.0 - visible, 3.0);

    // Subtle scale expansion (starts at 94% size)
    float scale = mix(0.94, 1.0, p);
    vec2 centered_uv = (uv - vec2(0.5)) / scale + vec2(0.5);

    // Minor upward settling float
    float y_offset = (1.0 - p) * 0.04;
    vec2 target_uv = centered_uv + vec2(0.0, y_offset);

    // Opacity fades in faster than the motion completes
    float alpha = smoothstep(0.0, 0.85, visible);

    return umbriel_sample(target_uv) * alpha;
}