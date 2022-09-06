#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 a_position;
layout(location=1) in vec2 a_texcoord0;

layout(location=0) out vec3 v_position;
layout(location=1) out vec2 v_texcoord0;

/*
 * Copyright 2015 Andrew Mac. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"

SAMPLER2D(s_heightTexture, 0);

void main()
{
	v_texcoord0 = a_texcoord0;
	v_position = a_position.xyz;
	v_position.y = textureLod(s_heightTexture, a_texcoord0, 0).x * 255.0;

	gl_Position = mul(u_modelViewProj, vec4(v_position.xyz, 1.0));
}
