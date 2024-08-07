shader_type spatial;

uniform sampler2D circle_image;
uniform sampler2D noise_texture;

uniform vec3 glow_color: source_color;
uniform float glow_intensity : hint_range(0.0, 10.0) = 10.0;

uniform float chalk_scale: hint_range(1, 50.0, 5) = 10.0;
uniform float chalk_blend: hint_range(0.1, 1.0, 0.1) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 sampled = texture(circle_image, UV);
	vec4 color = vec4(glow_color, 1.0);
	vec4 noise = texture(noise_texture, UV * chalk_scale);
	float chalk_alpha = mix(1., 1. - noise.r,  chalk_blend); // Adjust blending as necessary

	ALPHA = (1. - sampled.r) * chalk_alpha;
    ALBEDO = color.rgb;
	EMISSION = glow_color * glow_intensity * (1. - sampled.r) * chalk_alpha;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
