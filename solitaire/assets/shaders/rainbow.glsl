// holographic.glsl (Fragment Shader)
extern float time;  // Time variable for animation

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Sample the card back texture
    vec4 texColor = Texel(texture, texture_coords);

    // Create a holographic effect using color shifting and distortion
    float shift = sin(texture_coords.y * 10.0 + time * 5.0) * 0.1;  // Vertical distortion
    vec2 distortedCoords = vec2(texture_coords.x + shift, texture_coords.y);

    // Sample the texture again with distorted coordinates
    vec4 holographicColor = Texel(texture, distortedCoords);

    // Apply a color shift (e.g., rainbow effect)
    float hue = texture_coords.x + time * 0.5;
    vec3 rainbowColor = vec3(
        0.5 + 0.5 * sin(hue),
        0.5 + 0.5 * sin(hue + 2.094),  // 2.094 radians = 120 degrees
        0.5 + 0.5 * sin(hue + 4.188)   // 4.188 radians = 240 degrees
    );

    // Blend the holographic effect with the original texture
    vec4 finalColor = mix(texColor, vec4(rainbowColor, texColor.a), 0.5);

    return finalColor;
}