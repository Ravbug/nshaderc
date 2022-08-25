cd ..
mkdir -p build
cd build
cmake -G "Xcode" -DNSHADERC_EXAMPLES=ON -DST_BUNDLED_DXC=OFF ..
