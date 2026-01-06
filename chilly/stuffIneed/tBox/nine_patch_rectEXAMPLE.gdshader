shader_type canvas_item;

uniform sampler2D star_texture : repeat_enable;
uniform float anim_speed = .1;

void fragment() {
	// animate the star uv
	// UV must be relative to the screen, because the 9 match messes with it
	vec2 uv_anim = SCREEN_UV + vec2(TIME * anim_speed);
	
	vec4 pattern = texture(star_texture, uv_anim);
	vec4 base = texture(TEXTURE, UV);
	
	// //Layer pattern over whole object
	COLOR = vec4(pattern.rgb, base.a);
	
	//base.rgb = step(base.rgb, vec3(.5));  
	//base.rgb = 1.0 - base.rgb;
    //vec4 mask = vec4(step(base.rgb, vec3(0.5)), 1.0);
    //COLOR = mix(pattern, base, mask);
	
	// mix(pattern1, pattern2, mask)
	// where mask is 1, show pattern1, where mask is 0, show pattern2 
	// COLOR = mix(base, vec4(pattern.rgb, base.a), pattern.a);
	

}
