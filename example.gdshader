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

uniform float height: hint_range(0.1, 1.0, 0.1) = 0.7;
uniform float width: hint_range(0.1, 1.0, 0.1) = 0.5;

uniform 	float fade = 0.7;

uniform float grain_amount : hint_range(0.0, 1.0) = 0.05; // Adjust the amount of grain
uniform float grain_size : hint_range(0.1, 10.0) = 1.0; // Adjust the size of the grain

uniform float vignette_mix : hint_range(0.0, 1.0, 0.1) = 1.;


uniform float vignetteGrainMixAmount: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float grainMixAmount: hint_range(0.0, 1.0, 0.1) = 0.1;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

vec4 grain(vec2 uv, vec2 screenUv, vec4 color) {
	//Produce some noise based on the coords
	float grain = fract(sin(dot(screenUv.xy, vec2(17.0,180.)))* 2500. + TIME);
    vec4 grainPlate = vec4(vec3(grain), 1.);

    //Mix the two signals together
    vec4 mixer = mix(color, grainPlate, grainMixAmount);
	
	return mixer;
}

vec4 chromaticAbberation(sampler2D screenTexture, vec2 uv, vec2 screenUv, vec2 viewportSize,) {
	float shrink_width = 2.0 / width;
	float shrink_height = 2.0 / height;
	float abberationDist = distance(vec2(uv.x * shrink_width, uv.y * shrink_height), vec2(0.5 * shrink_width, 0.5 * shrink_height));
	
	vec2 SCREEN_PIXEL_SIZE = 1.0/viewportSize;
	float r = texture(screenTexture, screenUv + vec2(SCREEN_PIXEL_SIZE*r_displacement), 0.0).r;
	float g = texture(screenTexture, screenUv + vec2(SCREEN_PIXEL_SIZE*g_displacement), 0.0).g;
	float b = texture(screenTexture, screenUv + vec2(SCREEN_PIXEL_SIZE*b_displacement), 0.0).b;
	vec4 abberationResult = vec4(r, g, b, abberationDist - fade);
	
	return abberationResult;
}

vec4 vignette(vec2 uv, vec4 current_color) {
    float dist = distance(uv, vec2(0.5, 0.5));
    
    float vignette = smoothstep(inner_radius, outer_radius, dist) * vignette_strength;
    float dither = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123 + sin(TIME/10.)) * dither_strength;
    
    vec3 vignetteEffect = current_color.rgb * (1.0 - vignette + dither);
    
    return  vec4(vignetteEffect, current_color.a);
}


void fragment() {
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	ALBEDO = screen_color;
	ALPHA = 1.;
	
	vec4 abberationResult = chromaticAbberation(SCREEN_TEXTURE, UV, SCREEN_UV, VIEWPORT_SIZE);

	vec4 vignetteResult = vignette(SCREEN_UV,abberationResult);

	vec4 grainResult = grain(UV, SCREEN_UV, vignetteResult);
    ALBEDO = mix(vignetteResult.rgb, grainResult.rgb, vignetteGrainMixAmount); 
	ALPHA = mix(vignetteResult.a, grainResult.a, vignetteGrainMixAmount);
}