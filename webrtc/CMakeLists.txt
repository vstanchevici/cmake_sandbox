cmake_minimum_required( VERSION 3.17.0 )

# Declare project
project(webrtc_test LANGUAGES C CXX)

# Set standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

add_executable(webrtc_test test_1.cpp)

#target_link_libraries()

#target_include_directories(ffmpeg_test PRIVATE ${FFMPEG_INCLUDE_DIR})
