cmake_minimum_required(VERSION 3.17)

#
# This project allows to configure, build, archive and upload an OpenSSL install tree.
#

project(OpenSSL)

set(config_type "")

if(CMAKE_CONFIGURATION_TYPES)
    message("Multi-configuration generator ${CMAKE_CONFIGURATION_TYPES}")
    set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "My multi config types" FORCE)
    list(APPEND config_type ${CMAKE_CONFIGURATION_TYPES})
else()
    message("Single-configuration generator ${CMAKE_BUILD_TYPE}")
    list(APPEND config_type "${CMAKE_BUILD_TYPE}")
endif()

include(ExternalProject)

set(version "3.0.0")
string(REPLACE "." "_" version_underscore ${version})
set(source_archive_name "openssl-${version_underscore}")
math(EXPR bitness "${CMAKE_SIZEOF_VOID_P} * 8")
set(binary_archive_name "${source_archive_name}-install-msvc${MSVC_VERSION}-${bitness}")

find_program(PERL_COMMAND "Path to perl executable")
if(NOT PERL_COMMAND)
  message(FATAL_ERROR "PERL_COMMAND is not set !")
endif()
get_filename_component(PERL_BIN_DIR ${PERL_COMMAND} PATH)

set(proj ${PROJECT_NAME})

if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(config "VC-WIN32")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(config "VC-WIN64A")
endif()

#if(CMAKE_BUILD_TYPE STREQUAL "Debug")
#    set(config "debug-${config}")
#endif()

foreach (ct_entry IN LISTS config_type)
    #message("config type:  ${ct_entry}")
    if(${ct_entry} STREQUAL "Debug")
        set(is_debug "debug-")
    else()
        set(is_debug '')
    endif()
    
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${proj}-configure-${ct_entry}.bat"
        "set PATH=%PATH%;${PERL_BIN_DIR}
        perl Configure ${is_debug}${config} no-asm --prefix=${CMAKE_BINARY_DIR}/${binary_archive_name}-${ct_entry} --openssldir=${CMAKE_BINARY_DIR}/${binary_archive_name}-${ct_entry}
        ")    
endforeach()


file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${proj}-build.bat"
    "set PATH=%PATH%;${PERL_BIN_DIR}
    nmake")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${proj}-install.bat"
    "set PATH=%PATH%;${PERL_BIN_DIR}
    nmake install")

ExternalProject_Add(${proj}
    # Use github archive instead of the one hosted on openssl.org because of CMake bug #13251
    GIT_REPOSITORY "https://github.com/openssl/openssl.git"
    GIT_TAG  "openssl-${version}"
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
    SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/${proj}-configure-$<CONFIG>.bat"
    BUILD_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/${proj}-build.bat"
    INSTALL_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/${proj}-install.bat"
    )
