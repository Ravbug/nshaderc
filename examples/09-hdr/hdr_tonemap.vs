
#extension GL_GOOGLE_include_directive : enable
#include "common.glsl"
#include "../shaderlib.glsl"

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec2 a_texcoord0;

layout(location = 0) out vec2 v_texcoord0;
layout(location = 1) out vec4 v_texcoord1;
layout(location = 2) out vec4 v_texcoord2;
layout(location = 3) out vec4 v_texcoord3;
layout(location = 4) out vec4 v_texcoord4;

void main()
{
	float offset = u_viewTexel.x*8.0;

	gl_Position = u_modelViewProj * vec4(a_position, 1.0);
	v_texcoord0 = a_texcoord0;
	v_texcoord1 = vec4(a_texcoord0.x - offset*1.0, a_texcoord0.y,
					   a_texcoord0.x + offset*1.0, a_texcoord0.y
					  );
	v_texcoord2 = vec4(a_texcoord0.x - offset*2.0, a_texcoord0.y,
					   a_texcoord0.x + offset*2.0, a_texcoord0.y
					  );
	v_texcoord3 = vec4(a_texcoord0.x - offset*3.0, a_texcoord0.y,
					   a_texcoord0.x + offset*3.0, a_texcoord0.y
					  );
	v_texcoord4 = vec4(a_texcoord0.x - offset*4.0, a_texcoord0.y,
					   a_texcoord0.x + offset*4.0, a_texcoord0.y
					  );
}
