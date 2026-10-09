vec4 animation(vec2 uv) {
    // When closing, visible runs from 1.0 down to 0.0
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;[cite: 3]

    // Ease-in curve so the collapse accelerates as it closes
    float scale_x = pow(visible, 2.0);

    // Prevent division by zero at the final close frame
    if (scale_x <= 0.001) {
        return vec4(0.0);
    }

    // Anchoring at the left edge (x = 0.0) means sampling UVs are stretched across the scaled width
    vec2 target_uv = vec2(uv.x / scale_x, uv.y);

    // Discard any fragments beyond the right edge of the collapsing window
    if (target_uv.x < 0.0 || target_uv.x > 1.0 || target_uv.y < 0.0 || target_uv.y > 1.0) {
        return vec4(0.0);[cite: 3]
    }

    return umbriel_sample(target_uv);[cite: 3]
}
