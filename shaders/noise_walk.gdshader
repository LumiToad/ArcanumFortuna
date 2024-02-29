shader_type canvas_item;

uniform sampler2D noise;
uniform float strength = 0.0;
uniform float noise_speed = 0.1;
uniform float noise_threshold = 0.2;
uniform float noise_falloff = 0.1;
uniform float bleed_strength = 1.1;

void fragment() {
	vec2 centeredUV = (UV - vec2(0.5));
	vec2 scaledUV = centeredUV * bleed_strength;
	float result = smoothstep(noise_threshold, 1.0, texture(noise, fract(scaledUV + TIME * noise_speed)).r);
	float mask = step(0.5, max(abs(scaledUV).x, abs(scaledUV).y));
	float blending = (1.0 - smoothstep(0.5, 0.5 * bleed_strength, max(abs(scaledUV).x, abs(scaledUV).y))) * noise_falloff;
	COLOR.a = (1.0 - mask) + (mask * result * strength) * blending;
	
}