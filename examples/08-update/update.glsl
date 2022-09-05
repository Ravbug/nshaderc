
#extension GL_GOOGLE_include_directive : enable
#include "../shaderlib.glsl"

layout(rgba8, binding=0) writeonly uniform highp image2DArray s_texColor;
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

void main()
{
	vec3 colors[] =
	{
		vec3(1.0, 0.0, 0.0),
		vec3(1.0, 1.0, 0.0),
		vec3(1.0, 0.0, 1.0),
		vec3(0.0, 1.0, 0.0),
		vec3(0.0, 1.0, 1.0),
		vec3(0.0, 0.0, 1.0),
	};
	
	for (int face = 0; face < 6; face++)
	{
		vec3 color = colors[face]*0.75 + sin(u_time.x*4.0)*0.25;
		ivec3 dest = ivec3(gl_GlobalInvocationID.xy, face);
		imageStore(s_texColor, dest, vec4(color, 1.0) );
	}
}
