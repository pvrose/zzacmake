#[=[
	Copyright 2026, Philip Rose, GM3ZZA
	
    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

# CMake helper function for Piper TTS integration.
# Note this assumes that Piper has been installed:
# For MSVC, set the PIPER_ROOT environment variable to the installation directory.
# For Linux, piper should be installed to /usr/local/lib and headers to /usr/local/include.

function(gm3zza_find_piper)
	if (MSVC)
		if (PIPER_ROOT)
			message(STATUS "GM3ZZA: Using PIPER_ROOT: ${PIPER_ROOT}")
			set(PIPERLIB_INSTALL_DIR "${PIPER_ROOT}/install")
			find_library(PIPERLIB piper PATHS ${PIPERLIB_INSTALL_DIR})
			set(PIPERLIB_INCLUDE_DIR "${PIPER_ROOT}/include")
			set(ONNX_INCLUDE_DIR "${PIPER_ROOT}/lib/onnxruntime-win-x64-1.22.0/include")
			set(PIPERLIB_DLL "${PIPERLIB_INSTALL_DIR}/piper.dll")
			set(ONNXRUNTIME_DLL "${PIPERLIB_INSTALL_DIR}/lib/onnxruntime.dll")
		else()
			message(FATAL_ERROR "PIPER_ROOT environment variable must be set to the Piper installation directory for MSVC builds.")
		endif()
	else()
		find_library(PIPERLIB piper PATHS "/usr/local/lib")
		if(NOT PIPERLIB)
			message(FATAL_ERROR "Piper library not found. Please install Piper and set PIPER_ROOT environment variable to the installation directory.")
		endif()
		find_path(PIPERLIB_INCLUDE_DIR piper.h PATHS "/usr/local/include")
		if(NOT PIPERLIB_INCLUDE_DIR)
			message(FATAL_ERROR "Piper headers not found. Please install Piper development files.")
		endif()
	endif()
	
	set(PIPERLIB_INSTALL_DIR "${PIPERLIB_INSTALL_DIR}" PARENT_SCOPE)
	set(PIPERLIB_INCLUDE_DIR "${PIPERLIB_INCLUDE_DIR}" PARENT_SCOPE)
	set(ONNX_INCLUDE_DIR "${ONNX_INCLUDE_DIR}" PARENT_SCOPE)
	set(PIPERLIB_DLL "${PIPERLIB_DLL}" PARENT_SCOPE)
	set(ONNXRUNTIME_DLL "${ONNXRUNTIME_DLL}" PARENT_SCOPE)
	
	message(STATUS "GM3ZZA: Piper library: ${PIPERLIB}")
	message(STATUS "GM3ZZA: Piper include: ${PIPERLIB_INCLUDE_DIR}")
	message(STATUS "GM3ZZA: ONNX include: ${ONNX_INCLUDE_DIR}")
endfunction()

# Register Piper DLLs for install.
function(gm3zza_register_piper_dlls)
	if(NOT MSVC OR NOT PIPERLIB_DLL OR NOT ONNXRUNTIME_DLL)
		return()
	endif()
	gm3zza_register_runtime_dlls(FILES ${PIPERLIB_DLL} ${ONNXRUNTIME_DLL} COMPONENT applications)
	# Propagate the registration back to the caller's scope
	set(_GM3ZZA_RUNTIME_DLLS "${_GM3ZZA_RUNTIME_DLLS}" PARENT_SCOPE)
	set(_GM3ZZA_RUNTIME_DLLS_COMPONENT "${_GM3ZZA_RUNTIME_DLLS_COMPONENT}" PARENT_SCOPE)
endfunction()
