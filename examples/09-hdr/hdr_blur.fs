
#extension GL_GOOGLE_include_directive : enable
#include "common.glsl"

layout(location = 0) in vec2 v_texcoord0;
layout(location = 1) in vec4 v_texcoord1;
layout(location = 2) in vec4 v_texcoord2;
layout(location = 3) in vec4 v_texcoord3;
layout(location = 4) in vec4 v_texcoord4;
layout(location = 0) out vec4 outcolor;

layout(binding = 0) uniform sampler2D s_texColor;

void main()
{
	outcolor = blur9(s_texColor, v_texcoord0, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4);
}
