shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 blurred = textureLod(screen_texture, SCREEN_UV, blur_amount);
	COLOR = vec4(mix(blurred.rgb, tint.rgb, tint_strength), 1.0);
}