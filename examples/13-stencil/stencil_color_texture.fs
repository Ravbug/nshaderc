#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

uniform vec4 u_color;

layout(binding = 0) uniform sampler2D s_texColor;

layout(location = 0) in vec2 v_texcoord0;
layout(location = 0) out vec4 outcoolor;

void main()
{
	vec4 color = toLinear(texture(s_texColor, v_texcoord0) );

	if (color.x < 0.1)
	{
		discard;
	}

	outcoolor = toGamma(color + u_color);
}
