# CMakeList.txt : CMake project for spdlog, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.10)

# Set policies
cmake_policy(SET CMP0114 NEW)

project(spdlog_test-superbuild)

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

ExternalProject_Add(spdlog
    PREFIX                  ${LIBRARIES_PREFIX}/spdlog
    GIT_REPOSITORY          https://github.com/gabime/spdlog.git
    GIT_TAG                 v1.11.0 
    GIT_SHALLOW             YES
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            NO
    CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX:PATH=${LIBRARIES_INSTALL_PREFIX}/spdlog
)

ExternalProject_Add (spdlog_test
    PREFIX                  ${LIBRARIES_PREFIX}/spdlog_test
    DEPENDS                 spdlog
    SOURCE_DIR              ${PROJECT_SOURCE_DIR}/../
    BUILD_ALWAYS            TRUE
    INSTALL_COMMAND         ""
    CMAKE_CACHE_ARGS        -DCMAKE_PREFIX_PATH:STRING=${LIBRARIES_INSTALL_PREFIX}/spdlog
)
