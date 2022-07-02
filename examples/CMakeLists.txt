set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/")
set(NSHADERC "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/nshaderc")

function(addexample dirname vert frag outvert outfrag)
add_custom_target("example-${dirname}" ALL DEPENDS nshaderc
    COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${dirname}/${vert}" -o "${OUTPUT_DIR}${outvert}.bin" --stage vertex --api Metal -c 21
    COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${dirname}/${frag}" -o "${OUTPUT_DIR}${outfrag}.bin" --stage fragment --api Metal -c 21
)
endfunction()

addexample("01-cubes" "cubes.vs" "cubes.fs" "vs_cubes" "fs_cubes")
addexample("02-metaballs" "metaballs.vs" "metaballs.fs" "vs_metaballs" "fs_metaballs")
addexample("03-raymarch" "raymarch.vs" "raymarch.fs" "vs_raymarching" "fs_raymarching")
