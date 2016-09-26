#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST.LinearRing')
test:plan(36)

--------------------------------------------------------------------------------
-- ST.LinearRing()/ST.AsTable(linearring)
--------------------------------------------------------------------------------

local status, reason

local points = {
    {37.279357, 55.849493};
    {37.275152, 55.865005};
    {37.261676, 55.864041};
    {37.279357, 55.849493};
}

local pointsz = {
    {2855517.134262041, 2173695.700583999, 5255053.314718033};
    ST.Point({2854539.218976094, 2172620.409320028, 5256022.657867197}, 4328);
    {2855120.846946211, 2172002.748338718, 5255962.428821041};
    {2855517.134262041, 2173695.700583999, 5255053.314718033};
}

status, reason = pcall(ST.LinearRing)
test:like(reason, "Usage", "LinearRing()")
status, reason = pcall(ST.LinearRing, points)
test:like(reason, "Usage", "LinearRing(points)")
status, reason = pcall(ST.LinearRing, 12, 23223)
test:like(reason, "Usage", "LinearRing(invalid, srid)")
status, reason = pcall(ST.LinearRing, {0, 2}, 23223)
test:like(reason, "Invalid point", "LinearRing(invalidpoint, srid)")
status, reason = pcall(ST.LinearRing, {{0, 0}, {0, 1}, {1, 1}}, 4326)
test:like(reason, "closed linestring", "LinearRing(not_closed, srid)")

local linearring = ST.LinearRing(points, 4326)
test:is(ST.GeometryType(linearring), "LinearRing",
    "GeometryType(LinearRing(points, srid))")
test:is(ST.SRID(linearring), 4326, "SRID(LinearRing(points, srid)) == srid")
test:ok(ST.Equals(linearring, ST.LinearRing(linearring, 4326)),
    "LinearRing(linearring) == linearring")
local linestring = ST.LineString(linearring, 4326)
test:ok(ST.Equals(linearring, linestring),
    "LineString(linearring, srid) == linearring")
test:ok(ST.Equals(linestring, ST.LinearRing(linestring, 4326)),
    "LinearRing(linestring, srid) == linestring")

local linearringz = ST.LinearRing(pointsz, 4328)
test:is(ST.GeometryType(linearringz), "LinearRing", "LinearRing(pointsz, srid)")
test:is(ST.SRID(linearringz), 4328, "SRID(LinearRing(pointsz, srid)) == srid")

status, reason = pcall(ST.AsTable)
test:like(reason, "Usage", "AsTable()")

local linearringtab, srid = ST.AsTable(linearring)
test:is_deeply(linearringtab[1], ST.AsTable(ST.PointN(linearring, 1)),
    "AsTable(linearring)[1] data")
test:is_deeply(linearringtab[2], ST.AsTable(ST.PointN(linearring, 2)),
    "AsTable(linearring)[2] data")
test:is_deeply(linearringtab[3], ST.AsTable(ST.PointN(linearring, 3)),
    "AsTable(linearring)[3] data")
test:is(srid, ST.SRID(linearring), "AsTable(linearring) srid")
test:ok(ST.Equals(ST.LinearRing(ST.AsTable(linearring)), linearring),
    "LinearRing(AsTable(linearring)) roundtrip")

local linearringztab, srid = ST.AsTable(linearringz)
test:is_deeply(linearringztab[1], ST.AsTable(ST.PointN(linearringz, 1)),
    "AsTable(linearringz)[1] data")
test:is_deeply(linearringztab[2], ST.AsTable(ST.PointN(linearringz, 2)),
    "AsTable(linearringz)[2] data")
test:is_deeply(linearringztab[3], ST.AsTable(ST.PointN(linearringz, 3)),
    "AsTable(linearringz)[3] data")
test:is(srid, ST.SRID(linearringz), "AsTable(linearringz) srid")
test:ok(ST.Equals(ST.LinearRing(ST.AsTable(linearringz)), linearringz),
    "LinearRing(AsTable(linearringz)) roundtrip")

--------------------------------------------------------------------------------
-- ST.GeomFromWKT()/ST.AsWKT()
--------------------------------------------------------------------------------

local linearringwkt = "LINEARRING (37.279357 55.849493, "..
    "37.275152 55.865005, 37.261676 55.864041, 37.279357 55.849493)"
status, reason = pcall(ST.GeomFromWKT)
test:like(reason, "Usage", "GeomFromWKT()")
status, reason = pcall(ST.GeomFromWKT, linearringwkt)
test:like(reason, "Usage", "GeomFromWKT(LINEARRING, missing srid")
status, reason = pcall(ST.AsWKT)
test:like(reason, "Usage", "AsWKT()")

local linearring1 = ST.GeomFromWKT(linearringwkt, 4326)
test:ok(ST.Equals(linearring1, linearring), "GeomFromWKT(LINEARRING, srid) data")
test:is(ST.SRID(linearring), ST.SRID(linearring1),
    "GeomFromWKT(LINEARRING, srid) srid")
test:is(ST.AsWKT(linearring), linearringwkt, "AsWKT(linearring)")
test:ok(ST.Equals(ST.GeomFromWKT(ST.AsWKT(linearring), 4326), linearring),
    "GeomFromWKT(AsWKT(linearring), srid) roundtrip")

local linearringzwkt = "LINEARRING Z ("..
    "2855517.134262041 2173695.700583999 5255053.314718033, "..
    "2854539.218976094 2172620.409320028 5256022.657867197, "..
    "2855120.846946211 2172002.748338718 5255962.428821041, "..
    "2855517.134262041 2173695.700583999 5255053.314718033)"
local linearringz1 = ST.GeomFromWKT(linearringzwkt, 4328)
test:ok(ST.Equals(linearringz1, linearringz),
    "GeomFromWKT(LINEARRING Z, srid) data")
test:is(ST.SRID(linearringz), ST.SRID(linearringz1),
    "GeomFromWKT(LINEARRING Z, srid) srid")
test:is(ST.AsWKT(linearringz), linearringzwkt, "AsWKT(linearringz)")
test:ok(ST.Equals(ST.GeomFromWKT(ST.AsWKT(linearringz), 4328), linearringz),
    "GeomFromWKT(AsWKT(linearringz), srid) roundtrip")

test:is(ST.AsWKT, linearring.wkt, "linearring:wkt()")
test:is(ST.AsWKT(linearring), tostring(linearring), "tostring(linearring)")

os.exit(test:check() == true and 0 or -1)
