shader_type canvas_item;

// No invalid hint here
uniform float opacity = .1;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tex.rgb, tex.a * opacity);
}
