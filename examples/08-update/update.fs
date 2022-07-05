#version 460

layout(location = 0) in vec3 v_texcoord0;
layout(location = 0) out vec4 outcolor;

layout(binding = 1) uniform samplerCube s_texCube;

void main()
{
	outcolor = texture(s_texCube, v_texcoord0);
}
