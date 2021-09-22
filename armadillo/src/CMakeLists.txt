cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(base_name CXX)

set(project "base_name")    

file(GLOB SRCS *.cpp *.h)

add_executable(${project} ${SRCS})

