shader_type spatial;
render_mode cull_disabled; // View both sides

uniform vec3 sphere_position = vec3(0.0);
uniform float sphere_radius = 1.0;
uniform float burn_threshold = 0.1;

uniform sampler2D noise_texture;
uniform float noise_strength = 0.1;
uniform float noise_scale = 1.0;

void fragment(){
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float dist = distance(world_pos, sphere_position);
	
	vec2 noise_uv = (world_pos.xy + world_pos.yz + world_pos.xz) * noise_scale;
	float noise = texture(noise_texture, noise_uv).r * 2.0 - 1.0;
	
	float noisy_radius = sphere_radius + noise * noise_strength;
	float sphere_dist = dist - noisy_radius;

	if (sphere_dist < 0.0) {
	    discard;
	}

	if (sphere_dist < burn_threshold) {
	    float burn_factor = sphere_dist / burn_threshold;
	    float burn_noise = texture(noise_texture, noise_uv * 2.0).r * 0.5;
	    burn_factor = mix(burn_factor, burn_factor * (1.0 + burn_noise), 0.5);
	    
	    ALBEDO = vec3(1.0);
	    EMISSION = vec3(1.0) * (1.0 - burn_factor);
	    EMISSION *= 1.0 + burn_noise * 0.5;
	}else {
    	ALBEDO = vec3(0.5); // Currently render just a gray color
	}
}