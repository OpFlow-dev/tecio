@echo on

:: Use conda toolchain (set by conda-build)
echo Using Conda MPI Toolchain:
echo   CC: %CC%
echo   CXX: %CXX%
echo   LIBRARY_PREFIX: %LIBRARY_PREFIX%
echo   LIBRARY_INC: %LIBRARY_INC%
echo   LIBRARY_LIB: %LIBRARY_LIB%

:: Create cmake config directory
if not exist %SRC_DIR%\teciompisrc\cmake mkdir %SRC_DIR%\teciompisrc\cmake
copy %RECIPE_DIR%\teciompiConfig.cmake.in %SRC_DIR%\teciompisrc\cmake\

:: Append install rules and GCC compatibility fix to CMakeLists.txt
(
echo.
echo # Fix for GCC 15 + Boost conflict: use strict C++14 standard
echo set^(CMAKE_CXX_EXTENSIONS OFF^)
echo set^(CMAKE_CXX_STANDARD_REQUIRED ON^)
echo.
echo # Installation rules (added by conda build)
echo install^(TARGETS teciompi^
echo     ARCHIVE DESTINATION lib^
echo     RUNTIME DESTINATION bin^
echo     LIBRARY DESTINATION lib^
echo ^)
echo.
echo # Install all headers to include/tecio/
echo file^(GLOB TECIOMPI_HEADERS "*.h" "*.hpp"^)
echo install^(FILES ${TECIOMPI_HEADERS} DESTINATION include/tecio^)
echo.
echo # CMake package configuration
echo include^(CMakePackageConfigHelpers^)
echo write_basic_package_version_file^(^
echo     "${CMAKE_CURRENT_BINARY_DIR}/teciompiConfigVersion.cmake"^
echo     VERSION 2025.2^
echo     COMPATIBILITY AnyNewerVersion^
echo ^)
echo.
echo configure_package_config_file^(^
echo     "${CMAKE_CURRENT_SOURCE_DIR}/cmake/teciompiConfig.cmake.in"^
echo     "${CMAKE_CURRENT_BINARY_DIR}/teciompiConfig.cmake"^
echo     INSTALL_DESTINATION lib/cmake/teciompi^
echo ^)
echo.
echo install^(FILES^
echo     "${CMAKE_CURRENT_BINARY_DIR}/teciompiConfig.cmake"^
echo     "${CMAKE_CURRENT_BINARY_DIR}/teciompiConfigVersion.cmake"^
echo     DESTINATION lib/cmake/teciompi^
echo ^)
) >> %SRC_DIR%\teciompisrc\CMakeLists.txt

:: Create build directory
if not exist %SRC_DIR%\teciompisrc\build mkdir %SRC_DIR%\teciompisrc\build
cd %SRC_DIR%\teciompisrc\build

:: Configure with CMake using conda toolchain
cmake .. ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DMPI_HOME=%LIBRARY_PREFIX% ^
    -DBoost_INCLUDE_DIR=%LIBRARY_INC% ^
    -DBoost_LIBRARY_DIR=%LIBRARY_LIB% ^
    -DCMAKE_CXX_STANDARD=14 ^
    -DCMAKE_CXX_EXTENSIONS=OFF ^
    -G "NMake Makefiles"

if errorlevel 1 exit 1

:: Build
nmake
if errorlevel 1 exit 1

:: Install using cmake
cmake --install .
if errorlevel 1 exit 1
