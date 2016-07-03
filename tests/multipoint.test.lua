#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST.MultiPoint')
test:plan(12)

local points = {
    {37.279357, 55.849493};
    {37.275152, 55.865005};
    {37.261676, 55.864041};
}

local status, reason
status, reason = pcall(ST.MultiPoint)
test:like(reason, "Usage", "MultiPoint()")
status, reason = pcall(ST.MultiPoint, points)
test:like(reason, "Usage", "MultiPoint(points)")
status, reason = pcall(ST.MultiPoint, 12, 23223)
test:like(reason, "Usage", "MultiPoint(invalid, srid)")
status, reason = pcall(ST.MultiPoint, {0, 2}, 23223)
test:like(reason, "Invalid point", "MultiPoint(invalidpoint, srid)")

local multipoint = ST.MultiPoint(points, 4326)
test:is(ST.GeometryType(multipoint), "MultiPoint",
    "GeometryType(MultiPoint(points, srid))")
test:is(ST.SRID(multipoint), 4326, "SRID(MultiPoint(points, srid)) == srid")

status, reason = pcall(ST.AsTable)
test:like(reason, "Usage", "AsTable()")

local multipointtab, srid = ST.AsTable(multipoint)
test:is_deeply(multipointtab[1], ST.AsTable(ST.GeometryN(multipoint, 1)),
    "AsTable(multipoint)[1] data")
test:is_deeply(multipointtab[2], ST.AsTable(ST.GeometryN(multipoint, 2)),
    "AsTable(multipoint)[2] data")
test:is_deeply(multipointtab[3], ST.AsTable(ST.GeometryN(multipoint, 3)),
    "AsTable(multipoint)[3] data")
test:is(srid, ST.SRID(multipoint), "AsTable(multipoint) srid")
test:ok(ST.Equals(ST.MultiPoint(ST.AsTable(multipoint)), multipoint),
    "MultiPoint(AsTable(multipoint)) roundtrip")

os.exit(test:check() == true and 0 or -1)
