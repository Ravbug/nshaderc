
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

uniform vec4 u_lightPosRadius[4];
uniform	vec4 u_lightRgbInnerR[4];

layout(binding = 0) uniform sampler2D s_texColor;
layout(binding = 1) uniform sampler2D s_texNormal;

layout(location = 0) in vec3 v_bitangent;
layout(location = 1) in vec3 v_normal;
layout(location = 2) in vec3 v_tangent;
layout(location = 3) in vec2 v_texcoord0;
layout(location = 4) in vec3 v_view;
layout(location = 5) in vec3 v_wpos;

layout(location = 0) out vec4 outcolor;

vec2 blinn(vec3 _lightDir, vec3 _normal, vec3 _viewDir)
{
	float ndotl = dot(_normal, _lightDir);
	vec3 reflected = 2.0 * ndotl * _normal - _lightDir;
	float rdotv = dot(reflected, _viewDir);
	return vec2(ndotl, rdotv);
}

float fresnel(float _ndotl, float _bias, float _pow)
{
	float facing = (1.0 - _ndotl);
	return max(_bias + (1.0 - _bias) * pow(facing, _pow), 0.0);
}

vec4 lit(float _ndotl, float _rdotv, float _m)
{
	float diff = max(0.0, _ndotl);
	float spec = step(0.0, _ndotl) * max(0.0, _rdotv * _m);
	return vec4(1.0, diff, spec, 1.0);
}

vec4 powRgba(vec4 _rgba, float _pow)
{
	vec4 result;
	result.xyz = pow(_rgba.xyz, vec3_splat(_pow) );
	result.w = _rgba.w;
	return result;
}

vec3 calcLight(int _idx, mat3 _tbn, vec3 _wpos, vec3 _normal, vec3 _view)
{
	vec3 lp = u_lightPosRadius[_idx].xyz - _wpos;
	float attn = 1.0 - smoothstep(u_lightRgbInnerR[_idx].w, 1.0, length(lp) / u_lightPosRadius[_idx].w);
	vec3 lightDir =  normalize(lp) * _tbn;
	vec2 bln = blinn(lightDir, _normal, _view);
	vec4 lc = lit(bln.x, bln.y, 1.0);
	vec3 rgb = u_lightRgbInnerR[_idx].xyz * saturate(lc.y) * attn;
	return rgb;
}

void main()
{
	mat3 tbn;
	tbn[0] = v_tangent;
	tbn[1] = v_bitangent;
	tbn[2] = v_normal;
	
	vec3 normal;
	normal.xy = texture(s_texNormal, v_texcoord0).xy * 2.0 - 1.0;
	normal.z = sqrt(1.0 - dot(normal.xy, normal.xy) );
	vec3 view = normalize(v_view);
	
	vec3 lightColor;
	lightColor =  calcLight(0, tbn, v_wpos, normal, view);
	lightColor += calcLight(1, tbn, v_wpos, normal, view);
	lightColor += calcLight(2, tbn, v_wpos, normal, view);
	lightColor += calcLight(3, tbn, v_wpos, normal, view);
	
	vec4 color = toLinear(texture(s_texColor, v_texcoord0) );
	
	outcolor.xyz = max(vec3_splat(0.05), lightColor.xyz)*color.xyz;
	outcolor.w = 1.0;
	outcolor = toGamma(outcolor);
}
