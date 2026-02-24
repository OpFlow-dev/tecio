#!/bin/bash
set -ex

# Use conda toolchain (set by conda-build)
echo "Using Conda Toolchain:"
echo "  CC: ${CC}"
echo "  CXX: ${CXX}"
echo "  PREFIX: ${PREFIX}"

# Create cmake config directory
mkdir -p ${SRC_DIR}/teciosrc/cmake
cp ${RECIPE_DIR}/tecioConfig.cmake.in ${SRC_DIR}/teciosrc/cmake/

# Fix for Boost + GCC 15 __float128 conflict
# Use -std=c++14 instead of -std=gnu++14 to avoid __float128
cat >> ${SRC_DIR}/teciosrc/CMakeLists.txt << 'EOF'

# Fix for GCC 15 + Boost conflict: use strict C++14 standard
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Installation rules (added by conda build)
install(TARGETS tecio szcombine
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)

# Install all headers to include/tecio/
file(GLOB TECIO_HEADERS "*.h" "*.hpp" "*.inc")
install(FILES ${TECIO_HEADERS} DESTINATION include/tecio)

# CMake package configuration
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/tecioConfigVersion.cmake"
    VERSION 2025.2
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/tecioConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/tecioConfig.cmake"
    INSTALL_DESTINATION lib/cmake/tecio
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/tecioConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/tecioConfigVersion.cmake"
    DESTINATION lib/cmake/tecio
)
EOF

# Create build directory
mkdir -p ${SRC_DIR}/teciosrc/build
cd ${SRC_DIR}/teciosrc/build

# Configure with CMake using conda toolchain
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DBoost_INCLUDE_DIR=${PREFIX}/include \
    -DBoost_LIBRARY_DIR=${PREFIX}/lib \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_CXX_EXTENSIONS=OFF

# Build
make -j${CPU_COUNT}

# Install using cmake
cmake --install .
