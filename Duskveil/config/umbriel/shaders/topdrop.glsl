vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;

    // Deceleration curve (settles smoothly as it reaches resting position)
    float p = 1.0 - pow(1.0 - visible, 2.0);

    // Negative offset in UV space shifts the sample down,
    // causing the visual texture to enter from above the screen
    float distance = 3.0; // Multiplier to clear top edge regardless of window height/offset
    float y_offset = (1.0 - p) * distance;

    vec2 target_uv = uv + vec2(0.0, y_offset);

    return umbriel_sample(target_uv);
}