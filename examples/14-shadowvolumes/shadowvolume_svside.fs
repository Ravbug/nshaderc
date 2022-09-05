#extension GL_GOOGLE_include_directive : enable

layout(location=0) in float v_k;

/*
 * Copyright 2013-2014 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"
layout(location=0) out vec4 outcolor;

void main()
{
	float k = v_k;
	if (!gl_FrontFacing)
	{
		k = -k;
	}

	outcolor.xyzw =
		vec4( float(abs(k - 1.0) < 0.0001)/255.0
			, float(abs(k + 1.0) < 0.0001)/255.0
			, float(abs(k - 2.0) < 0.0001)/255.0
			, float(abs(k + 2.0) < 0.0001)/255.0
			);
}
