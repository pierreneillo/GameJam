shader_type canvas_item;


float noise(float r,float theta,float t){
	return 1.;
}

float intensity(float radius){
	if (radius <= 1.){
		return pow(radius,5.);
	}else{
		return 0.;
	}
}

void fragment() {
	vec4 col = vec4(UV, .5, 1);
	vec4 white = vec4(.9);
	float r = sqrt((UV.x - .5)*(UV.x - .5) + (UV.y - .5)*(UV.y - .5))*2.;
	COLOR = white * intensity(r);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
