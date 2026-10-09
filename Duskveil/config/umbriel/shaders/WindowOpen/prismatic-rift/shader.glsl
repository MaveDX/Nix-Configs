// GLSL ES 1.00 - Diagonal chromatic crystal rift window spawn animation

const float RIFT_ANGLE   = 0.65;   // Slit diagonal tilt in radians (~37 degrees)
const float DISPERSION   = 16.0;   // Chromatic aberration spread in logical pixels
const float FEATHER_PX   = 2.0;    // Edge softness
const vec3  FALLBACK_ACC = vec3(0.72, 0.45, 1.0); // Violet fallback

vec4 animation(vec2 uv) {
    float visibility = (umbriel_direction > 0.0) 
        ? umbriel_clamped_progress 
        : (1.0 - umbriel_clamped_progress);

    // Centered coordinates in logical pixels
    vec2 p = (uv - vec2(0.5)) * umbriel_size;

    // Rotate frame to align with rift orientation
    float cos_a = cos(RIFT_ANGLE);
    float sin_a = sin(RIFT_ANGLE);
    vec2 rot_p = vec2(p.x * cos_a - p.y * sin_a, p.x * sin_a + p.y * cos_a);

    // Dynamic crystalline facet ripples along the tear axis
    float ripple = sin(rot_p.y * 0.045 + umbriel_time * 6.0) * 12.0 * (1.0 - visibility);
    float dist_axis = abs(rot_p.x + ripple);

    // Maximum expansion distance across the diagonal
    float max_extent = length(umbriel_size);
    float open_width = smoothstep(0.0, 1.0, visibility) * (max_extent * 0.6);

    // Primary content reveal mask
    float mask = smoothstep(open_width, open_width - FEATHER_PX, dist_axis);

    // Chromatic dispersion offsets at the opening edge
    float edge_factor = smoothstep(open_width + DISPERSION, open_width, dist_axis) 
                      * (1.0 - mask) 
                      * smoothstep(1.0, 0.75, visibility);

    vec2 disp_dir = vec2(cos_a, sin_a) * (DISPERSION / umbriel_size);
    vec4 sample_r = umbriel_sample(uv + disp_dir * edge_factor * (1.0 - visibility));
    vec4 sample_g = umbriel_sample(uv);
    vec4 sample_b = umbriel_sample(uv - disp_dir * edge_factor * (1.0 - visibility));

    // Combine channels with chromatic split
    vec3 dispersed_rgb = vec3(sample_r.r, sample_g.g, sample_b.b);
    float dispersed_a = (sample_r.a + sample_g.a + sample_b.a) * 0.3333;
    vec4 base_content = mix(sample_g, vec4(dispersed_rgb, dispersed_a), edge_factor);

    // Electric prism blade running right down the leading edge
    float blade_delta = abs(dist_axis - open_width);
    float blade = exp(-blade_delta / 3.0) * smoothstep(1.0, 0.82, visibility) * 2.2;

    vec3 blade_color = FALLBACK_ACC;
    if (umbriel_palette_count > 0) {
        vec4 pal1 = umbriel_palette_at(0.0);
        vec4 pal2 = umbriel_palette_at(0.25);
        blade_color = mix(pal1.rgb, pal2.rgb, 0.5 + 0.5 * sin(rot_p.y * 0.02 + umbriel_time * 8.0));
    }

    vec4 masked_window = (base_content * mask);
    vec4 blade_glow = vec4(blade_color * blade, blade);

    return masked_window + blade_glow;
}