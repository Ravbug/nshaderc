#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 v_texCoord;
layout(location=0) out vec4 outcolor;

/*
 * Copyright 2014 Stanlo Slasinski. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"
#include "uniforms.sh"

void main()
{
	vec3 color = mix(vec3(0.1f, 0.8f, 0.2f), 0.5 *  vec3(0.3, 0.25, 0.05), v_texCoord.z);
	float f = u_particleIntensity * pow(max(1.0 - length(v_texCoord.xy), 0.0), u_particlePower);
    outcolor = vec4(color * f, 1.0);
}
