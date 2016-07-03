set(LUA_PATH "LUA_PATH=${PROJECT_SOURCE_DIR}/?.lua\\;${PROJECT_SOURCE_DIR}/?/init.lua\\;;")
set(LUA_CPATH "LUA_CPATH=${PROJECT_SOURCE_DIR}/?.so\\;${PROJECT_SOURCE_DIR}/?.dylib\\;;")
set(tests projection geometry point linestring linearring polygon multipoint
    multilinestring multipolygon rtree)
foreach(t IN LISTS tests)
    add_test(NAME ${t} COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/${t}.test.lua)
    set_tests_properties(${t} PROPERTIES ENVIRONMENT "${LUA_PATH}")
endforeach()
