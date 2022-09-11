#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 a_position;
layout(location=1) in vec4 i_data0;
layout(location=2) in vec4 i_data1;
layout(location=3) in vec4 i_data2;
layout(location=4) in vec4 i_data3;
layout(location=0) out float v_materialID;

/*
 * Copyright 2018 Kostas Anagnostou. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"

void main()
{
	mat4 model;
	model[0] = vec4(i_data0.xyz, 0.0);
	model[1] = i_data1;
	model[2] = i_data2;
	model[3] = i_data3;

	v_materialID = i_data0.w;

	vec4 worldPos = (model * vec4(a_position, 1.0) );
	gl_Position = mul(u_viewProj, worldPos);
}
