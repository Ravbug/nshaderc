#extension GL_GOOGLE_include_directive : enable

layout(location=0) in vec3 v_position;
layout(location=1) in vec2 v_texcoord0;
layout(location=0) out vec4 outcolor;

/*
 * Copyright 2015 Andrew Mac. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#include "../shaderlib.glsl"

void main()
{
    outcolor = vec4(v_texcoord0.x, v_texcoord0.y, v_position.y / 50.0, 1.0);
}
