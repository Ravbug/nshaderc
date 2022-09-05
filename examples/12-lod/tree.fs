
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

uniform vec4 u_stipple;

layout(location = 0) in vec3 v_pos;
layout(location = 1) in vec3 v_view;
layout(location = 2) in vec3 v_normal;
layout(location = 3) in vec2 v_texcoord0;
layout(location = 0) out vec4 outcolor;

layout(binding = 0) uniform sampler2D s_texColor;
layout(binding = 1) uniform sampler2D s_texStipple;

vec2 blinn(vec3 _lightDir, vec3 _normal, vec3 _viewDir)
{
	float ndotl = dot(_normal, _lightDir);
	vec3 reflected = _lightDir - 2.0*ndotl*_normal; // reflect(_lightDir, _normal);
	float rdotv = dot(reflected, _viewDir);
	return vec2(ndotl, rdotv);
}

void main()
{
	vec2 viewport = (u_viewRect.zw - u_viewRect.xy) * vec2(1.0/8.0, 1.0/4.0);
	vec2 stippleUV = viewport*(v_pos.xy*0.5 + 0.5);
	vec4 color = texture(s_texColor, v_texcoord0);
	if ( (u_stipple.x - texture(s_texStipple, stippleUV).x)*u_stipple.y > u_stipple.z || color.w < 0.5)
	{
		discard;
	}

	vec3 lightDir = vec3(0.0, 0.0, -1.0);
	vec3 normal = normalize(v_normal);
	vec3 view = normalize(v_view);
	vec2 bln = blinn(lightDir, normal, view);
	float l = saturate(bln.y) + 0.12;

	color.xyz = toLinear(color.xyz)*l;
	outcolor = toGamma(color);
}

