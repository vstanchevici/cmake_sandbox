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
project(webrtc_test-superbuild LANGUAGES C CXX)


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
#option(WEBRTC_MSVC_STATIC_RUNTIME "Link with static msvc runtime libraries" OFF) #not yet implemented


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

#read more about depol tools here:
#   https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html
ExternalProject_Add(depot_tools
    PREFIX                  ${LIBRARIES_PREFIX}/depot_tools
    GIT_REPOSITORY          https://chromium.googlesource.com/chromium/tools/depot_tools.git
    GIT_TAG                 main
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    CONFIGURE_COMMAND       ""
    BUILD_COMMAND           ""
    INSTALL_COMMAND         ""
)
ExternalProject_Get_property(depot_tools SOURCE_DIR)
set(DEPOT_TOOLS_DIR ${SOURCE_DIR})

#read more about webrtc here:
#   https://webrtc.github.io/webrtc-org/native-code/development/
#   https://gist.github.com/jasonrudolph/1810768
set(WEBRTC_DIR ${LIBRARIES_PREFIX}/webrtc)

#https://stackoverflow.com/questions/55708589/how-to-pass-an-environment-variable-to-externalproject-add-configure-command
#https://stackoverflow.com/questions/4036754/why-does-only-the-first-line-of-this-windows-batch-file-execute-but-all-three-li

#https://stackoverflow.com/questions/26452225/how-to-reuse-extracted-source-with-cmakes-externalproject-add
file(WRITE "${WEBRTC_DIR}/download_webrtc.bat"
"set PATH=${DEPOT_TOOLS_DIR};%PATH%
cd webrtc
if not exist .gclient (
    call fetch.bat --nohooks webrtc
    cd src
    call gclient.bat sync
    call git checkout branch-heads/m79
    call gclient.bat sync
    call python.bat -m pip install pywin32
)
")


file(WRITE "${WEBRTC_DIR}/configure_webrtc.bat"
"set PATH=${DEPOT_TOOLS_DIR};%PATH%
cd src
gn gen out/%1 --args=\"enable_iterator_debugging=false is_debug=false use_rtti=true is_clang=false rtc_build_tools=false rtc_include_tests=false rtc_build_examples=false\"
")

file(WRITE "${WEBRTC_DIR}/compile_webrtc.bat"
"set PATH=${DEPOT_TOOLS_DIR};%PATH%
cd src
ninja -C out/%1
")        
        
ExternalProject_Add(webrtc
    PREFIX                  ${WEBRTC_DIR}
    DEPENDS                 depot_tools
    DOWNLOAD_COMMAND        ${WEBRTC_DIR}/download_webrtc.bat
    BUILD_IN_SOURCE         ON
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    CONFIGURE_COMMAND       ${WEBRTC_DIR}/configure_webrtc.bat $<IF:$<CONFIG:Debug>,debug,release>
    BUILD_COMMAND           ${WEBRTC_DIR}/compile_webrtc.bat $<IF:$<CONFIG:Debug>,debug,release>
    INSTALL_COMMAND         ""
)

        
ExternalProject_Add(webrtc_test
    PREFIX              ${LIBRARIES_PREFIX}/webrtc_test
    DEPENDS             webrtc
    SOURCE_DIR          ${PROJECT_SOURCE_DIR}/../
    #CMAKE_ARGS          -DFFMPEG_ROOT:PATHL="" #-DLIBRARIES_INSTALL_PREFIX=${LIBRARIES_INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    CMAKE_CACHE_ARGS    -DWEBRTC_ROOT:PATH=${LIBRARIES_INSTALL_PREFIX}/webrtc
    BUILD_ALWAYS        TRUE
    INSTALL_COMMAND     ""
)
