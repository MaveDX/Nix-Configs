vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Deceleration curve (settles smoothly as it reaches resting position)
    float p = 1.0 - pow(1.0 - visible, 2.0);

    // Multiplier to ensure the window clears the left edge completely
    float distance = 1.0;
    float x_offset = (1.0 - p) * distance;

    // Shifting UV by +x_offset causes the sampled texture to move in from the left
    vec2 target_uv = uv + vec2(x_offset, 0.0);

    if (target_uv.x < 0.0 || target_uv.x > 1.0 || target_uv.y < 0.0 || target_uv.y > 1.0) {
        return vec4(0.0);
    }

    return umbriel_sample(target_uv);
}
