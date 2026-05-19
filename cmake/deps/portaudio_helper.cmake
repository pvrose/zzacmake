#[=[
	Copyright 2026, Philip Rose, GM3ZZA
	
    This file is part of ZZALOG. Amateur Radio Logging Software.

    ZZALOG is free software: you can redistribute it and/or modify it under the
	terms of the Lesser GNU General Public License as published by the Free Software
	Foundation, either version 3 of the License, or (at your option) any later version.

    ZZALOG is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
	PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with ZZALOG. 
	If not, see <https://www.gnu.org/licenses/>. 

#]=]

function(gm3zza_find_portaudio)
	if (PORTAUDIO_ROOT)
		if(MSVC)
			add_subdirectory(${PORTAUDIO_ROOT}
			  ${CMAKE_BINARY_DIR}/portaudio 
			  EXCLUDE_FROM_ALL
			)
			set(PORTAUDIO_INCLUDE_DIR ${PORTAUDIO_ROOT}/include)
			set(PORTAUDIOLIB portaudio_static)
		else()
			find_library(PORTAUDIOLIB portaudio PATHS "/usr/local/lib")
		endif()
	else()
		if(MSVC)
			message(FATAL_ERROR "PORTAUDIO_ROOT environment variable must be set to the PortAudio installation directory for MSVC builds.")
		else()
			find_library(PORTAUDIOLIB portaudio PATHS "/usr/local/lib")
		endif()
	endif()
	set (PORTAUDIO_INCLUDE_DIR "${PORTAUDIO_INCLUDE_DIR}" PARENT_SCOPE)	
	set (PORTAUDIOLIB "${PORTAUDIOLIB}" PARENT_SCOPE)
endfunction()