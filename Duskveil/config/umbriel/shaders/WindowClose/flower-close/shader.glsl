// GLSL ES 1.00 - Window close animation folding into a spinning 5-petal flower with an active border

const float PETALS          = 5.0;   // Number of flower petals
const float PETAL_AMP       = 0.32;  // Depth of the petal indents
const float SPIN_REVS       = 0.45;  // Total rotational spin during collapse (in full turns)
const float BORDER_WIDTH_PX = 3.5;   // Border stroke width in logical pixels
const float FEATHER_PX      = 2.0;   // Antialiasing smoothness in logical pixels

const vec3 FALLBACK_BORDER  = vec3(0.85, 0.72, 1.0); // Fallback border color if palette is disabled

vec4 animation(vec2 uv) {
    vec4 color = umbriel_sample(uv);

    // Compute lifecycle visibility: 1.0 when fully open -> 0.0 when fully closed
    float visibility = (umbriel_direction > 0.0)
        ? umbriel_clamped_progress
        : (1.0 - umbriel_clamped_progress);

    // Normalized progress through the closing event (0.0 = start of close, 1.0 = fully closed)
    float close_t = 1.0 - visibility;

    // Vector and polar coordinates in logical pixels relative to window center
    vec2 pos = (uv - vec2(0.5)) * umbriel_size;
    float dist = length(pos);
    float angle = atan(pos.y, pos.x);

    // Maximum distance from center to corner
    float max_radius = length(umbriel_size * 0.5);

    // Rotation angle as it folds up
    float rotation = close_t * SPIN_REVS * 6.2831853;
    float petal_angle = angle * PETALS + rotation;

    // Modulate petal profile: transitions from round at start to deep petals as it closes
    float current_amp = PETAL_AMP * smoothstep(0.0, 0.45, close_t);
    float flower_modulation = 1.0 + current_amp * cos(petal_angle);

    // Contracting scale radius: collapses to 0.0 at the end of the transition
    float collapse_radius = max_radius * (1.0 - close_t);
    float target_radius = collapse_radius * flower_modulation;

    // Scale border width and antialiasing by display scale
    float border_width = BORDER_WIDTH_PX * umbriel_scale;
    float feather = FEATHER_PX * umbriel_scale;

    // Outer edge of the border stroke
    float outer_mask = smoothstep(target_radius, target_radius - feather, dist);

    // Inner edge of the border stroke (where window content sits)
    float inner_radius = max(target_radius - border_width, 0.0);
    float content_mask = smoothstep(inner_radius, inner_radius - feather, dist);

    // The border band itself is the region between outer_mask and content_mask
    float border_mask = clamp(outer_mask - content_mask, 0.0, 1.0);

    // Fade out smoothly toward complete closure
    float fade = smoothstep(0.0, 0.25, visibility);

    // Content alpha with inner cut
    vec4 masked_content = color * (content_mask * fade);

    // Resolve border color (samples primary accent if palette is active)
    vec3 border_rgb = FALLBACK_BORDER;
    if (umbriel_palette_count > 0) {
        border_rgb = umbriel_palette_at(0.0).rgb;
    }

    // Premultiplied border stroke
    float border_alpha = border_mask * fade;
    vec4 border_layer = vec4(border_rgb * border_alpha, border_alpha);

    // Composite border over the window content
    return masked_content * (1.0 - border_layer.a) + border_layer;
}
