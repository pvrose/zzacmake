#[=[
    Copyright 2026, Philip Rose, GM3ZZA
    
    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# Centralised zzacommon discovery and FetchContent fallback.

function(gm3zza_use_zzacommon)
    # Find or fetch zzacommon and make it available.
    #
    # Usage: gm3zza_use_zzacommon(COMPONENTS <list> [GIT_TAG <tag>] [ENABLE_DOCS])
    
    set(oneValueArgs GIT_TAG)
    set(multiValueArgs COMPONENTS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT ARG_COMPONENTS)
        message(FATAL_ERROR "GM3ZZA: gm3zza_use_zzacommon: COMPONENTS is required")
    endif()
    
    if(NOT ARG_GIT_TAG)
        set(ARG_GIT_TAG "master")
    endif()
    
    # Build search paths for locally installed zzacommon sibling
    set (ZZACOMMON_LOCAL_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../zzacommon")
    
    include(FetchContent)

    # Set the components to be built by zzacommon's CMakeLists.txt.
    set(ZZACOMMON_BUILD_COMPONENTS ${ARG_COMPONENTS})

    if (EXISTS "${ZZACOMMON_LOCAL_SOURCE_DIR}/CMakeLists.txt")
        message(STATUS "GM3ZZA: Using zzacommon from ${ZZACOMMON_LOCAL_SOURCE_DIR}")

        FetchContent_Declare(
            zzacommon
            SOURCE_DIR ${ZZACOMMON_LOCAL_SOURCE_DIR}
        )

    else()
        message(STATUS "GM3ZZA: Fetching zzacommon from GitHub (${ARG_GIT_TAG})")
    
        FetchContent_Declare(
            zzacommon
            GIT_REPOSITORY https://github.com/pvrose/zzacommon.git
            GIT_TAG ${ARG_GIT_TAG}
            FIND_PACKAGE_ARGS NAMES zzacommon COMPONENTS ${ARG_COMPONENTS}
    )

    endif()
    
    FetchContent_MakeAvailable(zzacommon)
    
    if(zzacommon_FOUND)
        message(STATUS "GM3ZZA: Using zzacommon from ${zzacommon_DIR}")
    else()
        message(STATUS "GM3ZZA: Using zzacommon fetched from GitHub (${ARG_GIT_TAG})")
    endif()
endfunction()
