
#extension GL_GOOGLE_include_directive : enable
#include "common.glsl"
#include "../shaderlib.glsl"

layout(location = 0) in vec2 v_texcoord0;
layout(location = 0) out vec4 outcolor;

layout(binding = 0) uniform sampler2D s_texColor;

void main()
{
	float delta = 0.0001;

	vec3 rgb0 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[0].xy) );
	vec3 rgb1 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[1].xy) );
	vec3 rgb2 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[2].xy) );
	vec3 rgb3 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[3].xy) );
	vec3 rgb4 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[4].xy) );
	vec3 rgb5 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[5].xy) );
	vec3 rgb6 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[6].xy) );
	vec3 rgb7 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[7].xy) );
	vec3 rgb8 = decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[8].xy) );
	float avg = luma(rgb0).x
			  + luma(rgb1).x
			  + luma(rgb2).x
			  + luma(rgb3).x
			  + luma(rgb4).x
			  + luma(rgb5).x
			  + luma(rgb6).x
			  + luma(rgb7).x
			  + luma(rgb8).x
			  ;
	avg *= 1.0/9.0;

	outcolor = encodeRE8(avg);
}
