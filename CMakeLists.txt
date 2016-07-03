cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project(gis C)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

# Find Tarantool and Lua dependecies
set(TARANTOOL_FIND_REQUIRED ON)
find_package(Tarantool)
include_directories(${TARANTOOL_INCLUDE_DIRS})

# Find GEOS
set(GEOS_FIND_REQUIRED ON)
find_package(GEOS)
if(GEOS_VERSION VERSION_LESS "3.4")
    message(FATAL_ERROR "Please install GEOS >= 3.4")
endif()
include_directories(${GEOS_INCLUDE_DIR})

# Find PROJ.4
set(PROJ_FIND_REQUIRED ON)
find_package(PROJ)
if(PROJ_VERSION VERSION_LESS 480)
    message(FATAL_ERROR "Please install PROJ.4 >= 480")
endif()
include_directories(${PROJ_INCLUDE_DIR})

# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall -Wextra")

add_subdirectory(gis)
add_subdirectory(doc)
enable_testing()
add_subdirectory(tests)
