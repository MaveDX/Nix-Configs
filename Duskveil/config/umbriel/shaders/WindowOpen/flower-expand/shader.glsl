// GLSL ES 1.00 - Window spawn animation blooming from a 5-petal flower into an expanding circle

const float PETALS          = 5.0;   // Number of flower petals
const float PETAL_AMP       = 0.35;  // Initial depth of petal indents
const float BORDER_WIDTH_PX = 3.5;   // Border stroke width in logical pixels
const float FEATHER_PX      = 2.0;   // Antialiasing smoothness in logical pixels

const vec3 FALLBACK_BORDER  = vec3(0.85, 0.72, 1.0); // Fallback border if palette is disabled

vec4 animation(vec2 uv) {
    vec4 color = umbriel_sample(uv);

    // Compute lifecycle visibility: 0.0 (closed) -> 1.0 (open)
    float visibility = (umbriel_direction > 0.0)
        ? umbriel_clamped_progress
        : (1.0 - umbriel_clamped_progress);

    // Vector and polar coordinates in logical pixels relative to window center
    vec2 pos = (uv - vec2(0.5)) * umbriel_size;
    float dist = length(pos);
    float angle = atan(pos.y, pos.x);

    // Maximum distance from center to corner
    float max_radius = length(umbriel_size * 0.5);

    // Petal orientation (stationary, no spin)
    float petal_angle = angle * PETALS;

    // Morphing: starts with deep petals, gradually flattens to 0.0 (perfect circle) by 70% progress
    float current_amp = PETAL_AMP * (1.0 - smoothstep(0.0, 0.70, visibility));
    float flower_modulation = 1.0 + current_amp * cos(petal_angle);

    // Scale border and feathering by compositor display scale
    float border_width = BORDER_WIDTH_PX * umbriel_scale;
    float feather = FEATHER_PX * umbriel_scale;

    // Expanding radius: reaches past corner max_radius so the circle fully reveals the window
    float expansion_radius = visibility * (max_radius + border_width + feather * 2.0);
    float target_radius = expansion_radius * flower_modulation;

    // Outer edge of the boundary
    float outer_mask = smoothstep(target_radius, target_radius - feather, dist);

    // Inner edge where window content sits inside the border stroke
    float inner_radius = max(target_radius - border_width, 0.0);
    float content_mask = smoothstep(inner_radius, inner_radius - feather, dist);

    // Border band between outer and inner thresholds
    float border_mask = clamp(outer_mask - content_mask, 0.0, 1.0);

    // Border line fades away as the window nears completion so it leaves no lingering edge
    float border_fade = 1.0 - smoothstep(0.70, 0.95, visibility);

    // Fade-in factor for the window content at inception
    float content_fade = smoothstep(0.0, 0.15, visibility);

    // Masked content in premultiplied format
    vec4 masked_content = color * (content_mask * content_fade);

    // Resolve border color (primary theme accent or fallback)
    vec3 border_rgb = FALLBACK_BORDER;
    if (umbriel_palette_count > 0) {
        border_rgb = umbriel_palette_at(0.0).rgb;
    }

    // Premultiplied border layer
    float border_alpha = border_mask * border_fade;
    vec4 border_layer = vec4(border_rgb * border_alpha, border_alpha);

    // Composite border over the opening window content
    return masked_content * (1.0 - border_layer.a) + border_layer;
}