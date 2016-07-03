#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST.Polygon')
test:plan(38)

--------------------------------------------------------------------------------
-- ST.Polygon()/ST.AsTable(polygon)
--------------------------------------------------------------------------------

local status, reason

local shell = {
    {37.279357, 55.849493};
    {37.275152, 55.865005};
    {37.261676, 55.864041};
    {37.279357, 55.849493};
}

local hole = {
    {37.267856, 55.853781};
    {37.269401, 55.858502};
    {37.273864, 55.854937};
    {37.267856, 55.853781};
}
status, reason = pcall(ST.Polygon)
test:like(reason, "Usage", "Polygon()")
status, reason = pcall(ST.Polygon, 12, 23223)
test:like(reason, "Usage", "Polygon(invalid, srid)")
status, reason = pcall(ST.Polygon, {0, 2}, 23223)
test:like(reason, "Usage", "Polygon(invalidpoint, srid)")
status, reason = pcall(ST.Polygon, {{{0, 0}, {0, 1}, {1, 1}}}, 4326)
test:like(reason, "closed linestring", "Polygon(not_closed, srid)")

local nohole = ST.Polygon({shell}, 4326)
test:is(ST.GeometryType(nohole), "Polygon",
    "GeometryType(Polygon({shell}, srid))")
test:is(ST.SRID(nohole), 4326, "SRID(Polygon(shell, srid)) == srid")
test:ok(ST.Equals(ST.ExteriorRing(nohole, 4326), ST.LinearRing(shell, 4326)),
    "ExteriourRing(nohole)")

test:is(ST.NumInteriorRings(nohole), 0, "NumInteriourRings(nohole)")
test:isnil(ST.InteriorRingN(nohole, 1), "InteriourRingN(nohole, 1)")
test:is(ST.NumInteriorRings, nohole.numinteriorrings,
    "onehole:numinteriorrings()")
test:is(ST.NumInteriorRings, nohole.numholes, "onehole:numholes()")
test:is(ST.InteriorRingN, nohole.interiorringn, "onehole:interiorringn()")
test:is(ST.InteriorRingN, nohole.interiorring, "onehole:interiorring()")
test:is(ST.InteriorRingN, nohole.hole, "onehole:hole()")

local onehole = ST.Polygon({shell, hole}, 4326)
test:is(ST.NumInteriorRings(onehole), 1, "NumInteriourRings(onehole)")
test:isnil(ST.InteriorRingN(onehole, 0), "InteriorRingN(onehole, 0)")
test:ok(ST.Equals(ST.InteriorRingN(onehole, 1), ST.LinearRing(hole, 4326)),
    "InteriorRingN(onehole, 1)")
test:isnil(ST.InteriorRingN(onehole, 2), "InteriorRingN(onehole, 2)")

status, reason = pcall(onehole.holes)
test:like(reason, "Usage", "onehole.holes")
local holes = onehole:holes()
test:isnil(holes[0], "onehole:holes()[0]")
test:ok(ST.Equals(holes[1], ST.LinearRing(hole, 4326)), "onehole:holes()[1]")
test:isnil(holes[2], "onehole:holes()[2]")
test:is(onehole.holes, onehole.interiorrings, "onehole:interiorrings()")

status, reason = pcall(onehole.iterholes)
test:like(reason, "Usage", "onehole.iterholes")
local holes = {}
for i, hole in onehole:iterholes() do holes[i] = hole end
test:isnil(holes[0], "onehole:iterholes()[0]")
test:ok(ST.Equals(holes[1], ST.LinearRing(hole, 4326)),
    "onehole:iterholes()[1]")
test:isnil(holes[2], "onehole:iterholes()[2]")
test:is(onehole.iterholes, onehole.iterinteriorrings,
    "onehole:iterinteriorrings()")

status, reason = pcall(ST.AsTable)
test:like(reason, "Usage", "AsTable()")

local noholetab, srid = ST.AsTable(nohole)
test:is_deeply(noholetab[1], ST.AsTable(ST.ExteriorRing(nohole)),
    "AsTable(noholes) exterior ring")
test:isnil(noholetab[2], "AsTable(noholes) interior ring 1")
test:ok(ST.Equals(ST.Polygon(ST.AsTable(nohole)), nohole),
    "Polygon(AsTable(nohole)) roundtrip")
test:is(srid, ST.SRID(nohole), "AsTable(nohole) srid")

local oneholetab, srid = ST.AsTable(onehole)
test:is_deeply(oneholetab[1], ST.AsTable(ST.ExteriorRing(onehole)),
    "AsTable(onehole) exterior ring")
test:is_deeply(oneholetab[2], ST.AsTable(ST.InteriorRingN(onehole, 1)),
    "AsTable(onehole) interior ring 1")
test:isnil(oneholetab[3], "AsTable(onehole) interior ring 2")
test:ok(ST.Equals(ST.Polygon(ST.AsTable(onehole)), onehole),
    "Polygon(AsTable(onehole)) roundtrip")
test:is(srid, ST.SRID(onehole), "AsTable(onehole) srid")

os.exit(test:check() == true and 0 or -1)
