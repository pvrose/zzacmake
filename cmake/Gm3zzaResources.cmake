#[=[
    Copyright 2026, Philip Rose, GM3ZZA

    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# Runtime asset staging and install.

# Capture the directory where this module resides at include time
set(_GM3ZZA_RESOURCES_MODULE_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(gm3zza_stage_runtime_files)
    # Copy runtime data files to build directory for development use.
    #
    # Usage: gm3zza_stage_runtime_files(TARGET <name> FILES <list> [DEST_SUBDIR <dir>])
    
    set(options "")
    set(oneValueArgs TARGET DEST_SUBDIR)
    set(multiValueArgs FILES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT ARG_TARGET)
        message(FATAL_ERROR "GM3ZZA: gm3zza_stage_runtime_files: TARGET is required")
    endif()
    
    if(NOT ARG_FILES)
        return()
    endif()
    
    set(DEST_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    if(ARG_DEST_SUBDIR)
        set(DEST_DIR "${CMAKE_CURRENT_BINARY_DIR}/${ARG_DEST_SUBDIR}")
    endif()
    
    foreach(F ${ARG_FILES})
        if(IS_ABSOLUTE "${F}")
            set(SOURCE_FILE "${F}")
        else()
            set(SOURCE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${F}")
        endif()

        add_custom_command(TARGET ${ARG_TARGET} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${SOURCE_FILE}"
                "${DEST_DIR}"
            COMMENT "GM3ZZA: Staging ${SOURCE_FILE} to ${DEST_DIR}"
        )
    endforeach()
endfunction()

function(gm3zza_install_runtime_files)
    # Install runtime data files to app data directory.
    #
    # Usage: gm3zza_install_runtime_files(FILES <list> [DEST_SUBDIR <dir>] [COMPONENT <name>])
    
    set(options "")
    set(oneValueArgs DEST_SUBDIR COMPONENT)
    set(multiValueArgs FILES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT ARG_FILES)
        return()
    endif()
    
    if(NOT ARG_COMPONENT)
        set(ARG_COMPONENT "data")
    endif()
    
    set(DEST_DIR "${APP_DATA_INSTALL_DIR}")
    if(ARG_DEST_SUBDIR)
        set(DEST_DIR "${APP_DATA_INSTALL_DIR}/${ARG_DEST_SUBDIR}")
    endif()
    
    install(FILES ${ARG_FILES}
        DESTINATION "${DEST_DIR}"
        COMPONENT ${ARG_COMPONENT}
    )
    
    message(STATUS "GM3ZZA: Installing data files to ${DEST_DIR}")
endfunction()

function(gm3zza_enable_windows_icon)
    # Generate Windows icon and resource file.
    #
    # Usage: gm3zza_enable_windows_icon(TARGET <name> PNG_FILE <png> RC_TEMPLATE <template> OUTPUT_VAR <var> [WHITE_THRESHOLD <0-255>])
    
    if(NOT MSVC)
        return()
    endif()
    
    set(options "")
    set(oneValueArgs TARGET PNG_FILE RC_TEMPLATE OUTPUT_VAR WHITE_THRESHOLD)
    set(multiValueArgs "")
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT ARG_PNG_FILE OR NOT ARG_RC_TEMPLATE OR NOT ARG_OUTPUT_VAR)
        message(FATAL_ERROR "GM3ZZA: gm3zza_enable_windows_icon: PNG_FILE, RC_TEMPLATE, and OUTPUT_VAR are required")
    endif()
    
    if(NOT ARG_WHITE_THRESHOLD)
        set(ARG_WHITE_THRESHOLD 240)
    endif()
    
    # Find the icon helper
    set(ICON_HELPER_PATH "${_GM3ZZA_RESOURCES_MODULE_DIR}/windows/icon_helper.cmake")
    if(NOT EXISTS "${ICON_HELPER_PATH}")
        message(FATAL_ERROR "GM3ZZA: icon_helper.cmake not found at ${ICON_HELPER_PATH}")
    endif()

    include("${ICON_HELPER_PATH}")
    
    generate_windows_icon_and_resource(
        PNG_FILE "${ARG_PNG_FILE}"
        RC_TEMPLATE "${ARG_RC_TEMPLATE}"
        WHITE_THRESHOLD ${ARG_WHITE_THRESHOLD}
    )
    
    # Export the generated RC file to the requested variable
    set(${ARG_OUTPUT_VAR} "${${PROJECT_NAME}_RC_FILE}" PARENT_SCOPE)
endfunction()
