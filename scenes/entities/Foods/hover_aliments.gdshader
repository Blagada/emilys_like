shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 20.0) = 20;
uniform bool hover_active = false;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 base_color = tex_color * COLOR; // respecte modulate (flash, teintes, etc.)

	if (hover_active && tex_color.a < 1.0) {
		vec2 offset = TEXTURE_PIXEL_SIZE * outline_width;
		float neighbor_alpha = 0.0;

		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				if (x == 0 && y == 0) {
					continue;
				}
				vec2 sample_uv = UV + vec2(float(x) * offset.x, float(y) * offset.y);
				neighbor_alpha = max(neighbor_alpha, texture(TEXTURE, sample_uv).a);
			}
		}

		if (neighbor_alpha > 0.0) {
			COLOR = vec4(outline_color.rgb, neighbor_alpha);
		} else {
			COLOR = base_color;
		}
	} else {
		COLOR = base_color;
	}
}