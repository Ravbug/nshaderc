#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 v_dir;
layout(location=0) out vec4 outcolor;

/*
 * Copyright 2014-2016 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"
#include "uniforms.sh"

SAMPLERCUBE(s_texCube, 0);
SAMPLERCUBE(s_texCubeIrr, 1);

void main()
{
	vec3 dir = normalize(v_dir);

	vec4 color;
	if (u_bgType == 7.0)
	{
		color = toLinear(texture(s_texCubeIrr, dir));
	}
	else
	{
		float lod = u_bgType;
		dir = fixCubeLookup(dir, lod, 256.0);
		color = toLinear(textureLod(s_texCube, dir, lod));
	}
	color *= exp2(u_exposure);

	outcolor = toFilmic(color);
}
