#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST.GeometryCollection')
test:plan(10)

local geometries = {
    ST.Point({37.279357, 55.849493}, 4326);
    ST.Point({37.275152, 55.865005}, 4326);
    ST.Point({37.261676, 55.864041}, 4326);
}

local status, reason
status, reason = pcall(ST.GeometryCollection)
test:like(reason, "Usage", "GeometryCollection()")
status, reason = pcall(ST.GeometryCollection, geometries)
test:like(reason, "Usage", "GeometryCollection(geometries)")
status, reason = pcall(ST.GeometryCollection, {{12, 12}}, 23223)
test:like(reason, "Usage", "GeometryCollection(invalid, srid)")

local collection = ST.GeometryCollection(geometries, 4326)
test:is(ST.GeometryType(collection), "GeometryCollection",
    "GeometryType(GeometryCollection(geometries, srid))")
test:is(ST.SRID(collection), 4326, "SRID(GeometryCollection(geometries, srid)) == srid")

status, reason = pcall(ST.AsTable)
test:like(reason, "Usage", "AsTable()")

local collectiontab, srid = ST.AsTable(collection)
test:is_deeply(collectiontab[1], ST.AsTable(ST.GeometryN(collection, 1)),
    "AsTable(collection)[1] data")
test:is_deeply(collectiontab[2], ST.AsTable(ST.GeometryN(collection, 2)),
    "AsTable(collection)[2] data")
test:is_deeply(collectiontab[3], ST.AsTable(ST.GeometryN(collection, 3)),
    "AsTable(collection)[3] data")
test:is(srid, ST.SRID(collection), "AsTable(collection) srid")

os.exit(test:check() == true and 0 or -1)
