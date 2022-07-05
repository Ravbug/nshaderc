#version 460
#extension GL_GOOGLE_include_directive : enable
#include "common.glsl"
#include "../shaderlib.glsl"

layout(location = 0) in vec2 v_texcoord0;
layout(location = 0) out vec4 outcolor;

layout(binding = 0) uniform samplerCube s_texCube;

layout(binding = 1) uniform ShaderLocal{
	mat4 u_mtx;
};

void main()
{
	vec3 dir = vec3(v_texcoord0*2.0 - 1.0, 1.0);
	dir = normalize((u_mtx * vec4(dir, 0.0)).xyz);
	outcolor = encodeRGBE8(texture(s_texCube, dir).xyz);
}
