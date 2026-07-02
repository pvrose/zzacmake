#[=[
    Copyright 2026, Philip Rose, GM3ZZA

    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# Optional Doxygen-based documentation build for GM3ZZA projects.
#
# Provides one public entry point:
#
#   gm3zza_enable_docs(
#       TARGET       <target>            # main executable target
#       APP_NAME     <name>              # application name, used for PDF filename
#       USERGUIDE_DIR <dir>              # source directory containing userguide/Doxyfile.in
#       API_DIR       <dir>              # source directory containing api/Doxyfile.in
#       API_FILES     <files...>         # header files for API dependency tracking
#       [PDF]                            # also generate a PDF of the userguide
#   )
#
# After gm3zza_enable_docs() returns, the following parent-scope variables are set:
#   GM3ZZA_USERGUIDE_HTML_DIR  - path to the generated userguide html/ directory
#   GM3ZZA_API_HTML_DIR        - path to the generated api html/ directory
#   GM3ZZA_USERGUIDE_PDF_FILE  - path to the generated PDF (only when PDF is requested)
#
# Design notes:
#   - The api/ and userguide/ subdirectories retain their own Doxyfile.in files,
#     keeping the documentation configuration split as intended.
#   - configure_file is called with CMAKE_CURRENT_SOURCE_DIR temporarily overridden
#     to the relevant subdir so that @CMAKE_CURRENT_SOURCE_DIR@ substitutions in
#     each Doxyfile.in resolve to the correct location.
#   - All project-specific CMake variables referenced by @...@ in the Doxyfile.in
#     (e.g. ZZALOG_INCLUDE_DIR) must be set in the calling scope before invoking
#     gm3zza_enable_docs().

function(gm3zza_enable_docs)
    cmake_parse_arguments(ARG
        "PDF"
        "TARGET;APP_NAME;USERGUIDE_DIR;API_DIR"
        "API_FILES"
        ${ARGN}
    )

    if(NOT ARG_APP_NAME)
        message(WARNING "GM3ZZA Docs: APP_NAME not specified")
        set(ARG_APP_NAME "App")
    endif()

    find_package(Doxygen)

    if(NOT DOXYGEN_FOUND)
        message(WARNING "GM3ZZA Docs: Doxygen not found - documentation will not be generated")
        return()
    endif()

    message(STATUS "GM3ZZA Docs: Doxygen found: ${DOXYGEN_EXECUTABLE}")

    add_custom_target(docs)

    # -----------------------------------------------------------------------
    # User Guide
    # -----------------------------------------------------------------------

    if(ARG_USERGUIDE_DIR)
        set(_ug_src_dir  "${ARG_USERGUIDE_DIR}")
        set(_ug_bin_dir  "${CMAKE_BINARY_DIR}/userguide")
        set(_ug_doxyfile "${_ug_bin_dir}/Doxyfile_ug")

        file(MAKE_DIRECTORY "${_ug_bin_dir}")

        # Glob source files for dependency tracking.
        # The Doxyfile.in INPUT tag points at the src/ directory, so all .dox
        # and .md files there are relevant.  Extra tex and image files are also
        # tracked so re-runs happen when content changes.
        file(GLOB _ug_sources
            "${_ug_src_dir}/src/*.dox"
            "${_ug_src_dir}/src/*.md"
            "${_ug_src_dir}/*.tex"
        )
        file(GLOB _ug_images "${_ug_src_dir}/images/*")

        # Override CMAKE_CURRENT_SOURCE_DIR locally so that
        # @CMAKE_CURRENT_SOURCE_DIR@ substitutions in the Doxyfile.in resolve
        # to the userguide source directory.
        set(CMAKE_CURRENT_SOURCE_DIR "${_ug_src_dir}")
        configure_file("${_ug_src_dir}/Doxyfile.in" "${_ug_doxyfile}" @ONLY)

        add_custom_command(
            OUTPUT "${_ug_bin_dir}/html/index.html"
            DEPENDS ${_ug_sources} ${_ug_images} "${_ug_doxyfile}"
            COMMAND ${DOXYGEN_EXECUTABLE} "${_ug_doxyfile}"
            WORKING_DIRECTORY "${_ug_bin_dir}"
            COMMENT "GM3ZZA: Generating ${ARG_APP_NAME} userguide"
            VERBATIM
        )

        add_custom_target(ug_html
            DEPENDS "${_ug_bin_dir}/html/index.html"
        )

        # PDF generation from the Doxygen-produced LaTeX output
            if(MSVC)
                add_custom_command(
                    OUTPUT "${_ug_bin_dir}/latex/refman.pdf"
                    DEPENDS "${_ug_bin_dir}/html/index.html" ug_html
                    COMMAND miktex-texworks.exe "${_ug_bin_dir}/latex/refman.tex"
                    COMMENT "GM3ZZA: Generating ${ARG_APP_NAME} PDF userguide"
                    VERBATIM
                )
            else()
                add_custom_command(
                    OUTPUT "${_ug_bin_dir}/latex/refman.pdf"
                    DEPENDS "${_ug_bin_dir}/html/index.html" ug_html
                    COMMAND make -C "${_ug_bin_dir}/latex" >> /dev/null
                    COMMENT "GM3ZZA: Generating ${ARG_APP_NAME} PDF userguide"
                    VERBATIM
                )
            endif()

            add_custom_target(ug_pdf
                DEPENDS "${_ug_bin_dir}/latex/refman.pdf"
            )

            # Rename refman.pdf to <APP_NAME>.pdf for clarity
            add_custom_command(
                OUTPUT "${_ug_bin_dir}/${ARG_APP_NAME}.pdf"
                DEPENDS "${_ug_bin_dir}/latex/refman.pdf" ug_pdf
                COMMAND ${CMAKE_COMMAND} -E copy
                    "${_ug_bin_dir}/latex/refman.pdf"
                    "${_ug_bin_dir}/${ARG_APP_NAME}.pdf"
                COMMENT "GM3ZZA: Copying ${ARG_APP_NAME}.pdf"
            )

            add_custom_target(pdf 
                DEPENDS "${_ug_bin_dir}/${ARG_APP_NAME}.pdf"
            )

            set(GM3ZZA_USERGUIDE_PDF_FILE "${_ug_bin_dir}/${ARG_APP_NAME}.pdf" PARENT_SCOPE)

        set(GM3ZZA_USERGUIDE_HTML_DIR "${_ug_bin_dir}/html" PARENT_SCOPE)
        message(STATUS "GM3ZZA Docs: Userguide output: ${_ug_bin_dir}/html")

        add_dependencies(docs ug_html pdf)
   endif()

    # -----------------------------------------------------------------------
    # API Documentation
    # -----------------------------------------------------------------------

    if(ARG_API_DIR)
        set(_api_src_dir  "${ARG_API_DIR}")
        set(_api_bin_dir  "${CMAKE_BINARY_DIR}/api")
        set(_api_doxyfile "${_api_bin_dir}/Doxyfile")

        file(MAKE_DIRECTORY "${_api_bin_dir}")

        # Override CMAKE_CURRENT_SOURCE_DIR locally so that
        # @CMAKE_CURRENT_SOURCE_DIR@ substitutions in the Doxyfile.in resolve
        # to the api source directory.
        set(CMAKE_CURRENT_SOURCE_DIR "${_api_src_dir}")
        configure_file("${_api_src_dir}/Doxyfile.in" "${_api_doxyfile}" @ONLY)

        add_custom_command(
            OUTPUT "${_api_bin_dir}/html/index.html"
            DEPENDS ${ARG_API_FILES} "${_api_doxyfile}"
            COMMAND ${DOXYGEN_EXECUTABLE} "${_api_doxyfile}"
            WORKING_DIRECTORY "${_api_bin_dir}"
            COMMENT "GM3ZZA: Generating ${ARG_APP_NAME} API documentation"
            VERBATIM
        )

        add_custom_target(api_html 
            DEPENDS "${_api_bin_dir}/html/index.html"
        )

        set(GM3ZZA_API_HTML_DIR "${_api_bin_dir}/html" PARENT_SCOPE)
        message(STATUS "GM3ZZA Docs: API docs output: ${_api_bin_dir}/html")

        add_dependencies(docs api_html zzacommon_api_html)
    endif()

endfunction()
