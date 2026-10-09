// GLSL ES 1.00 - Expanding circle reveal animation for window spawning
// Distance is evaluated in logical pixels to keep the circle round on rectangular windows.

const float FEATHER_PX = 2.0;

vec4 animation(vec2 uv) {
    vec4 color = umbriel_sample(uv);

    // Compute lifecycle visibility: 0.0 when spawning begins, 1.0 when fully open
    float visibility = (umbriel_direction > 0.0)
        ? umbriel_clamped_progress
        : (1.0 - umbriel_clamped_progress);

    // Coordinate offset in logical pixels from the center of the window
    vec2 pos = (uv - vec2(0.5)) * umbriel_size;
    float dist = length(pos);

    // Maximum distance from center to corner
    float max_radius = length(umbriel_size * 0.5);

    // Current expansion radius
    float current_radius = visibility * (max_radius + FEATHER_PX);

    // Antialiased edge mask
    float mask = smoothstep(current_radius, current_radius - FEATHER_PX, dist);

    // Return premultiplied RGBA
    return color * mask;
}
