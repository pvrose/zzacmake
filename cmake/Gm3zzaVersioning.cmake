#[=[
    Copyright 2026, Philip Rose, GM3ZZA
    
    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# Version metadata handling and generated file normalisation.

# Function to get the current version from git
function(gm3zza_get_git_version RESULT_VAR)
    # Hardcoded fallback values if Git is missing entirely
    set(FALLBACK_VERSION "1.0.0.0")

    find_package(Git QUIET)
    if(GIT_FOUND)
        # Get the closest 3-level tag and count all commits ahead of it
        execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --tags --long --always
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_VERSION_RAW
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
    endif()

    # Parse the Git output string (e.g., v1.2.3-45-gabcd123)
    if(GIT_VERSION_RAW MATCHES "^v?([0-9]+)\\.([0-9]+)\\.([0-9]+)-([0-9]+)-g")
        set(VERSION_MAJOR ${CMAKE_MATCH_1})
        set(VERSION_MINOR ${CMAKE_MATCH_2})
        set(VERSION_PATCH ${CMAKE_MATCH_3})
        set(VERSION_TWEAK ${CMAKE_MATCH_4}) # Tweak = number of commits since tag
        
        set(CALCULATED_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_TWEAK}")
    else()
        set(CALCULATED_VERSION "${FALLBACK_VERSION}")
    endif()

    # Force CMake to re-configure automatically if the Git history changes
    if(GIT_FOUND AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git/HEAD")
        set_property(DIRECTORY APPEND PROPERTY 
            CMAKE_CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/.git/HEAD"
        )
    endif()

    # Send the final version string back to the parent scope
    set(${RESULT_VAR} "${CALCULATED_VERSION}" PARENT_SCOPE)
endfunction()

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
