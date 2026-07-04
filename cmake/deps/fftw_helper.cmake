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
		    file(TO_CMAKE_PATH "${FFTW_ROOT}" FFTW_ROOT)
			message(STATUS "GM3ZZA: Using FFTW_ROOT: ${FFTW_ROOT}")
			set(FFTW3_INCLUDE_DIRS "${FFTW_ROOT}")
			set(FFTW3_LIBRARIES "${FFTW_ROOT}/libfftw3-3.lib")
			set(FFTW3_DLL "${FFTW_ROOT}/libfftw3-3.dll")

			# Copy FFTW DLL to build directory for development/debugging
			add_custom_target(fftw_dll ALL)
			add_custom_command(TARGET fftw_dll POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_if_different ${FFTW3_DLL} ${CMAKE_BINARY_DIR}
				COMMENT "GM3ZZA: Copying FFTW DLL to build directory"
			)
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
	# Propagate the registration back to the caller's scope
	set(_GM3ZZA_RUNTIME_DLLS "${_GM3ZZA_RUNTIME_DLLS}" PARENT_SCOPE)
	set(_GM3ZZA_RUNTIME_DLLS_COMPONENT "${_GM3ZZA_RUNTIME_DLLS_COMPONENT}" PARENT_SCOPE)
endfunction()
