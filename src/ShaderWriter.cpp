#include "ShaderWriter.hpp"
#include <fmt/format.h>
#include <string>

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
2b - size of the uniform array
*/

std::vector<char> makeBGFXShaderBinary(const shadert::CompileResult& result, shadert::ShaderStage stage) {
	std::vector<char> output;
	output.reserve(result.data.shaderData.size() + 100);

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
	// TODO: calculate hashes
	insertItem(output, uint32_t(0));	// input hash
	insertItem(output, uint32_t(0));	// output hash

	// next write the uniform data
	insertItem(output, uint16_t(result.data.uniformData.size()));		// number of uniforms
	// switch on uniform.glDefineType to convert to bgfx enum for writing, and error on unkown types instead of writing UniformType::End
	for (const auto& uniform : result.data.uniformData) {
		insertItem(output, uint8_t(uniform.name.length()));				 // uniform name length
		insertBytes(output, uniform.name.c_str(),uniform.name.length()); // uniform name
		insertItem(output, uint8_t());									 // TODO: fragment bit

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
			fatal(fmt::format("Invalid Uniform type ({}) for Uniform \"{}\" ",uniform.glDefineType,uniform.name));
		}
		uint32_t fragmentBit = isFragmentShader ? kUniformFragmentBit : 0;
		insertItem(output, uint8_t(bgfx_type | fragmentBit));			// fragment bit + type
		insertItem(output, uint8_t(uniform.arraySize));					// array buffer size
		insertItem(output, uint16_t(uniform.bufferOffset));				// buffer offset
		insertItem(output, regCount);									// regCount
		insertItem(output, uint8_t(uniform.texComponent));				// texComponent
		insertItem(output, uint8_t(uniform.texDimension));				// texDimension
		insertItem(output, uint16_t(uniform.texFormat));				// texFormat
	}

	// then write the shader data itself
	insertItem(output, uint16_t(result.data.shaderData.size()));	// shader size
	insertBytes(output, result.data.shaderData.data(), result.data.shaderData.size() * sizeof(decltype(result.data.shaderData)::value_type));
	output.push_back('\0');	// null terminator

	// write LiveAttribute data

	return output;
}
