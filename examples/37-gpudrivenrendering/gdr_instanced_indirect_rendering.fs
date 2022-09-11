#extension GL_GOOGLE_include_directive : enable

layout(location=0) in float v_materialID;
layout(location=0) out vec4 outcolor;

/*
 * Copyright 2018 Kostas Anagnostou. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"

uniform vec4 u_color[32];

void main()
{
	vec4 color = u_color[uint(v_materialID)];

	if (color.w < 1.0f)
	{
		//render dithered alpha
		if ( (int(gl_FragCoord.x) % 2) == (int(gl_FragCoord.y) % 2) )
		{
			discard;
		}
	}

    outcolor = vec4(color.xyz, 1.0);
}
