#version 460
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec4 a_color0;
layout(location = 1) in vec3 a_position;

layout(location = 0) out vec4 v_color0;
layout(location = 1) out vec3 v_world;


void main()
{
	gl_Position = u_modelViewProj * vec4(a_position, 1.0);
	v_world = (u_model[0] * vec4(a_position, 1.0) ).xyz;
	v_color0 = a_color0;
}
