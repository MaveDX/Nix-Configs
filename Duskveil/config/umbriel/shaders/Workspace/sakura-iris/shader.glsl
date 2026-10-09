// GLSL ES 1.00 - Mass Sakura Blizzard (Blossom Storm) Workspace Transition
// Grid-partitioned instancing for rendering high quantities of petals with zero loop overhead

const float GRID_SIZE_PX = 85.0;  // Spacing between petal stream cells
const float PETAL_BASE_R = 26.0;  // Size of individual petals
const float NOTCH_DEPTH  = 7.0;   // Tip notch depth
const vec3  FALLBACK_COL = vec3(0.96, 0.82, 0.94); // Light lavender-rose
const vec3  FALLBACK_RIM = vec3(1.0, 0.95, 1.0);

// Deterministic 2D hash
vec2 hash22(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

// 5-petal notched sakura tip SDF
float sakura_petal_sdf(vec2 p, float r) {
    // Oriented petal body (elongated droplet)
    p.y *= 1.35;
    float body = length(vec2(p.x * 0.9, p.y)) - r;

    // V-notch cutout at petal tip
    vec2 notch_c = vec2(0.0, r * 0.95);
    float notch = length(p - notch_c) - (NOTCH_DEPTH * (r / PETAL_BASE_R));

    return max(body, -notch);
}

vec4 animation(vec2 uv) {
    float t = umbriel_clamped_progress;

    // Impulse curve: zero at boundary frames, peaking mid-swipe
    float impulse = sin(t * 3.14159265);
    float storm_power = pow(impulse, 1.2);

    // Direction mapping:
    // Next (+1): Petals fly UPWARDS (-y)
    // Previous (-1): Petals fly DOWNWARDS (+y)
    float dir_y = (umbriel_direction < -0.01) ? 1.0 : -1.0;

    // Screen pixel position
    vec2 p_screen = uv * umbriel_size;

    // Continuous flow coordinates: translates space according to wind velocity
    float stream_speed = (t * 2.2) * umbriel_size.y * dir_y;
    vec2 flow_p = p_screen + vec2(0.0, stream_speed);

    // Spatial grid indexing
    vec2 cell_idx = floor(flow_p / GRID_SIZE_PX);

    vec4 petal_composite = vec4(0.0);

    // Evaluate 3x3 local neighbor cells (renders 9 potential overlapping petals per screen point)
    for (float ox = -1.0; ox <= 1.0; ox += 1.0) {
        for (float oy = -1.0; oy <= 1.0; oy += 1.0) {
            vec2 current_cell = cell_idx + vec2(ox, oy);
            vec2 seed = hash22(current_cell);

            // Jittered origin within grid cell
            vec2 cell_origin = (current_cell + 0.15 + 0.7 * seed) * GRID_SIZE_PX;

            // Lateral wind flutter
            float sway = sin(t * 9.0 + seed.x * 6.28) * 28.0;
            vec2 petal_center = cell_origin + vec2(sway, 0.0);

            // Relative offset from current pixel to petal center
            vec2 delta = flow_p - petal_center;

            // 3D tumbling: rotation (yaw) and perspective flattening (pitch)
            float rot_angle = t * 6.0 * (seed.y - 0.5) * 8.0 + seed.x * 6.28;
            float cos_r = cos(rot_angle);
            float sin_r = sin(rot_angle);

            float pitch = sin(t * 7.5 + seed.y * 6.28);
            float tumble_squeeze = 0.35 + 0.65 * abs(pitch);

            vec2 rot_delta = vec2(
                delta.x * cos_r - delta.y * sin_r,
                (delta.x * sin_r + delta.y * cos_r) * tumble_squeeze
            );

            // Varied sizes per petal
            float r = PETAL_BASE_R * (0.65 + 0.55 * seed.x);

            // Evaluate petal distance field
            float d = sakura_petal_sdf(rot_delta, r);

            // Antialiased silhouette
            float petal_mask = smoothstep(1.8, -1.8, d);
            float alpha = petal_mask * storm_power * (0.8 + 0.2 * seed.y);

            if (alpha > 0.01) {
                // Color palette sampling
                vec3 base_rgb = FALLBACK_COL;
                if (umbriel_palette_count > 0) {
                    vec4 c1 = umbriel_palette_at(0.0);  // Primary accent
                    vec4 c2 = umbriel_palette_at(0.25); // Secondary accent
                    base_rgb = mix(c1.rgb, c2.rgb, seed.x);
                }

                // Shading: illuminated rim light + deep core tint
                float dist_norm = length(rot_delta) / r;
                float rim = smoothstep(0.65, 1.0, dist_norm) * 0.45;
                float core_crease = smoothstep(0.0, 0.4, dist_norm) * 0.25;

                vec3 petal_color = (base_rgb + vec3(rim)) - vec3(core_crease);

                // Layer onto composite accumulator (premultiplied blending)
                vec4 layer = vec4(petal_color * alpha, alpha);
                petal_composite = petal_composite + layer * (1.0 - petal_composite.a);
            }
        }
    }

    // Sample the native workspace scene
    vec4 workspace_base = umbriel_sample(uv);

    // Composite mass petals over workspace
    return workspace_base * (1.0 - petal_composite.a) + petal_composite;
}
