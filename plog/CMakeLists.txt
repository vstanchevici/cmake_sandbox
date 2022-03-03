# CMakeList.txt : CMake project for sync-server, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.10)

project(plog_test)

# Set standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

add_executable(${PROJECT_NAME} main.cpp)

if(MSVC)
    add_definitions(-D_WIN32_WINNT=0x600 -D_SCL_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_WARNINGS -D_WINSOCK_DEPRECATED_NO_WARNINGS)
endif()
if (MINGW)
    add_definitions(-D_WIN32_WINNT=0x600)
endif()

# Include cmake modules
#list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

if (PLOG_INCLUDE_DIR)
    target_include_directories(${PROJECT_NAME} PRIVATE ${PLOG_INCLUDE_DIR})
else()
    message(FATAL_ERROR "PLOG_INCLUDE_PATH is not defined!")
endif()
