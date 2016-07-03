#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST.MultiPolygon')
test:plan(12)

local polygons = {
    {{
        {37.279357, 55.849493};
        {37.275152, 55.865005};
        {37.261676, 55.864041};
        {37.279357, 55.849493};
    }};
    {{
        {37.267856, 55.853781};
        {37.269401, 55.858502};
        {37.273864, 55.854937};
        {37.267856, 55.853781};
    }};
}

local status, reason
status, reason = pcall(ST.MultiPolygon)
test:like(reason, "Usage", "MultiPolygon()")
status, reason = pcall(ST.MultiPolygon, polygons)
test:like(reason, "Usage", "MultiPolygon(polygons)")
status, reason = pcall(ST.MultiPolygon, 12, 23223)
test:like(reason, "Usage", "MultiPolygon(invalid, srid)")
status, reason = pcall(ST.MultiPolygon, {0, 2}, 23223)
test:like(reason, "Usage", "MultiPolygon(invalidpoint, srid)")

local multipolygon = ST.MultiPolygon(polygons, 4326)
test:is(ST.GeometryType(multipolygon), "MultiPolygon",
    "GeometryType(MultiPolygon(multipolygon, srid))")
test:is(ST.SRID(multipolygon), 4326,
    "SRID(MultiPolygon(points, srid)) == srid")

status, reason = pcall(ST.AsTable)
test:like(reason, "Usage", "AsTable()")

local multipolygontab, srid = ST.AsTable(multipolygon)
test:is_deeply(multipolygontab[1], ST.AsTable(ST.GeometryN(multipolygon, 1)),
    "AsTable(multipolygon)[1] data")
test:is_deeply(multipolygontab[2], ST.AsTable(ST.GeometryN(multipolygon, 2)),
    "AsTable(multipolygon)[2] data")
test:isnil(multipolygontab[3], "AsTable(multipolygon)[3] data")
test:is(srid, ST.SRID(multipolygon), "AsTable(multipolygon) srid")
test:ok(ST.Equals(ST.MultiPolygon(ST.AsTable(multipolygon)), multipolygon),
    "MultiPolygon(AsTable(multipolygon)) roundtrip")

os.exit(test:check() == true and 0 or -1)
