set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/")
set(NSHADERC "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/nshaderc")

function(addexample_impl)
	set(optional )
	set(args DIRNAME API VERSION)
	set(list_args VERTSHADERS FRAGSHADERS OUTVERTNAMES OUTFRAGNAMES COMPSHADERS OUTCOMPNAMES) 
	cmake_parse_arguments(
		PARSE_ARGV 0
		ARGS
		"${optional}"
		"${args}"
		"${list_args}"
	)
	
	set(all_depends "")
	foreach(item IN LISTS ARGS_OUTVERTNAMES ARGS_OUTFRAGNAMES ARGS_OUTCOMPNAMES)
		list(APPEND all_depends "${OUTPUT_DIR}${item}.bin")
	endforeach()

	foreach(item IN ZIP_LISTS ARGS_VERTSHADERS ARGS_OUTVERTNAMES)
		add_custom_command(
			OUTPUT "${OUTPUT_DIR}${item_1}.bin"
			DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" nshaderc
			COMMENT Compiling "${item_0}"
			COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" -o "${OUTPUT_DIR}${item_1}.bin" --stage vertex --api ${ARGS_API} -c ${ARGS_VERSION}
		)
	endforeach()

	foreach(item IN ZIP_LISTS ARGS_FRAGSHADERS ARGS_OUTFRAGNAMES)
		add_custom_command(
			OUTPUT "${OUTPUT_DIR}${item_1}.bin"
			DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" nshaderc
			COMMENT Compiling "${item_0}"
			COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" -o "${OUTPUT_DIR}${item_1}.bin" --stage fragment --api ${ARGS_API} -c ${ARGS_VERSION}
		)
	endforeach()

	foreach(item IN ZIP_LISTS ARGS_COMPSHADERS ARGS_OUTCOMPNAMES)
		add_custom_command(
			OUTPUT "${OUTPUT_DIR}${item_1}.bin"
			DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" nshaderc
			COMMENT Compiling "${item_0}"
			COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" -o "${OUTPUT_DIR}${item_1}.bin" --stage compute --api ${ARGS_API} -c ${ARGS_VERSION}
		)
	endforeach()
	add_custom_target("example-${ARGS_DIRNAME}-${ARGS_API}" DEPENDS nshaderc ${all_depends})


	file(GLOB SHADERS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/*.glsl" "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/*.fs" "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/*.vs")
	set_source_files_properties(${SHADERS} PROPERTIES HEADER_FILE_ONLY TRUE LANGUAGE OpenGL) 	# prevent VS from compiling these
	target_sources("example-${ARGS_DIRNAME}-${ARGS_API}" PRIVATE ${SHADERS})	# display them in the IDE

endfunction()

function(addexample)
	set(optional )
	set(args DIRNAME API VERSION)
	set(list_args VERTSHADERS FRAGSHADERS OUTVERTNAMES OUTFRAGNAMES)
	cmake_parse_arguments(
		PARSE_ARGV 0
		ARGS
		"${optional}"
		"${args}"
		"${list_args}"
	)

	if(APPLE)
		addexample_impl(
			DIRNAME ${ARGS_DIRNAME}
			API Metal
			VERSION 21
			VERTSHADERS ${ARGS_VERTSHADERS}
			OUTVERTNAMES ${ARGS_OUTVERTNAMES}
			FRAGSHADERS ${ARGS_FRAGSHADERS}
			OUTFRAGNAMES ${ARGS_OUTFRAGNAMES}
		)
	elseif(MSVC)
		addexample_impl(
			DIRNAME ${ARGS_DIRNAME}
			API DirectX
			VERSION 50
			VERTSHADERS ${ARGS_VERTSHADERS}
			OUTVERTNAMES ${ARGS_OUTVERTNAMES}
			FRAGSHADERS ${ARGS_FRAGSHADERS}
			OUTFRAGNAMES ${ARGS_OUTFRAGNAMES}
		)
		addexample_impl(
			DIRNAME ${ARGS_DIRNAME}
			API Vulkan
			VERSION 15
			VERTSHADERS ${ARGS_VERTSHADERS}
			OUTVERTNAMES ${ARGS_OUTVERTNAMES}
			FRAGSHADERS ${ARGS_FRAGSHADERS}
			OUTFRAGNAMES ${ARGS_OUTFRAGNAMES}
		)
	else()
		# Linux & unidentified
		addexample_impl(
			DIRNAME ${ARGS_DIRNAME}
			API Vulkan
			VERSION 15
			VERTSHADERS ${ARGS_VERTSHADERS}
			OUTVERTNAMES ${ARGS_OUTVERTNAMES}
			FRAGSHADERS ${ARGS_FRAGSHADERS}
			OUTFRAGNAMES ${ARGS_OUTFRAGNAMES}
		)
	endif()
endfunction()

addexample(
	DIRNAME "01-cubes"
	VERTSHADERS "cubes.vs"
	OUTVERTNAMES "vs_cubes"
	FRAGSHADERS "cubes.fs"
	OUTFRAGNAMES "fs_cubes"
)

addexample(
	DIRNAME "02-metaballs"
	VERTSHADERS "metaballs.vs"
	OUTVERTNAMES "vs_metaballs"
	FRAGSHADERS "metaballs.fs"
	OUTFRAGNAMES "fs_metaballs"
)

addexample(
	DIRNAME "03-raymarch"
	VERTSHADERS "raymarch.vs"
	OUTVERTNAMES "vs_raymarching"
	FRAGSHADERS "raymarch.fs"
	OUTFRAGNAMES "fs_raymarching"
)

addexample(
	DIRNAME "04-mesh"
	VERTSHADERS "mesh.vs"
	OUTVERTNAMES "vs_mesh"
	FRAGSHADERS "mesh.fs"
	OUTFRAGNAMES "fs_mesh"
)

addexample(
	DIRNAME "05-instancing"
	VERTSHADERS "instancing.vs"
	OUTVERTNAMES "vs_instancing"
	FRAGSHADERS "instancing.fs"
	OUTFRAGNAMES "fs_instancing"
)

addexample(
	DIRNAME "06-bump"
	VERTSHADERS "bump_instanced.vs" "bump.vs"
	OUTVERTNAMES "vs_bump_instanced" "vs_bump"
	FRAGSHADERS "bump.fs"
	OUTFRAGNAMES "fs_bump"
)

addexample(
	DIRNAME "07-callback"
	VERTSHADERS "callback.vs"
	OUTVERTNAMES "vs_callback"
	FRAGSHADERS "callback.fs"
	OUTFRAGNAMES "fs_callback"
)

addexample(
	DIRNAME "08-update"
	VERTSHADERS "update.vs"
	OUTVERTNAMES "vs_update"
	FRAGSHADERS "update.fs" "update_3d.fs" "update_cmp.fs"
	OUTFRAGNAMES "fs_update" "fs_update_3d" "fs_update_cmp"
	COMPSHADERS "update.glsl"
	OUTCOMPNAMES "cs_update"
)

addexample(
	DIRNAME "09-hdr" 
	VERTSHADERS hdr_blur.vs hdr_bright.vs hdr_lum.vs hdr_lumavg.vs hdr_mesh.vs hdr_skybox.vs hdr_tonemap.vs 
	OUTVERTNAMES vs_hdr_blur vs_hdr_bright vs_hdr_lum vs_hdr_lumavg vs_hdr_mesh vs_hdr_skybox vs_hdr_tonemap
	FRAGSHADERS hdr_blur.fs hdr_bright.fs hdr_lum.fs hdr_lumavg.fs hdr_mesh.fs hdr_skybox.fs hdr_tonemap.fs
	OUTFRAGNAMES fs_hdr_blur fs_hdr_bright fs_hdr_lum fs_hdr_lumavg fs_hdr_mesh fs_hdr_skybox fs_hdr_tonemap
)