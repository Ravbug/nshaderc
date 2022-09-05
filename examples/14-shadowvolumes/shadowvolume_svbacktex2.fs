#extension GL_GOOGLE_include_directive : enable

/*
 * Copyright 2013-2014 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"
layout(location=0) out vec4 outcolor;

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
	float k = 2.0;
	if (!gl_FrontFacing)
	{
		k = -k;
	}

	outcolor = stencilColor(k);
}
