shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 1.0;
uniform vec4 color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 uv_centered = (UV - vec2(0.5)) * 2.0; // Center the UV coordinates
    float dist = length(uv_centered);
    
    float alpha = smoothstep(radius, radius - 0.05, dist); // Smooth fade effect
    COLOR = vec4(color.rgb, alpha);
}
