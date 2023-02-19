
#
# === CMake lists for the multiuser-superbuild ===
#


# === CMake options ===

# Set CMake version
cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

# Set policies
cmake_policy(SET CMP0114 NEW)

# Set paths

if(NOT DEFINED LIBRARIES_PREFIX)
    set(LIBRARIES_PREFIX ${CMAKE_BINARY_DIR})
endif()

if(NOT DEFINED LIBRARIES_INSTALL_PREFIX)
    set(LIBRARIES_INSTALL_PREFIX ${LIBRARIES_PREFIX}/install/${CMAKE_SYSTEM_NAME})
endif()

# If is not set CMAKE_INSTALL_PREFIX set it
if(NOT CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX ${LIBRARIES_INSTALL_PREFIX} CACHE STRING "Final install location." FORCE)
endif()


#
# Configure CMake environment
#

# Declare project
project(multiuser-superbuild LANGUAGES C CXX)


# Set standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

include(ProcessorCount)
ProcessorCount(PROCESSOR_COUNT)
set(NUM_BUILD_JOBS ${PROCESSOR_COUNT} CACHE STRING "Number of build jobs '-j <n>'")
if(NUM_BUILD_JOBS EQUAL 0)
    set(NUM_BUILD_JOBS 1)
endif()
math(EXPR NUM_BUILD_JOBS "${NUM_BUILD_JOBS} / 2 + 1")

option(MULTIUSER_MSVC_STATIC_RUNTIME "Link with static msvc runtime libraries" ON)


include(ExternalProject)

#-DBOOST_INCLUDE_LIBRARIES="comp1;comp2;"
ExternalProject_Add(boost
    PREFIX                  ${LIBRARIES_PREFIX}/boost
    GIT_REPOSITORY          https://github.com/boostorg/boost.git
    GIT_TAG                 boost-1.81.0
    GIT_SHALLOW             YES
    GIT_SUBMODULES_RECURSE  YES
    CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX:PATH=${LIBRARIES_INSTALL_PREFIX}/boost
    CMAKE_CACHE_ARGS        -DBOOST_RUNTIME_LINK:STRING=$<IF:$<BOOL:${MULTIUSER_MSVC_STATIC_RUNTIME}>,static,shared>
                            -DBUILD_SHARED_LIBS:BOOL=NO
    UPDATE_DISCONNECTED     YES
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            NO
)

ExternalProject_Add(json
    PREFIX                  ${LIBRARIES_PREFIX}/json
    GIT_REPOSITORY          https://github.com/nlohmann/json.git
    GIT_TAG                 v3.11.2
    GIT_SHALLOW             1
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE
    CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX=${LIBRARIES_INSTALL_PREFIX}/json
                            -DJSON_BuildTests=OFF
                            -DJSON_Install=ON
)

ExternalProject_Add(argparse
    PREFIX                  ${LIBRARIES_PREFIX}/argparse
    GIT_REPOSITORY          https://github.com/p-ranav/argparse.git
    GIT_TAG                 v2.9
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE
    CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX:PATH=${LIBRARIES_INSTALL_PREFIX}/argparse
                            -DARGPARSE_BUILD_TESTS:BOOL=OFF
                            -DARGPARSE_LONG_VERSION_ARG_ONLY:BOOL=OFF
)

if(WIN32)
    #read more about perl strawberry tools here: https://strawberryperl.com/
    ExternalProject_Add(perl_strawberry
        PREFIX                      ${LIBRARIES_PREFIX}/perl_strawberry
        URL                         https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit-portable.zip
        DOWNLOAD_EXTRACT_TIMESTAMP  YES
        UPDATE_DISCONNECTED         YES
        UPDATE_COMMAND              ""
        CONFIGURE_COMMAND           ""
        BUILD_COMMAND               ""
        INSTALL_COMMAND             ""
    )
    ExternalProject_Get_property(perl_strawberry SOURCE_DIR)
    set(PERL_STRAWBERRY_DIR ${SOURCE_DIR})

    set(PERL_COMMAND ${PERL_STRAWBERRY_DIR}/perl/bin/perl.exe)

    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
        separate_arguments(openssl_config NATIVE_COMMAND "${PERL_COMMAND} Configure $<$<CONFIG:Debug>:--debug> VC-WIN32")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        separate_arguments(openssl_config NATIVE_COMMAND "${PERL_COMMAND} Configure $<$<CONFIG:Debug>:--debug> VC-WIN64A")
    endif()

    set(openssl_make set cl=/MP & nmake)

    ExternalProject_Add_Step(perl_strawberry DEPENDERS openssl)
elseif(UNIX)
    set(openssl_config ./config)
    set(openssl_make make -j ${CPU_COUNT})
endif()

ExternalProject_Add(openssl
    PREFIX                  ${LIBRARIES_PREFIX}/openssl
    GIT_REPOSITORY          https://github.com/openssl/openssl.git
    GIT_TAG                 openssl-3.0.7 
    GIT_SHALLOW             YES
    GIT_PROGRESS            YES
    UPDATE_DISCONNECTED     YES
    UPDATE_COMMAND          ""
    BUILD_IN_SOURCE         YES

    BUILD_ALWAYS            NO
    CONFIGURE_COMMAND       ${openssl_config} no-asm no-shared no-tests no-unit-test no-zlib-dynamic --prefix=${LIBRARIES_INSTALL_PREFIX}/openssl_$<IF:$<CONFIG:Debug>,debug,release> --openssldir=${LIBRARIES_INSTALL_PREFIX}/openssl_$<IF:$<CONFIG:Debug>,debug,release>
    BUILD_COMMAND           ${openssl_make}
    INSTALL_COMMAND         ${openssl_make} install
)

ExternalProject_Add(multiuser
    PREFIX                  ${LIBRARIES_PREFIX}/multiuser
    DEPENDS                 boost openssl json argparse
    SOURCE_DIR              ${PROJECT_SOURCE_DIR}/../
    CMAKE_CACHE_ARGS        -DCMAKE_PREFIX_PATH:STRING=
                                    ${LIBRARIES_INSTALL_PREFIX}/argparse
                                    ${LIBRARIES_INSTALL_PREFIX}/json
                                    ${LIBRARIES_INSTALL_PREFIX}/boost
                            -DMULTIUSER_MSVC_STATIC_RUNTIME:BOOL=${MULTIUSER_MSVC_STATIC_RUNTIME}
                            -DOPENSSL_ROOT_DIR:PATH=${LIBRARIES_INSTALL_PREFIX}/openssl_$<IF:$<CONFIG:Debug>,debug,release>
                            -DOPENSSL_USE_STATIC_LIBS:BOOL=YES
                            -DBoost_USE_STATIC_LIBS:BOOL=YES
                            -DBoost_USE_STATIC_RUNTIME:BOOL=${MULTIUSER_MSVC_STATIC_RUNTIME}
                            -DBoost_ADDITIONAL_VERSIONS:STRING=1.81
                            -DBoost_NO_SYSTEM_PATHS:BOOL=YES
                            -DBoost_NO_WARN_NEW_VERSIONS:BOOL=YES
    BUILD_ALWAYS            TRUE
    INSTALL_COMMAND         ""
)