#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 a_bitangent;
layout(location=1) in vec3 a_position;
layout(location=2) in vec3 a_tangent;
layout(location=3) in vec2 a_texcoord0;

layout(location=0) out vec2 v_texcoord0;
layout(location=1) out vec3 v_ts_frag_pos;
layout(location=2) out vec3 v_ts_light_pos;
layout(location=3) out vec3 v_ts_view_pos;

uniform mat4 u_norm_mtx;
uniform vec4 u_light_pos;

#include "../shaderlib.glsl"

void main()
{
	vec3 wpos = mul(u_model[0], vec4(a_position, 1.0) ).xyz;
	gl_Position = mul(u_viewProj, vec4(wpos, 1.0) );

	vec3 tangent   = a_tangent   * 2.0 - 1.0;
	vec3 bitangent = a_bitangent * 2.0 - 1.0;
	vec3 normal    = cross(tangent, bitangent);

	vec3 t = normalize(mul(u_norm_mtx, vec4(tangent,   0.0) ).xyz);
	vec3 b = normalize(mul(u_norm_mtx, vec4(bitangent, 0.0) ).xyz);
	vec3 n = normalize(mul(u_norm_mtx, vec4(normal,    0.0) ).xyz);
	mat3 tbn = mat3(t, b, n);

	v_ts_light_pos = (u_light_pos.xyz * tbn);
	// Our camera is always at the origin
	v_ts_view_pos  = (vec3_splat(0.0) * tbn);
	v_ts_frag_pos  = (wpos * tbn);

	v_texcoord0 = a_texcoord0;
}
