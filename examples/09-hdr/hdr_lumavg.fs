#version 460
#extension GL_GOOGLE_include_directive : enable
#include "common.glsl"
#include "../shaderlib.glsl"

layout(location = 0) in vec2 v_texcoord0;
layout(location = 0) out vec4 outcolor;

layout(binding = 0) uniform sampler2D s_texColor;

void main()
{
	float sum;
	sum  = decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 0].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 1].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 2].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 3].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 4].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 5].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 6].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 7].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 8].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[ 9].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[10].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[11].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[12].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[13].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[14].xy) );
	sum += decodeRE8(texture(s_texColor, v_texcoord0+u_offset[15].xy) );
	float avg = sum/16.0;
	outcolor = encodeRE8(avg);
}
