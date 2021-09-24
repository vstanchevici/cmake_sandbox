cmake_minimum_required(VERSION 3.18)
project(my_project)

# GoogleTest requires at least C++11
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

#https://coderoad.ru/50861636/%D0%98%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-google-tests-%D1%81-CMake-Ctest-%D1%81-%D0%BD%D0%BE%D0%B2%D0%BE%D0%B9-%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D0%BE%D0%B9-gtest_discover_tests

option(BUILD_TESTS "Build the tests" ON)

add_executable(my_project main.cpp )

if (BUILD_TESTS)
    enable_testing()

    if (DEFINED LIBS_PATH)
        list(APPEND CMAKE_PREFIX_PATH ${LIBS_PATH})
        message(STATUS "LIBS_PATH = ${LIBS_PATH}")
        #set(GTEST_LIBRARY ${LIBS_PATH})
        #set(GTEST_MAIN_LIBRARY ${LIBS_PATH})
    endif()

    
    include(GoogleTest)

    #set(GTEST_MSVC_SEARCH MT)
    find_package(GTest REQUIRED)

    add_executable(my_project_tests hello_test1.cpp hello_test2.cpp)

    if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        set_property(TARGET my_project_tests PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
        #set_property(TARGET my_project_tests PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    endif()

    target_link_libraries(my_project_tests ${GTEST_BOTH_LIBRARIES})
    target_include_directories(my_project_tests PRIVATE ${GTEST_INCLUDE_DIRS})
    message(STATUS "include dirs : ${GTEST_INCLUDE_DIRS}")
    gtest_discover_tests(my_project_tests)
endif()
