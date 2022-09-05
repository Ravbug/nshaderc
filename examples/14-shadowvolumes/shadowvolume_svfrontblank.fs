#extension GL_GOOGLE_include_directive : enable

/*
 * Copyright 2013-2014 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"
layout(location=0) out vec4 outcolor;

void main()
{
	outcolor.xyz = vec3_splat(0.0);
	outcolor.w = 1.0;
}
