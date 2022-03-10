#
# === CMake lists for the mvisus ===
#


# === CMake options ===

# Set CMake version
cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

#[[
#https://github.com/oneapi-src/oneTBB/blob/master/CMakeLists.txt
if (POLICY CMP0091)
    # The NEW behavior for this policy is to not place MSVC runtime library flags in the default
    # CMAKE_<LANG>_FLAGS_<CONFIG> cache entries and use CMAKE_MSVC_RUNTIME_LIBRARY abstraction instead.
    cmake_policy(SET CMP0091 NEW)
    message(STATUS "CMAKE_MSVC_RUNTIME_LIBRARY -> ${CMAKE_MSVC_RUNTIME_LIBRARY}")
elseif (DEFINED CMAKE_MSVC_RUNTIME_LIBRARY)
    message(FATAL_ERROR "CMAKE_MSVC_RUNTIME_LIBRARY was defined while policy CMP0091 is not available. Use CMake 3.15 or newer.")
endif()

#https://discourse.cmake.org/t/how-to-set-cmake-msvc-runtime-library-for-an-external-project/2805/4
#set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
#set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
#set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
]]

#
# Configure CMake environment
#

# Declare project
project(ffmpeg_test-superbuild LANGUAGES C CXX)


# Set standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

include(ProcessorCount)
ProcessorCount(CPU_COUNT)
if(CPU_COUNT EQUAL 0)
    set(CPU_COUNT 1)
endif()
math(EXPR CPU_COUNT "${CPU_COUNT} / 2 + 1")

#https://stackoverflow.com/questions/44284275/passing-compiler-options-cmake
#https://stackoverflow.com/questions/12021448/how-can-cmake-arguments-be-forwarded-to-externalproject
option(MVISUS_MSVC_STATIC_RUNTIME "Link with static msvc runtime libraries" OFF) #not yet implemented


include(ExternalProject)

if(NOT DEFINED LIBRARIES_PREFIX)
    set(LIBRARIES_PREFIX ${CMAKE_BINARY_DIR})
endif()

if(NOT DEFINED LIBRARIES_INSTALL_PREFIX)
    set(LIBRARIES_INSTALL_PREFIX ${LIBRARIES_PREFIX}/installed/${CMAKE_SYSTEM_NAME})
endif()

if (WIN32)
    set(SHELL_EXTENSION ".bat")
    set(EXE_EXTENSION ".exe")
elseif (UNIX)
    set(SHELL_EXTENSION ".sh")
    set(EXE_EXTENSION "")
endif()

if(CMAKE_CXX_COMPILER_LOADED)
    message(STATUS "Compiler path: ${CMAKE_CXX_COMPILER}")
    message(STATUS "Compiler ID: ${CMAKE_CXX_COMPILER_ID}")
    message(STATUS "Compiler version: ${CMAKE_CXX_COMPILER_VERSION}")
    message(STATUS "Compiler is part of GCC: ${CMAKE_COMPILER_IS_GNUCXX}")
    message(STATUS "CMAKE_AR: ${CMAKE_AR}")
    message(STATUS "CMAKE_ASM_COMPILER: ${CMAKE_ASM_COMPILER}")
    message(STATUS "CMAKE_LINKER: ${CMAKE_LINKER}")
    message(STATUS "CMAKE_OBJCOPY: ${CMAKE_OBJCOPY}")
    message(STATUS "CMAKE_RANLIB: ${CMAKE_RANLIB}")
endif()

#set(ENV{PATH} "C:\\msys64\\usr\\bin;$ENV{PATH}")

message(STATUS "PATH: $ENV{PATH}")

#https://stackoverflow.com/questions/63059904/setting-environment-variables-to-externalproject-add-context
#./configure --toolchain=msvc --enable-debug --arch=x86 --extra-cflags="-MTd" extra-cxxflags="-MTd" --extra-ldflags="-nodefaultlib:LIBCMT"
#./configure --prefix=ffmpeg-bin --enable-gpl --enable-nonfree --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libxvid --enable-shared --disable-static --disable-optimizations --disable-mmx --disable-stripping
ExternalProject_Add(ffmpeg
    PREFIX                  ${LIBRARIES_PREFIX}/ffmpeg
    GIT_REPOSITORY          https://git.ffmpeg.org/ffmpeg.git
    GIT_TAG                 n4.4
    GIT_SHALLOW             1
    BUILD_IN_SOURCE         ON
    CONFIGURE_COMMAND       bash ./configure --toolchain=msvc --target-os=win64 --arch=x86_64 --enable-w32threads --disable-shared --enable-static --disable-doc --disable-programs --prefix=${LIBRARIES_INSTALL_PREFIX}/ffmpeg
    BUILD_COMMAND           make -j ${CPU_COUNT}
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE
    INSTALL_COMMAND         make install
)

ExternalProject_Add(ffmpeg_test
    PREFIX              ${LIBRARIES_PREFIX}/ffmpeg_test
    DEPENDS             ffmpeg
    SOURCE_DIR          ${PROJECT_SOURCE_DIR}/../
    #CMAKE_ARGS          -DFFMPEG_ROOT:PATHL="" #-DLIBRARIES_INSTALL_PREFIX=${LIBRARIES_INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    CMAKE_CACHE_ARGS    -DCMAKE_PREFIX_PATH:PATH=${LIBRARIES_INSTALL_PREFIX}/ffmpeg
    BUILD_ALWAYS        TRUE
    INSTALL_COMMAND     ""
)
