cmake_minimum_required(VERSION 3.10...4.1)

if (NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE Release CACHE STRING "CMake build type (Debug|Release)" FORCE)
endif ()

project (tecio C CXX)

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

include_directories(.)

set (CMAKE_CXX_STANDARD 14)
IF (WIN32)
    # C++20 and newer has conforming C++, "/permissive-", as the default. Until C++20 is updated,
    # enable conforming C++ by disabling permissive mode.
    set(BaseFlags "/permissive- /Zc:__cplusplus /EHsc /MP /wd\"4996\" /D MSWIN /D TP_PROJECT_USES_BOOST /D BOOST_ALL_NO_LIB /D MAKEARCHIVE /D NO_THIRD_PARTY_LIBS /D NO_ASSERTS /D tecio_EXPORTS")
ELSE ()
	set(BaseFlags "-DLINUX -DLINUX64 -DTP_PROJECT_USES_BOOST -DBOOST_ALL_NO_LIB -DMAKEARCHIVE -DNO_THIRD_PARTY_LIBS -DNO_ASSERTS -Dtecio_EXPORTS -fmessage-length=0 -fPIC -fvisibility=hidden -w")
ENDIF ()
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${BaseFlags}")

FILE(GLOB mainFiles "*.cpp" "*.h")
LIST(REMOVE_ITEM mainFiles "${CMAKE_CURRENT_SOURCE_DIR}/szcombine.cpp")

add_library(tecio STATIC ${mainFiles})

add_executable(szcombine "szcombine.cpp")
if (WIN32)
    target_link_libraries(szcombine tecio)
else ()
    target_link_libraries(szcombine tecio pthread)
endif ()

# Had to add this so building tecio care package within loci-chem works...
set_target_properties(tecio PROPERTIES LINKER_LANGUAGE CXX)
set_target_properties(szcombine PROPERTIES LINKER_LANGUAGE CXX)
