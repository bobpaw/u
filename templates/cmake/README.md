## General Idea
```CMake

# CMake Initialization (minver, project, standards, policies)

# Default build types

# Include modules folder
# Include CTest
# Include CMake files
# FetchContent

# Compiler features
# Cache options
# Compiler flags (default debug, etc.)

# Include directories
# Find libraries

# config.h compiler definitions
# configure_file calls

# add_subdirectory calls
# add testing subdirectory
```

### Notes:
1. Use HAVE prefix for symbols and headers and FOUND prefix for packages
2. Order of individual stuff doesn't matter too much. Use groups and orders that make sense.
