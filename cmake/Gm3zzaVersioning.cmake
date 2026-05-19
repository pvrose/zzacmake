#[=[
    Copyright 2026, Philip Rose, GM3ZZA
    
    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# Version metadata handling and generated file normalisation.

function(gm3zza_split_version)
    # Parse <project>_VERSION into major, minor, patch, tweak components.
    # Supports either call style:
    #   gm3zza_split_version(${PROJECT_NAME})
    #   gm3zza_split_version(PROJECT_NAME ${PROJECT_NAME})
    # Exports <project>_VERSION_MAJOR, etc. to parent scope.

    set(PROJECT_ID "")

    if(ARGC EQUAL 1)
        set(PROJECT_ID "${ARGV0}")
    else()
        set(options "")
        set(oneValueArgs PROJECT_NAME)
        set(multiValueArgs "")
        cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
        set(PROJECT_ID "${ARG_PROJECT_NAME}")
    endif()

    if(NOT PROJECT_ID)
        message(FATAL_ERROR "GM3ZZA: gm3zza_split_version requires project name, e.g. gm3zza_split_version(${PROJECT_NAME})")
    endif()

    set(VERSION_VAR "${PROJECT_ID}_VERSION")
    set(VERSION_VALUE "${${VERSION_VAR}}")
    
    if(NOT VERSION_VALUE)
        message(WARNING "GM3ZZA: ${VERSION_VAR} not set; using 0.0.0.0")
        set(VERSION_VALUE "0.0.0.0")
    endif()
    
    string(REPLACE "." ";" VERSION_LIST "${VERSION_VALUE}")
    list(LENGTH VERSION_LIST VERSION_LIST_LENGTH)
    
    list(GET VERSION_LIST 0 MAJOR)
    set(${PROJECT_ID}_VERSION_MAJOR "${MAJOR}" PARENT_SCOPE)
    
    if(VERSION_LIST_LENGTH GREATER 1)
        list(GET VERSION_LIST 1 MINOR)
        set(${PROJECT_ID}_VERSION_MINOR "${MINOR}" PARENT_SCOPE)
    else()
        set(${PROJECT_ID}_VERSION_MINOR "0" PARENT_SCOPE)
    endif()
    
    if(VERSION_LIST_LENGTH GREATER 2)
        list(GET VERSION_LIST 2 PATCH)
        set(${PROJECT_ID}_VERSION_PATCH "${PATCH}" PARENT_SCOPE)
    else()
        set(${PROJECT_ID}_VERSION_PATCH "0" PARENT_SCOPE)
    endif()
    
    if(VERSION_LIST_LENGTH GREATER 3)
        list(GET VERSION_LIST 3 TWEAK)
        set(${PROJECT_ID}_VERSION_TWEAK "${TWEAK}" PARENT_SCOPE)
    else()
        set(${PROJECT_ID}_VERSION_TWEAK "0" PARENT_SCOPE)
    endif()
    
    message(STATUS "GM3ZZA: Version ${PROJECT_ID} = ${${PROJECT_ID}_VERSION_MAJOR}.${${PROJECT_ID}_VERSION_MINOR}.${${PROJECT_ID}_VERSION_PATCH}.${${PROJECT_ID}_VERSION_TWEAK}")
endfunction()

function(gm3zza_generate_app_source)
    # Generate app.cpp from template, placing output in the build tree (not source tree).
    # 
    # Usage: gm3zza_generate_app_source(INPUT <template> OUTPUT_VAR <var>)
    
    set(options "")
    set(oneValueArgs INPUT OUTPUT_VAR)
    set(multiValueArgs "")
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT ARG_INPUT)
        message(FATAL_ERROR "GM3ZZA: gm3zza_generate_app_source: INPUT is required")
    endif()
    
    if(NOT ARG_OUTPUT_VAR)
        message(FATAL_ERROR "GM3ZZA: gm3zza_generate_app_source: OUTPUT_VAR is required")
    endif()
    
    if(NOT EXISTS "${ARG_INPUT}")
        message(FATAL_ERROR "GM3ZZA: Template not found: ${ARG_INPUT}")
    endif()
    
    # Generate into binary tree
    get_filename_component(TEMPLATE_NAME "${ARG_INPUT}" NAME_WE)
    set(OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/src/${TEMPLATE_NAME}.cpp")
    
    configure_file(
        "${ARG_INPUT}"
        "${OUTPUT_FILE}"
        @ONLY
    )
    
    # Export path to parent scope
    set(${ARG_OUTPUT_VAR} "${OUTPUT_FILE}" PARENT_SCOPE)
    
    message(STATUS "GM3ZZA: Generated ${OUTPUT_FILE}")
endfunction()
