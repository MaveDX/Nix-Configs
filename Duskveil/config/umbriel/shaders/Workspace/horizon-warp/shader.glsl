// GLSL ES 1.00 - Dynamic relativistic horizon warp for workspace transitions

const float WARP_DEPTH    = 0.38;   // Depth contraction intensity along the motion axis
const float DISPERSION    = 14.0;   // Peak chromatic separation in logical pixels
const float SCAN_LINES    = 60.0;   // Frequency of high-speed velocity streak lines
const vec3  FALLBACK_HUE  = vec3(0.7, 0.45, 1.0); // Violet/lavender fallback

vec4 animation(vec2 uv) {
    // Monotonic linear timeline for workspace slide progress
    float progress = umbriel_clamped_progress;

    // Movement impulse envelope: zero at start and finish, peaks at midpoint (progress = 0.5)
    float impulse = sin(progress * 3.14159265);
    float warp_strength = pow(impulse, 1.6);

    // Lateral direction sign (+1 or -1)
    float dir = (umbriel_direction >= 0.0) ? 1.0 : -1.0;

    // Center-relative coordinates
    vec2 p = uv - vec2(0.5);

    // Non-linear horizontal spatial compression (Lorentz-like contraction)
    // Curvature concentrates toward the vertical center
    float horizon_pinch = 1.0 + WARP_DEPTH * warp_strength * (1.0 - 4.0 * p.y * p.y);
    float displaced_x = p.x * horizon_pinch - (dir * warp_strength * 0.18);

    // Fast-moving horizontal streak slices
    float streak = sin(uv.y * SCAN_LINES + umbriel_time * 12.0);
    float streak_offset = streak * warp_strength * (2.5 / umbriel_size.x);

    vec2 target_uv = vec2(displaced_x + 0.5 + streak_offset, uv.y);

    // Compute chromatic aberration offset based on logical pixel density
    float split = (DISPERSION * warp_strength) / umbriel_size.x;
    vec2 split_vec = vec2(split * dir, 0.0);

    // Sample chromatic channels across the warp vector
    vec4 sample_r = umbriel_sample(target_uv + split_vec);
    vec4 sample_g = umbriel_sample(target_uv);
    vec4 sample_b = umbriel_sample(target_uv - split_vec);

    vec3 composite_rgb = vec3(sample_r.r, sample_g.g, sample_b.b);
    float composite_a = (sample_r.a + sample_g.a + sample_b.a) * 0.33333;
    vec4 warped_content = vec4(composite_rgb, composite_a);

    // Luminous speedlines at peak transition velocity
    float streak_glow = smoothstep(0.75, 1.0, abs(streak)) * warp_strength * 0.25;
    vec3 glow_color = FALLBACK_HUE;
    if (umbriel_palette_count > 0) {
        glow_color = umbriel_palette_at(0.0).rgb;
    }

    vec4 additive_light = vec4(glow_color * streak_glow, streak_glow);

    // Output clean premultiplied RGBA
    return warped_content + additive_light;
}