vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Cubic ease-out: rapid expansion that decelerates smoothly into place
    float p = 1.0 - pow(1.0 - visible, 3.0);

    // Starts from 40% scale and zooms up to 100%
    float scale = mix(0.40, 1.0, p);
    vec2 target_uv = (uv - vec2(0.5)) / max(0.001, scale) + vec2(0.5);

    // Quick fade-in so the window is clearly visible throughout the zoom
    float alpha = smoothstep(0.0, 0.5, visible);

    return umbriel_sample(target_uv) * alpha;
}