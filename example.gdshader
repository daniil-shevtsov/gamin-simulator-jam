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

vec4 grain(vec2 uv, vec2 screenUv, vec4 color) {
	//Produce some noise based on the coords
	float grain = fract(sin(dot(screenUv.xy, vec2(17.0,180.)))* 2500. + TIME);
    vec3 grainPlate = vec3(grain);

    //Mix the two signals together
    vec3 mixer = mix(color.rgb, grainPlate, .1);
	
	return vec4(mixer, 1);
}

vec4 chromaticAbberation(vec2 uv, vec2 screenUv, vec2 viewportSize) {
	float shrink_width = 2.0 / width;
	float shrink_height = 2.0 / height;
	float abberationDist = distance(vec2(uv.x * shrink_width, uv.y * shrink_height), vec2(0.5 * shrink_width, 0.5 * shrink_height));
	
	vec2 SCREEN_PIXEL_SIZE = 1.0/viewportSize;
	float r = texture(SCREEN_TEXTURE, screenUv + vec2(SCREEN_PIXEL_SIZE*r_displacement), 0.0).r;
	float g = texture(SCREEN_TEXTURE, screenUv + vec2(SCREEN_PIXEL_SIZE*g_displacement), 0.0).g;
	float b = texture(SCREEN_TEXTURE, screenUv + vec2(SCREEN_PIXEL_SIZE*b_displacement), 0.0).b;
	vec4 abberationResult = vec4(r, g, b, abberationDist - fade);
	
	return abberationResult;
}

vec4 vignette(vec2 uv) {
	float dist = distance(uv, vec2(0.5));
	
	float vignette = smoothstep(inner_radius, outer_radius, dist) * vignette_strength;
	float dither = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123) * dither_strength;
	
	return vec4(vignette_color.rgb, vignette + dither);
}


void fragment() {
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	ALBEDO = screen_color;
	//vec4 vignetteResult = vignette(UV);
	//ALBEDO = vignetteResult.rgb;
	//ALPHA = vignetteResult.a;
	//
	vec4 abberationResult = chromaticAbberation(UV, SCREEN_UV, VIEWPORT_SIZE);
    ALBEDO = abberationResult.rgb; 
	ALPHA = abberationResult.a;
	
	vec4 grainResult = grain(UV, SCREEN_UV, vec4(ALBEDO, ALPHA));

    ALBEDO = grainResult.rgb; 
	ALPHA = 1.0f;
	

}