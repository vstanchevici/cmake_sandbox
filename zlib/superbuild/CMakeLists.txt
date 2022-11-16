# CMakeList.txt : CMake project for sync-server, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.10)

project(zlib_test-superbuild)

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

ExternalProject_Add(zlib
    PREFIX                  ${LIBRARIES_PREFIX}/zlib
    GIT_REPOSITORY          https://github.com/madler/zlib.git
    GIT_TAG                 v1.2.11
    GIT_SHALLOW             1
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE    
    CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX=${LIBRARIES_INSTALL_PREFIX}/zlib
)
ExternalProject_Add_Step(zlib replace_cmakelists
    DEPENDEES download
    DEPENDERS configure
    COMMAND cp ${PROJECT_SOURCE_DIR}/patch/zlib1.2.11/CMakeLists.txt                   ${LIBRARIES_PREFIX}/zlib/src/zlib/CMakeLists.txt
)

ExternalProject_Add(libzip
    PREFIX                  ${LIBRARIES_PREFIX}/libzip
    DEPENDS                 zlib
    GIT_REPOSITORY          https://github.com/nih-at/libzip.git
    GIT_TAG                 v1.9.2
    GIT_SHALLOW             1
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE
    CMAKE_ARGS              -DBUILD_TOOLS:BOOL=OFF
                            -DBUILD_REGRESS:BOOL=OFF
                            -DBUILD_EXAMPLES:BOOL=OFF
                            -DBUILD_DOC:BOOL=OFF
                            -DBUILD_SHARED_LIBS:BOOL=OFF
    CMAKE_CACHE_ARGS        -DCMAKE_INSTALL_PREFIX:STRING=${LIBRARIES_INSTALL_PREFIX}/libzip
                            -DCMAKE_PREFIX_PATH:STRING=${LIBRARIES_INSTALL_PREFIX}/zlib
)

ExternalProject_Add (zlib_test
    PREFIX              ${LIBRARIES_PREFIX}/zlib_test
    DEPENDS             libzip
    SOURCE_DIR          ${PROJECT_SOURCE_DIR}/../
    BUILD_ALWAYS        TRUE
    INSTALL_COMMAND     ""
    CMAKE_CACHE_ARGS    -DCMAKE_PREFIX_PATH:STRING=${LIBRARIES_INSTALL_PREFIX}/zlib
                        -DCMAKE_PREFIX_PATH:STRING=${LIBRARIES_INSTALL_PREFIX}/libzip
)
