 #
# === CMake lists for the multiuser ===
#


# === CMake options ===

# Set CMake version
cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

#
# Configure CMake environment
#

# Register general cmake commands
#include(cmake/Custom.cmake)

# Set policies
#set_policy(CMP0054 NEW) # ENABLE CMP0054: Only interpret if() arguments as variables or keywords when unquoted.
#set_policy(CMP0042 NEW) # ENABLE CMP0042: MACOSX_RPATH is enabled by default.
#set_policy(CMP0063 NEW) # ENABLE CMP0063: Honor visibility properties for all target types.
#set_policy(CMP0077 NEW) # ENABLE CMP0077: option() honors normal variables

# Remove ZERO_CHECK target
#set(CMAKE_SUPPRESS_REGENERATION true)

# Include cmake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(GenerateExportHeader)

# Include custom cmake modules
include(cmake/GenerateTemplateExportHeader.cmake)
include(cmake/GetGitRevisionDescription.cmake)



#
# === Project description and (meta) information ===
#

# Get git revision
get_git_head_revision(GIT_REFSPEC GIT_SHA1)
string(SUBSTRING "${GIT_SHA1}" 0 12 GIT_REV)
if(NOT GIT_SHA1)
    set(GIT_REV "0")
endif()

# Meta information about the project
set(META_PROJECT_NAME        "multiuser")
set(META_PROJECT_DESCRIPTION "Multiuser project for syncroniz/monitor users from gotoviar.")
set(META_AUTHOR_ORGANIZATION "Gotoviar B.V")
set(META_AUTHOR_DOMAIN       "https://gotoviar.com")
set(META_AUTHOR_MAINTAINER   "info@gotoviar.com")
set(META_VERSION_MAJOR       "1")
set(META_VERSION_MINOR       "0")
set(META_VERSION_PATCH       "0")
set(META_VERSION_REVISION    "${GIT_REV}")
set(META_VERSION             "${META_VERSION_MAJOR}.${META_VERSION_MINOR}.${META_VERSION_PATCH}")
set(META_NAME_VERSION        "${META_PROJECT_NAME} v${META_VERSION} (${META_VERSION_REVISION})")
set(META_CMAKE_INIT_SHA      "${GIT_SHA1}")

string(MAKE_C_IDENTIFIER ${META_PROJECT_NAME} META_PROJECT_ID)
string(TOUPPER ${META_PROJECT_ID} META_PROJECT_ID)


#
# Project configuration options
#

# Project options
option(MULTIUSER_MSVC_STATIC_RUNTIME        "Link with static msvc runtime libraries"       ON)
#option(OPTION_SELF_CONTAINED  "Create a self-contained install with all dependencies." OFF)
#option(OPTION_BUILD_TESTS     "Build tests."                                           ON)
#option(OPTION_BUILD_DOCS      "Build documentation."                                   OFF)
#option(OPTION_ENABLE_COVERAGE "Add coverage information."                              OFF)

#
# Declare project
#

# Generate folders for IDE targets (e.g., VisualStudio solutions)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(IDE_FOLDER "")

# Declare project
project(${META_PROJECT_NAME} LANGUAGES C CXX)

# Set standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})

# Create executable
add_executable(${PROJECT_NAME})

# Create version file
file(WRITE "${PROJECT_BINARY_DIR}/VERSION" "${META_NAME_VERSION}")

# Generate version header
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/version.h.in ${PROJECT_BINARY_DIR}/generated/include/version.h @ONLY)
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_BINARY_DIR}/generated/include/version.h)

# Set sources root path
set(SOURCE_ROOT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/sources/")

file(
    GLOB_RECURSE SOURCE_LIST
    LIST_DIRECTORIES false
    "${SOURCE_ROOT_PATH}/*.c"
    "${SOURCE_ROOT_PATH}/*.cpp"
    "${SOURCE_ROOT_PATH}/*.h"
    "${SOURCE_ROOT_PATH}/*.hpp"
)

foreach(_source IN ITEMS ${SOURCE_LIST})
    get_filename_component(_source_path "${_source}" PATH)
    file(RELATIVE_PATH _source_path_rel "${SOURCE_ROOT_PATH}" "${_source_path}")
    string(REPLACE "/" "\\" _group_path "${_source_path_rel}")
    source_group("source\\${_group_path}" FILES "${_source}")
endforeach()

target_sources(${PROJECT_NAME} PRIVATE ${SOURCE_LIST})
target_include_directories(${PROJECT_NAME} PRIVATE ${SOURCE_ROOT_PATH})

# Set compiler options
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    if (MULTIUSER_MSVC_STATIC_RUNTIME)
        set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    else()
        set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    endif()
endif()

if(MSVC)
    target_compile_definitions(${PROJECT_NAME} PRIVATE -D_WIN32_WINNT=0x600 -D_SCL_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_WARNINGS -D_WINSOCK_DEPRECATED_NO_WARNINGS)
endif()

# Add for libraries
#set(CMAKE_FIND_DEBUG_MODE TRUE)
find_package(Boost 1.78 REQUIRED COMPONENTS url)
#set(CMAKE_FIND_DEBUG_MODE FALSE)

#target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE Boost::headers Boost::url)
#message(STATUS "Boost_INCLUDE_DIRS: ${Boost_INCLUDE_DIRS}")
#message(STATUS "Boost_LIBRARIES: ${Boost_LIBRARIES}")

# add openssl
find_package(OpenSSL REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE ${OPENSSL_LIBRARIES})
target_include_directories(${PROJECT_NAME} PRIVATE ${OPENSSL_INCLUDE_DIR})

find_package(nlohmann_json REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json)

find_package(argparse REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC argparse::argparse)

# link system libraries
if(UNIX)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${CMAKE_DL_LIBS})
endif()

if(WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE ws2_32 wsock32 crypt32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE -D_WIN32_WINDOWS)
endif()