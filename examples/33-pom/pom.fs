#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec2 v_texcoord0;
layout(location=1) in vec3 v_ts_frag_pos;
layout(location=2) in vec3 v_ts_light_pos;
layout(location=3) in vec3 v_ts_view_pos;
layout(location=0) out vec4 outcolor;

#include "../shaderlib.glsl"

SAMPLER2D(s_texColor,  0);
SAMPLER2D(s_texNormal, 1);
SAMPLER2D(s_texDepth,  2);

uniform vec4 u_pomParam;

#define u_shading_type         u_pomParam.x
#define u_show_diffuse_texture u_pomParam.y
#define u_parallax_scale       u_pomParam.z
#define u_num_steps            u_pomParam.w

vec2 parallax_uv(vec2 uv, vec3 view_dir)
{
	float depth_scale = float(u_parallax_scale) / 1000.0;
	if (u_shading_type == 2.0)
	{
		// Parallax mapping
		float depth = texture(s_texDepth, uv).r;
		vec2 p = view_dir.xy * (depth * depth_scale) / view_dir.z;
		return uv - p;
	}
	else
	{
		float layer_depth = 1.0 / float(u_num_steps);
		float cur_layer_depth = 0.0;
		vec2 delta_uv = view_dir.xy * depth_scale / (view_dir.z * u_num_steps);
		vec2 cur_uv = uv;

		float depth_from_tex = texture(s_texDepth, cur_uv).r;

		for (int i = 0; i < 32; i++)
		{
			cur_layer_depth += layer_depth;
			cur_uv -= delta_uv;
			depth_from_tex = texture(s_texDepth, cur_uv).r;
			if (depth_from_tex < cur_layer_depth)
			{
				break;
			}
		}

		if (u_shading_type == 3.0)
		{
			// Steep parallax mapping
			return cur_uv;
		}
		else
		{
			// Parallax occlusion mapping
			vec2 prev_uv = cur_uv + delta_uv;
			float next = depth_from_tex - cur_layer_depth;
			float prev = texture(s_texDepth, prev_uv).r - cur_layer_depth + layer_depth;
			float weight = next / (next - prev);
			return mix(cur_uv, prev_uv, weight);
		}
	}
}

void main()
{
	vec3 light_dir = normalize(v_ts_light_pos - v_ts_frag_pos);
	vec3 view_dir  = normalize(v_ts_view_pos  - v_ts_frag_pos);

	// Only perturb the texture coordinates if a parallax technique is selected
	vec2 uv = (u_shading_type < 2.0) ? v_texcoord0 : parallax_uv(v_texcoord0, view_dir);

	vec3 albedo;
	if (u_show_diffuse_texture == 0.0)
	{
		albedo = vec3(1.0, 1.0, 1.0);
	}
	else
	{
		albedo = texture(s_texColor, uv).rgb;
	}

	vec3 ambient = 0.3 * albedo;

	vec3 normal;

	if (u_shading_type == 0.0)
	{
		normal = vec3(0.0, 0.0, 1.0);
	}
	else
	{
		normal.xy = texture2DBc5(s_texNormal, uv) * 2.0 - 1.0;
		normal.z  = sqrt(1.0 - dot(normal.xy, normal.xy) );
	}

	float diffuse = max(dot(light_dir, normal), 0.0);
    outcolor = vec4(diffuse * albedo + ambient, 1.0);
}
