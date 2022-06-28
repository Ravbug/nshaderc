set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/")
set(NSHADERC "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/nshaderc")

add_custom_target("example-01-cubes" ALL DEPENDS nshaderc
    COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/01-cubes/cubes.vs" -o "${OUTPUT_DIR}/vs_cubes.bin" --stage vertex --api Metal -c 21
    COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/01-cubes/cubes.fs" -o "${OUTPUT_DIR}/fs_cubes.bin" --stage fragment --api Metal -c 21
)
