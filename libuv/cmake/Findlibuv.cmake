#[=======================================================================[.rst:
FindLibUV
---------

Find libuv includes and library.

Imported Targets
^^^^^^^^^^^^^^^^

An :ref:`imported target <Imported targets>` named
``LibUV::LibUV`` is provided if libuv has been found.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

``LibUV_FOUND``
  True if libuv was found, false otherwise.
``LibUV_INCLUDE_DIRS``
  Include directories needed to include libuv headers.
``LibUV_LIBRARIES``
  Libraries needed to link to libuv.
``LibUV_VERSION``
  The version of libuv found.
``LibUV_VERSION_MAJOR``
  The major version of libuv.
``LibUV_VERSION_MINOR``
  The minor version of libuv.
``LibUV_VERSION_PATCH``
  The patch version of libuv.

Cache Variables
^^^^^^^^^^^^^^^

This module uses the following cache variables:

``LibUV_LIBRARY``
  The location of the libuv library file.
``LibUV_INCLUDE_DIR``
  The location of the libuv include directory containing ``uv.h``.

The cache variables should not be used by project code.
They may be set by end users to point at libuv components.
#]=======================================================================]

include(SelectLibraryConfigurations)

set(STATIC_LIB "_a")


find_path(LibUV_INCLUDE_DIR
  NAMES uv.h
  PATH_SUFFIXES include
  )
mark_as_advanced(LibUV_INCLUDE_DIR)

find_library(LibUV_LIBRARY_RELEASE
  NAMES uv${STATIC_LIB}
  PATH_SUFFIXES lib/Release
  )
  
find_library(LibUV_LIBRARY_DEBUG
  NAMES uv${STATIC_LIB}
  PATH_SUFFIXES lib/Debug
  )
mark_as_advanced(LibUV_LIBRARY)
select_library_configurations(LibUV)

#-----------------------------------------------------------------------------
# Extract version number if possible.
set(_LibUV_H_REGEX "#[ \t]*define[ \t]+UV_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+")
if(LibUV_INCLUDE_DIR AND EXISTS "${LibUV_INCLUDE_DIR}/uv/version.h")
  file(STRINGS "${LibUV_INCLUDE_DIR}/uv/version.h" _LibUV_H REGEX "${_LibUV_H_REGEX}")
elseif(LibUV_INCLUDE_DIR AND EXISTS "${LibUV_INCLUDE_DIR}/uv.h")
  file(STRINGS "${LibUV_INCLUDE_DIR}/uv.h" _LibUV_H REGEX "${_LibUV_H_REGEX}")
else()
  set(_LibUV_H "")
endif()
foreach(c MAJOR MINOR PATCH)
  if(_LibUV_H MATCHES "#[ \t]*define[ \t]+UV_VERSION_${c}[ \t]+([0-9]+)")
    set(_LibUV_VERSION_${c} "${CMAKE_MATCH_1}")
  else()
    unset(_LibUV_VERSION_${c})
  endif()
endforeach()
if(DEFINED _LibUV_VERSION_MAJOR AND DEFINED _LibUV_VERSION_MINOR)
  set(LibUV_VERSION_MAJOR "${_LibUV_VERSION_MAJOR}")
  set(LibUV_VERSION_MINOR "${_LibUV_VERSION_MINOR}")
  set(LibUV_VERSION "${LibUV_VERSION_MAJOR}.${LibUV_VERSION_MINOR}")
  if(DEFINED _LibUV_VERSION_PATCH)
    set(LibUV_VERSION_PATCH "${_LibUV_VERSION_PATCH}")
    set(LibUV_VERSION "${LibUV_VERSION}.${LibUV_VERSION_PATCH}")
  else()
    unset(LibUV_VERSION_PATCH)
  endif()
else()
  set(LibUV_VERSION_MAJOR "")
  set(LibUV_VERSION_MINOR "")
  set(LibUV_VERSION_PATCH "")
  set(LibUV_VERSION "")
endif()
unset(_LibUV_VERSION_MAJOR)
unset(_LibUV_VERSION_MINOR)
unset(_LibUV_VERSION_PATCH)
unset(_LibUV_H_REGEX)
unset(_LibUV_H)

#-----------------------------------------------------------------------------
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibUV
  FOUND_VAR LibUV_FOUND
  REQUIRED_VARS LibUV_LIBRARY LibUV_INCLUDE_DIR
  VERSION_VAR LibUV_VERSION
  )
set(LIBUV_FOUND ${LibUV_FOUND})

#-----------------------------------------------------------------------------
# Provide documented result variables and targets.
if(LibUV_FOUND)
  set(LibUV_INCLUDE_DIRS ${LibUV_INCLUDE_DIR})
  set(LibUV_LIBRARIES ${LibUV_LIBRARY})
  if(NOT TARGET LibUV::LibUV)
    add_library(LibUV::LibUV UNKNOWN IMPORTED)
    set_target_properties(LibUV::LibUV PROPERTIES
      IMPORTED_LOCATION "${LibUV_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${LibUV_INCLUDE_DIRS}"
      )
  endif()
endif()
