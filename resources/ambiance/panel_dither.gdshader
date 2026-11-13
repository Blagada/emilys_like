shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.1, 0.5, 0.25, 1.0);
uniform vec2 panel_size = vec2(200.0, 200.0);
uniform float pixel_size = 3.0;
uniform bool use_gradient = true;
uniform float gradient_strength : hint_range(0.0, 1.0) = 0.5;
uniform float corner_radius = 12.0;
uniform float gradient_angle : hint_range(0.0, 360.0) = 0.0;

const float BAYER[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
);

float rounded_box_alpha(vec2 pos, vec2 size, float radius) {
	vec2 q = abs(pos - size * 0.5) - (size * 0.5 - vec2(radius));
	float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
	return step(dist, 0.0);
}

void fragment() {
	vec2 pos = UV * panel_size;
	vec2 cell = floor(pos / pixel_size);

	float value = 0.5;
	if (use_gradient) {
		vec2 dir = vec2(sin(radians(gradient_angle)), cos(radians(gradient_angle)));
		vec2 centered = (cell + 0.5) * pixel_size - panel_size * 0.5;
		float extent = abs(dir.x) * panel_size.x + abs(dir.y) * panel_size.y;
		float t = clamp(dot(centered, dir) / extent + 0.5, 0.0, 1.0);
		value = mix(0.5 - gradient_strength * 0.5, 0.5 + gradient_strength * 0.5, t);
	}

	int index = int(mod(cell.x, 4.0)) + int(mod(cell.y, 4.0)) * 4;
	float threshold = (BAYER[index] + 0.5) / 16.0;

	float level = floor(value * 3.0 + threshold);
	level = clamp(level, 0.0, 3.0);

	vec3 dark = mix(base_color.rgb, vec3(0.0), 0.5);
	vec3 mid_dark = mix(base_color.rgb, vec3(0.0), 0.2);
	vec3 mid_light = base_color.rgb;
	vec3 light = mix(base_color.rgb, vec3(1.0), 0.2);

	vec3 palette[4] = vec3[4](dark, mid_dark, mid_light, light);

	COLOR = vec4(palette[int(level)], rounded_box_alpha(pos, panel_size, corner_radius));
}