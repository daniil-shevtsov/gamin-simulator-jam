shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;

uniform float depth_range:hint_range(0.1, 100.0, 0.1);

uniform float inner_radius = 0.1;
uniform float outer_radius = 1;
uniform float vignette_strength = 1.0;
uniform float dither_strength = 10.03;
uniform vec4 vignette_color: source_color;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

float grain (vec2 st) {
    return fract(sin(dot(st.xy, vec2(17.0,180.)))* 2500. + TIME);
}


void fragment() {
	 //Coords
	vec2 uv = SCREEN_UV;
    
	float dist = distance(UV, vec2(0.5));
	
	float vignette = smoothstep(inner_radius, outer_radius, dist) * vignette_strength;
	float dither = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453123) * dither_strength;
	
	ALBEDO = vignette_color.rgb;
	ALPHA = vignette + dither;
	
	
	
    ////Produce some noise based on the coords
    //vec3 grainPlate = vec3(grain(uv));
    //
    ////Get the webcam
   //vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
    //
    ////Mix the two signals together
    //vec3 mixer = mix(screen_color.rgb, grainPlate, .1);
	//
    //
    //ALBEDO = mixer; 
	
	
	
	
	
	//vec2 uv = SCREEN_UV;
	//
	//vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	//vec3 normal = texture(NORMAL_TEXTURE, uv).rgb;
	//float roughness =  texture(NORMAL_TEXTURE, uv).w;
	//
	//float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	//vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	//vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	//view.xyz /= view.w;
	//float linear_depth = -view.z / depth_range;
	//
	//// your code goes here!
	//
	//vec3 fog = vec3(linear_depth);
	//vec3 final_color = fog + screen_color;
	//
	//ALBEDO = final_color;
	
	// example outputs
	
	//ALBEDO = vec3(linear_depth); 	// showing depth texture
	//ALBEDO = normal; 				// showing normal texture
	//ALBEDO = vec3(roughness); 	// showing roughness texture
	//ALBEDO = screen_color;		// showing screen texture
}