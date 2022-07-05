#version 460

layout(location = 0) in vec2 v_texcoord0;
layout(location = 0) out vec4 outcolor;

layout(binding = 1) uniform sampler2D s_texColor;

void main()
{
	outcolor = texture(s_texColor, v_texcoord0.xy * 0.5 + 0.5);
}
