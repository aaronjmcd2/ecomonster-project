shader_type canvas_item;

uniform vec4 fill_color;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float brightness = (tex.r + tex.g + tex.b) / 3.0;

	if (brightness < 0.3) {
		// Keep black lines
		COLOR = tex;
	} else if (brightness < 0.85) {
		// Gray = shaded fill color
		float shade_factor = brightness / 0.85; // 0 → 1
		COLOR = fill_color * shade_factor * tex.a;
	} else {
		// White = full fill color
		COLOR = fill_color * tex.a;
	}
}
