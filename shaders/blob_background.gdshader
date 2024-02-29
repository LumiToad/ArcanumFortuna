shader_type canvas_item;

uniform float strength;
uniform sampler2D noise;

float sdfCircle(vec2 pos, vec2 center, float radius) {
	return length(pos - center) - radius;
}

float sdfRect(vec2 pos, vec2 center, vec2 size) {
	vec2 d = abs(pos - center) - size;
	return max(d.x, d.y);
}

float definedCircle(vec2 pos) {
	return sdfRect(pos, vec2(0.5), vec2(0.5));
}

void fragment() {
	vec2 DIRECTION = vec2(definedCircle(UV + vec2(0.0001, 0)) - definedCircle(UV + vec2(0, -0.0001)), definedCircle(UV + vec2(0, 0.0001)) - definedCircle(UV + vec2(0, -0.0001)));
	float rad = atan(DIRECTION.y, DIRECTION.x);
	float mappedCoordinate = (rad + PI) / (PI * 2.0);
	COLOR.a *= (1.0 - smoothstep(0.0, 0.01, definedCircle(UV + DIRECTION * 100.0 * texture(noise, fract(UV.xy + TIME * 0.1)).x * strength)));
}
