cmake_minimum_required(VERSION 3.19)
project(my_project-superbuid)

# GoogleTest requires at least C++11
set(CMAKE_CXX_STANDARD 11)

#[[
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY  https://github.com/google/googletest.git
    GIT_TAG         release-1.11.0
)

# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)
]]

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)



include(ExternalProject)

ExternalProject_Add(googletest
    PREFIX              ${PROJECT_BINARY_DIR}/googletest
    GIT_REPOSITORY      https://github.com/google/googletest.git
    GIT_TAG             release-1.11.0
    GIT_SHALLOW         TRUE
    GIT_PROGRESS        TRUE
    CMAKE_ARGS          -DCMAKE_INSTALL_PREFIX=${PROJECT_BINARY_DIR}/googletest/install -Dgtest_force_shared_crt=OFF
    BUILD_ALWAYS        TRUE
    UPDATE_DISCONNECTED TRUE
    )


ExternalProject_Add(my_project
    PREFIX          ${PROJECT_BINARY_DIR}/my_project
    SOURCE_DIR      ${PROJECT_SOURCE_DIR}/..
    CMAKE_ARGS      -DLIBS_PATH=${PROJECT_BINARY_DIR}/googletest/install
    BUILD_ALWAYS    TRUE
    )
