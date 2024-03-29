cmake_minimum_required( VERSION 3.17.0 )

# Declare project
project(ffmpeg_test LANGUAGES C CXX)

# Set standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

add_executable(ffmpeg_test src/dshow_capture_video.c)

find_package(FFMPEG COMPONENTS avcodec avdevice avfilter avformat avutil swscale swresample REQUIRED)
message(STATUS ${FFMPEG_LIBRARIES})

set(PLATFORM_LIBS mfplat.lib mfuuid.lib Strmiids.lib Bcrypt.lib ws2_32.lib secur32.lib vfw32.lib shlwapi.lib)

target_link_libraries(ffmpeg_test FFMPEG::avcodec FFMPEG::avformat FFMPEG::avutil FFMPEG::avdevice FFMPEG::avfilter FFMPEG::swscale FFMPEG::swresample ${PLATFORM_LIBS})

target_include_directories(ffmpeg_test PRIVATE ${FFMPEG_INCLUDE_DIR})
