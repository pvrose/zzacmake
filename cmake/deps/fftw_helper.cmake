#[=[
	Copyright 2026, Philip Rose, GM3ZZA
	
    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# CMake helper function for FFTW integration.
# Note this assumes that FFTW has been installed:
# for MSVC using the packages in https://www.fftw.org/install/windows.html.
# For Linux, use the package manager to install the appropriate FFTW packages.
function(gm3zza_find_fftw)
	if (MSVC)
	    if (FFTW_ROOT)
			message(STATUS "GM3ZZA: Using FFTW_ROOT: ${FFTW_ROOT}")
			set(FFTW3_INCLUDE_DIRS "${FFTW_ROOT}")
			set(FFTW3_LIBRARIES "${FFTW_ROOT}/libfftw3-3.lib")
			set(FFTW3_DLL "${FFTW_ROOT}/libfftw3-3.dll")
		else()
		  message(FATAL_ERROR "FFTW_ROOT environment variable must be set to the FFTW installation directory for MSVC builds.")
		endif()
	else()
	    find_library(FFTW3_LIBRARIES fftw3)
		if (NOT FFTW3_LIBRARIES)
		  message(FATAL_ERROR "FFTW3 library not found. Please install FFTW3 using your package manager.")
		endif()
		find_path(FFTW3_INCLUDE_DIRS fftw3.h)
		if (NOT FFTW3_INCLUDE_DIRS)
			message(FATAL_ERROR "FFTW3 not found. Please install FFTW3 using your package manager.")
		endif()
	endif()
	set(FFTW3_INCLUDE_DIRS "${FFTW3_INCLUDE_DIRS}" PARENT_SCOPE)
	set(FFTW3_LIBRARIES "${FFTW3_LIBRARIES}" PARENT_SCOPE)
	set(FFTW3_DLL "${FFTW3_DLL}" PARENT_SCOPE)
	
	message(STATUS "GM3ZZA: FFTW include: ${FFTW3_INCLUDE_DIRS}")
	message(STATUS "GM3ZZA: FFTW libraries: ${FFTW3_LIBRARIES}")
endfunction()

# Register FFTW DLLs for install.
function(gm3zza_register_fftw_dlls)
	if(NOT MSVC OR NOT FFTW3_DLL)
		return()
	endif()
	gm3zza_register_runtime_dlls(FILES ${FFTW3_DLL} COMPONENT applications)
endfunction()
