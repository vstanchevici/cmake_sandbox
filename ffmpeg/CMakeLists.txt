cmake_minimum_required( VERSION 3.17.0 )

project (cmake_sandbox)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

add_executable(cmake_sandbox src/ffmpeg/decode_video.c)

set(FFMPEG_ROOT "${PROJECT_SOURCE_DIR}/libs/ffmpeg/static")
find_package(FFMPEG COMPONENTS avcodec avformat avutil avdevice avfilter swscale swresample REQUIRED)

set(PLATFORM_LIBS mfplat.lib mfuuid.lib Strmiids.lib Bcrypt.lib)

target_link_libraries(cmake_sandbox FFMPEG::avcodec FFMPEG::avformat FFMPEG::avutil FFMPEG::avdevice FFMPEG::avfilter FFMPEG::swscale FFMPEG::swresample ${PLATFORM_LIBS})

target_include_directories(cmake_sandbox PRIVATE ${FFMPEG_INCLUDE_DIR})
