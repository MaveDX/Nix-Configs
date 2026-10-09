vec4 animation(vec2 uv) {
    float visible = umbriel_direction > 0.0 
        ? umbriel_clamped_progress 
        : 1.0 - umbriel_clamped_progress;
    
    float p = smoothstep(0.0, 1.0, visible);

    // Center coordinates
    vec2 centered = uv - vec2(0.5);
    
    // Convert to polar coordinates
    float angle = atan(centered.y, centered.x);
    float dist = length(centered);

    // Apply rotation twist that dissipates as progress approaches 1.0
    float twist_strength = (1.0 - p) * 12.0;
    float twisted_angle = angle + twist_strength * smoothstep(0.7, 0.0, dist);

    // Convert back to cartesian coordinates
    vec2 warped = vec2(cos(twisted_angle), sin(twisted_angle)) * dist;

    // Scale down when disappearing
    float scale = mix(0.05, 1.0, p);
    vec2 final_uv = (warped / scale) + vec2(0.5);

    return umbriel_sample(final_uv) * p;
}