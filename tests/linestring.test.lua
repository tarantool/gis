#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST.LineString')
test:plan(75)

--------------------------------------------------------------------------------
-- ST.LineString()/ST.AsTable(linestring)
--------------------------------------------------------------------------------

local status, reason

local points = {
    {37.279357, 55.849493};
    {37.275152, 55.865005};
    {37.261676, 55.864041};
}

local pointsz = {
    {2855517.134262041, 2173695.700583999, 5255053.314718033};
    ST.Point({2854539.218976094, 2172620.409320028, 5256022.657867197}, 4328);
    {2855120.846946211, 2172002.748338718, 5255962.428821041};
}

status, reason = pcall(ST.LineString)
test:like(reason, "Usage", "LineString()")
status, reason = pcall(ST.LineString, points)
test:like(reason, "Usage", "LineString(points)")
status, reason = pcall(ST.LineString, 12, 23223)
test:like(reason, "Usage", "LineString(invalid, srid)")
status, reason = pcall(ST.LineString, {0, 2}, 23223)
test:like(reason, "Invalid point", "LineString(invalidpoint, srid)")

test:is(tostring(ST.LineString({{0, 2}, {2, 2}}, 4326)),
        "LINESTRING (0 2, 2 2)", "LineString(points) 1")
test:is(tostring(ST.LineString({ST.Point({0, 2}, 4326), {2, 2}}, 4326)),
        "LINESTRING (0 2, 2 2)", "LineString(points) 2")
test:is(tostring(ST.LineString({{0, 2}, ST.Point({2, 2}, 4326)}, 4326)),
        "LINESTRING (0 2, 2 2)", "LineString(points) 3")

test:is(tostring(ST.LineString({{0, 2}, {2, 2, 3}}, 4328)),
        "LINESTRING Z (0 2 0, 2 2 3)", "LineString(pointsz) 1")
test:is(tostring(ST.LineString({{0, 2, 3}, {2, 2}}, 4328)),
        "LINESTRING Z (0 2 3, 2 2 0)", "LineString(pointsz) 2")
test:is(tostring(ST.LineString({ST.Point({0, 2}, 4326), {2, 2, 3}}, 4328)),
        "LINESTRING Z (0 2 0, 2 2 3)", "LineString(pointsz) 3")
test:is(tostring(ST.LineString({{0, 2, 3}, ST.Point({2, 2}, 4328)}, 4328)),
        "LINESTRING Z (0 2 3, 2 2 0)", "LineString(pointsz) 4")

local linestring = ST.LineString(points, 4326)
test:is(ST.GeometryType(linestring), "LineString",
    "GeometryType(LineString(points, srid))")
test:is(ST.SRID(linestring), 4326, "SRID(LineString(points, srid)) == srid")
test:ok(ST.Equals(linestring, ST.LineString(linestring, 4326)),
    "LineString(linestring) == linestring")

local linestringz = ST.LineString(pointsz, 4328)
test:is(ST.GeometryType(linestringz), "LineString", "LineString(pointsz, srid)")
test:is(ST.SRID(linestringz), 4328, "SRID(LineString(pointsz, srid)) == srid")
test:ok(ST.Equals(linestringz, ST.LineString(linestringz, 4328)),
    "LineString(linestringz) == linestringz")

status, reason = pcall(ST.AsTable)
test:like(reason, "Usage", "AsTable()")

local linestringtab, srid = ST.AsTable(linestring)
test:is_deeply(linestringtab[1], ST.AsTable(ST.PointN(linestring, 1)),
    "AsTable(linestring)[1] data")
test:is_deeply(linestringtab[2], ST.AsTable(ST.PointN(linestring, 2)),
    "AsTable(linestring)[2] data")
test:is_deeply(linestringtab[3], ST.AsTable(ST.PointN(linestring, 3)),
    "AsTable(linestring)[3] data")
test:is(srid, ST.SRID(linestring), "AsTable(linestring) srid")
test:ok(ST.Equals(ST.LineString(ST.AsTable(linestring)), linestring),
    "LineString(AsTable(linestring)) roundtrip")

local linestringztab, srid = ST.AsTable(linestringz)
test:is_deeply(linestringztab[1], ST.AsTable(ST.PointN(linestringz, 1)),
    "AsTable(linestringz)[1] data")
test:is_deeply(linestringztab[2], ST.AsTable(ST.PointN(linestringz, 2)),
    "AsTable(linestringz)[2] data")
test:is_deeply(linestringztab[3], ST.AsTable(ST.PointN(linestringz, 3)),
    "AsTable(linestringz)[3] data")
test:is(srid, ST.SRID(linestringz), "AsTable(linestringz) srid")
test:ok(ST.Equals(ST.LineString(ST.AsTable(linestringz)), linestringz),
    "LineString(AsTable(linestringz)) roundtrip")

--------------------------------------------------------------------------------
-- ST.GeomFromWKT()/ST.AsWKT()
--------------------------------------------------------------------------------

local linestringwkt = "LINESTRING (37.279357 55.849493, "..
    "37.275152 55.865005, 37.261676 55.864041)"
status, reason = pcall(ST.GeomFromWKT)
test:like(reason, "Usage", "GeomFromWKT()")
status, reason = pcall(ST.GeomFromWKT, pointwkt)
test:like(reason, "Usage", "GeomFromWKT(LINESTRING, missing srid")
status, reason = pcall(ST.AsWKT)
test:like(reason, "Usage", "AsWKT()")

local linestring1 = ST.GeomFromWKT(linestringwkt, 4326)
test:ok(ST.Equals(linestring1, linestring), "GeomFromWKT(LINESTRING, srid) data")
test:is(ST.SRID(linestring), ST.SRID(linestring1),
    "GeomFromWKT(LINESTRING, srid) srid")
test:is(ST.AsWKT(linestring), linestringwkt, "AsWKT(linestring)")
test:ok(ST.Equals(ST.GeomFromWKT(ST.AsWKT(linestring), 4326), linestring),
    "GeomFromWKT(AsWKT(linestring), srid) roundtrip")

local linestringzwkt = "LINESTRING Z ("..
    "2855517.134262041 2173695.700583999 5255053.314718033, "..
    "2854539.218976094 2172620.409320028 5256022.657867197, "..
    "2855120.846946211 2172002.748338718 5255962.428821041)"
local linestringz1 = ST.GeomFromWKT(linestringzwkt, 4328)
test:ok(ST.Equals(linestringz1, linestringz),
    "GeomFromWKT(LINESTRING Z, srid) data")
test:is(ST.SRID(linestringz), ST.SRID(linestringz1),
    "GeomFromWKT(LINESTRING Z, srid) srid")
test:is(ST.AsWKT(linestringz), linestringzwkt, "AsWKT(linestringz)")
test:ok(ST.Equals(ST.GeomFromWKT(ST.AsWKT(linestringz), 4328), linestringz),
    "GeomFromWKT(AsWKT(linestringz), srid) roundtrip")

test:is(ST.AsWKT, linestring.wkt, "linestring:wkt()")
test:is(ST.AsWKT(linestring), tostring(linestring), "tostring(linestring)")

--------------------------------------------------------------------------------
-- ST.GeomFromWKB()/ST.AsWKB()
--------------------------------------------------------------------------------

local linestringwkb = "\x01\x02\x00\x00\x00\x03\x00\x00\x00\x4F\x74\x5D\xF8"..
    "\xC1\xA3\x42\x40\x29\x97\xC6\x2F\xBC\xEC\x4B\x40\xE9\xB6\x44\x2E\x38"..
    "\xA3\x42\x40\x30\xF0\xDC\x7B\xB8\xEE\x4B\x40\xF5\x12\x63\x99\x7E\xA1"..
    "\x42\x40\x9A\xB3\x3E\xE5\x98\xEE\x4B\x40"
status, reason = pcall(ST.GeomFromWKB)
test:like(reason, "Usage", "GeomFromWKB()")
status, reason = pcall(ST.GeomFromWKB, linestringwkb)
test:like(reason, "Usage", "GeomFromWKB(bin) missing srid")
status, reason = pcall(ST.AsWKB)
test:like(reason, "Usage", "AsWKB()")

local linestring1 = ST.GeomFromWKB(linestringwkb, 4326)
test:ok(ST.Equals(linestring1, linestring), "GeomFromWKB(bin, srid) data")
test:is(ST.SRID(linestring), ST.SRID(linestring1),  "GeomFromWKB(bin, srid) srid")
test:is(ST.AsWKB(linestring), linestringwkb, "AsWKB(linestring)")
test:ok(ST.Equals(ST.GeomFromWKB(ST.AsWKB(linestring), 4328), linestring),
    "GeomFromWKB(AsWKB(linestring), srid) roundtrip")

local linestringzwkb = "\x01\x02\x00\x00\x00\x03\x00\x00\x00\xA2\x7F\x2F"..
    "\x91\x2E\xC9\x45\x41\x8A\xBC\xAC\xD9\x7F\x95\x40\x41\x9D\x68\x07\x9C"..
    "\x45\xC7\x45\x41\x43\x99\x64\x34\x66\x93\x40\x41\xC3\xBB\x68\x6C\x68"..
    "\xC8\x45\x41\x28\x90\xC9\x5F\x31\x92\x40\x41"
local linestringz1 = ST.GeomFromWKB(linestringzwkb, 4328)
test:ok(ST.Equals(linestringz, linestringz1), "GeomFromWKB(binz, srid) data")
test:is(ST.SRID(linestring), ST.SRID(linestring1),  "GeomFromWKB(binz, srid) srid")
test:is(ST.AsWKB(linestringz), linestringzwkb, "AsWKB(linestringz)")
test:ok(ST.Equals(ST.GeomFromWKB(ST.AsWKB(linestringz), 4328), linestringz),
    "GeomFromWKB(AsWKB(linestringz), srid) roundtrip")

test:is(ST.AsWKB, linestring.wkb, "linestring:wkb()")
test:is(ST.AsWKB, linestring.bin, "linestring:bin()")

--------------------------------------------------------------------------------
-- ST.GeomFromHEXWKB()/ST.AsHExWKB()
--------------------------------------------------------------------------------

local linestringhexwkb = "0102000000030000004F745DF8C1A342402997C62FBCEC4B40"..
    "E9B6442E38A3424030F0DC7BB8EE4B40F51263997EA142409AB33EE598EE4B40"
status, reason = pcall(ST.GeomFromHEXWKB)
test:like(reason, "Usage", "GeomFromHEXWKB()")
status, reason = pcall(ST.GeomFromHEXWKB, linestringhexwkb)
test:like(reason, "Usage", "GeomFromHEXWKB(hex) missing srid")
status, reason = pcall(ST.AsHEXWKB)
test:like(reason, "Usage", "AsHEXWKB()")

local linestring1 = ST.GeomFromHEXWKB(linestringhexwkb, 4326)
test:ok(ST.Equals(linestring1, linestring), "GeomFromHEXWKB(hex, srid) data")
test:is(ST.SRID(linestring), ST.SRID(linestring1),  "GeomFromHEXWKB(hex, srid) srid")
test:is(ST.AsHEXWKB(linestring), linestringhexwkb, "AsHEXWKB(linestring)")
test:ok(ST.Equals(ST.GeomFromHEXWKB(ST.AsHEXWKB(linestring), 4328), linestring),
    "GeomFromHEXWKB(AsHEXWKB(linestring), srid) roundtrip")

local linestringzhexwkb = "010200000003000000A27F2F912EC945418ABCACD97F954"..
    "0419D68079C45C745414399643466934041C3BB686C68C845412890C95F31924041"
local linestringz1 = ST.GeomFromHEXWKB(linestringzhexwkb, 4328)
test:ok(ST.Equals(linestringz, linestringz1), "GeomFromHEXWKB(hexz, srid) data")
test:is(ST.SRID(linestring), ST.SRID(linestring1),  "GeomFromWKB(hexz, srid) srid")
test:is(ST.AsHEXWKB(linestringz), linestringzhexwkb, "AsHEXWKB(linestringz)")
test:ok(ST.Equals(ST.GeomFromHEXWKB(ST.AsHEXWKB(linestringz), 4328), linestringz),
    "GeomFromHEXWKB(AsHEXWKB(linestringz), srid) roundtrip")

test:is(ST.AsHEXWKB, linestring.hexwkb, "linestring:hexwkb()")
test:is(ST.AsHEXWKB, linestring.hex, "linestring:hex()")

--------------------------------------------------------------------------------
-- ST.Transform()
--------------------------------------------------------------------------------

local latlongid = 4326
local utmid = 32644
local geocentid = 4328

local latlong = ST.LineString(points, latlongid)
local geocent = ST.LineString(pointsz, geocentid)
local utm = ST.LineString({
    {-2116061.657717823, 7085544.124896262};
    {-2115122.65378007, 7087189.730049551};
    {-2115911.417331398, 7087666.627804892};
}, utmid)

local utm1 = ST.Transform(latlong, utmid)
test:ok(utm:distance(utm1) < 1, "ST_Transform(latlong, utm)")
test:is(utm1:srid(), utmid, "ST_Transform(latlong, utm)")

local latlong1 = ST.Transform(utm, latlongid)
test:ok(latlong:distance(latlong1) < 2, "ST_Transform(utm, latlong)")
test:is(latlong1:srid(), latlongid, "ST_Transform(utm, latlong)")

local geocent1 = ST.Transform(latlong, geocentid)
test:ok(geocent:distance(geocent1) < 1, "ST_Transform(latlong, geocent)")
test:is(geocent1:srid(), geocentid, "ST_Transform(latlong, geocent)")

local latlong1 = ST.Transform(geocent, latlongid)
test:ok(latlong:distance(latlong1) < 1, "ST_Transform(geocent, latlong)")
test:is(latlong1:srid(), latlongid, "ST_Transform(geocent, latlong)")

os.exit(test:check() == true and 0 or -1)
