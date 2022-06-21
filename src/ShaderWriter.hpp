#pragma once
#include <ShaderTranspiler/ShaderTranspiler.hpp>

std::vector<char> makeBGFXShaderBinary(const shadert::CompileResult& result, shadert::ShaderStage stage);
