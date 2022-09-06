#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 a_position;

/*
 * Copyright 2013-2014 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"

void main()
{
	gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}