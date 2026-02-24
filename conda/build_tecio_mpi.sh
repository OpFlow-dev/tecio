#!/bin/bash
set -ex

# Use conda toolchain (set by conda-build)
# For MPI, use mpicc/mpicxx wrappers from conda mpich
export CC="${PREFIX}/bin/mpicc"
export CXX="${PREFIX}/bin/mpicxx"

echo "Using Conda MPI Toolchain:"
echo "  CC: ${CC}"
echo "  CXX: ${CXX}"
echo "  PREFIX: ${PREFIX}"

# Create cmake config directory
mkdir -p ${SRC_DIR}/teciompisrc/cmake
cp ${RECIPE_DIR}/teciompiConfig.cmake.in ${SRC_DIR}/teciompisrc/cmake/

# Fix for Boost + GCC 15 __float128 conflict
# Use -std=c++14 instead of -std=gnu++14 to avoid __float128
cat >> ${SRC_DIR}/teciompisrc/CMakeLists.txt << 'EOF'

# Fix for GCC 15 + Boost conflict: use strict C++14 standard
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Installation rules (added by conda build)
install(TARGETS teciompi
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)

# Install all headers to include/tecio/
file(GLOB TECIOMPI_HEADERS "*.h" "*.hpp")
install(FILES ${TECIOMPI_HEADERS} DESTINATION include/tecio)

# CMake package configuration
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/teciompiConfigVersion.cmake"
    VERSION 2025.2
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/teciompiConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/teciompiConfig.cmake"
    INSTALL_DESTINATION lib/cmake/teciompi
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/teciompiConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/teciompiConfigVersion.cmake"
    DESTINATION lib/cmake/teciompi
)
EOF

# Create build directory
mkdir -p ${SRC_DIR}/teciompisrc/build
cd ${SRC_DIR}/teciompisrc/build

# Configure with CMake using conda toolchain
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DMPI_C_COMPILER=${CC} \
    -DMPI_CXX_COMPILER=${CXX} \
    -DBoost_INCLUDE_DIR=${PREFIX}/include \
    -DBoost_LIBRARY_DIR=${PREFIX}/lib \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_CXX_EXTENSIONS=OFF

# Build
make -j${CPU_COUNT}

# Install using cmake
cmake --install .
