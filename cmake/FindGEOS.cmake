# - Find libgeos_c library
# The module defines the following variables:
#
#  GEOS_FOUND - true if GEOS was found
#  GEOS_INCLUDE_DIR - the directory of geos_c.h header
#  GEOS_LIBRARY - the libgeos_c library
#

# Find GEOS includes
find_path(GEOS_INCLUDE_DIR geos_c.h)
if(GEOS_INCLUDE_DIR)
    file (STRINGS "${GEOS_INCLUDE_DIR}/geos_c.h" _contents
        REGEX "^[ \t ]*#define[\t ]+GEOS_VERSION[\t ]+\"([^\"]*)\"")
    string(REGEX REPLACE
        "^[ \t ]*#define[\t ]+GEOS_VERSION[ \t]+\"([0-9]+).([0-9]+).([0-9]+)..*"
        "\\1.\\2.\\3"
        GEOS_VERSION "${_contents}")
endif()

# Find GEOS library:
find_library(GEOS_LIBRARY NAMES geos_c)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GEOS VERSION_VAR GEOS_VERSION REQUIRED_VARS
    GEOS_LIBRARY GEOS_INCLUDE_DIR)
mark_as_advanced(GEOS_INCLUDE_DIR GEOS_LIBRARY GEOS_VERSION)
