#[=[
    Copyright 2026, Philip Rose, GM3ZZA
    
    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# Establish default project policies and common settings for GM3ZZA projects.

function(gm3zza_project_defaults)
    # C++ standard
    set(CMAKE_CXX_STANDARD 17 PARENT_SCOPE)
    set(CMAKE_CXX_STANDARD_REQUIRED ON PARENT_SCOPE)
    set(CMAKE_CXX_EXTENSIONS OFF PARENT_SCOPE)
    
    # Build defaults
    if(NOT MSVC)
        set(BUILD_SHARED_LIBS OFF PARENT_SCOPE)
    endif()
    
    # Generate compile_commands.json for IDE support
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON PARENT_SCOPE)
    
    # Compiler options
    if(MSVC)
        # Note: /MD is typically not needed; CMake handles runtime library selection
    else()
        add_compile_options(-g)
    endif()
    
    # Set portable user home directory
    if(MSVC)
        set(USER_HOME_DIR "$ENV{USERPROFILE}" PARENT_SCOPE)
    else()
        set(USER_HOME_DIR "$ENV{HOME}" PARENT_SCOPE)
    endif()
    
    message(STATUS "GM3ZZA: CXX standard: ${CMAKE_CXX_STANDARD}")
    message(STATUS "GM3ZZA: User home: ${USER_HOME_DIR}")
endfunction()

function(gm3zza_set_default_install_dirs APP_NAME)
    # Standardise install destination for application data and assets.
    # This replaces ad-hoc use of CMAKE_INSTALL_RPATH as a data destination.
    
    if(MSVC)
        set(APP_DATA_INSTALL_DIR "C:/ProgramData/GM3ZZA/${APP_NAME}" PARENT_SCOPE)
    else()
        set(APP_DATA_INSTALL_DIR "/etc/GM3ZZA/${APP_NAME}" PARENT_SCOPE)
    endif()
    
    message(STATUS "GM3ZZA: Data install directory: ${APP_DATA_INSTALL_DIR}")
endfunction()

function(gm3zza_define_standard_options)
    # Export common build options with sensible defaults.
    
    option(GM3ZZA_ENABLE_PDB "Generate PDB files for debugging (MSVC only)" OFF)
    option(GM3ZZA_ENABLE_DOCS "Generate documentation (if supported by project)" OFF)
    
    if(MSVC AND GM3ZZA_ENABLE_PDB)
        string(APPEND CMAKE_CXX_FLAGS_RELWITHDEBINFO " /Zi")
        string(APPEND CMAKE_CXX_FLAGS_RELEASE " /Zi")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO " /DEBUG /OPT:REF /OPT:ICF")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE " /DEBUG /OPT:REF /OPT:ICF")
    endif()
    
    message(STATUS "GM3ZZA: PDB generation: ${GM3ZZA_ENABLE_PDB}")
    message(STATUS "GM3ZZA: Docs generation: ${GM3ZZA_ENABLE_DOCS}")
endfunction()
