#include <iostream>
#include <filesystem>
#include <unordered_map>
#include <cxxopts.hpp>
#include <fmt/format.h>
#include <ShaderTranspiler/ShaderTranspiler.hpp>

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
		("s,stage","Shader stage", cxxopts::value<std::string>())
		("i,include","Include paths", cxxopts::value<std::vector<filesystem::path>>())
		//("v,verbose", "Verbose logs")
		;
	auto args = options.parse(argc, argv);
	if (args["version"].as<bool>()) {
		printf("%s", fmt::format("nshaderc version 0.0.1").c_str());
	}

	// check for input and output file
	std::filesystem::path inputFile;
	try{
		inputFile = std::move(args["file"].as<std::filesystem::path>());
	}
	catch(exception& e){
		FATAL("no input file")
	}
	std::filesystem::path outputFile;
	try{
		outputFile = std::move(args["output"].as<std::filesystem::path>());
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
	try{
		auto& apiString = args["api"].as<string>();
		static const unordered_map<string, TargetAPI> apiMap{
			{"OpenGLES",TargetAPI::OpenGL_ES},
			{"OpenGL",TargetAPI::OpenGL},
			{"Vulkan", TargetAPI::Vulkan},
			{"DirectX", TargetAPI::DirectX11},
			{"Metal", TargetAPI::Metal}
		};
		try{
			api = apiMap.at(apiString);
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
	
	FileCompileTask task{inputFile,ShaderStage::Vertex};
	
	ShaderTranspiler transpiler;
	
	try{
		transpiler.CompileTo(task, api, {});
	}
	catch(exception& e){
		FATAL(e.what());
	}

	return 0;
}
