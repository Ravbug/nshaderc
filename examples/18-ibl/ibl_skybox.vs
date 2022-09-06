#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 a_position;
layout(location=1) in vec2 a_texcoord0;

layout(location=0) out vec3 v_dir;

/*
 * Copyright 2014-2016 Dario Manesku. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"
#include "uniforms.sh"

uniform mat4 u_mtx;

void main()
{
	gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );

	float fov = radians(45.0);
	float height = tan(fov*0.5);
	float aspect = height*(u_viewRect.z / u_viewRect.w);
	vec2 tex = (2.0*a_texcoord0-1.0) * vec2(aspect, height);

	mat4 mtx;
	mtx[0] = u_mtx0;
	mtx[1] = u_mtx1;
	mtx[2] = u_mtx2;
	mtx[3] = u_mtx3;
	v_dir = (mtx * vec4(tex, 1.0, 0.0) ).xyz;
}
