
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec3 v_texcoord0;
layout(location = 0) out vec4 outcolor;
layout(binding = 0) uniform sampler3D s_texColor;

void main()
{
	vec3 uvw = vec3(v_texcoord0.xy * 0.5+0.5, sin(u_time.x) * 0.5 + 0.5);
	outcolor = vec4_splat(texture(s_texColor, uvw).x);
}
