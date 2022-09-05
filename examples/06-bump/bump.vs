
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec4 a_normal;
layout(location = 1) in vec3 a_position;
layout(location = 2) in vec4 a_tangent;
layout(location = 3) in vec2 a_texcoord0;

layout(location = 0) out vec3 v_bitangent;
layout(location = 1) out vec3 v_normal;
layout(location = 2) out vec3 v_tangent;
layout(location = 3) out vec2 v_texcoord0;
layout(location = 4) out vec3 v_view;
layout(location = 5) out vec3 v_wpos;

void main()
{
	vec3 wpos = (u_model[0] * vec4(a_position, 1.0)).xyz;
	v_wpos = wpos;
	
	gl_Position = u_viewProj * vec4(wpos, 1.0);
	
	vec4 normal = a_normal * 2.0 - 1.0;
	vec4 tangent = a_tangent * 2.0 - 1.0;
	
	vec3 wnormal = (u_model[0] * vec4(normal.xyz, 0.0)).xyz;
	vec3 wtangent = (u_model[0] * vec4(tangent.xyz, 0.0)).xyz;
	
	v_normal = normalize(wnormal);
	v_tangent = normalize(wtangent);
	v_bitangent = cross(v_normal, v_tangent) * tangent.w;
	
	mat3 tbn;
	tbn[0] = v_tangent;
	tbn[1] = v_bitangent;
	tbn[2] = v_normal;
	
	// eye position in world space
	vec3 weyepos = (vec4(0.0, 0.0, 0.0, 1.0) * u_view).xyz;
	// tangent space view dir
	v_view = weyepos - wpos * tbn;
	v_texcoord0 = a_texcoord0;
}
