shader_type canvas_item;

uniform sampler2D noiseMap;
uniform float height_multiplier = .1;
uniform float noise_sample_size = .1;
uniform float animation_speed = 0.025;

float radius_from_theta(float theta){
	return .5;
}

void fragment() {
	float dx = UV.x - .5;
	float dy = UV.y - .5;
	float r = sqrt(dx*dx+dy*dy);
	float theta = atan(dy,dx);
	float theta01 = theta/TAU + .5;
	COLOR = vec4(245.,255.,0.,float(radius_from_theta(theta01)>r));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
