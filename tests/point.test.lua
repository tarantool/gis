#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST.Point')
test:plan(77)

--------------------------------------------------------------------------------
-- ST.Point()/ST.AsTable(point)
--------------------------------------------------------------------------------

local status, reason
status, reason = pcall(ST.Point)
test:like(reason, "Usage", "Point()")
status, reason = pcall(ST.Point, {37.17284, 55.74495})
test:like(reason, "Usage", "Point({x, y})")
status, reason = pcall(ST.Point, 12, 23223)
test:like(reason, "Usage", "Point(invalid, srid)")

local point = ST.Point({37.17284, 55.74495}, 4326)
test:is(ST.GeometryType(point), "Point",
    "GeometryType(Point({x, y}, srid))")
test:is(ST.SRID(point), 4326, "SRID(Point({x, y}, srid)) == srid")

local pointz = ST.Point({420562, 3801090, 5087342}, 4328)
test:is(ST.GeometryType(pointz), "Point",
    "GeometryType(Point({x, y, z}, srid))")
test:is(ST.SRID(pointz), 4328, "SRID(Point({x, y, z}, srid)) == srid")

status, reason = pcall(ST.AsTable)
test:like(reason, "Usage", "AsTable()")

local pointtab, srid = ST.AsTable(point)
test:is_deeply(pointtab, {ST.X(point), ST.Y(point)}, "AsTable(point) data")
test:is(srid, ST.SRID(point), "AsTable(point) srid")
test:ok(ST.Equals(ST.Point(ST.AsTable(point)), point),
    "Point(AsTable(point)) roundtrip")

local pointztab, srid = ST.AsTable(pointz)
test:is_deeply(pointztab, {ST.X(pointz), ST.Y(pointz), ST.Z(pointz)},
    "AsTable(pointz) data")
test:is(srid, ST.SRID(pointz), "AsTable(pointz) srid")
test:ok(ST.Equals(ST.Point(ST.AsTable(pointz)), pointz),
    "Point(AsTable(pointz)) roundtrip")

--------------------------------------------------------------------------------
-- ST.GeomFromWKT()/ST.AsWKT()
--------------------------------------------------------------------------------

local pointwkt = "POINT (37.17284 55.74495)"
status, reason = pcall(ST.GeomFromWKT)
test:like(reason, "Usage", "GeomFromWKT()")
status, reason = pcall(ST.GeomFromWKT, pointwkt)
test:like(reason, "Usage", "GeomFromWKT(POINT (x y)) missing srid")
status, reason = pcall(ST.AsWKT)
test:like(reason, "Usage", "AsWKT()")

local point1 = ST.GeomFromWKT(pointwkt, 4326)
test:ok(ST.Equals(point1, point), "GeomFromWKT(POINT (x y), srid) data")
test:is(ST.SRID(point), ST.SRID(point1),  "GeomFromWKT(POINT (x y), srid) srid")
test:is(ST.AsWKT(point), pointwkt, "AsWKT(point)")
test:ok(ST.Equals(ST.GeomFromWKT(ST.AsWKT(point), 4326), point),
    "GeomFromWKT(AsWKT(point), srid) roundtrip")

local pointzwkt = "POINT Z (420562 3801090 5087342)"
local pointz1 = ST.GeomFromWKT(pointzwkt, 4328)
test:ok(ST.Equals(pointz1, pointz), "GeomFromWKT(POINT Z (x y z), srid) data")
test:is(ST.SRID(pointz), ST.SRID(pointz1),  "GeomFromWKT(POINT Z (x y z), srid) srid")
test:is(ST.AsWKT(pointz), pointzwkt, "AsWKT(pointz)")
test:ok(ST.Equals(ST.GeomFromWKT(ST.AsWKT(pointz), 4328), pointz),
    "GeomFromWKT(AsWKT(pointz), srid) roundtrip")

test:is(ST.AsWKT, point.wkt, "point:wkt()")
test:is(ST.AsWKT(point), tostring(point), "tostring(geom)")

--------------------------------------------------------------------------------
-- ST.GeomFromWKB()/ST.AsWKB()
--------------------------------------------------------------------------------

local pointwkb = "\x01\x01\x00\x00\x00\x67\xB8\x01"..
    "\x9F\x1F\x96\x42\x40\xDE\x93\x87\x85\x5A\xDF\x4B\x40"
status, reason = pcall(ST.GeomFromWKB)
test:like(reason, "Usage", "GeomFromWKB()")
status, reason = pcall(ST.GeomFromWKB, pointwkb)
test:like(reason, "Usage", "GeomFromWKB(bin) missing srid")
status, reason = pcall(ST.AsWKB)
test:like(reason, "Usage", "AsWKB()")

local point1 = ST.GeomFromWKB(pointwkb, 4326)
test:ok(ST.Equals(point1, point), "GeomFromWKB(bin, srid) data")
test:is(ST.SRID(point), ST.SRID(point1),  "GeomFromWKB(bin, srid) srid")
test:is(ST.AsWKB(point), pointwkb, "AsWKB(point)")
test:ok(ST.Equals(ST.GeomFromWKB(ST.AsWKB(point), 4328), point),
    "GeomFromWKB(AsWKB(point), srid) roundtrip")

local pointzwkb = "\x01\x01\x00\x00\x00\x00\x00\x00\x00\x48\xAB\x19\x41"..
    "\x00\x00\x00\x00\x01\x00\x4D\x41"
local pointz1 = ST.GeomFromWKB(pointzwkb, 4328)
test:ok(ST.Equals(pointz, pointz1), "GeomFromWKB(binz, srid) data")
test:is(ST.SRID(point), ST.SRID(point1),  "GeomFromWKB(binz, srid) srid")
test:is(ST.AsWKB(pointz), pointzwkb, "AsWKB(pointz)")
test:ok(ST.Equals(ST.GeomFromWKB(ST.AsWKB(pointz), 4328), pointz),
    "GeomFromWKB(AsWKB(pointz), srid) roundtrip")

test:is(ST.AsWKB, point.wkb, "point:wkb()")
test:is(ST.AsWKB, point.bin, "point:bin()")

--------------------------------------------------------------------------------
-- ST.GeomFromHEXWKB()/ST.AsHExWKB()
--------------------------------------------------------------------------------

local pointhexwkb = "010100000067B8019F1F964240DE9387855ADF4B40"
status, reason = pcall(ST.GeomFromHEXWKB)
test:like(reason, "Usage", "GeomFromHEXWKB()")
status, reason = pcall(ST.GeomFromHEXWKB, pointhexwkb)
test:like(reason, "Usage", "GeomFromHEXWKB(hex) missing srid")
status, reason = pcall(ST.AsHEXWKB)
test:like(reason, "Usage", "AsHEXWKB()")

local point1 = ST.GeomFromHEXWKB(pointhexwkb, 4326)
test:ok(ST.Equals(point1, point), "GeomFromHEXWKB(hex, srid) data")
test:is(ST.SRID(point), ST.SRID(point1),  "GeomFromHEXWKB(hex, srid) srid")
test:is(ST.AsHEXWKB(point), pointhexwkb, "AsHEXWKB(point)")
test:ok(ST.Equals(ST.GeomFromHEXWKB(ST.AsHEXWKB(point), 4328), point),
    "GeomFromHEXWKB(AsHEXWKB(point), srid) roundtrip")

local pointzhexwkb = "01010000000000000048AB19410000000001004D41"
local pointz1 = ST.GeomFromHEXWKB(pointzhexwkb, 4328)
test:ok(ST.Equals(pointz, pointz1), "GeomFromHEXWKB(hexz, srid) data")
test:is(ST.SRID(point), ST.SRID(point1),  "GeomFromWKB(hexz, srid) srid")
test:is(ST.AsHEXWKB(pointz), pointzhexwkb, "AsHEXWKB(pointz)")
test:ok(ST.Equals(ST.GeomFromHEXWKB(ST.AsHEXWKB(pointz), 4328), pointz),
    "GeomFromHEXWKB(AsHEXWKB(pointz), srid) roundtrip")

test:is(ST.AsHEXWKB, point.hexwkb, "point:hexwkb()")
test:is(ST.AsHEXWKB, point.hex, "point:hex()")

--------------------------------------------------------------------------------
-- ST.X()/ST.Y()/ST.Z()
--------------------------------------------------------------------------------

-- X
test:ok(not pcall(ST.X), "X()")
test:is(ST.X(point), 37.17284, "X(point)")
test:is(ST.X(pointz), 420562, "X(pointz)")
test:is(ST.X, point.x, "point:x()")

-- Y
test:ok(not pcall(ST.Y), "Y()")
test:is(ST.Y(point), 55.74495, "Y(point)")
test:is(ST.Y(pointz), 3801090, "Y(pointz)")
test:is(ST.Y, point.y, "point:y()")

-- Z
test:ok(not pcall(ST.Z), "Z()")
test:isnil(ST.Z(point), "Z(point)")
test:is(ST.Z(pointz), 5087342, "Z(pointz)")
test:is(ST.Z, point.z, "point:z()")

--------------------------------------------------------------------------------
-- ST.Transform()
--------------------------------------------------------------------------------

local latlongid = 4326
local utmid = 32644
local geocentid = 4328

local latlong = ST.Point({83.6863374710083, 53.2515552815204}, latlongid)
local geocent = ST.Point({420562, 3801090, 5087342}, geocentid)
local utm = ST.Point({679212.9, 5903622}, utmid)

local utm1 = ST.Transform(latlong, utmid)
test:ok(utm:distance(utm1) < 1, "ST_Transform(latlong, utm)")
test:is(utm1:srid(), utmid, "ST_Transform(latlong, utm)")
test:isnil(utm1:z(), "ST_Transform(latlong, utm)")

local latlong1 = ST.Transform(utm, latlongid)
test:ok(latlong:distance(latlong1) < 1, "ST_Transform(utm, latlong)")
test:is(latlong1:srid(), latlongid, "ST_Transform(utm, latlong)")
test:isnil(latlong1:z(), "ST_Transform(utm, latlong)")

local geocent1 = ST.Transform(latlong, geocentid)
test:ok(geocent:distance(geocent1) < 1, "ST_Transform(latlong, geocent)")
test:is(geocent1:srid(), geocentid, "ST_Transform(latlong, geocent)")
test:isnt(geocent1:z(), nil, "ST_Transform(latlong, geocent)")

local latlong1 = ST.Transform(geocent, latlongid)
test:ok(latlong:distance(latlong1) < 1, "ST_Transform(geocent, latlong)")
test:is(latlong1:srid(), latlongid, "ST_Transform(geocent, latlong)")
test:isnil(latlong1:z(), "ST_Transform(geocent, latlong)")

os.exit(test:check() == true and 0 or -1)
