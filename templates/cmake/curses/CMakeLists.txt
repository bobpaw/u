cmake_minimum_required(VERSION 3.11) # FetchContent
project(#[[FIXME: Your project's name]] VERSION 0.0 LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
cmake_policy(SET CMP0067 NEW) # Force CMake to observe CXX_STANDARD in checks

##
## HAVE is for symbols and headers
## FOUND is for packages
##

# Give some default build types to use
set(default_build_type "Release")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
	message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
	set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
		STRING "Choose the type of build." FORCE)
	# Set the possible values of build type for cmake-gui
	set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
		"Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# This expects you to have modules. Uncomment if you do
# list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# CTest if this is the top-level project
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
	include(CTest)
endif()

include(FetchContent)
include(CheckIncludeFileCXX)
include(CheckIncludeFile)
include(CheckCXXSymbolExists)

# Fetch PDCurses
FetchContent_DECLARE(
	PDCurses
	GIT_REPOSITORY https://github.com/bobpaw/FindPDCurses.git
	GIT_TAG v1.0
	GIT_SHALLOW true
)

FetchContent_GetProperties(PDCurses)
if(NOT PDCurses_POPULATED)
  FetchContent_Populate(PDCurses)
  list(APPEND CMAKE_MODULE_PATH ${NAME}_SOURCE_DIR})
endif()

if ($<COMPILE_FEATURES:cxx_noexcept>)
	set(HAVE_NOEXCEPT YES)
endif()

# Put any cache options here


if ($<CONFIG:Debug>)
	# Enable most compiler warnings if a debug build
	add_compile_options(${PROJECT_NAME} PRIVATE $<$<C_COMPILER_ID:MSVC>:/W4 /WX>)
	add_compile_options(${PROJECT_NAME} PRIVATE $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wall -Wextra -pedantic -Werror>)
endif()

# Add the binary directory to includes to be safe
include_directories(${CMAKE_CURRENT_BINARY_DIR})

#CURSES
if (USE_PDCURSES)
	message(STATUS "Using PDCurses")
	set(CURSES_INCLUDE_DIRS ${PDCURSES_SRCDIR})
	set(CURSES_LIBRARIES ${PDCURSES_LIBRARIES})
	set(PDCURSES_FOUND YES)
	set(HAVE_CURSES_H YES)
else ()
	if(DEFINED ENV{TRAVIS_OS_NAME} AND ("$ENV{TRAVIS_OS_NAME}" STREQUAL "windows"))
		find_package(Curses PATHS "${PROJECT_SOURCE_DIR}/ncurses-6.1")
	else()
		find_package(Curses)
		if (NOT CURSES_FOUND)
			find_package(PDCurses MODULE REQUIRED)
			set(CURSES_LIBRARIES "${PDCURSES_LIBRARIES}")
			set(CURSES_INCLUDE_DIRS "${PDCURSES_INCLUDE_DIR}")
			mark_as_advanced(CURSES_LIBRARIES CURSES_INCLUDE_DIRS)
		endif()
	endif()
endif ()
if (CURSES_HAVE_NCURSES_CURSES_H)
	set(CURSES_HEADER "<ncurses/curses.h>")
elseif (CURSES_HAVE_NCURSES_H)
	set(CURSES_HEADER "<ncurses.h>")
elseif (CURSES_HAVE_CURSES_H OR HAVE_CURSES_H)
	set(CURSES_HEADER "<curses.h>")
endif()

if (CURSES_FOUND OR PDCURSES_FOUND)
	set(CMAKE_REQUIRED_INCLUDES ${CURSES_INCLUDE_DIRS})
	set(CMAKE_REQUIRED_LIBRARIES ${CURSES_LIBRARIES})
	check_cxx_symbol_exists(start_color ${CURSES_HEADER} HAVE_CURSES_COLOR)
	if (HAVE_CURSES_COLOR)
		message(STATUS "Found color support for curses")
	else()
		message(STATUS "Did NOT find color support for curses")
	endif()
endif()

find_library(MATH_FOUND m)

if ($<VERSION_GREATER_EQUAL:"${CMAKE_VERSION}","3.12">)
	add_compile_definitions(HAVE_CMAKE_CONFIG_H)
else()
	add_compile_options(-DHAVE_CMAKE_CONFIG_H)
endif()

configure_file("${PROJECT_SOURCE_DIR}/cmakeconfig.h.in" "${PROJECT_BINARY_DIR}/cmakeconfig.h" ESCAPE_QUOTES @ONLY)
configure_file("${PROJECT_SOURCE_DIR}/src/correct_curses.h.in" "${PROJECT_BINARY_DIR}/src/correct_curses.h" ESCAPE_QUOTES @ONLY)

# Assumes your directory tree is as follows
# CMakeLists.txt
# test
# + CMakeLists.txt with build info
# src
# + CMakeLists.txt with test build info and other test stuff
add_subdirectory(src)


# Only enable testing if this is the top-level project or it's a test build
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test/" AND (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR #[[FIXME: Your project's shortname]]_BUILD_TESTING) AND BUILD_TESTING)
	add_subdirectory(test)
endif()
