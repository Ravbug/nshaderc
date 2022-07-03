set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/")
set(NSHADERC "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/nshaderc")


function(addexample_impl dirname vert frag outvert outfrag api version)
	add_custom_target("example-${dirname}-${api}" DEPENDS nshaderc
		COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${dirname}/${vert}" -o "${OUTPUT_DIR}${outvert}.bin" --stage vertex --api ${api} -c ${version}
		COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${dirname}/${frag}" -o "${OUTPUT_DIR}${outfrag}.bin" --stage fragment --api ${api} -c ${version}
)
endfunction()

function(addexample dirname vert frag outvert outfrag)
	if(APPLE)
		addexample_impl(${dirname} ${vert} ${frag} ${outvert} ${outfrag} Metal 21)
	elseif(MSVC)
		addexample_impl(${dirname} ${vert} ${frag} ${outvert} ${outfrag} DirectX 50)
		addexample_impl(${dirname} ${vert} ${frag} ${outvert} ${outfrag} Vulkan 15)
	else()
		# Linux & unidentified
		addexample_impl(${dirname} ${vert} ${frag} ${outvert} ${outfrag} Vulkan 15)
	endif()
endfunction()


addexample("01-cubes" "cubes.vs" "cubes.fs" "vs_cubes" "fs_cubes")
addexample("02-metaballs" "metaballs.vs" "metaballs.fs" "vs_metaballs" "fs_metaballs")
addexample("03-raymarch" "raymarch.vs" "raymarch.fs" "vs_raymarching" "fs_raymarching")
addexample("04-mesh" "mesh.vs" "mesh.fs" "vs_mesh" "fs_mesh")
addexample("05-instancing" "instancing.vs" "instancing.fs" "vs_instancing" "fs_instancing")
