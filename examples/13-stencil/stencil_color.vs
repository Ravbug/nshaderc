#version 460
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec3 a_position;

void main()
{
	gl_Position = u_modelViewProj * vec4(a_position, 1.0);
}
