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
  add_custom_target(${TARGET_NAME}_api_html
    DEPENDS ${DOXY_OUTPUT_INDEX}
  )

  add_dependencies(${TARGET_NAME}_api_html zzacommon_api_html)

endfunction()

## Function to configure and build the userguide HTML and PDF documentation.
function(setup_ug_documentation 
   TARGET_NAME                 ## The target project (e.g. zzalog)
   DOXY_FILES                  ## List of source files
   DOXY_IMAGES                 ## List of image files
)
  set(DOXY_IN "${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in")
  set(DOXY_OUT "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile")
  
  # Configure Doxyfile
  configure_file(${DOXY_IN} ${DOXY_OUT} @ONLY)

  # =========================================================================
  # 1. THE DOXYGEN STEP (HTML + LATEX GENERATION)
  # =========================================================================
  set(DOXY_OUTPUT_INDEX "${CMAKE_CURRENT_BINARY_DIR}/html/index.html")
  set(LATEX_MAIN_INPUT "${CMAKE_CURRENT_BINARY_DIR}/latex/refman.tex")

  add_custom_command(
    OUTPUT ${DOXY_OUTPUT_INDEX}
    DEPENDS ${DOXY_FILES} ${DOXY_OUT} ${DOXY_IMAGES}
    
    # CRITICAL FIX: Tell CMake that Doxygen spits out refman.tex as a byproduct
    BYPRODUCTS "${LATEX_MAIN_INPUT}"
    
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXY_OUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "${TARGET_NAME}: Generating Userguide documentation from ${DOXY_OUT}"
    VERBATIM
  )

  # Custom Target for HTML
  add_custom_target(${TARGET_NAME}_ug_html
    DEPENDS ${DOXY_OUTPUT_INDEX}
  )


  # =========================================================================
  # 2. THE LATEX STEP (PDF GENERATION)
  # =========================================================================
  if(MSVC)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf"
        
        # FIX: Depend on the HTML target directly so CMake knows how to trace 
        # back to the rule that creates the 'byproduct' latex folder.
        DEPENDS ${TARGET_NAME}_ug_html "${LATEX_MAIN_INPUT}"
        
        COMMAND pdflatex -interaction=nonstopmode -halt-on-error refman.tex 
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/latex"
        COMMENT "${TARGET_NAME}: Generating PDF Userguide (Windows CLI)"   
        VERBATIM
    )
  else()
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf"
        
        # FIX: Same target dependency adjustment applied to Linux
        DEPENDS ${TARGET_NAME}_ug_html "${LATEX_MAIN_INPUT}"
        
        COMMAND make -C ${CMAKE_CURRENT_BINARY_DIR}/latex >> /dev/null
        COMMENT "${TARGET_NAME}: Generating PDF Userguide (Linux)"
        VERBATIM
    )
  endif()

  # Custom Target for PDF
  add_custom_target(${TARGET_NAME}_ug_pdf
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf"
  )
      
  # 3. Custom Command: Copies and renames the final PDF
  add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf"
    COMMAND ${CMAKE_COMMAND} -E copy
      "${CMAKE_CURRENT_BINARY_DIR}/latex/refman.pdf"
      "${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf"
    COMMENT "${TARGET_NAME}: Copying PDF to final location"
    VERBATIM
  )
  
  # Master PDF Target for this subdirectory (Dynamic name)
  add_custom_target(${TARGET_NAME}_pdf
      DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.pdf"
  )

  add_dependencies(${TARGET_NAME}_pdf ${TARGET_NAME}_ug_pdf)

endfunction()
