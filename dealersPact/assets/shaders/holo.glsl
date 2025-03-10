#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;  // Time variable for animation
uniform vec2 u_resolution;
uniform sampler2D u_mask;  // Mask texture

// Utility function to convert HSV to RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(random2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                    dot(random2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(random2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                    dot(random2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

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

vec3 pastelRainbow(float n) {
    // Evenly distribute hues across the full rainbow spectrum
    float hue = fract(n + u_time * 0.05);  // Gradual color shifting
    float saturation = 0.5;
    float value = 1.0;
    
    // Convert from HSV to RGB for smoother rainbow colors
    vec3 color = hsv2rgb(vec3(hue, saturation, value));
    
    // Mix with white to achieve a pastel effect
    color = mix(vec3(1.0), color, 0.6);
    return color;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = screen_coords / u_resolution.xy;
    uv.x *= u_resolution.x / u_resolution.y;

    // Add subtle dynamic movement
    uv += vec2(sin(u_time * 0.3), cos(u_time * 0.25)) * 0.1;

    // Generate the noise pattern for a fluid holographic effect
    float n = fbm(uv * 4.0 + u_time * 0.4);

    // Get the pastel rainbow holographic color
    vec3 hologram = pastelRainbow(n);

    // Sample the texture color
    vec4 texColor = Texel(texture, texture_coords);

    // Sample the mask texture
    float mask = Texel(u_mask, texture_coords).r;

    // Mix with the texture color, applying the holographic effect only where the mask is white
    vec3 finalColor = mix(texColor.rgb, hologram, mask * 0.5);  // Adjust the multiplier for intensity

    return vec4(finalColor, texColor.a);
}