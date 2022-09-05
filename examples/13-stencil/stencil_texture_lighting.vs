#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec4 a_normal;
layout(location = 2) in vec2 a_texcoord0;

layout(location = 0) out vec3 v_normal;
layout(location = 1) out vec3 v_view;
layout(location = 2) out vec2 v_texcoord0;

void main()
{
	gl_Position = u_modelViewProj * vec4(a_position, 1.0);

	vec4 normal = a_normal * 2.0 - 1.0;
	v_normal = (u_modelView * vec4(normal.xyz, 0.0) ).xyz;
	v_view   = (u_modelView * vec4(a_position, 1.0) ).xyz;

	v_texcoord0 = a_texcoord0;
}
