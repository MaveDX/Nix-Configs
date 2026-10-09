// GLSL ES 1.00 - Cherry Blossom (Sakura) split-horizon workspace transition

const float SAKURA_RADIUS = 340.0; // Petal reach in logical pixels
const float NOTCH_DEPTH   = 42.0;  // Circular cutout size at petal tips
const vec3  HEART_GOLD    = vec3(0.96, 0.82, 0.45); // Golden heart core
const vec3  PETAL_LINE    = vec3(1.0, 0.94, 0.98);  // Crisp white/lavender line
const vec3  PETAL_FILL_C  = vec3(0.40, 0.18, 0.32); // Deep plum/wine body fill

// Clean heart distance field
float get_heart(vec2 p, float s) {
    p /= s;
    p.y += 0.35;
    p.x = abs(p.x);
    if (p.y + p.x > 1.0) {
        return length(p - vec2(0.25, 0.75)) - 0.3535;
    }
    return max(p.x + p.y - 1.0, -p.y - 0.5 * p.x);
}

// Sakura distance field with circular petal notch
float get_sakura(vec2 p, float r) {
    float d = length(p);
    float a = atan(p.y, p.x); // [-PI, PI]

    // 5-fold petal symmetry
    const float TAU_5 = 6.2831853 / 5.0; // 72 deg
    float sector_angle = mod(a + TAU_5 * 0.5, TAU_5) - TAU_5 * 0.5;

    // Rotate to petal local axis
    vec2 p_petal = vec2(cos(sector_angle), sin(sector_angle)) * d;

    // Petal body profile (tapered base, widened lobe)
    float body = length(vec2(p_petal.x * 0.9, p_petal.y * 1.45)) - r;

    // Circular notch at petal tip
    vec2 notch_center = vec2(r * 0.98, 0.0);
    float notch = length(p_petal - notch_center) - NOTCH_DEPTH;

    return max(body, -notch);
}

vec4 animation(vec2 uv) {
    // Monotonic curve progress (0.0 -> 1.0)
    float t = umbriel_clamped_progress;

    // Visual envelope: peaks at 1.0 mid-transition, zero at 0.0 and 1.0
    float bloom = sin(t * 3.14159265);

    // Direction mapping:
    // If umbriel_direction < 0.0 -> Previous (top edge downwards)
    // Otherwise -> Next (bottom edge upwards)
    bool is_prev = (umbriel_direction < -0.01);

    // Anchor center along workspace seam
    vec2 seam_origin = is_prev ? vec2(0.5, 0.0) : vec2(0.5, 1.0);
    vec2 p = (uv - seam_origin) * umbriel_size;

    // Orient flower so petals point INTO the screen
    float y_local = is_prev ? p.y : -p.y;
    vec2 p_flower = vec2(p.x, y_local);

    // Petal scale expansion
    float current_r = SAKURA_RADIUS * (0.65 + 0.35 * bloom);

    // Line thickness adjusted by display scale
    float stroke = 4.0 * umbriel_scale;

    // Outer contour
    float d_outer = get_sakura(p_flower, current_r);
    float outer_line = smoothstep(stroke, 0.0, abs(d_outer));

    // Inner contour line
    float d_inner = get_sakura(p_flower, current_r * 0.72);
    float inner_line = smoothstep(stroke * 0.75, 0.0, abs(d_inner));

    // Petal interior body fill (dark semi-opaque plum fill from screenshot)
    float petal_body = smoothstep(1.5, -1.5, d_outer) * 0.55;

    // God rays radiating from the center
    float ray_angle = atan(p_flower.y, p_flower.x);
    float rays = sin(ray_angle * 12.0 + umbriel_time * 2.0);
    rays = smoothstep(0.4, 1.0, rays) * smoothstep(current_r * 1.6, 0.0, length(p_flower));
    float ray_alpha = rays * bloom * 0.35;

    // Heart core at seam center
    float d_heart = get_heart(p_flower, 46.0 * (0.8 + 0.2 * bloom));
    float heart_mask = smoothstep(1.5, -1.5, d_heart);

    // 4-point twinkle star on the heart
    vec2 hp = abs(p_flower);
    float star_dist = min(hp.x, hp.y) + length(hp) * 0.45;
    float star_glint = smoothstep(14.0, 0.0, star_dist) * heart_mask * 2.0;

    // Mask to strictly keep the bloom on the screen-side of the seam (half flower)
    float half_plane = smoothstep(-stroke, stroke, y_local);

    // Resolve colors
    vec3 line_rgb = PETAL_LINE;
    if (umbriel_palette_count > 0) {
        line_rgb = mix(PETAL_LINE, umbriel_palette_at(0.0).rgb, 0.3);
    }

    vec3 heart_rgb = mix(HEART_GOLD, vec3(1.0), star_glint * 0.4);

    // Layer alphas
    float lines_total = max(outer_line, inner_line) * bloom * half_plane;
    float fill_total  = petal_body * bloom * half_plane;
    float heart_total = heart_mask * bloom * half_plane;
    float rays_total  = ray_alpha * half_plane;

    // Sample background workspace capture
    vec4 bg = umbriel_sample(uv);

    // Assemble premultiplied layers
    vec4 ray_col   = vec4(line_rgb * rays_total, rays_total);
    vec4 fill_col  = vec4(PETAL_FILL_C * fill_total, fill_total);
    vec4 line_col  = vec4(line_rgb * lines_total, lines_total);
    vec4 heart_col = vec4(heart_rgb * heart_total, heart_total);

    // Composite: background -> god rays -> petal body fill -> contour outlines -> golden heart
    vec4 out_color = bg + ray_col;
    out_color = out_color * (1.0 - fill_col.a) + fill_col;
    out_color = out_color * (1.0 - line_col.a) + line_col;
    out_color = out_color * (1.0 - heart_col.a) + heart_col;

    return out_color;
}
