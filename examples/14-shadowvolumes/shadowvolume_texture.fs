#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec2 v_texcoord0;
layout(location=0) out vec4 outcolor;


/*
 * Copyright 2013-2014 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"
SAMPLER2D(s_texColor, 0);

void main()
{
	outcolor = texture2D(s_texColor, v_texcoord0);
}
