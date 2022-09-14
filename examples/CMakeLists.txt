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
		list(APPEND all_depends "${OUTPUT_DIR}${ARGS_API}/${item}.bin")
	endforeach()

	foreach(item IN ZIP_LISTS ARGS_VERTSHADERS ARGS_OUTVERTNAMES)
		add_custom_command(
			OUTPUT "${OUTPUT_DIR}${ARGS_API}/${item_1}.bin"
			DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" "${CMAKE_CURRENT_LIST_DIR}/shaderlib.glsl" nshaderc
			COMMENT Compiling "${item_0}"
			COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" -o "${OUTPUT_DIR}${ARGS_API}/${item_1}.bin" --stage vertex --api ${ARGS_API} -c ${ARGS_VERSION}
		)
	endforeach()

	foreach(item IN ZIP_LISTS ARGS_FRAGSHADERS ARGS_OUTFRAGNAMES)
		add_custom_command(
			OUTPUT "${OUTPUT_DIR}${ARGS_API}/${item_1}.bin"
			DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" "${CMAKE_CURRENT_LIST_DIR}/shaderlib.glsl" nshaderc
			COMMENT Compiling "${item_0}"
			COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" -o "${OUTPUT_DIR}${ARGS_API}/${item_1}.bin" --stage fragment --api ${ARGS_API} -c ${ARGS_VERSION}
		)
	endforeach()

	foreach(item IN ZIP_LISTS ARGS_COMPSHADERS ARGS_OUTCOMPNAMES)
		add_custom_command(
			OUTPUT "${OUTPUT_DIR}${ARGS_API}/${item_1}.bin"
			DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" "${CMAKE_CURRENT_LIST_DIR}/shaderlib.glsl" nshaderc
			COMMENT Compiling "${item_0}"
			COMMAND "${NSHADERC}" -f "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/${item_0}" -o "${OUTPUT_DIR}${ARGS_API}/${item_1}.bin" --stage compute --api ${ARGS_API} -c ${ARGS_VERSION}
		)
	endforeach()
	add_custom_target("example-${ARGS_DIRNAME}-${ARGS_API}" DEPENDS nshaderc ${all_depends})


	file(GLOB SHADERS "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/*.glsl" "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/*.comp" "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/*.sh" "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/*.fs" "${CMAKE_CURRENT_LIST_DIR}/${ARGS_DIRNAME}/*.vs")
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
		addexample_impl(
			DIRNAME ${ARGS_DIRNAME}
			API OpenGL
			VERSION 120
			VERTSHADERS ${ARGS_VERTSHADERS}
			OUTVERTNAMES ${ARGS_OUTVERTNAMES}
			FRAGSHADERS ${ARGS_FRAGSHADERS}
			OUTFRAGNAMES ${ARGS_OUTFRAGNAMES}
		)
		addexample_impl(
			DIRNAME ${ARGS_DIRNAME}
			API OpenGLES
			VERSION 330
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
		addexample_impl(
			DIRNAME ${ARGS_DIRNAME}
			API OpenGL
			VERSION 460
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

addexample(
	DIRNAME "12-lod"
	VERTSHADERS "tree.vs"
	OUTVERTNAMES "vs_tree"
	FRAGSHADERS "tree.fs"
	OUTFRAGNAMES "fs_tree"
)

addexample(
	DIRNAME "13-stencil"
	VERTSHADERS stencil_color_lighting.vs stencil_color_texture.vs stencil_color.vs stencil_texture_lighting.vs stencil_texture.vs
	OUTVERTNAMES vs_stencil_color_lighting vs_stencil_color_texture vs_stencil_color vs_stencil_texture_lighting vs_stencil_texture
	FRAGSHADERS stencil_texture.fs stencil_color_black.fs stencil_color_lighting.fs stencil_color_texture.fs stencil_texture_lighting.fs
	OUTFRAGNAMES fs_stencil_texture fs_stencil_color_black fs_stencil_color_lighting fs_stencil_color_texture fs_stencil_texture_lighting
)


addexample(
    DIRNAME "14-shadowvolumes"
    VERTSHADERS shadowvolume_color_lighting.vs shadowvolume_color_texture.vs shadowvolume_svback.vs shadowvolume_svfront.vs shadowvolume_svside.vs shadowvolume_texture.vs shadowvolume_texture_lighting.vs
    OUTVERTNAMES vs_shadowvolume_color_lighting vs_shadowvolume_color_texture vs_shadowvolume_svback vs_shadowvolume_svfront vs_shadowvolume_svside vs_shadowvolume_texture vs_shadowvolume_texture_lighting
    FRAGSHADERS shadowvolume_color_lighting.fs shadowvolume_color_texture.fs shadowvolume_svbackblank.fs shadowvolume_svbackcolor.fs shadowvolume_svbacktex1.fs shadowvolume_svbacktex2.fs shadowvolume_svfrontblank.fs shadowvolume_svfrontcolor.fs shadowvolume_svfronttex1.fs shadowvolume_svfronttex2.fs shadowvolume_svside.fs shadowvolume_svsideblank.fs shadowvolume_svsidecolor.fs shadowvolume_svsidetex.fs shadowvolume_texture.fs shadowvolume_texture_lighting.fs
    OUTFRAGNAMES fs_shadowvolume_color_lighting fs_shadowvolume_color_texture fs_shadowvolume_svbackblank fs_shadowvolume_svbackcolor fs_shadowvolume_svbacktex1 fs_shadowvolume_svbacktex2 fs_shadowvolume_svfrontblank fs_shadowvolume_svfrontcolor fs_shadowvolume_svfronttex1 fs_shadowvolume_svfronttex2 fs_shadowvolume_svside fs_shadowvolume_svsideblank fs_shadowvolume_svsidecolor fs_shadowvolume_svsidetex fs_shadowvolume_texture fs_shadowvolume_texture_lighting
)

addexample(
    DIRNAME "15-shadowmaps-single"
    VERTSHADERS sms_mesh.vs sms_shadow.vs sms_shadow_pd.vs
    OUTVERTNAMES vs_sms_mesh vs_sms_shadow vs_sms_shadow_pd
    FRAGSHADERS sms_mesh.fs sms_mesh_pd.fs sms_shadow.fs sms_shadow_pd.fs
    OUTFRAGNAMES fs_sms_mesh fs_sms_mesh_pd fs_sms_shadow fs_sms_shadow_pd
)

addexample(
    DIRNAME "18-ibl"
    VERTSHADERS ibl_mesh.vs ibl_skybox.vs
    OUTVERTNAMES vs_ibl_mesh vs_ibl_skybox
    FRAGSHADERS ibl_mesh.fs ibl_skybox.fs
    OUTFRAGNAMES fs_ibl_mesh fs_ibl_skybox
)

addexample(
    DIRNAME "27-terrain"
    VERTSHADERS terrain.vs terrain_height_texture.vs
    OUTVERTNAMES vs_terrain vs_terrain_height_texture
    FRAGSHADERS terrain.fs
    OUTFRAGNAMES fs_terrain
)

addexample(
    DIRNAME "33-pom"
    VERTSHADERS pom.vs
    OUTVERTNAMES vs_pom
    FRAGSHADERS pom.fs
    OUTFRAGNAMES fs_pom
)

addexample(
    DIRNAME "24-nbody"
    VERTSHADERS particle.vs
    OUTVERTNAMES vs_particle
    FRAGSHADERS particle.fs
    OUTFRAGNAMES fs_particle
    COMPSHADERS indirect.comp init_instances.comp update_instances.comp
    OUTCOMPNAMES cs_indirect cs_init_instances cs_update_instances
)

addexample(
    DIRNAME "37-gpudrivenrendering"
    VERTSHADERS gdr_instanced_indirect_rendering.vs gdr_render_occlusion.vs
    OUTVERTNAMES vs_gdr_instanced_indirect_rendering vs_gdr_render_occlusion
    FRAGSHADERS gdr_instanced_indirect_rendering.fs
    OUTFRAGNAMES fs_gdr_instanced_indirect_rendering
    COMPSHADERS gdr_copy_z.comp gdr_downscale_hi_z.comp gdr_occlude_props.comp gdr_stream_compaction.comp
    OUTCOMPNAMES cs_gdr_copy_z cs_gdr_downscale_hi_z cs_gdr_occlude_props cs_gdr_stream_compaction
)
