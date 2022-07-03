# nshaderc
A work-in-progress replacement shader compiler for bgfx. It is not backwards compatible with the existing bgfx shader compiler.

**Goals**
1. To take only standard GLSL as input
2. To not rely on macros or other hacks for feature support
3. To generate readable source that matches the original input as closely as possible for easier shader source debugging
4. To be linkable as a library for runtime shader compilation

**Non-goals**
1. To support the DX9, NVN, PSSL, and legacy OpenGL backends  
2. To support legacy compilers or C++ versions

### Usage
Run `nshaderc --help` for a menu of options. To specify the compatibility version, supply the major and minor versions 
in one integer. For example, for Metal 2.1, use 21, for DirectX Shader Model 5.1, use 51, and for Vulkan 1.3, use 13.

### Building
Clone recursive to get all submodules:
```
git clone https://github.com/Ravbug/nshaderc --depth=1 --recurse-submodules
```
Then build with cmake:
```
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
```
