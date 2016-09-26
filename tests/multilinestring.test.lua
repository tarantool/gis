#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST.MultiLineString')
test:plan(12)

local linestrings = {
    {
        {37.279357, 55.849493};
        {37.275152, 55.865005};
        {37.261676, 55.864041};
    };
    ST.LineString({
        {37.267856, 55.853781};
        {37.269401, 55.858502};
        {37.273864, 55.854937};
    }, 4326);
}

local status, reason
status, reason = pcall(ST.MultiLineString)
test:like(reason, "Usage", "MultiLineString()")
status, reason = pcall(ST.MultiLineString, linestrings[1])
test:like(reason, "Usage", "MultiLineString(points)")
status, reason = pcall(ST.MultiLineString, 12, 23223)
test:like(reason, "Usage", "MultiLineString(invalid, srid)")
status, reason = pcall(ST.MultiLineString, {0, 2}, 23223)
test:like(reason, "Usage", "MultiLineString(invalidpoint, srid)")

local multilinestring = ST.MultiLineString(linestrings, 4326)
test:is(ST.GeometryType(multilinestring), "MultiLineString",
    "GeometryType(MultiLineString(points, srid))")
test:is(ST.SRID(multilinestring), 4326,
    "SRID(MultiLineString(points, srid)) == srid")

status, reason = pcall(ST.AsTable)
test:like(reason, "Usage", "AsTable()")

local multilinestringtab, srid = ST.AsTable(multilinestring)
test:is_deeply(multilinestringtab[1], ST.AsTable(ST.GeometryN(multilinestring, 1)),
    "AsTable(multilinestring)[1] data")
test:is_deeply(multilinestringtab[2], ST.AsTable(ST.GeometryN(multilinestring, 2)),
    "AsTable(multilinestring)[2] data")
test:isnil(multilinestringtab[3], "AsTable(multilinestring)[3] data")
test:is(srid, ST.SRID(multilinestring), "AsTable(multilinestring) srid")
test:ok(ST.Equals(ST.MultiLineString(ST.AsTable(multilinestring)), multilinestring),
    "MultiLineString(AsTable(multilinestring)) roundtrip")

os.exit(test:check() == true and 0 or -1)
