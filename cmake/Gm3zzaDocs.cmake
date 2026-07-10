#[=[
    Copyright 2026, Philip Rose, GM3ZZA

    GNU General Public License Version 3 or later.
    This file is part of the GM3ZZA CMake shared layer.

#]=]

## Doxygen based scriptsfor generating documents for GM3ZZA 
## projects.

## Function to configure and build the API documentation.
## This will generate a set of HTML files for the project itself
## and copy the same for ZZACOMMON.
function(setup_api_documentation 
   TARGET_NAME                 ## The target project
   DOXY_FILES                  ## List of source files
)
  set(DOXY_IN "${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in")
  set(DOXY_OUT "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile")
  # Configure Doxyfile
  configure_file(${DOXY_IN} ${DOXY_OUT} @ONLY)

  # Set "real" dependency
  set(DOXY_OUTPUT_INDEX "${CMAKE_CURRENT_BINARY_DIR}/html/index.html")

   # Custom Command: This is the actual command that will run Doxygen
  add_custom_command(
    OUTPUT ${DOXY_OUTPUT_INDEX}
    DEPENDS ${DOXY_API_FILES} ${DOXY_OUT} zzacommon_api_html
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      "${ZZACOMMON_API_HTML_DIR}"
      "${CMAKE_CURRENT_BINARY_DIR}/html/zzacommon"
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXY_API_OUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "${TARGET_NAME}: Generating API documentation"
    VERBATIM
  )

  #The Custom Target: This gives you the clickable menu item in Visual Studio
  add_custom_target(api_html
    DEPENDS ${DOXY_OUTPUT_INDEX}
  )

endfunction()

## Function to configure and build the API documentation.
## This will generate a set of HTML files for the project itself
## and copy the same for ZZACOMMON.
function(setup_ug_documentation 
   TARGET_NAME                 ## The target project
   DOXY_FILES                  ## List of source files
   DOXY_IMAGES                 ## List of image files
)
  set(DOXY_IN "${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in")
  set(DOXY_OUT "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile")
  # Configure Doxyfile
  configure_file(${DOXY_IN} ${DOXY_OUT} @ONLY)

  # Set "real" dependency
  set(DOXY_OUTPUT_INDEX "${CMAKE_CURRENT_BINARY_DIR}/html/index.html")

    # The Custom Command: This handles the actual dependency checking
  add_custom_command(
    OUTPUT ${DOXY_OUTPUT_INDEX}
    DEPENDS ${DOXY_FILES} ${DOXY_OUT} ${DOXY_IMAGES}
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXY_OUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "ZZALOG: Generating Userguide documentation"
    VERBATIM
  )

  # The Custom Target: This gives you the clickable menu item in Visual Studio
  add_custom_target(ug_html
    DEPENDS ${DOXY_OUTPUT_INDEX}
  )
 
    # Command for generating PDF from userguide latex files
    if(MSVC)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf
        COMMAND miktex-texworks.exe  ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.tex
        COMMENT "ZZALOG: Generating PDF Userguide"
        VERBATIM
    )
    else()
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf
        COMMAND make -C ${CMAKE_CURRENT_BINARY_DIR}/latex >> /dev/null
        COMMENT "ZZALOG: Generating PDF Userguide"
        VERBATIM
    )
    endif()

    add_custom_target(ug_pdf
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf ug_html
    )
      
    # Copy from latex/refman.pdf to ZZALOG.pdf
    add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf
    COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf
    ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf
    COMMENT "Copying PDF"
    )
    add_custom_target(pdf
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf ug_pdf
    )

endfunction()

