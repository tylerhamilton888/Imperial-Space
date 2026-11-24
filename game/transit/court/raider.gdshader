shader_type canvas_item;

// Keep the cleaver neutral while giving ochre armor and mauve skin distinct hues.
void fragment() {
	vec3 ink = COLOR.rgb;
	float value = dot(ink, vec3(0.28, 0.49, 0.23));
	float armor = smoothstep(0.025, 0.10, ink.r - ink.b) * smoothstep(0.01, 0.06, ink.g - ink.b);
	float skin = smoothstep(-0.012, 0.06, ink.b - ink.g) * smoothstep(0.03, 0.14, ink.r - ink.g);
	float light = smoothstep(0.11, 0.40, value);
	vec3 leather = ink * vec3(1.20, 0.93, 0.76) + vec3(0.065, 0.014, 0.0) * light;
	vec3 violet = ink * vec3(0.95, 0.80, 1.16) + vec3(0.02, 0.0, 0.09) * light;
	COLOR.rgb = mix(mix(ink, leather, armor), violet, skin);
}
