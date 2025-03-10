#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;
uniform sampler2D u_mask;  // Mask texture
uniform vec2 u_cursor;     // Cursor position in [0, 1] range

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

// Procedural normal generation
vec3 proceduralNormal(vec2 uv) {
    // Add cursor-based parallax effect
    vec2 parallaxOffset = u_cursor * 0.5;  // Adjust the multiplier for parallax strength
    float noise = fbm(uv * 4.0 + u_time * 0.6 + parallaxOffset);
    return normalize(vec3(noise, noise, 1.0));  // Create a normal vector
}

// Simulate a reflective gold surface
vec3 goldReflection(vec2 uv, vec3 normal, vec3 viewDir) {
    // Base gold color
    vec3 baseColor = vec3(0.85, 0.65, 0.3);

    // Light direction (simulate a light source)
    vec3 lightDir = normalize(vec3(1.0, 0.5, 1.0));  // Adjusted light direction

    // Diffuse lighting
    float diffuse = max(dot(normal, lightDir), 0.0);

    // Specular highlight (Blinn-Phong model)
    vec3 halfDir = normalize(lightDir + viewDir);
    float specular = pow(max(dot(normal, halfDir), 0.0), 16.0);  // Adjusted specular power

    // Ambient light
    vec3 ambient = vec3(0.2);  // Add ambient light

    // Combine base color, diffuse, ambient, and specular
    vec3 finalColor = baseColor * (diffuse + ambient) + vec3(1.0) * specular;

    return finalColor;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    uv.x *= u_resolution.x / u_resolution.y;

    // Generate a procedural normal vector
    vec3 normal = proceduralNormal(uv);

    // View direction (simulate camera looking at the surface)
    vec3 viewDir = vec3(0.0, 0.0, 1.0);

    // Calculate the gold reflection
    vec3 gold = goldReflection(uv, normal, viewDir);

    // Sample the texture color
    vec4 texColor = Texel(texture, texture_coords);

    // Sample the mask texture
    float mask = Texel(u_mask, texture_coords).r;

    // Mix with the texture color, applying the gold effect only where the mask is white
    vec3 finalColor = mix(texColor.rgb, gold, mask * 0.7);  // Adjust the multiplier for intensity

    return vec4(finalColor, texColor.a);
}