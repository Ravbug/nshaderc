uniform mat4 u_model[32];
uniform mat4 u_modelView;
uniform mat4 u_modelViewProj;
uniform mat4 u_viewProj;
uniform mat4 u_proj;
uniform	mat4 u_view;
uniform	vec4 u_viewTexel;
uniform	vec4 u_viewRect;
uniform	vec4 u_time;

#define M_PI 3.1415926538
#define saturate(_x) clamp(_x, 0.0, 1.0)

vec2 vec2_splat(float _x) { return vec2(_x, _x); }
vec3 vec3_splat(float _x) { return vec3(_x, _x, _x); }
vec4 vec4_splat(float _x) { return vec4(_x, _x, _x, _x); }

// for compatibility with old-style bgfx shaders
// avoid using this, instead use the * operator directly
#define mul(_a, _b) ( (_a) * (_b) )
#define texture2D texture
#define texture3D texture
#define SAMPLER2DSHADOW(name,b) layout(binding=b) uniform sampler2DShadow name
#define SAMPLER2D(name,b) layout(binding=b) uniform sampler2D name
#define SAMPLER3D(name,b) layout(binding=b) uniform sampler3D name
#define SAMPLERCUBE(name,b) layout(binding=b) uniform samplerCube name

float decodeRE8(vec4 _re8)
{
	float exponent = _re8.w * 255.0 - 128.0;
	return _re8.x * exp2(exponent);
}

vec4 encodeRE8(float _r)
{
	float exponent = ceil(log2(_r) );
	return vec4(_r / exp2(exponent)
				, 0.0
				, 0.0
				, (exponent + 128.0) / 255.0
				);
}

vec4 encodeRGBE8(vec3 _rgb)
{
	vec4 rgbe8;
	float maxComponent = max(max(_rgb.x, _rgb.y), _rgb.z);
	float exponent = ceil(log2(maxComponent) );
	rgbe8.xyz = _rgb / exp2(exponent);
	rgbe8.w = (exponent + 128.0) / 255.0;
	return rgbe8;
}

vec3 decodeRGBE8(vec4 _rgbe8)
{
	float exponent = _rgbe8.w * 255.0 - 128.0;
	vec3 rgb = _rgbe8.xyz * exp2(exponent);
	return rgb;
}

vec3 luma(vec3 _rgb)
{
	float yy = dot(vec3(0.2126729, 0.7151522, 0.0721750), _rgb);
	return vec3_splat(yy);
}

vec4 luma(vec4 _rgba)
{
	return vec4(luma(_rgba.xyz), _rgba.w);
}

vec3 convertRGB2XYZ(vec3 _rgb)
{
	// Reference(s):
	// - RGB/XYZ Matrices
	//   https://web.archive.org/web/20191027010220/http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
	vec3 xyz;
	xyz.x = dot(vec3(0.4124564, 0.3575761, 0.1804375), _rgb);
	xyz.y = dot(vec3(0.2126729, 0.7151522, 0.0721750), _rgb);
	xyz.z = dot(vec3(0.0193339, 0.1191920, 0.9503041), _rgb);
	return xyz;
}

vec3 convertXYZ2RGB(vec3 _xyz)
{
	vec3 rgb;
	rgb.x = dot(vec3( 3.2404542, -1.5371385, -0.4985314), _xyz);
	rgb.y = dot(vec3(-0.9692660,  1.8760108,  0.0415560), _xyz);
	rgb.z = dot(vec3( 0.0556434, -0.2040259,  1.0572252), _xyz);
	return rgb;
}

vec3 convertXYZ2Yxy(vec3 _xyz)
{
	// Reference(s):
	// - XYZ to xyY
	//   https://web.archive.org/web/20191027010144/http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_xyY.html
	float inv = 1.0/dot(_xyz, vec3(1.0, 1.0, 1.0) );
	return vec3(_xyz.y, _xyz.x*inv, _xyz.y*inv);
}

vec3 convertYxy2XYZ(vec3 _Yxy)
{
	// Reference(s):
	// - xyY to XYZ
	//   https://web.archive.org/web/20191027010036/http://www.brucelindbloom.com/index.html?Eqn_xyY_to_XYZ.html
	vec3 xyz;
	xyz.x = _Yxy.x*_Yxy.y/_Yxy.z;
	xyz.y = _Yxy.x;
	xyz.z = _Yxy.x*(1.0 - _Yxy.y - _Yxy.z)/_Yxy.z;
	return xyz;
}

vec3 convertRGB2Yxy(vec3 _rgb)
{
	return convertXYZ2Yxy(convertRGB2XYZ(_rgb) );
}

vec3 convertYxy2RGB(vec3 _Yxy)
{
	return convertXYZ2RGB(convertYxy2XYZ(_Yxy) );
}

vec3 convertRGB2Yuv(vec3 _rgb)
{
	vec3 yuv;
	yuv.x = dot(_rgb, vec3(0.299, 0.587, 0.114) );
	yuv.y = (_rgb.x - yuv.x)*0.713 + 0.5;
	yuv.z = (_rgb.z - yuv.x)*0.564 + 0.5;
	return yuv;
}

vec3 convertYuv2RGB(vec3 _yuv)
{
	vec3 rgb;
	rgb.x = _yuv.x + 1.403*(_yuv.y-0.5);
	rgb.y = _yuv.x - 0.344*(_yuv.y-0.5) - 0.714*(_yuv.z-0.5);
	rgb.z = _yuv.x + 1.773*(_yuv.z-0.5);
	return rgb;
}

vec3 convertRGB2YIQ(vec3 _rgb)
{
	vec3 yiq;
	yiq.x = dot(vec3(0.299,     0.587,     0.114   ), _rgb);
	yiq.y = dot(vec3(0.595716, -0.274453, -0.321263), _rgb);
	yiq.z = dot(vec3(0.211456, -0.522591,  0.311135), _rgb);
	return yiq;
}

vec3 convertYIQ2RGB(vec3 _yiq)
{
	vec3 rgb;
	rgb.x = dot(vec3(1.0,  0.9563,  0.6210), _yiq);
	rgb.y = dot(vec3(1.0, -0.2721, -0.6474), _yiq);
	rgb.z = dot(vec3(1.0, -1.1070,  1.7046), _yiq);
	return rgb;
}

vec3 toLinear(vec3 _rgb)
{
	return pow(abs(_rgb), vec3_splat(2.2) );
}

vec4 toLinear(vec4 _rgba)
{
	return vec4(toLinear(_rgba.xyz), _rgba.w);
}

vec3 toLinearAccurate(vec3 _rgb)
{
	vec3 lo = _rgb / 12.92;
	vec3 hi = pow( (_rgb + 0.055) / 1.055, vec3_splat(2.4) );
	vec3 rgb = mix(hi, lo, vec3(lessThanEqual(_rgb, vec3_splat(0.04045) ) ) );
	return rgb;
}

vec4 toLinearAccurate(vec4 _rgba)
{
	return vec4(toLinearAccurate(_rgba.xyz), _rgba.w);
}

float toGamma(float _r)
{
	return pow(abs(_r), 1.0/2.2);
}

vec3 toGamma(vec3 _rgb)
{
	return pow(abs(_rgb), vec3_splat(1.0/2.2) );
}

vec4 toGamma(vec4 _rgba)
{
	return vec4(toGamma(_rgba.xyz), _rgba.w);
}

vec3 toGammaAccurate(vec3 _rgb)
{
	vec3 lo  = _rgb * 12.92;
	vec3 hi  = pow(abs(_rgb), vec3_splat(1.0/2.4) ) * 1.055 - 0.055;
	vec3 rgb = mix(hi, lo, vec3(lessThanEqual(_rgb, vec3_splat(0.0031308) ) ) );
	return rgb;
}

vec4 toGammaAccurate(vec4 _rgba)
{
	return vec4(toGammaAccurate(_rgba.xyz), _rgba.w);
}

vec3 toReinhard(vec3 _rgb)
{
	return toGamma(_rgb/(_rgb+vec3_splat(1.0) ) );
}

vec4 toReinhard(vec4 _rgba)
{
	return vec4(toReinhard(_rgba.xyz), _rgba.w);
}

vec3 toFilmic(vec3 _rgb)
{
	_rgb = max(vec3_splat(0.0), _rgb - 0.004);
	_rgb = (_rgb*(6.2*_rgb + 0.5) ) / (_rgb*(6.2*_rgb + 1.7) + 0.06);
	return _rgb;
}

vec4 toFilmic(vec4 _rgba)
{
	return vec4(toFilmic(_rgba.xyz), _rgba.w);
}

vec3 toAcesFilmic(vec3 _rgb)
{
	// Reference(s):
	// - ACES Filmic Tone Mapping Curve
	//   https://web.archive.org/web/20191027010704/https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
	float aa = 2.51f;
	float bb = 0.03f;
	float cc = 2.43f;
	float dd = 0.59f;
	float ee = 0.14f;
	return saturate( (_rgb*(aa*_rgb + bb) )/(_rgb*(cc*_rgb + dd) + ee) );
}

vec4 toAcesFilmic(vec4 _rgba)
{
	return vec4(toAcesFilmic(_rgba.xyz), _rgba.w);
}

float unpackRgbaToFloat(vec4 _rgba)
{
    const vec4 shift = vec4(1.0 / (256.0 * 256.0 * 256.0), 1.0 / (256.0 * 256.0), 1.0 / 256.0, 1.0);
    return dot(_rgba, shift);
}

vec4 packFloatToRgba(float _value)
{
    const vec4 shift = vec4(256 * 256 * 256, 256 * 256, 256, 1.0);
    const vec4 mask = vec4(0, 1.0 / 256.0, 1.0 / 256.0, 1.0 / 256.0);
    vec4 comp = fract(_value * shift);
    comp -= comp.xxyz * mask;
    return comp;
}


vec3 fixCubeLookup(vec3 _v, float _lod, float _topLevelCubeSize)
{
    // Reference(s):
    // - Seamless cube-map filtering
    //   https://web.archive.org/web/20190411181934/http://the-witness.net/news/2012/02/seamless-cube-map-filtering/
    float ax = abs(_v.x);
    float ay = abs(_v.y);
    float az = abs(_v.z);
    float vmax = max(max(ax, ay), az);
    float scale = 1.0 - exp2(_lod) / _topLevelCubeSize;
    if (ax != vmax) { _v.x *= scale; }
    if (ay != vmax) { _v.y *= scale; }
    if (az != vmax) { _v.z *= scale; }
    return _v;
}

vec2 texture2DBc5(sampler2D _sampler, vec2 _uv)
{
    return texture(_sampler, _uv).xy;
}

// compute things for compatibility with old shaderc...
#define drawIndirect( \
      _buffer         \
    , _offset         \
    , _numVertices    \
    , _numInstances   \
    , _startVertex    \
    , _startInstance  \
    )                 \
    _buffer[(_offset)*2+0] = uvec4(_numVertices, _numInstances, _startVertex, _startInstance)

#define drawIndexedIndirect( \
      _buffer                \
    , _offset                \
    , _numIndices            \
    , _numInstances          \
    , _startIndex            \
    , _startVertex           \
    , _startInstance         \
    )                        \
    _buffer[(_offset)*2+0] = uvec4(_numIndices, _numInstances, _startIndex, _startVertex); \
    _buffer[(_offset)*2+1] = uvec4(_startInstance, 0u, 0u, 0u)

#define dispatchIndirect( \
      _buffer             \
    , _offset             \
    , _numX               \
    , _numY               \
    , _numZ               \
    )                     \
    _buffer[(_offset)*2+0] = uvec4(_numX, _numY, _numZ, 0u)

#define COMPAT_BUFFER_XX(_name, _type, _reg, _access)                \
    layout(std430, binding=_reg) _access buffer _name ## Buffer \
    {                                                           \
        _type _name[];                                          \
    }

#define BUFFER_RO(_name, _type, _reg) COMPAT_BUFFER_XX(_name, _type, _reg, readonly)
#define BUFFER_RW(_name, _type, _reg) COMPAT_BUFFER_XX(_name, _type, _reg, readwrite)
#define BUFFER_WR(_name, _type, _reg) COMPAT_BUFFER_XX(_name, _type, _reg, writeonly)

#define NUM_THREADS(_x, _y, _z) layout (local_size_x = _x, local_size_y = _y, local_size_z = _z) in;

#define COMPAT_IMAGE_XX(_name, _format, _reg, _image, _access) \
    layout(_format, binding=_reg) _access uniform highp _image _name

#define readwrite
#define IMAGE2D_RO( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image2D,  readonly)
#define UIMAGE2D_RO(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage2D, readonly)
#define IMAGE2D_WR( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image2D,  writeonly)
#define UIMAGE2D_WR(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage2D, writeonly)
#define IMAGE2D_RW( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image2D,  readwrite)
#define UIMAGE2D_RW(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage2D, readwrite)

#define IMAGE2D_ARRAY_RO( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image2DArray,  readonly)
#define UIMAGE2D_ARRAY_RO(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage2DArray, readonly)
#define IMAGE2D_ARRAY_WR( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image2DArray,  writeonly)
#define UIMAGE2D_ARRAY_WR(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage2DArray, writeonly)
#define IMAGE2D_ARRAY_RW( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image2DArray,  readwrite)
#define UIMAGE2D_ARRAY_RW(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage2DArray, readwrite)

#define IMAGE3D_RO( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image3D,  readonly)
#define UIMAGE3D_RO(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage3D, readonly)
#define IMAGE3D_WR( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image3D,  writeonly)
#define UIMAGE3D_WR(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage3D, writeonly)
#define IMAGE3D_RW( _name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, image3D,  readwrite)
#define UIMAGE3D_RW(_name, _format, _reg) COMPAT_IMAGE_XX(_name, _format, _reg, uimage3D, readwrite)
