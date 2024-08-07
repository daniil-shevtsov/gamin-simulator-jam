shader_type spatial;

uniform sampler2D circle_image;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//vec4 sampled = texture(circle_image, UV);
	//
	//ALBEDO = sampled.rgb;
	//if(sampled.rgb == vec3(1.)) {
		//ALPHA = 0.;
	//} else {
		//ALPHA = sampled.a;
	//}
	vec4 color = texture(circle_image, UV);
    
    // Check if the pixel is white
    if (color.r > 0.5 && color.g > 0.5 && color.b > 0.5) {
        color.a = 0.0; // Make white pixels transparent
    }
    
    ALBEDO = color.rgb;
    ALPHA = color.a;
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
