This contains CMake scripts that are intended to provide a commonality among my projects.


## CMake function summary

### cmake/Gm3zzaVersioning.cmake

- `gm3zza_split_version`: Splits a `<project>_VERSION` string into major, minor, patch, and tweak variables in the parent scope.
- `gm3zza_generate_app_source`: Expands a source template into a generated `.cpp` file in the build tree and returns its path.

### cmake/Gm3zzaResources.cmake

- `gm3zza_stage_runtime_files`: Copies runtime data files into the build output after a target is built.
- `gm3zza_install_runtime_files`: Installs runtime files and directories into the configured application data location.
- `gm3zza_enable_windows_icon`: Enables Windows icon/resource generation for MSVC builds via the shared icon helper.

### cmake/windows/icon_helper.cmake

- `generate_windows_icon`: Converts a PNG file into a Windows `.ico` file, with optional white-to-transparent thresholding.
- `configure_windows_resource`: Configures a Windows `.rc` resource file from a template.
- `generate_windows_icon_and_resource`: Generates both the Windows icon and matching resource file in one step.

### cmake/Gm3zzaDocs.cmake

- `gm3zza_enable_docs`: Sets up Doxygen-driven user guide and API documentation targets, optionally including PDF output.

### cmake/Gm3zzaProjectDefaults.cmake

- `gm3zza_project_defaults`: Applies common GM3ZZA project defaults such as C++ standard, build settings, and home-directory detection.
- `gm3zza_set_default_install_dirs`: Defines the default install directory used for application data files.
- `gm3zza_define_standard_options`: Declares shared build options such as PDB and documentation generation support.

### cmake/Gm3zzaWindowsRuntime.cmake

- `gm3zza_copy_runtime_dlls`: Copies a target's runtime DLL dependencies into the build directory on Windows.
- `gm3zza_register_runtime_dlls`: Registers extra runtime DLLs so they can be installed later as a group.
- `gm3zza_install_registered_runtime_dlls`: Installs all previously registered runtime DLLs into the binary install directory.

### cmake/Gm3zzaZzacommon.cmake

- `gm3zza_use_zzacommon`: Finds or fetches `zzacommon` and makes the requested components available to the project.

### cmake/deps/portaudio_helper.cmake

- `gm3zza_find_portaudio`: Locates PortAudio libraries and headers, using `PORTAUDIO_ROOT` or system installs depending on platform.

### cmake/deps/fftw_helper.cmake

- `gm3zza_find_fftw`: Locates FFTW headers and libraries, and copies the FFTW DLL for MSVC development builds.
- `gm3zza_register_fftw_dlls`: Registers the discovered FFTW DLL for later installation on Windows.

### cmake/deps/hamlib_helper.cmake

- `gm3zza_find_hamlib`: Locates Hamlib and its runtime DLLs, with extra MSVC fallback handling via `HAMLIB_ROOT`.
- `gm3zza_register_hamlib_dlls`: Registers Hamlib runtime DLLs for installation on Windows.
- `gm3zza_install_hamlib_dlls`: Installs the Hamlib runtime DLL set into the application binary directory.

### cmake/deps/piper_helper.cmake

- `gm3zza_find_piper`: Locates Piper and ONNX Runtime headers, libraries, and DLLs for the active platform.
- `gm3zza_register_piper_dlls`: Registers Piper and ONNX Runtime DLLs for installation on Windows.

