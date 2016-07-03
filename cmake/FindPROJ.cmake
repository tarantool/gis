# - Find libproj library
# The module defines the following variables:
#
#  PROJ_FOUND - true if PROJ was found
#  PROJ_INCLUDE_DIR - the directory of proj_api.h header
#  PROJ_LIBRARY - the libproj library
#

# Find PROJ.4 includes
find_path(PROJ_INCLUDE_DIR proj_api.h)
if(PROJ_INCLUDE_DIR)
    file (STRINGS "${PROJ_INCLUDE_DIR}/proj_api.h" _contents
        REGEX "^[ \t ]*#define[\t ]+PJ_VERSION[\t ]+([0-9]+)")
    string(REGEX REPLACE
        "^[ \t ]*#define[\t ]+PJ_VERSION[ \t]+([0-9]+).*" "\\1"
        PROJ_VERSION "${_contents}")
endif()

# Find PROJ.4 library:
find_library(PROJ_LIBRARY NAMES proj)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PROJ VERSION_VAR PROJ_VERSION REQUIRED_VARS
    PROJ_LIBRARY PROJ_INCLUDE_DIR)
mark_as_advanced(PROJ_INCLUDE_DIR PROJ_LIBRARY PROJ_VERSION)
