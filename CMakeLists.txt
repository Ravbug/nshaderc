cmake_minimum_required(VERSION 3.16)
project(nshaderc)

if(MSVC)
	add_definitions(/MP)	# force parallel compile
endif()

file(GLOB SRC "src/*.hpp" "src/*.cpp" "src/*.h")

add_executable(${PROJECT_NAME} ${SRC})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

set(ST_ENABLE_TEST OFF CACHE INTERNAL "")
add_subdirectory("deps/ShaderTranspiler" EXCLUDE_FROM_ALL)
add_subdirectory("deps/cxxopts" EXCLUDE_FROM_ALL)

set(FMT_DOC OFF CACHE INTERNAL "")
set(FMT_INSTALL OFF CACHE INTERNAL "")
set(FMT_INSTALL OFF CACHE INTERNAL "")
set(FMT_TEST OFF CACHE INTERNAL "")
set(FMT_OS OFF CACHE INTERNAL "")
add_subdirectory("deps/fmt" EXCLUDE_FROM_ALL)

target_link_libraries(${PROJECT_NAME} PRIVATE ShaderTranspiler cxxopts fmt)
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT "${PROJECT_NAME}")
set_target_properties("${PROJECT_NAME}" PROPERTIES XCODE_GENERATE_SCHEME ON)
