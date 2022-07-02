#version 460
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 1) in vec3 a_position;
layout(location = 0) in vec3 a_normal;
layout(location = 2) out vec3 v_pos;
layout(location = 3) out vec3 v_view;
layout(location = 1) out vec3 v_normal;
layout(location = 0) out vec4 v_color0;

void main()
{
	vec3 pos = a_position;
	
	float sx = sin(pos.x*32.0+u_time.x*4.0)*0.5+0.5;
	float cy = cos(pos.y*32.0+u_time.x*4.0)*0.5+0.5;
	vec3 displacement = vec3(sx, cy, sx*cy);
	vec3 normal = a_normal.xyz*2.0 - 1.0;
	
	pos = pos + normal*displacement*vec3(0.06, 0.06, 0.06);
	
	gl_Position = u_modelViewProj * vec4(pos, 1.0);
	v_pos = gl_Position.xyz;
	v_view = (u_modelView * vec4(pos, 1.0) ).xyz;
	
	v_normal = (u_modelView * vec4(normal, 0.0)).xyz;
	
	float len = length(displacement)*0.4+0.6;
	v_color0 = vec4(len, len, len, 1.0);
}

