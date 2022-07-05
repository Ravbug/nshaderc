#version 460
#extension GL_GOOGLE_include_directive : enable
#include "common.glsl"
#include "../shaderlib.glsl"

layout(location = 0) in vec2 v_texcoord0;
layout(location = 0) out vec4 outcolor;

layout(binding = 0) uniform sampler2D s_texColor;
layout(binding = 1) uniform sampler2D s_texLum;

void main()
{
	float lum = clamp(decodeRE8(texture(s_texLum, v_texcoord0) ), 0.1, 0.7);

	vec3 rgb = vec3(0.0, 0.0, 0.0);
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[0].xy) );
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[1].xy) );
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[2].xy) );
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[3].xy) );
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[4].xy) );
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[5].xy) );
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[6].xy) );
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[7].xy) );
	rgb += decodeRGBE8(texture(s_texColor, v_texcoord0+u_offset[8].xy) );

	rgb *= 1.0/9.0;

	float middleGray = u_tonemap.x;
	float whiteSqr   = u_tonemap.y;
	float treshold   = u_tonemap.z;
	float offset     = u_tonemap.w;

	rgb = max(vec3_splat(0.0), rgb - treshold) * middleGray / (lum + 0.0001);
	rgb = reinhard2(rgb, whiteSqr);

	outcolor = toGamma(vec4(rgb, 1.0) );
}
