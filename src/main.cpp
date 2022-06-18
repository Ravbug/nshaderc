#include <iostream>
#include <filesystem>
#include <cxxopts.hpp>
#include <fmt/format.h>
#include <ShaderTranspiler/ShaderTranspiler.hpp>

using namespace std;
using namespace shadert;

int main(int argc, char** argv) {
	cxxopts::Options options("nshaderc", "New bgfx shader compiler");
	options.add_options()
		("d,debug", "Enable debugging") // a bool parameter
		("v,version", "Print version information")
		("f,file", "Input file path", cxxopts::value<string>())
		("o,output", "Ouptut file path", cxxopts::value<string>())
		("a,api","Target API", cxxopts::value<string>())
		("t,type","Shader type", cxxopts::value<std::string>())
		//("v,verbose", "Verbose logs")
		;
	auto results = options.parse(argc, argv);
	if (results["version"].as<bool>()) {
		printf("%s", fmt::format("nshaderc version 0.0.1").c_str());
	}


	ShaderTranspiler transpiler;

	return 0;
}