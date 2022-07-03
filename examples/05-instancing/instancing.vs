#version 460
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec4 a_color0;
layout(location = 1) in vec3 a_position;
layout(location = 2) in vec4 i_data0;
layout(location = 3) in vec4 i_data1;
layout(location = 4) in vec4 i_data2;
layout(location = 5) in vec4 i_data3;
layout(location = 6) in vec4 i_data4;

layout(location = 0) out vec4 v_color0;

void main()
{
	mat4 model = mat4(i_data0, i_data1, i_data2, i_data3);
	
	vec4 worldPos = model * vec4(a_position, 1.0);
	gl_Position = u_viewProj * worldPos;
	v_color0 = a_color0 * i_data4;
}

