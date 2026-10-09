vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Quartic ease-in: smooth start, rapid acceleration away
    float drop = 1.0 - visible;
    float p = drop * drop * drop * drop;

    // Shrink back down to 85%
    float scale = mix(1.0, 0.85, p);
    vec2 centered_uv = (uv - vec2(0.5)) / max(0.001, scale) + vec2(0.5);

    // Sinks downwards as it closes
    float y_offset = p * 0.08;
    vec2 target_uv = centered_uv - vec2(0.0, y_offset);

    // Fades out before the animation fully finishes so it doesn't linger
    float alpha = smoothstep(0.2, 1.0, visible);

    return umbriel_sample(target_uv) * alpha;
}