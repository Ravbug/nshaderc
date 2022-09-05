
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(location = 0) in vec4 a_normal;
layout(location = 1) in vec3 a_position;
layout(location = 2) in vec4 a_tangent;
layout(location = 3) in vec2 a_texcoord0;
layout(location = 4) in vec4 i_data0;
layout(location = 5) in vec4 i_data1;
layout(location = 6) in vec4 i_data2;
layout(location = 7) in vec4 i_data3;

layout(location = 0) out vec3 v_bitangent;
layout(location = 1) out vec3 v_normal;
layout(location = 2) out vec3 v_tangent;
layout(location = 3) out vec2 v_texcoord0;
layout(location = 4) out vec3 v_view;
layout(location = 5) out vec3 v_wpos;

void main()
{
	mat4 model = mat4(i_data0, i_data1, i_data2, i_data3);
	
	vec3 wpos = (model * vec4(a_position, 1.0)).xyz;
	gl_Position = u_viewProj * vec4(wpos, 1.0);
	
	vec4 normal = a_normal * 2.0 - 1.0;
	vec3 wnormal = (model * vec4(normal.xyz, 0.0) ).xyz;
	
	vec4 tangent = a_tangent * 2.0 - 1.0;
	vec3 wtangent = (model * vec4(tangent.xyz, 0.0) ).xyz;
	
	v_normal = wnormal;
	v_tangent = wtangent;
	v_bitangent = cross(v_normal, v_tangent) * tangent.w;
	
	mat3 tbn = mat3(v_tangent, v_bitangent, v_normal);
	
	v_wpos = wpos;
	
	vec3 weyepos = (vec4(0.0, 0.0, 0.0, 1.0) * u_view).xyz;
	v_view = weyepos - wpos * tbn;
	
	v_texcoord0 = a_texcoord0;
}
