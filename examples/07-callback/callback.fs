#version 460
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec4 v_color0;
layout(location = 1) in vec3 v_world;
layout(location = 0) out vec4 outcolor;

void main()
{
	vec3 normal = normalize(cross(dFdx(v_world), dFdy(v_world) ) );
	vec3 lightDir = vec3(0.0, 0.0, 1.0);
	float ndotl = max(dot(normal, lightDir), 0.0);
	float spec = pow(ndotl, 30.0);
	outcolor = pow(pow(v_color0, vec4_splat(2.2) ) * ndotl + spec, vec4_splat(1.0/2.2) );
}
