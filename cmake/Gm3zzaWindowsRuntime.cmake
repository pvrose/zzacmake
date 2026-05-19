#[=[
    Copyright 2026, Philip Rose, GM3ZZA
    
    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# Windows runtime DLL handling.

function(gm3zza_copy_runtime_dlls)
    # Copy runtime DLLs to build directory post-build; needed for running app from IDE.
    #
    # Usage: gm3zza_copy_runtime_dlls(TARGET <name>)
    
    set(options "")
    set(oneValueArgs TARGET)
    set(multiValueArgs "")
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT ARG_TARGET)
        message(FATAL_ERROR "GM3ZZA: gm3zza_copy_runtime_dlls: TARGET is required")
    endif()
    
    if(NOT MSVC)
        return()
    endif()
    
    add_custom_command(TARGET ${ARG_TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_RUNTIME_DLLS:${ARG_TARGET}>
            ${CMAKE_BINARY_DIR}
        COMMAND_EXPAND_LISTS
        COMMENT "GM3ZZA: Copying runtime DLLs to ${CMAKE_BINARY_DIR}"
    )
endfunction()

# Track DLLs to install from dependency helpers
set(_GM3ZZA_RUNTIME_DLLS "")
set(_GM3ZZA_RUNTIME_DLLS_COMPONENT "")

function(gm3zza_register_runtime_dlls)
    # Register additional DLLs to be installed (used by dependency helpers).
    #
    # Usage: gm3zza_register_runtime_dlls(FILES <list> [COMPONENT <name>])
    
    set(options "")
    set(oneValueArgs COMPONENT)
    set(multiValueArgs FILES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT ARG_FILES)
        return()
    endif()
    
    if(NOT ARG_COMPONENT)
        set(ARG_COMPONENT "applications")
    endif()
    
    set(_GM3ZZA_RUNTIME_DLLS "${_GM3ZZA_RUNTIME_DLLS};${ARG_FILES}" PARENT_SCOPE)
    set(_GM3ZZA_RUNTIME_DLLS_COMPONENT "${ARG_COMPONENT}" PARENT_SCOPE)
endfunction()

function(gm3zza_install_registered_runtime_dlls)
    # Install all registered runtime DLLs.
    
    if(NOT _GM3ZZA_RUNTIME_DLLS)
        return()
    endif()
    
    install(FILES ${_GM3ZZA_RUNTIME_DLLS}
        DESTINATION bin
        COMPONENT ${_GM3ZZA_RUNTIME_DLLS_COMPONENT}
    )
    
    message(STATUS "GM3ZZA: Registered ${_GM3ZZA_RUNTIME_DLLS_COMPONENT} DLLs for install")
endfunction()
