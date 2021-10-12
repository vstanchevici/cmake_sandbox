# CMakeList.txt : CMake project for sync-server, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.10)

project(libuv_test)

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


add_executable(libuv_test main.cpp)

if(MSVC)
    add_definitions(-D_WIN32_WINNT=0x600 -D_SCL_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_WARNINGS -D_WINSOCK_DEPRECATED_NO_WARNINGS)
endif()
if (MINGW)
    add_definitions(-D_WIN32_WINNT=0x600)
endif()

# Include cmake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

find_package(libuv REQUIRED)
target_include_directories(libuv_test PRIVATE ${LibUV_INCLUDE_DIRS})
target_link_libraries(libuv_test PRIVATE ${LibUV_LIBRARIES})

if(WIN32)
  target_link_libraries(libuv_test PRIVATE Userenv Iphlpapi ws2_32)
endif()

message(STATUS "LibUV_FOUND: ${LibUV_FOUND}")
message(STATUS "LibUV_INCLUDE_DIRS: ${LibUV_INCLUDE_DIRS}")
message(STATUS "LibUV_LIBRARIES: ${LibUV_LIBRARIES}")
message(STATUS "LibUV_VERSION: ${LibUV_VERSION}")
message(STATUS "LibUV_VERSION_MAJOR: ${LibUV_VERSION_MAJOR}")
message(STATUS "LibUV_VERSION_MINOR: ${LibUV_VERSION_MINOR}")
message(STATUS "LibUV_VERSION_PATCH: ${LibUV_VERSION_PATCH}")
  
