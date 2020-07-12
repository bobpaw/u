cmake_minimum_required(VERSION 3.8) # Allows use of compile_features requesting certain C++ standard levels
project(PROJECT_NAME #[[FIXME: Your project's name]] VERSION 0.0 LANGUAGES C CXX)

##
## Conventions:
## HAVE_FOO: if foo is a symbol that exists
## FOO_FOUND: if foo is a library/header that exists
##
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

# CTest if this is the top-level project
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
	include(CTest)
endif()

include(CheckIncludeFileCXX)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CheckCXXSymbolExists)

# Put any cache options here


if ($<CONFIG:Debug>)
	# Enable most compiler warnings if a debug build
	add_compile_options(${PROJECT_NAME} PRIVATE $<$<C_COMPILER_ID:MSVC>:/W4 /WX>)
	add_compile_options(${PROJECT_NAME} PRIVATE $<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wall -Wextra -pedantic -Werror>)
endif()

# Add the binary directory to includes to be safe
include_directories(${CMAKE_CURRENT_BINARY_DIR})

find_library(MATH_FOUND m)

# Technically these types are optional so we should check and use fast or least
check_cxx_symbol_exists(std::int8_t cstdint HAVE_INT8_T)
check_cxx_symbol_exists(std::uint8_t cstdint HAVE_UINT8_T)

if ($<VERSION_GREATER_EQUAL:"${CMAKE_VERSION}","3.12">)
	add_compile_definitions(HAVE_CMAKE_CONFIG_H)
else()
	add_compile_options(-DHAVE_CMAKE_CONFIG_H)
endif()

configure_file("${PROJECT_SOURCE_DIR}/cmakeconfig.h.in" "${PROJECT_BINARY_DIR}/cmakeconfig.h" ESCAPE_QUOTES @ONLY)

# Assumes your directory tree is as follows
# CMakeLists.txt
# test
# + CMakeLists.txt with build info
# src
# + CMakeLists.txt with test build info and other test stuff
add_subdirectory(src)


# Only enable testing if this is the top-level project or it's a test build
if ((CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR PROJECT_BUILD_TESTING #[[FIXME: Your project's shortname]]) AND BUILD_TESTING)
	add_subdirectory(test)
endif()
