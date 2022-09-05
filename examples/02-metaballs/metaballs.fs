
layout(location = 0) in vec3 v_color0;
layout(location = 1) in vec3 v_normal;
layout(location = 0) out vec4 outcolor;

vec3 vec3_splat(float _x) { return vec3(_x, _x, _x); }

void main(){
    const vec3 lightDir = vec3(0.0, 0.0, -1.0);
	const float ndotl = dot(normalize(v_normal), lightDir);
	const float spec = pow(ndotl, 30.0);
	outcolor = vec4(pow(pow(v_color0.xyz, vec3_splat(2.2) ) * ndotl + spec, vec3_splat(1.0/2.2) ), 1.0);

}
