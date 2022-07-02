#version 460
layout(binding=0) uniform _Global{
	mat4 u_model[32];
	mat4 u_modelViewProj;
};
layout(location = 0) in vec3 a_color0;
layout(location = 1) in vec3 a_normal;
layout(location = 2) in vec3 a_position;
layout(location = 0) out vec3 v_color0;
layout(location = 1) out vec3 v_normal;

void main(){
    gl_Position = u_modelViewProj * vec4(a_position, 1.0);
    v_normal = (u_model[0] * vec4(a_normal, 0.0)).xyz;
    v_color0 = a_color0;
}
