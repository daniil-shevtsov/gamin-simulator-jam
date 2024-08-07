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
	vec4 chalk_color = mix(color, vec4(vec3(1.0), 1. - noise.r),  chalk_blend); // Adjust blending as necessary

	ALPHA = (1. - sampled.r) * chalk_color.a;
    ALBEDO = color.rgb;
	//ALPHA = chalk_color.a;
	//ALPHA = 1. - sampled.r;
	//EMISSION = glow_color * glow_intensity * (1. - sampled.r);
    /*if (color.r > 0.5 && color.g > 0.5 && color.b > 0.5) {
        //ALPHA = 0.0; // Make white pixels transparent
    }  else */
	//if (color.r < 0.05 && color.g < 0.05 && color.b < 0.05) {
        //// Make black pixels glow
        //EMISSION = glow_color * glow_intensity;
    //} else {
        //EMISSION = vec3(0.0); // No glow zfor other colors
    //}
	//vec3 debug_color = vec3(UV, 0.0);
	 //ALBEDO = mix(color.rgb, debug_color, 0.);

    
    //ALBEDO = color.rgb;
    //ALPHA = color.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
