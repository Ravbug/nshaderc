#version 460
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec3 a_normal;
layout(location = 1) in vec3 a_position;
layout(location = 2) in vec2 a_texcoord0;


layout(location = 0) out vec3 v_pos;
layout(location = 1) out vec3 v_view;
layout(location = 2) out vec3 v_normal;
layout(location = 3) out vec2 v_texcoord0;

void main()
{
	vec3 pos = a_position;

	vec3 normal = a_normal.xyz*2.0 - 1.0;

	gl_Position = u_modelViewProj * vec4(pos, 1.0);
	v_pos = gl_Position.xyz/gl_Position.w;
	v_view = (u_modelView * vec4(pos, 1.0) ).xyz;

	v_normal = (u_modelView * vec4(normal, 0.0) ).xyz;
	v_texcoord0 = a_texcoord0;
}
