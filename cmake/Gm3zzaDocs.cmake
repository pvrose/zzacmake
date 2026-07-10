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
    DEPENDS ${DOXY_FILES} ${DOXY_OUT} 
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      "${ZZACOMMON_API_HTML_DIR}"
      "${CMAKE_CURRENT_BINARY_DIR}/html/zzacommon"
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXY_OUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "${TARGET_NAME}: Generating API documentation"
    VERBATIM
  )

  #The Custom Target: This gives you the clickable menu item in Visual Studio
  add_custom_target(api_html
    DEPENDS ${DOXY_OUTPUT_INDEX}
  )

  add_dependencies(api_html zzacommon_api_html)

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
    COMMENT "${TARGET_NAME}: Generating Userguide documentation from ${DOXY_OUT}"
    VERBATIM
  )

  # The Custom Target: This gives you the clickable menu item in Visual Studio
  add_custom_target(ug_html
    DEPENDS ${DOXY_OUTPUT_INDEX}
  )

  # The principal latex file created by doxygen is refman.tex, which is used to generate the PDF userguide.
  set(LATEX_MAIN_INPUT "${CMAKE_CURRENT_BINARY_DIR}/latex/refman.tex")
  # Add any other latex files that are needed for the userguide here.
  set(LATEX_ALL_SOURCES ${LATEX_MAIN_INPUT}) 
 
    # Command for generating PDF from userguide latex files
    if(MSVC)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf
        DEPENDS ${LATEX_ALL_SOURCES}
        COMMAND pdflatex -interaction=nonstopmode -halt-on-error refman.tex 
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/latex"
        COMMENT "ZZALOG: Generating PDF Userguide (Windows CLI)"   
        VERBATIM
    )
    else()
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf
        DEPENDS ${LATEX_ALL_SOURCES}
        COMMAND make -C ${CMAKE_CURRENT_BINARY_DIR}/latex >> /dev/null
        COMMENT "ZZALOG: Generating PDF Userguide (Linux)"
        VERBATIM
    )
    endif()

    add_custom_target(ug_pdf
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf
    )

    add_dependencies(ug_pdf ug_html)
      
    # Copy from latex/refman.pdf to ZZALOG.pdf
    add_custom_command(
      OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf
      COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf
        ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf
      COMMENT "Copying PDF"
    )
    add_custom_target(pdf
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf
    )

    add_dependencies(pdf ug_pdf)

endfunction()

