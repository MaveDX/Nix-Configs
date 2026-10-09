vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Quartic ease-out: incredibly smooth deceleration at the end
    float p = 1.0 - pow(1.0 - visible, 4.0);

    // Noticeable scale from 85% up to 100%
    float scale = mix(0.85, 1.0, p);
    vec2 centered_uv = (uv - vec2(0.5)) / max(0.001, scale) + vec2(0.5);

    // Glides upwards into its final resting spot
    float y_offset = (1.0 - p) * 0.08;
    vec2 target_uv = centered_uv + vec2(0.0, y_offset);

    // Opacity reaches 100% before the motion completely stops
    float alpha = smoothstep(0.0, 0.6, visible);

    return umbriel_sample(target_uv) * alpha;
}