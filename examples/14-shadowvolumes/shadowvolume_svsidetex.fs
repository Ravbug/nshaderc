#extension GL_GOOGLE_include_directive : enable

layout(location=0) in float v_k;

/*
 * Copyright 2013-2014 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"

uniform vec4 u_svparams;
layout(location=0) out vec4 outcolor;

#define u_dfail u_svparams.y

vec4 stencilColor(float _k)
{
	return vec4(float(abs(_k - 1.0) < 0.0001)/255.0
			  , float(abs(_k + 1.0) < 0.0001)/255.0
			  , float(abs(_k - 2.0) < 0.0001)/255.0
			  , float(abs(_k + 2.0) < 0.0001)/255.0
			  );
}

void main()
{
	float k = v_k;

	if (!gl_FrontFacing)
		k = -k;

	if (u_dfail == 0.0)
		k = -k;

	outcolor = stencilColor(k);
}
