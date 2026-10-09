vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Smooth cubic easing for an organic pop
    float p = smoothstep(0.0, 1.0, visible);

    // Expand scale uniformly from the center (0.5, 0.5)
    // Clamped at 0.001 to prevent division-by-zero artifacts
    float scale = max(0.001, p);
    vec2 target_uv = (uv - vec2(0.5)) / scale + vec2(0.5);

    // Fade opacity alongside the scale expansion
    return umbriel_sample(target_uv) * p;
}