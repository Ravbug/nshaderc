set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/")
set(NSHADERC "${CMAKE_BINARY_DIR}/$<CONFIGURATION>/nshaderc")

function(addexample_impl)
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

	add_custom_target("example-${ARGS_DIRNAME}-${ARGS_API}" DEPENDS nshaderc "example-${ARGS_DIRNAME}-${ARGS_API}_out")
	add_custom_command(
		OUTPUT "example-${ARGS_DIRNAME}-${ARGS_API}_out"
		COMMAND echo "Compiling shaders"
	)

	foreach(item IN ZIP_LISTS ARGS_VERTSHADERS ARGS_OUTVERTNAMES)
		add_custom_command(
			OUTPUT "example-${ARGS_DIRNAME}-${ARGS_API}_out" APPEND
			DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}"
			COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" -o "${OUTPUT_DIR}${item_1}.bin" --stage vertex --api ${ARGS_API} -c ${ARGS_VERSION}
		)
	endforeach()

	foreach(item IN ZIP_LISTS ARGS_FRAGSHADERS ARGS_OUTFRAGNAMES)
		add_custom_command(
			OUTPUT "example-${ARGS_DIRNAME}-${ARGS_API}_out" APPEND
			DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}"
			COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" -o "${OUTPUT_DIR}${item_1}.bin" --stage fragment --api ${ARGS_API} -c ${ARGS_VERSION}
		)
	endforeach()


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