# CMakeList.txt : CMake project for sync-server, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.10)

project(libuv_test-superbuild)

# Set standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

include(ProcessorCount)
ProcessorCount(CPU_COUNT)
if(CPU_COUNT EQUAL 0)
    set(CPU_COUNT 1)
endif()
math(EXPR CPU_COUNT "${CPU_COUNT} / 2 + 1")


include(ExternalProject)

if(NOT DEFINED LIBRARIES_PREFIX)
    set(LIBRARIES_PREFIX ${CMAKE_BINARY_DIR})
endif()

if(NOT DEFINED LIBRARIES_INSTALL_PREFIX)
    set(LIBRARIES_INSTALL_PREFIX ${LIBRARIES_PREFIX}/installed/${CMAKE_SYSTEM_NAME})
endif()

#https://sourcegraph.com/github.com/neovim/neovim/-/blob/CMakeLists.txt
#https://community.opengroup.org/osdu/platform/domain-data-mgmt-services/seismic/open-vds/-/blob/master/CMake/FindLibUV.cmake
#https://gitlab.cs.washington.edu/syslab/diamond-src/blob/master/platform/cmake/Modules/FindLibUV.cmake
#https://github.com/xenoscopic/libuv-cmake/blob/master/Findlibuv.cmake

ExternalProject_Add(libuv
    PREFIX                  ${LIBRARIES_PREFIX}/libuv
    GIT_REPOSITORY          https://github.com/libuv/libuv.git
    GIT_TAG                 v1.42.0
    CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX:PATH=${LIBRARIES_INSTALL_PREFIX}/libuv
    CMAKE_CACHE_ARGS        -DLIBUV_BUILD_BENCH:BOOL=OFF -DLIBUV_BUILD_TESTS:BOOL=OFF
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE
    #CONFIGURE_COMMAND      ""
    #BUILD_COMMAND          ""
    #INSTALL_COMMAND        ""
    #TEST_COMMAND           ""
)


ExternalProject_Add (libuv_test
    PREFIX              ${LIBRARIES_PREFIX}/libuv_test
    DEPENDS             libuv
    SOURCE_DIR          ${PROJECT_SOURCE_DIR}/../
    CMAKE_CACHE_ARGS    -DCMAKE_PREFIX_PATH:STRING="${LIBRARIES_INSTALL_PREFIX}/libuv;"
    BUILD_ALWAYS        TRUE
    INSTALL_COMMAND     ""
)