vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Quadratic acceleration curve for gravity feel
    float drop = 1.0 - visible;
    float gravity = drop * drop;

    // A factor of ~3.0 ensures even small/centered windows fully clear 
    // the bottom edge of typical aspect ratios before finishing
    float y_offset = gravity * 3.0;

    vec2 target_uv = uv - vec2(0.0, y_offset);

    return umbriel_sample(target_uv);
}
