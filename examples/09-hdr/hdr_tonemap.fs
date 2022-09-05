
#extension GL_GOOGLE_include_directive : enable
#include "common.glsl"
#include "../shaderlib.glsl"


layout(location = 0) in vec2 v_texcoord0;
layout(location = 1) in vec4 v_texcoord1;
layout(location = 2) in vec4 v_texcoord2;
layout(location = 3) in vec4 v_texcoord3;
layout(location = 4) in vec4 v_texcoord4;
layout(location = 0) out vec4 outcolor;

layout(binding = 0) uniform sampler2D s_texColor;
layout(binding = 1) uniform sampler2D s_texLum;
layout(binding = 2) uniform sampler2D s_texBlur;

void main()
{
	vec3 rgb = decodeRGBE8(texture(s_texColor, v_texcoord0) );
	float lum = clamp(decodeRE8(texture(s_texLum, v_texcoord0) ), 0.1, 0.7);

	vec3 Yxy = convertRGB2Yxy(rgb);

	float middleGray = u_tonemap.x;
	float whiteSqr   = u_tonemap.y;
	float treshold   = u_tonemap.z;
	float offset     = u_tonemap.w;

	float lp = Yxy.x * middleGray / (lum + 0.0001);
	Yxy.x = reinhard2(lp, whiteSqr);

	rgb = convertYxy2RGB(Yxy);

	vec4 blur = blur9(s_texBlur
					, v_texcoord0
					, v_texcoord1
					, v_texcoord2
					, v_texcoord3
					, v_texcoord4
					);

	rgb += 0.6 * blur.xyz;

	outcolor = toGamma(vec4(rgb, 1.0) );
}
