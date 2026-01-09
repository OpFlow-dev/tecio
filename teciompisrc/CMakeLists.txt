cmake_minimum_required(VERSION 3.10...4.1)

if (NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE Release CACHE STRING "CMake build type (Debug|Release)" FORCE)
endif ()

project (teciompi)

if (Boost_INCLUDE_DIR)
    if (NOT EXISTS "${Boost_INCLUDE_DIR}")
        message(FATAL_ERROR "Boost_INCUDE_DIR (${Boost_INCLUDE_DIR}) does not exist")
    else ()
        include_directories(SYSTEM ${Boost_INCLUDE_DIR})
    endif ()
else ()
    find_package(Boost 1.69.0)
    if (NOT Boost_FOUND)
        Set (Boost_INCLUDE_DIR /3rdpartylibs/boost/1.69.0/build/linux64-centos6.10/release/include CACHE PATH "Boost include directory")
        message (WARNING "Warning:  Cannot find boost include directories. Hardcoding to ${Boost_INCLUDE_DIR}")
    endif ()
    include_directories(SYSTEM ${Boost_INCLUDE_DIR})
endif()

FIND_PACKAGE(MPI)
IF (NOT MPI_CXX_FOUND)
    message(FATAL_ERROR "Unable to find MPI installation.")
ENDIF ()

include_directories(.)
if(NOT "${MPI_CXX_INCLUDE_PATH}" STREQUAL "")
    include_directories(SYSTEM "${MPI_CXX_INCLUDE_PATH}")
endif()

set (CMAKE_CXX_STANDARD 14)
IF (WIN32)
    # C++20 and newer has conforming C++, "/permissive-", as the default. Until C++20 is updated,
    # enable conforming C++ by disabling permissive mode.
    set(BaseFlags "/permissive- /Zc:__cplusplus /EHsc /MP /wd\"4996\" /D MSWIN /D TP_PROJECT_USES_BOOST /D BOOST_ALL_NO_LIB /D MAKEARCHIVE /D NO_THIRD_PARTY_LIBS /D TECIOMPI /D NO_ASSERTS /D tecio_EXPORTS")
ELSE ()
    set(BaseFlags "-DLINUX -DLINUX64 -DTP_PROJECT_USES_BOOST -DBOOST_ALL_NO_LIB -DMAKEARCHIVE -DNO_THIRD_PARTY_LIBS -DTECIOMPI -DOMPI_SKIP_MPICXX -DMPICH_SKIP_MPICXX -DMPI_NO_CPPBIND -DNO_ASSERTS -Dtecio_EXPORTS -fmessage-length=0 -fPIC -fvisibility=hidden -w")
ENDIF ()
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${BaseFlags} ${MPI_CXX_COMPILE_FLAGS}")

FILE(GLOB mainFiles "*.cpp" "*.h")
LIST(REMOVE_ITEM mainFiles "${CMAKE_CURRENT_SOURCE_DIR}/szcombine.cpp")

add_library(teciompi STATIC ${mainFiles})

add_executable(szcombine "szcombine.cpp")
target_link_libraries(szcombine teciompi ${MPI_LIBRARIES})

