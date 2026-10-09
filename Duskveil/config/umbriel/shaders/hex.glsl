vec2 hex_coords(vec2 p) {
    vec2 r = vec2(1.0, 1.7320508);
    vec2 h = r * 0.5;
    vec2 a = mod(p, r) - h;
    vec2 b = mod(p - h, r) - h;
    return dot(a, a) < dot(b, b) ? a : b;
}

vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0 
        ? umbriel_clamped_progress 
        : 1.0 - umbriel_clamped_progress;

    // Preserve aspect ratio using umbriel_size
    vec2 aspect = vec2(umbriel_size.x / umbriel_size.y, 1.0);
    vec2 aspect_uv = uv * aspect;

    // Adjust grid frequency based on transition state
    float hex_size = mix(30.0, 180.0, smoothstep(0.0, 1.0, visible));
    vec2 grid_uv = aspect_uv * hex_size;
    vec2 hex_center = (aspect_uv - hex_coords(grid_uv) / hex_size) / aspect;

    // Cellular noise mask
    float noise = fract(sin(dot(floor(grid_uv), vec2(12.9898, 78.233))) * 43758.5453);

    // Threshold check for dissolve effect
    float threshold = smoothstep(0.0, 1.0, visible);
    if (noise > threshold) {
        return vec4(0.0);
    }

    // Blend between sampled hex center and pixel coordinate
    vec2 target_uv = mix(hex_center, uv, smoothstep(0.6, 1.0, visible));
    return umbriel_sample(target_uv);
}