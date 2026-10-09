// GLSL ES 1.00 - Geometric shard shear & prismatic collapse window close animation

const float SHARD_SCALE = 0.035;  // Voronoi cell scale for glass fragments
const float FEATHER_PX  = 2.5;

vec2 hash22(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

vec4 animation(vec2 uv) {
    float visibility = (umbriel_direction > 0.0) 
        ? umbriel_clamped_progress 
        : (1.0 - umbriel_clamped_progress);

    float close_t = 1.0 - visibility; // 0.0 (open) -> 1.0 (closed)

    vec2 p = (uv - vec2(0.5)) * umbriel_size;
    float dist = length(p);

    // Discretize into crystal shard cells
    vec2 cell = floor(p * SHARD_SCALE + umbriel_random_seed.xy);
    vec2 rnd = hash22(cell);

    // Each crystal shard slides outward and rotates along its own shear vector
    vec2 shear_dir = normalize(rnd - vec2(0.5));
    float shard_delay = rnd.x * 0.35; // Staggered collapse
    float active_t = clamp((close_t - shard_delay) / (1.0 - shard_delay), 0.0, 1.0);

    // Distortion UV shift pulling fragments towards the center singularity
    vec2 displacement = shear_dir * (active_t * 60.0) / umbriel_size;
    vec2 sampled_uv = uv + displacement;

    vec4 color = umbriel_sample(sampled_uv);

    // Collapsing event boundary: star-faceted diamond mask
    float max_r = length(umbriel_size * 0.5);
    float collapse_r = max_r * (1.0 - pow(close_t, 1.35));

    // Diamond metric: |x| + |y| gives crisp 4-point angular geometry
    float diamond_dist = abs(p.x) + abs(p.y);
    float boundary_mask = smoothstep(collapse_r, collapse_r - FEATHER_PX, diamond_dist);

    // Edge flash & chromatic burning before disappearance
    float edge_burn = exp(-abs(diamond_dist - collapse_r) / 8.0) * smoothstep(0.0, 0.4, close_t);
    vec3 burn_rgb = vec3(0.6, 0.8, 1.0);
    if (umbriel_palette_count > 0) {
        burn_rgb = umbriel_palette_at(0.25).rgb;
    }

    // Accelerate alpha fade in the closing moments
    float alpha_fade = smoothstep(0.0, 0.22, visibility);
    vec4 final_color = color * (boundary_mask * alpha_fade);
    vec4 burn_glow = vec4(burn_rgb * edge_burn * alpha_fade, edge_burn * alpha_fade);

    return final_color + burn_glow;
}