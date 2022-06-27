#include <iostream>
#include <fstream>
#include <filesystem>
#include <unordered_map>
#include <cxxopts.hpp>
#include <fmt/format.h>
#include "ShaderWriter.hpp"

using namespace std;
using namespace shadert;

#define FATAL(reason) {std::cerr << "nshaderc error: " << reason << std::endl; return 1;}

int main(int argc, char** argv) {
	cxxopts::Options options("nshaderc", "New bgfx shader compiler");
	options.add_options()
		("d,debug", "Enable debugging") // a bool parameter
		("v,version", "Print version information")
		("f,file", "Input file path", cxxopts::value<filesystem::path>())
		("o,output", "Ouptut file path", cxxopts::value<filesystem::path>())
		("a,api","Target API", cxxopts::value<string>())
		("c,compatibility","Target API minimum compatibility", cxxopts::value<uint32_t>())
		("m,mobile", "Mobile backend (default false)", cxxopts::value<bool>()->default_value("false"))
		("s,stage","Shader stage", cxxopts::value<std::string>())
		("i,include","Include paths", cxxopts::value<std::vector<filesystem::path>>())
		//("v,verbose", "Verbose logs")
		;
	auto args = options.parse(argc, argv);
	if (args["version"].as<bool>()) {
		printf("%s", fmt::format("nshaderc version 0.0.1\n").c_str());
	}

	// check for input and output file
	std::filesystem::path inputFile;
	try{
		inputFile = std::move(args["file"].as<decltype(inputFile)>());
	}
	catch(exception& e){
		FATAL("no input file")
	}
	std::filesystem::path outputFile;
	try{
		outputFile = std::move(args["output"].as<decltype(outputFile)>());
	}
	catch(exception& e){
		FATAL("no output file")
	}
	
	// get the stage
	ShaderStage inputStage;
	try{
		auto& shaderStageString = args["stage"].as<string>();
		static const unordered_map<string, ShaderStage> shaderStageMap{
			{"vertex",ShaderStage::Vertex},
			{"fragment",ShaderStage::Fragment},
			{"compute", ShaderStage::Compute}
		};
		try{
			inputStage = shaderStageMap.at(shaderStageString);
		}
		catch(exception& e){
			cerr << fmt::format("nshaderc error: \"{}\" is not a valid shader stage\nExpected one of:\n", shaderStageString);
			for(const auto& row : shaderStageMap){
				cerr << "\t" << row.first << "\n";
			}
			return 1;
		}
	}
	catch(exception& e){
		FATAL("shader stage not provided")
	}
	
	// get the target API
	TargetAPI api;
	const char* entryPoint = nullptr;
	shadert::Options opt;
	try{
		auto& apiString = args["api"].as<string>();
		struct apiData {
			TargetAPI e_api;
			shadert::Options options;
		};
		static const unordered_map<string, apiData> apiMap{
			{"OpenGLES",{TargetAPI::OpenGL_ES,shadert::Options{
				.entryPoint = "main"}
			}},
			{"OpenGL",{TargetAPI::OpenGL,shadert::Options{
				.entryPoint = "main"}
			}},
			{"Vulkan", {TargetAPI::Vulkan,shadert::Options{
				.entryPoint = ""}
			}},
			{"DirectX", {TargetAPI::DirectX,shadert::Options
				{.entryPoint = "main"}}},
			{"Metal", {TargetAPI::Metal, shadert::Options{
				.entryPoint = "xlatMtlMain",
				.uniformBufferSettings{"_mtl_u",true}}
			}}
		};
		try{
			const auto& data = apiMap.at(apiString);
			api = data.e_api;
			opt = std::move(data.options);
		}
		catch(exception& e){
			cerr << fmt::format("nshaderc error: \"{}\" is not a valid target API\nExpected one of:\n", apiString);
			for(const auto& row : apiMap){
				cerr << "\t" << row.first << "\n";
			}
			return 1;
		}
	}
	catch (exception& e){
		FATAL("target API not provided")
	}
	// get target API version
	uint32_t version = 0;
	try{
		version = args["compatibility"].as<decltype(version)>();
	}
	catch(exception& e){
		FATAL("backend compatibility version not set")
	}
	
	FileCompileTask task{std::move(inputFile),inputStage };
	
	ShaderTranspiler transpiler;
	
	try{
		opt.version = version;
		opt.mobile = args["mobile"].as<bool>();
		auto result = transpiler.CompileTo(task, api,opt);

		// make bgfx binary
		auto binary = makeBGFXShaderBinary(result, inputStage);
		ofstream out(outputFile, ios::out | ios::binary);
		out.write(binary.data(), binary.size() * sizeof(decltype(binary)::value_type));
		if (!out.good()){
			FATAL(fmt::format("Error writing to {}", outputFile.string()));
		}
	}
	catch(exception& e){
		FATAL(e.what());
	}

	return 0;
}
