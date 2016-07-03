add_custom_command(OUTPUT proj4_cdef.lua
    DEPENDS "${PROJ_INCLUDE_DIR}/proj_api.h"
    COMMAND echo "\"require('ffi').cdef([[\"" > proj4_cdef.tmp
    COMMAND echo 'typedef struct PJ *projPJ\;' >> proj4_cdef.tmp
    COMMAND cat ${PROJ_INCLUDE_DIR}/proj_api.h |
            sed '/\#include/d'|
            ${CMAKE_C_COMPILER} -E - -P >> proj4_cdef.tmp
    COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/lib.h >> proj4_cdef.tmp
    COMMAND echo ']]\)' >> proj4_cdef.tmp
    COMMAND ${CMAKE_COMMAND} -E rename proj4_cdef.tmp proj4_cdef.lua
)

add_custom_command(OUTPUT geos_cdef.lua
    DEPENDS ${GEOS_INCLUDE_DIR}/geos_c.h
    COMMAND echo "\"require('ffi').cdef([[\"" > geos_cdef.tmp
    COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/lib.h >> geos_cdef.tmp
    COMMAND cat ${GEOS_INCLUDE_DIR}/geos_c.h |
            sed '/\#include/d'|
            ${CMAKE_C_COMPILER} -E - -P -DGEOS_DLL="" -DGEOS_USE_ONLY_R_API=1 >> geos_cdef.tmp
    COMMAND echo "\"]])\"" >> geos_cdef.tmp
    COMMAND ${CMAKE_COMMAND} -E rename geos_cdef.tmp geos_cdef.lua
)

add_custom_target(generate_cdefs DEPENDS
    proj4_cdef.lua geos_cdef.lua
)

if(APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS
        "${CMAKE_SHARED_LINKER_FLAGS} -undefined suppress -flat_namespace")
endif(APPLE)

add_library(lib SHARED lib.c)
target_link_libraries(lib ${GEOS_LIBRARY} ${PROJ_LIBRARY})
set_target_properties(lib PROPERTIES PREFIX "" OUTPUT_NAME "lib")
add_dependencies(lib generate_cdefs)

install(FILES init.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/gis/)
install(FILES projection.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/gis/)
install(FILES ST.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/gis/)
install(FILES wkt.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/gis/)
install(FILES wkb.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/gis/)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/geos_cdef.lua
    DESTINATION ${TARANTOOL_INSTALL_LUADIR}/gis/)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/proj4_cdef.lua
    DESTINATION ${TARANTOOL_INSTALL_LUADIR}/gis/)
install(FILES data/spatial_ref_sys.lua DESTINATION
    ${TARANTOOL_INSTALL_LUADIR}/gis/data/)
install(TARGETS lib LIBRARY DESTINATION ${TARANTOOL_INSTALL_LIBDIR}/gis/)
