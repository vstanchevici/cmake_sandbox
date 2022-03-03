# CMakeList.txt : CMake project for sync-server, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.10)

project(plog_test-superbuild)

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
    set(LIBRARIES_INSTALL_PREFIX ${LIBRARIES_PREFIX}/install/${CMAKE_SYSTEM_NAME})
endif()

ExternalProject_Add(plog
    PREFIX                  ${LIBRARIES_PREFIX}/plog
    GIT_REPOSITORY          https://github.com/SergiusTheBest/plog.git
    GIT_TAG                 1.1.6
    GIT_SHALLOW             ON
    CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX:PATH=${LIBRARIES_INSTALL_PREFIX}/plog
    CMAKE_CACHE_ARGS        -DPLOG_BUILD_SAMPLES:BOOL=OFF
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE
)

ExternalProject_Add (plog_test
    PREFIX              ${LIBRARIES_PREFIX}/plog_test
    DEPENDS             plog
    SOURCE_DIR          ${PROJECT_SOURCE_DIR}/../
    CMAKE_CACHE_ARGS    -DPLOG_INCLUDE_DIR:STRING=${LIBRARIES_INSTALL_PREFIX}/plog/include
    BUILD_ALWAYS        TRUE
    INSTALL_COMMAND     ""
)
