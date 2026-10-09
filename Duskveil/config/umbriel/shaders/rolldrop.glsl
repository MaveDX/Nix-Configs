vec4 animation(vec2 uv) {

    // basic clamping progression.
    float visible = umbriel_direction > 0.0
        ? umbriel_clamped_progress : 1.0 - umbriel_clamped_progress;
    float progress = visible * visible;

    vec2 coords = (uv - vec2(0.5, 0.0)) * umbriel_size;
    coords.y += (1.0 - progress) * 1440.0 * umbriel_direction;

    // standard 2D rotation matrix, standard formulate for rotation a point aorund the origin by angle in radians.
    // mat2(a, b, c, d) fills the matrix column-major.
    float angle = (1.0 - progress) * 0.3 * umbriel_direction;
    mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    coords = rotate * coords;

    // return sample.
    vec2 sample_uv = coords / umbriel_size + vec2(0.5, 0.0);
    return umbriel_sample(sample_uv);
}