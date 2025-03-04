#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;
uniform Image u_mask;

// Random number generator
vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

// Noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(random2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                    dot(random2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(random2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                    dot(random2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

// Fractal Brownian Motion for more detailed noise
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// Gold color palette
vec3 goldColor(float n) {
    // Warm golden hues with dynamic highlights
    float highlight = smoothstep(0.3, 0.7, sin(n * 6.28318 + u_time * 2.0));
    vec3 baseColor = vec3(0.85, 0.65, 0.3);  // Base gold color
    vec3 lightColor = vec3(1.0, 0.85, 0.6);  // Shiny highlight color

    // Mix base and highlight for metallic reflection
    return mix(baseColor, lightColor, highlight);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    uv.x *= u_resolution.x / u_resolution.y;

    // Noise animation independent of UV
    float noisePattern = fbm(uv * 6.0 + vec2(u_time * 0.3, u_time * 0.35));

    // Apply the gold color palette
    vec3 gold = goldColor(noisePattern);

    // Sample the card texture
    vec4 texColor = Texel(texture, texture_coords);

    // Sample the mask texture
    float mask = Texel(u_mask, texture_coords).r;

    // Apply the gold effect only where the mask is white
    vec3 finalColor = mix(texColor.rgb, gold, mask * 0.7);

    return vec4(finalColor, texColor.a);
}
