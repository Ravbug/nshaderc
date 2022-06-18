# nshaderc
A work-in-progress replacement shader compiler for bgfx. It is not backwards compatible with the existing bgfx shader compiler.

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
