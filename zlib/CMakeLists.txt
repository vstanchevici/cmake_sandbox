# CMakeList.txt : CMake project for sync-server, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.10)

project(zlib_test)

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

add_executable(zlib_test main.cpp sources/gvrzip.cpp sources/gvrzip.h)

if(MSVC)
    add_definitions(-D_WIN32_WINNT=0x600 -D_SCL_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_WARNINGS -D_WINSOCK_DEPRECATED_NO_WARNINGS)
endif()
if (MINGW)
    add_definitions(-D_WIN32_WINNT=0x600)
endif()

find_package(zlib REQUIRED)
target_link_libraries(zlib_test ZLIB::ZLIB)

find_package(libzip REQUIRED)
target_link_libraries(zlib_test libzip::zip)
