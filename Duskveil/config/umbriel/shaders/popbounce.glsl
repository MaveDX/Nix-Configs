vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Spring-like overshoot curve (peaks at ~1.04 before settling to 1.0)
    float t = visible;
    float p = sin(t * 1.5707963) + sin(t * 3.14159265) * 0.12;

    // Distinct scale from 70% up to full size
    float scale = mix(0.70, 1.0, p);
    vec2 centered_uv = (uv - vec2(0.5)) / max(0.001, scale) + vec2(0.5);

    // Visible 15% screen-relative rise into resting position
    float y_offset = (1.0 - visible) * 0.15;
    vec2 target_uv = centered_uv + vec2(0.0, y_offset);

    // Fast initial alpha fade
    float alpha = smoothstep(0.0, 0.4, visible);

    return umbriel_sample(target_uv) * alpha;
}