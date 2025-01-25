shader_type spatial;

uniform sampler2D noise_tex;
uniform vec4 bubble_color : source_color;
uniform float height_multiplier = .1;
uniform float noise_sample_size = .1;
uniform float animation_speed = .025;

varying float height;

float fresnel(vec3 normal, mat4 camera_matrix){
	vec3 view_direction_world = (camera_matrix * vec4(0.,0.,1.,0.)).xyz;
	vec3 normal_world = (camera_matrix * vec4(normal,0.)).xyz;
	float d = dot(view_direction_world,normal_world);
	d = abs(d);
	d = clamp(d, 0., 1.);
	
	return 1. - d;
}

void vertex() {  
	height = texture(noise_tex,VERTEX.xz * noise_sample_size + vec2(TIME * animation_speed)).r;
	VERTEX += NORMAL * height * height_multiplier;
}

void fragment(){
	ROUGHNESS = .1;
	SPECULAR = height;
	ALPHA = fresnel(NORMAL,VIEW_MATRIX);
	ALBEDO = bubble_color.rgb;
}
