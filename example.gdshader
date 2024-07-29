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

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform float height: hint_range(0.0, 1.0, 0.1) = 0.7;
uniform float width: hint_range(0.0, 1.0, 0.1) = 0.5;

uniform 	float fade = 0.7;

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
	
	
	
    //Produce some noise based on the coords
    vec3 grainPlate = vec3(grain(uv));
    vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
    //Mix the two signals together
    vec3 mixer = mix(ALBEDO.rgb, grainPlate, .1);
    ALBEDO = mixer; 
	
	float shrink_width = 2.0 / width;
	float shrink_height = 2.0 / height;
	float abberationDist = distance(vec2(UV.x * shrink_width, UV.y * shrink_height), vec2(0.5 * shrink_width, 0.5 * shrink_height));
	
	vec2 SCREEN_PIXEL_SIZE = 1.0/VIEWPORT_SIZE;
	float r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*r_displacement), 0.0).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*g_displacement), 0.0).g;
	float b = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*b_displacement), 0.0).b;
	
	ALBEDO = vec3(r, g, b);
	ALPHA = abberationDist - fade;
}