#include "ShaderWriter.hpp"
#include <fmt/format.h>
#include <string>
#include "MurmurHash.hpp"

void fatal(const std::string& errstr) {
	throw std::runtime_error(errstr);
}

void insertBytes(std::vector<char>& vec, const char* bytes, size_t size) {
	for (size_t i = 0; i < size; i++) {
		vec.push_back(bytes[i]);
	}
}

template<typename T>
void insertItem(std::vector<char>& vec, const T& value) {
	size_t nbytes = sizeof(T);
	const char* bytebegin = reinterpret_cast<const char*>(&value);
	for (size_t i = 0; i < nbytes; i++) {
		vec.push_back(bytebegin[i]);
	}
}

static const std::string_view s_attribName[] =
{
	"a_position",
	"a_normal",
	"a_tangent",
	"a_bitangent",
	"a_color0",
	"a_color1",
	"a_color2",
	"a_color3",
	"a_indices",
	"a_weight",
	"a_texcoord0",
	"a_texcoord1",
	"a_texcoord2",
	"a_texcoord3",
	"a_texcoord4",
	"a_texcoord5",
	"a_texcoord6",
	"a_texcoord7",
};

static uint16_t s_attribToId[] = {
	0x0001,
	0x0002,
	0x0003,
	0x0004,
	0x0005,
	0x0006,
	0x0018,
	0x0019,
	0x000e,
	0x000f,
	0x0010,
	0x0011,
	0x0012,
	0x0013,
	0x0014,
	0x0015,
	0x0016,
	0x0017
};
static_assert(sizeof(s_attribName)/sizeof(s_attribName[0]) == sizeof(s_attribToId)/sizeof(s_attribToId[0]), "length of s_attribName ≠ length of s_attribToId");

/**
The BGFX shader format:

bytes
4b - shader type (VSH, FSH, CSH) and version
4b - input hash (fragment only, 32 bit int 0 for others)
4b - output hash (vertex and compute only, 32 bit int 0 for others)
2b - number of uniforms (uint16_t)
for each uniform: 
{
	1b - length of uniform name (uint8_t)
	?b - Uniform name (up to 256 characters, error if there are more)
	1b - Uniform type bitwiseOR fragmentBit (value = 16)
	1b - size of the uniform according to gl Array Size
	2b - Uniform buffer offset (uint16_t) 
	2b - Uniform reg count (uint16_t) in multiples of vec4 (mat3 is 3, mat4 is 4) (see shaderc_metal.cpp:
	1b - Uniform texComponent (uint8_t) (what is this?)
	1b - Uniform texDimension (uint8_t) (what is this?)
	2b - Uniform texFormat (uint16_t) (what is this?)
}
4b - shader length in bytes (uint32_t)
?b - shader byte data
1b - constant 0 (the null byte)
1b - TProgram::getNumLiveAttributes()
for each TProgram->getAttributeName:
{
	2b - bgfx::attribToId(TProgram attribute) if attribute is not equal to bgfx::Attrib::Count, else UINT16_MAX
}
2b - size of the uniform array (again?)
*/

std::vector<char> makeBGFXShaderBinary(const shadert::CompileResult& result, shadert::ShaderStage stage) {
	std::vector<char> output;
	output.reserve(result.data.sourceData.size() + 100);

	bool isFragmentShader = stage == decltype(stage)::Fragment;

	constexpr uint8_t kUniformFragmentBit = 0x10;
	
	// first 4 bytes are 'VSH\v', 'FSH\v' or 'CSH\v' depending on the shader type 
	// the 4th byte is the shader version 

	switch (stage) {
	case decltype(stage)::Vertex:
		insertBytes(output, "VSH\v", 4);
		break;
	case decltype(stage)::Fragment:
		insertBytes(output, "FSH\v", 4);
		break;
	case decltype(stage)::Compute:
		insertBytes(output, "CSH\v", 4);
		break;
	default:
		fatal(fmt::format("Shader stage not supported: {}",(int)stage));
	}

	// then write the input and output hashes
	auto calcHashFor = [](const auto& container) -> uint32_t {
		HashMurmur2A murmur;
		murmur.begin();
		for (const auto& item : container) {
			murmur.add(item.name.c_str(), uint32_t(item.name.length()));
		}
		auto hash = murmur.end();
		return hash;
	};
	uint32_t inputHash = (stage == decltype(stage)::Fragment)? calcHashFor(result.data.reflectData.stage_inputs) : uint32_t(0);
	uint32_t outputHash = (stage == decltype(stage)::Fragment) ? uint32_t(0) : calcHashFor(result.data.reflectData.stage_outputs);
	insertItem(output, inputHash);	// input hash
	insertItem(output, outputHash);	// output hash
	
	auto uniformData = std::move(result.data.uniformData);
	
	// need to add Separate Images to the Uniform data
	for(const auto& item : result.data.reflectData.separate_images){
		decltype(uniformData)::value_type uniform;
		uniform.name = item.name;
		uniform.glDefineType = 0x1404;	// the ID for samplers
		
		// on metal these should be set to 0
		uniform.arraySize = 0;
		uniform.bufferOffset = 0;
		
		uniformData.push_back(uniform);
	}

	// next write the uniform data
	insertItem(output, uint16_t(uniformData.size()));		// number of uniforms
	// switch on uniform.glDefineType to convert to bgfx enum for writing, and error on unkown types instead of writing UniformType::End
	uint16_t uniformDataSize = 0;
	for (const auto& uniform : uniformData) {
		insertItem(output, uint8_t(uniform.name.length()));				 // uniform name length
		insertBytes(output, uniform.name.c_str(),uniform.name.length()); // uniform name

		uint8_t bgfx_type = 0;
		uint16_t regCount = uniform.arraySize;
		struct UniformType
		{
			/// Uniform types:
			enum Enum
			{
				Sampler, //!< Sampler.
				End,     //!< Reserved, do not use.

				Vec4,    //!< 4 floats vector.
				Mat3,    //!< 3x3 matrix.
				Mat4,    //!< 4x4 matrix.

				Count
			};
		};

		switch (uniform.glDefineType)
		{
			case 0x1404: // GL_INT:
			case 0x8B5E:
			case 0x8b60:
			case 0x8b5f:
			case 0x9053:
            case 0x8b62:
				bgfx_type = UniformType::Sampler;
				break;
			case 0x8B52: // GL_FLOAT_VEC4:
				bgfx_type = UniformType::Vec4;
				break;
			case 0x8B5B: // GL_FLOAT_MAT3:
				bgfx_type = UniformType::Mat3;
				regCount *= 3;
				break;
			case 0x8B5C: // GL_FLOAT_MAT4:
				bgfx_type = UniformType::Mat4;
				regCount *= 4;
				break;
			default:
				fatal(fmt::format("Invalid Uniform type (0x{:x}) for Uniform \"{}\" ",uniform.glDefineType,uniform.name));
		}
		uint32_t fragmentBit = isFragmentShader ? kUniformFragmentBit : 0;
		insertItem(output, uint8_t(bgfx_type | fragmentBit));			// fragment bit + type
		insertItem(output, uint8_t(uniform.arraySize));					// array buffer size
		insertItem(output, uint16_t(uniform.bufferOffset));				// buffer offset
		insertItem(output, regCount);									// regCount
		insertItem(output, uint8_t(uniform.texComponent));				// texComponent
		insertItem(output, uint8_t(uniform.texDimension));				// texDimension
		insertItem(output, uint16_t(uniform.texFormat));				// texFormat
		uniformDataSize += regCount * 16;
	}

	// then write the shader data itself
	const std::string& shaderData = result.data.binaryData.size() > 0 ? result.data.binaryData : result.data.sourceData;
	insertItem(output, uint32_t(shaderData.size()));	// shader size
	insertBytes(output, shaderData.data(), shaderData.size());
	output.push_back('\0');	// null terminator

	// write LiveAttribute data
	insertItem(output, uint8_t(result.data.attributeData.size()));	// number of attributes
	for (const auto& attribute : result.data.attributeData) {
		auto index = std::distance(std::begin(s_attribName), std::find(std::begin(s_attribName), std::end(s_attribName), attribute.name.c_str()));
		if (index >= sizeof(s_attribName) / sizeof(s_attribName[0])) {
			insertItem(output, std::numeric_limits<uint16_t>::max());
		}
		else {
			auto convertedID = s_attribToId[index];
			insertItem(output, uint16_t(convertedID));	// the index of the attribute
		}
	}
	insertItem(output, uniformDataSize);		// number of uniforms (again for some reason)

	return output;
}
