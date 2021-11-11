# CMakeList.txt : CMake project for sync-server, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.18)

project(restapi-superbuild)

# Set standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

if(NOT DEFINED CMAKE_CPU_COUNT)
    include(ProcessorCount)
    ProcessorCount(CPU_COUNT)
    if(CPU_COUNT EQUAL 0)
        set(CPU_COUNT 1)
    endif()
    math(EXPR CPU_COUNT "${CPU_COUNT} / 2 + 1")
else()
    set(CPU_COUNT ${CMAKE_CPU_COUNT})
endif()

include(ExternalProject)

if(NOT DEFINED LIBRARIES_PREFIX)
    set(LIBRARIES_PREFIX ${CMAKE_BINARY_DIR})
endif()

if(NOT DEFINED LIBRARIES_INSTALL_PREFIX)
    set(LIBRARIES_INSTALL_PREFIX ${LIBRARIES_PREFIX}/installed/${CMAKE_SYSTEM_NAME})
endif()

if (WIN32)
    set(SHELL_EXTENSION ".bat")
    set(EXE_EXTENSION ".exe")
elseif (UNIX)
    set(SHELL_EXTENSION ".sh")
    set(EXE_EXTENSION "")
endif()

if(WIN32)
    find_program(PERL_COMMAND "Path to perl executable"
                NAMES perl
                HINTS C:/Strawberry/perl/bin)
    
    if(NOT PERL_COMMAND)
        message(FATAL_ERROR "PERL_COMMAND is not set !")
    endif()

    get_filename_component(PERL_BIN_DIR ${PERL_COMMAND} PATH)

    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
        separate_arguments(openssl_config NATIVE_COMMAND "${PERL_COMMAND} Configure $<$<CONFIG:Debug>:--debug> VC-WIN32")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        separate_arguments(openssl_config NATIVE_COMMAND "${PERL_COMMAND} Configure $<$<CONFIG:Debug>:--debug> VC-WIN64A")
    endif()
    
    set(openssl_make nmake)
elseif(UNIX)
    set(openssl_config ./config)
    set(openssl_make make -j ${CPU_COUNT})
endif()


ExternalProject_Add(openssl
    PREFIX                  ${LIBRARIES_PREFIX}/openssl
    GIT_REPOSITORY          https://github.com/openssl/openssl.git
    GIT_TAG                 OpenSSL_1_1_1l
    GIT_SHALLOW             1
    GIT_PROGRESS            TRUE
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_IN_SOURCE         ON

    BUILD_ALWAYS            FALSE
    CONFIGURE_COMMAND       ${openssl_config} no-asm no-shared no-unit-test no-tests no-zlib-dynamic --prefix=${LIBRARIES_INSTALL_PREFIX}/OpenSSL --openssldir=${LIBRARIES_INSTALL_PREFIX}/OpenSSL
    BUILD_COMMAND           ${openssl_make}
    INSTALL_COMMAND         ${openssl_make} install
)


ExternalProject_Add(zlib
    PREFIX                  ${LIBRARIES_PREFIX}/zlib
    GIT_REPOSITORY          https://github.com/madler/zlib.git
    GIT_TAG                 v1.2.11
    GIT_SHALLOW             1
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE    
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${LIBRARIES_INSTALL_PREFIX}/zlib
)
ExternalProject_Add_Step(zlib replace_cmakelists
    DEPENDEES DOWNLOAD
    DEPENDERS CONFIGURE
    COMMAND cp ${PROJECT_SOURCE_DIR}/patch/zlib1.2.11/CMakeLists.txt                   ${LIBRARIES_PREFIX}/zlib/src/zlib/CMakeLists.txt
)


#https://wiki.postgresql.org/wiki/Working_With_VisualStudio
#https://stackoverflow.com/questions/1244778/where-do-i-get-libpq-source
#https://www.postgresql.org/message-id/16336-756c24e637b7a336%40postgresql.org
#https://www.postgresql.org/message-id/798d4a9b-1516-a151-4b4b-fba9b5374dc4%40emmenlauer.de
set(POSTGRESQL_DIR ${LIBRARIES_PREFIX}/postgresql)
if(WIN32)    
    file(WRITE "${POSTGRESQL_DIR}/build_postgresql.bat"
    "cd ${POSTGRESQL_DIR}/src/postgresql/src/tools/msvc/
    ${PERL_COMMAND} build.pl
    ")
    
    file(WRITE "${POSTGRESQL_DIR}/install_postgresql.bat"
    "cd ${POSTGRESQL_DIR}/src/postgresql/src/tools/msvc/
    set PERL5LIB=${POSTGRESQL_DIR}/src/postgresql/src/tools/msvc/
    ${PERL_COMMAND} install.pl ${LIBRARIES_INSTALL_PREFIX}/postgresql
    ")

    set(postgresql_config   "")
    set(postgresql_build    "${POSTGRESQL_DIR}/build_postgresql.bat")
    set(postgresql_install  "${POSTGRESQL_DIR}/install_postgresql.bat")
elseif(UNIX)
    set(postgresql_config   ./configure
                            --prefix=${LIBRARIES_INSTALL_PREFIX}/postgresql
                            --with-includes=${LIBRARIES_INSTALL_PREFIX}/zlib/include
                            --with-libraries=${LIBRARIES_INSTALL_PREFIX}/zlib/lib
                            --without-readline)
    set(postgresql_build    env MAKELEVEL=0 && make all)
    set(postgresql_install "")
endif()

ExternalProject_Add(postgresql
    PREFIX                  ${POSTGRESQL_DIR}
    DEPENDS                 zlib openssl
    BUILD_IN_SOURCE         ON
    #URL                     "https://ftp.postgresql.org/pub/source/v10.4/postgresql-10.4.tar.gz"
    #URL_HASH                SHA256=60192bc75cd73e688500e8350ea065cca032e21abe57e72d4f556e0bf84fcf17
    URL                    "https://ftp.postgresql.org/pub/source/v14.0/postgresql-14.0.tar.gz"
    URL_HASH               SHA256=8535d3e85d7351d57b349810ff5c9e8a80e699183cadefd6b47f6fc7da8e680e
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""    
    BUILD_ALWAYS            FALSE
    CONFIGURE_COMMAND       "${postgresql_config}"
    BUILD_COMMAND           "${postgresql_build}"
    INSTALL_COMMAND         "${postgresql_install}"
)

ExternalProject_Add_Step(postgresql replace_v142_version
    DEPENDEES DOWNLOAD
    DEPENDERS CONFIGURE
    COMMAND cp ${PROJECT_SOURCE_DIR}/patch/postgresql.14.0/Mkvcbuild.pm                     ${LIBRARIES_PREFIX}/postgresql/src/postgresql/src/tools/msvc/Mkvcbuild.pm
    COMMAND cp ${PROJECT_SOURCE_DIR}/patch/postgresql.14.0/Install.pm                       ${LIBRARIES_PREFIX}/postgresql/src/postgresql/src/tools/msvc/Install.pm
    
)

ExternalProject_Add(libpqxx
    PREFIX                  ${LIBRARIES_PREFIX}/libpqxx
    DEPENDS                 postgresql
    GIT_REPOSITORY          https://github.com/jtv/libpqxx.git
    GIT_TAG                 7.6.0
    GIT_SHALLOW             1
    UPDATE_DISCONNECTED     TRUE
    UPDATE_COMMAND          ""
    BUILD_ALWAYS            FALSE
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${LIBRARIES_INSTALL_PREFIX}/libpqxx
        -DCMAKE_PREFIX_PATH=${LIBRARIES_INSTALL_PREFIX}/postgresql
        -DBUILD_TEST=OFF
        -DSKIP_PQXX_SHARED=ON
)


ExternalProject_Add(test_pqxx
    PREFIX                  ${LIBRARIES_PREFIX}/test_pqxx
    DEPENDS                 libpqxx
    SOURCE_DIR              ${PROJECT_SOURCE_DIR}/../
    CMAKE_ARGS              -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/test_pqxx
    
    CMAKE_CACHE_ARGS        -DCMAKE_PREFIX_PATH:PATH=${LIBRARIES_INSTALL_PREFIX}/postgresql
                            -DOPENSSL_ROOT_DIR:PATH=${LIBRARIES_INSTALL_PREFIX}/openssl
                            -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
                            -DLIBPQXX_ROOT_DIR:PATH=${LIBRARIES_INSTALL_PREFIX}/libpqxx
                            -Dlibpqxx_DIR:PATH=${LIBRARIES_INSTALL_PREFIX}/libpqxx/lib/cmake/libpqxx

    BUILD_ALWAYS            TRUE
    INSTALL_COMMAND         ""
)

