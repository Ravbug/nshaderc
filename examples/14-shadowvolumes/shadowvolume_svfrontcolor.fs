#extension GL_GOOGLE_include_directive : enable

/*
 * Copyright 2013-2014 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"
uniform vec4 u_color;
layout(location=0) out vec4 outcolor;
 
void main()
{
	outcolor.xyz = u_color.xyz;
	outcolor.w = 0.98;
}
