layout(binding=0) uniform _Global{
	mat4 u_model[32];
	mat4 u_modelView;
	mat4 u_modelViewProj;
	mat4 u_viewProj;
	uniform vec4 u_time;
};

vec3 vec3_splat(float _x) { return vec3(_x, _x, _x); }

#define M_PI 3.1415926538
