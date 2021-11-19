cmake_minimum_required(VERSION 3.15)

project(test_pqxx VERSION 1.0.0 LANGUAGES CXX)

# 
# Project configuration options
# 

# Project options
option(BUILD_TESTS              "Build tests."                                              OFF)
option(BUILD_DOCS               "Build documentation."                                      OFF)
option(ENABLE_COVERAGE          "Add coverage information."                                 OFF)

# 
# Declare project
# 

# Generate folders for IDE targets (e.g., VisualStudio solutions)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(IDE_FOLDER "")

# Remove ZERO_CHECK target
#set(CMAKE_SUPPRESS_REGENERATION true)

add_executable(${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/main.cpp)

set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    )
    
target_include_directories(${PROJECT_NAME}
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>
        ${ADDITIONAL_INCLUDE_DIRS}
)

#include openssl
find_package(OpenSSL REQUIRED)
target_include_directories(${PROJECT_NAME} PRIVATE ${OPENSSL_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE ${OPENSSL_LIBRARIES})

#include pq and pqxx
find_package(PostgreSQL REQUIRED)
message(STATUS "PostgreSQL_INCLUDE_DIRS: ${PostgreSQL_INCLUDE_DIRS}")
message(STATUS "PostgreSQL_LIBRARIES: ${PostgreSQL_LIBRARIES}")
target_link_libraries(${PROJECT_NAME} PRIVATE ${PostgreSQL_LIBRARIES})
target_link_libraries(${PROJECT_NAME} PRIVATE D:/projects/testpg/build/installed/Windows/postgresql/lib/libpgcommon.lib)
target_link_libraries(${PROJECT_NAME} PRIVATE D:/projects/testpg/build/installed/Windows/postgresql/lib/libpgport.lib)

find_package(libpqxx REQUIRED)
message(STATUS "PQXX_INCLUDE_DIRECTORIES: ${PQXX_INCLUDE_DIRECTORIES}")
message(STATUS "PQXX_LIBRARIES: ${PQXX_LIBRARIES}")
message(STATUS "LIBPQXX_ROOT_DIR: ${LIBPQXX_ROOT_DIR}")
target_include_directories(${PROJECT_NAME} PRIVATE ${LIBPQXX_ROOT_DIR}/include)
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBPQXX_ROOT_DIR}/lib/pqxx${CMAKE_STATIC_LIBRARY_SUFFIX})
#set(CMAKE_FIND_DEBUG_MODE FALSE)

if (WIN32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE -DNOMINMAX -DWIN32 -D_WINDOWS -DWIN32_LEAN_AND_MEAN)
    target_compile_definitions(${PROJECT_NAME} PRIVATE -DCOMPILE_PLATFORM_WINDOWS -D_WIN32_WINDOWS)

    target_link_libraries(${PROJECT_NAME} PRIVATE ws2_32 wsock32 crypt32 wldap32 secur32)
    
endif()

if (UNIX)
    target_compile_definitions(${PROJECT_NAME} PRIVATE -DCOMPILE_PLATFORM_LINUX)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${CMAKE_DL_LIBS})
endif()

