cmake_minimum_required(VERSION 3.8) # Allows use of compile_features requesting certain C++ standard levels
project(PROJECT_NAME VERSION 0.0 LANGUAGES C CXX)

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
include(CheckCXXCompilerFlag)
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
