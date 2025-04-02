shader_type canvas_item;

uniform vec4 outline_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width: hint_range(0, 10) = 1.0;
uniform bool square_corners = false;
uniform float opacity_threshold: hint_range(0.0, 1.0) = 0.9;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    vec2 ps = TEXTURE_PIXEL_SIZE;

    if (col.a < 0.1) {
        float a = 0.0;

        float up = texture(TEXTURE, UV + vec2(0.0, -outline_width) * ps).a;
        float left = texture(TEXTURE, UV + vec2(-outline_width, 0.0) * ps).a;
        float down = texture(TEXTURE, UV + vec2(0.0, outline_width) * ps).a;
        float right = texture(TEXTURE, UV + vec2(outline_width, 0.0) * ps).a;

        // only count neighboring pixels that are above the opacity threshold
        if (up >= opacity_threshold) a += up;
        if (left >= opacity_threshold) a += left;
        if (down >= opacity_threshold) a += down;
        if (right >= opacity_threshold) a += right;

		// draw corners
        if (square_corners) {
            float upLeft = texture(TEXTURE, UV + vec2(-outline_width, -outline_width) * ps).a;
            float upRight = texture(TEXTURE, UV + vec2(outline_width, -outline_width) * ps).a;
            float downLeft = texture(TEXTURE, UV + vec2(-outline_width, outline_width) * ps).a;
            float downRight = texture(TEXTURE, UV + vec2(outline_width, outline_width) * ps).a;

            // only count pixels that are above the opacity threshold
            if (upLeft >= opacity_threshold) a += upLeft;
            if (upRight >= opacity_threshold) a += upRight;
            if (downLeft >= opacity_threshold) a += downLeft;
            if (downRight >= opacity_threshold) a += downRight;
        }

        if (a > 0.0) {
            col = outline_color;
        }
    }

    COLOR = col;
}