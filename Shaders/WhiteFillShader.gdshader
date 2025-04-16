shader_type canvas_item;

uniform vec4 fill_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // default: red

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float brightness = (tex.r + tex.g + tex.b) / 3.0;

	// Keep black outlines
	if (brightness < 0.3) {
		COLOR = tex;
	} else {
		COLOR = fill_color * tex.a;
	}
}
