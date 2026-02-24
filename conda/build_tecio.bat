@echo on

:: Use conda toolchain (set by conda-build)
echo Using Conda Toolchain:
echo   CC: %CC%
echo   CXX: %CXX%
echo   LIBRARY_PREFIX: %LIBRARY_PREFIX%
echo   LIBRARY_INC: %LIBRARY_INC%
echo   LIBRARY_LIB: %LIBRARY_LIB%

:: Create cmake config directory
if not exist %SRC_DIR%\teciosrc\cmake mkdir %SRC_DIR%\teciosrc\cmake
copy %RECIPE_DIR%\tecioConfig.cmake.in %SRC_DIR%\teciosrc\cmake\

:: Append install rules and GCC compatibility fix to CMakeLists.txt
(
echo.
echo # Fix for GCC 15 + Boost conflict: use strict C++14 standard
echo set^(CMAKE_CXX_EXTENSIONS OFF^)
echo set^(CMAKE_CXX_STANDARD_REQUIRED ON^)
echo.
echo # Installation rules (added by conda build)
echo install^(TARGETS tecio szcombine^
echo     ARCHIVE DESTINATION lib^
echo     RUNTIME DESTINATION bin^
echo     LIBRARY DESTINATION lib^
echo ^)
echo.
echo # Install all headers to include/tecio/
echo file^(GLOB TECIO_HEADERS "*.h" "*.hpp" "*.inc"^)
echo install^(FILES ${TECIO_HEADERS} DESTINATION include/tecio^)
echo.
echo # CMake package configuration
echo include^(CMakePackageConfigHelpers^)
echo write_basic_package_version_file^(^
echo     "${CMAKE_CURRENT_BINARY_DIR}/tecioConfigVersion.cmake"^
echo     VERSION 2025.2^
echo     COMPATIBILITY AnyNewerVersion^
echo ^)
echo.
echo configure_package_config_file^(^
echo     "${CMAKE_CURRENT_SOURCE_DIR}/cmake/tecioConfig.cmake.in"^
echo     "${CMAKE_CURRENT_BINARY_DIR}/tecioConfig.cmake"^
echo     INSTALL_DESTINATION lib/cmake/tecio^
echo ^)
echo.
echo install^(FILES^
echo     "${CMAKE_CURRENT_BINARY_DIR}/tecioConfig.cmake"^
echo     "${CMAKE_CURRENT_BINARY_DIR}/tecioConfigVersion.cmake"^
echo     DESTINATION lib/cmake/tecio^
echo ^)
) >> %SRC_DIR%\teciosrc\CMakeLists.txt

:: Create build directory
if not exist %SRC_DIR%\teciosrc\build mkdir %SRC_DIR%\teciosrc\build
cd %SRC_DIR%\teciosrc\build

:: Configure with CMake using conda toolchain
cmake .. ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
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
