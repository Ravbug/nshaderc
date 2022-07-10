#version 460
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec2 a_texcoord0;

layout(location = 0) out vec2 v_texcoord0;

void main()
{
	gl_Position = u_modelViewProj * vec4(a_position, 1.0);

    v_texcoord0 = a_texcoord0;
}
