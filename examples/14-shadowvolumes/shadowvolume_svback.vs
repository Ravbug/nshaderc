#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 a_position;

/*
 * Copyright 2013-2014 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"

uniform vec4 u_virtualLightPos_extrusionDist;

#define u_virtualLightPos   u_virtualLightPos_extrusionDist.xyz
#define u_extrusionDistance u_virtualLightPos_extrusionDist.w

void main()
{
	vec3 pos = a_position;

	vec3 toLight = pos - u_virtualLightPos;
	pos += normalize(toLight) * u_extrusionDistance;

	gl_Position = mul(u_modelViewProj, vec4(pos, 1.0));
}
