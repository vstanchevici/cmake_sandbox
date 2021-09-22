cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

# Set policies
#set_policy(CMP0054 NEW) # ENABLE CMP0054: Only interpret if() arguments as variables or keywords when unquoted.
#set_policy(CMP0042 NEW) # ENABLE CMP0042: MACOSX_RPATH is enabled by default.
#set_policy(CMP0063 NEW) # ENABLE CMP0063: Honor visibility properties for all target types.
#set_policy(CMP0077 NEW) # ENABLE CMP0077: option() honors normal variables

#https://stackoverflow.com/questions/24460486/cmake-build-type-is-not-being-used-in-cmakelists-txt

project(cmake_tester CXX)


set(project "base_name")    

#message("configure libs")

include(ExternalProject)

set(armadillo "armadillo")
#add_subdirectory(${armadillo})

#[[
if (${BEP})    
    ExternalProject_Add(${project}
        PREFIX                  ${PROJECT_BINARY_DIR}/${project}
        SOURCE_DIR              ../src
        #INSTALL_DIR             install
        #CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_BINARY_DIR}/base/${project}/install
        CMAKE_CACHE_ARGS        -DCMAKE_BUILD_CONFIG:BOOL=TRUE
        #UPDATE_DISCONNECTED     True
        #UPDATE_COMMAND          ""
        #CONFIGURE_COMMAND      ""
        #BUILD_COMMAND          ""
        INSTALL_COMMAND        ""
        #TEST_COMMAND           ""
    )
else()
    add_subdirectory(src)

    set(Armadillo_DIR ${PROJECT_BINARY_DIR}/third_party/armadillo/install/share/Armadillo/CMake)
    find_package(Armadillo REQUIRED NO_DEFAULT_PATH)
    target_include_directories("base_name" PRIVATE ${ARMADILLO_INCLUDE_DIRS})
    target_link_libraries("base_name" ${ARMADILLO_LIBRARIES})
endif()
]]

#file(GENERATE OUTPUT TEST$<CONFIG>.TXT CONTENT "CONFIG : $<CONFIG>")

add_subdirectory(src)
