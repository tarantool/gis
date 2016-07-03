#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib"..package.cpath

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
local ST = gis.ST

local test = require('tap').test('gis.ST')
test:plan(134)

local geom, point, pointz, linestring, polygon, status, reason

--------------------------------------------------------------------------------
-- WKT and WKB
--------------------------------------------------------------------------------

-- ST.GeomFromWKT
status, reason = pcall(ST.GeomFromWKT)
test:like(reason, "Usage", "GeomFromWKT()")
status, reason = pcall(ST.GeomFromWKT, "POINT(10 20)")
test:like(reason, "Usage", "GeomFromWKT(wkt)")
status, reason = pcall(ST.GeomFromWKT, "INVALID", 4326)
test:like(reason, "Unknown type", "GeomFromWKT(invalid_wkt, srid)")
point = ST.GeomFromWKT("POINT (37.17284 55.74495)", 4326)
test:ok(point, "GeomFromWKT('POINTZ (x y), srid'")
linestring = ST.GeomFromWKT('LINESTRING(0 0, 1 3)', 4326)
test:ok(linestring, "GeomFromWKT('LINESTRING (x1 y1, x2 y2), srid'")
polygon = ST.GeomFromWKT([[POLYGON (
    ( 10 130, 50 190, 110 190, 140 150, 150 80, 100 10, 20 40, 10 130  ),
    ( 70 40, 100 50, 120 80, 80 110, 50 90, 70 40  )
)]], 4326)
test:ok(polygon, "GeomFromWKT('POLYGON (...)', srid)")
local collection = ST.GeomFromWKT([[GEOMETRYCOLLECTION(
MULTIPOINT(-2 3 , -2 2),
LINESTRING(5 5 ,10 10),
POLYGON((-7 4.2,-7.1 5,-7.1 4.3,-7 4.2))
)]], 4326)
test:ok(collection, "GeomFromWKT('GEOMETRYCOLLECTION (...)', srid)")

test:is(ST.GeomFromWKT, gis.wkt.decode, "wkt.decode")
test:is(ST.AsWKT, gis.wkt.encode, "wkt.encode")
test:is(ST.AsWKT, point.wkt, "geom:wkt()")

test:is(ST.GeomFromWKB, gis.wkb.decode, "wkb.decode")
test:is(ST.AsWKB, gis.wkb.encode, "wkb.encode")
test:is(ST.AsWKB, point.wkb, "geom:wkb()")

test:is(ST.GeomFromHEXWKB, gis.wkb.decode_hex, "wkb.decode_hex")
test:is(ST.AsHEXWKB, gis.wkb.encode_hex, "wkb.encode_hex")
test:is(ST.AsHEXWKB, point.hexwkb, "geom:hexwkb()")

--------------------------------------------------------------------------------
-- Geometry Accesors
--------------------------------------------------------------------------------

-- Boundary
test:ok(not pcall(ST.Boundary), "Boundary()")
test:like(tostring(ST.Boundary(polygon)), "MULTILINESTRING", "Boundary(polygon)")
local shell = {{10, 130}, {50, 190}, {110, 190}, {140, 150}, {150, 80},
    {100, 10}, {20, 40}, {10, 130}};
local hole = {{70, 40}, {100, 50}, {120, 80}, {80, 110}, {50, 90}, {70, 40}}
test:ok(ST.Equals(ST.Boundary(ST.Polygon({shell, hole}, 0)),
        gis.MultiLineString({shell, hole}, 0)), "Boundary(polygon)")

-- Envelope
test:ok(not pcall(ST.Envelope), "Envelope()")
test:like(tostring(ST.Envelope(linestring)), "POLYGON", "Envelope(linestring)")
test:like(tostring(ST.Envelope(collection)), "POLYGON", "Envelope(collection)")
test:ok(ST.Equals(ST.Envelope(ST.Polygon({shell, hole}, 0)),
       gis.Polygon({{{10, 10}, {150, 10}, {150, 190}, {10, 190}, {10, 10}}}, 0)),
       "Envelope(polygon)")

-- GeometryType
test:ok(not pcall(ST.GeometryType), "GeometryType()")
test:is(ST.GeometryType(point), "Point", "GeometryType(point)")
test:is(ST.GeometryType(linestring), "LineString", "GeometryType(linestring)")
test:is(ST.GeometryType(polygon), "Polygon", "GeometryType(polygon)")
test:is(ST.GeometryType, point.type, "geom:type()")

-- GeometryId
test:ok(not pcall(ST.GeometryTypeId), "GeometryTypeId()")
test:is(ST.GeometryTypeId(point), 0, "GeometryTypeId(point)")
test:is(ST.GeometryTypeId(linestring), 1, "GeometryTypeId(linestring)")
test:is(ST.GeometryTypeId(polygon), 3, "GeometryTypeId(polygon)")
test:is(ST.GeometryTypeId, point.typeid, "geom:typeid()")

-- IsCollection
test:ok(not pcall(ST.IsCollection), "IsCollection()")
test:is(ST.IsCollection(point), false, "IsCollection(point)")
test:is(ST.IsCollection(linestring), false, "IsCollection(linestring)")
test:is(ST.IsCollection(collection), true, "IsCollection(collection)")

-- NumGeometries
test:ok(not pcall(ST.NumGeometries), "NumGeometries()")
test:is(ST.NumGeometries(point), 1, "NumGeometries(point)")
test:is(ST.NumGeometries(linestring), 1, "NumGeometries(linestring)")
test:is(ST.NumGeometries(collection), 3, "NumGeometries(collection)")

-- GeometryN
test:ok(not pcall(ST.GeometryN), "GeometryN()")
test:is(ST.GeometryN(point, 0), nil, "GeometryN(point, 0)")
test:like(ST.GeometryN(point, 1), 'POINT', "GeometryN(point, 1)")
test:is(ST.SRID(ST.GeometryN(point, 1)), ST.SRID(point),
    "SRID(GeometryN(point, 1))")

test:is(ST.GeometryN(point, 2), nil, "GeometryN(point, 2)")

test:is(ST.GeometryN(collection, 0), nil, "GeometryN(collection, 0)")
test:like(ST.GeometryN(collection, 1), 'MULTIPOINT', "GeometryN(collection, 1)")
test:like(ST.GeometryN(collection, 2), 'LINESTRING', "GeometryN(collection, 2)")
test:like(ST.GeometryN(collection, 3), 'POLYGON', "GeometryN(collection, 3)")
test:is(ST.GeometryN(collection, 4), nil, "GeometryN(collection, 4)")

-- :geometries()
local geometries = collection:geometries()
test:is(geometries[0], nil, "collection:geometries()[0]")
test:like(geometries[1], 'MULTIPOINT', "collection:geometries()[1]")
test:like(geometries[2], 'LINESTRING', "collection:geometries()[2]")
test:like(geometries[3], 'POLYGON', "collection:geometries()[3]")
test:is(geometries[4], nil, "collection:geometries()[4]")

-- :itergeometries()
local geometries2 = {}
for i, geom in collection:itergeometries() do geometries2[i] = geom end
test:is(geometries2[0], nil, "collection:itergeometries()[0]")
test:like(geometries2[1], 'MULTIPOINT', "collection:itergeometries()[1]")
test:like(geometries2[2], 'LINESTRING', "collection:itergeometries()[2]")
test:like(geometries2[3], 'POLYGON', "collection:itergeometries()[3]")
test:is(geometries2[4], nil, "collection:itergeometries()[3]")

-- NumPoints
test:ok(not pcall(ST.NumPoints), "NumPoints()")
test:ok(not pcall(ST.NumPoints, point), "NumPoints(point)")
test:is(ST.NumPoints(linestring), 2, "NumPoints(linestring)")
test:ok(not pcall(ST.NumPoints, collection), "NumPoints(collection)")
test:is(ST.NumPoints, linestring.numpoints, "linestring:numpoints()")

-- PointN
test:ok(not pcall(ST.PointN), "PointN()")
test:is(ST.PointN(linestring, 0), nil, "PointN(linestring, 0)")
test:like(ST.PointN(linestring, 1), "POINT", "PointN(linestring, 1)")
test:is(ST.PointN(linestring, 3), nil, "PointN(linestring, 3)")
test:like(ST.SRID(ST.PointN(linestring, 1)), ST.SRID(linestring),
    "SRID(PointN(linestring, 1))")
test:is(ST.PointN, linestring.pointn, "linestring:pointn()")
test:is(ST.PointN, linestring.point, "linestring:point()")

-- :points()
status, reason = pcall(linestring.points)
test:like(reason, 'Usage', "linestring.points")
local points = linestring:points()
test:is(points[0], nil, "linestring:points()[0]")
test:like(points[1], "POINT", "linestring:points()[1]")
test:is(points[3], nil, "linestring:points()[3]")

-- :iterpoints()
status, reason = pcall(linestring.iterpoints)
test:like(reason, 'Usage', "linestring.iterpoints")
local points = {}
for i, point in linestring:iterpoints() do points[i] = point end
test:is(points[0], nil, "linestring:iterpoints()[0]")
test:like(points[1], "POINT", "linestring:iterpoints()[1]")
test:is(points[3], nil, "linestring:iterpoints()[3]")

-- SetSRID/SRID
test:ok(not pcall(ST.SRID), "SRID()")
test:is(ST.SRID(point), 4326, "SRID(point)")

--------------------------------------------------------------------------------
-- Spatial Relationships and Measurements
--------------------------------------------------------------------------------

local wgs84 = 4326
local nevada = ST.Polygon({{
    {-120.000000, 42.000000};
    {-114.000000, 42.000000};
    {-114.000000, 34.687427};
    {-120.000000, 39.000000};
    {-120.000000, 42.000000};
}}, wgs84)

local lasvegas = ST.Point({-115.136389, 36.175}, wgs84)
local losangeles = ST.Point({-118.25, 34.05}, wgs84)

test:is(nevada:contains(lasvegas), true, "Contains()")
test:is(nevada:contains(losangeles), false, "Contains()")

local line = ST.LineString({lasvegas, losangeles}, wgs84)
local dist = line:transform(2770):length()
test:ok(dist < 380e3 and dist > 350e3, "Length()")
test:is(ST.Length, line.length, "g:area()")

local area = nevada:transform(2163):area() * 1e-6
test:ok(area > 290000 and area < 300000, "Area()")
test:is(ST.Area, nevada.area, "g:area()")

-- HausdorffDistance
local linestring = gis.LineString({ {0, 0}, {2, 0} }, 0)
local multipoint = gis.MultiPoint({ {0, 1}, {1, 0}, {2, 1} }, 0)
local linestring2 = gis.LineString({ {0, 0}, {3, 0}, {0, 3} }, 0)

test:is(ST.HausdorffDistance(linestring, multipoint), 1.0, "HausdoffDistance()")
test:is(ST.HausdorffDistance(linestring, linestring2), 3.0, "HausdoffDistance()")
test:is(ST.HausdorffDistance, linestring.hausdorff, "g1:hausdorff(g2)")
test:is(ST.HausdorffDistance, linestring.hausdorffdistance,
    "g1:hausdorffdistance(g2)")

-- Equals
status, reason = pcall(ST.Equals)
test:like(reason, "Usage", "Equals()")
test:ok(ST.Equals(
    ST.LineString({{0, 0}, {2, 2}}, 0),
    ST.LineString({{2, 2}, {0, 0}}, 0)), "Equals(g1, g2)")
test:ok(not ST.Equals(
    ST.LineString({{0, 0}, {2, 2}}, 0),
    ST.LineString({{3, 2}, {0, 0}}, 0)), "Equals(g1, g2)")
test:ok(ST.Equals(
    ST.LineString({{0, 0}, {2, 2}}, 0),
    ST.LineString({{2, 3}, {0, 0}}, 0), 10), "Equals(g1, g2)")
test:is(ST.Equals, point.equals, "g1:equals(g2)")

-- Disjoint
status, reason = pcall(ST.Disjoint)
test:like(reason, "Usage", "Disjoint()")
test:ok(ST.Disjoint(ST.Point({0, 0}, 0), ST.LineString({{2, 0}, {0, 2}}, 0)),
    "Disjoint(g1, g2)")
test:ok(not ST.Disjoint(ST.Point({0, 0}, 0), ST.LineString({{0, 0}, {0, 2}}, 0)),
    "Disjoint(g1, g2)")
test:is(ST.Disjoint, point.disjoint, "g1:disjoint(g2)")

-- Intersects
status, reason = pcall(ST.Intersects)
test:like(reason, "Usage", "Intersects()")
test:ok(not ST.Intersects(ST.Point({0, 0}, 0), ST.LineString({{2, 0}, {0, 2}}, 0)),
    "Intersects(g1, g2)")
test:ok(ST.Intersects(ST.Point({0, 0}, 0), ST.LineString({{0, 0}, {0, 2}}, 0)),
    "Intersects(g1, g2)")
test:is(ST.Intersects, point.intersects, "g1:intersects(g2)")

-- Touches
status, reason = pcall(ST.Touches)
test:like(reason, "Usage", "Touches()")
test:ok(not ST.Touches(ST.LineString({{0, 0}, {1, 1}, {0, 2}}, 0),
    ST.Point({1,1}, 0)), "Touches(g1, g2)")
test:ok(ST.Touches(ST.LineString({{0, 0}, {1, 1}, {0, 2}}, 0),
    ST.Point({0,2}, 0)), "Touches(g1, g2)")
test:is(ST.Touches, point.touches, "g1:touches(g2)")

-- Crosses
status, reason = pcall(ST.Touches)
test:like(reason, "Usage", "Crosses()")
test:ok(ST.Crosses(ST.LineString({{0, 0}, {2, 2}}, 0),
    ST.LineString({{0, 2}, {2, 0}}, 0)), "Crosses(g1, g2)")
test:ok(not ST.Crosses(ST.LineString({{0, 0}, {0, 8}}, 0),
    ST.LineString({{0, 2}, {2, 0}}, 0)), "Crosses(g1, g2)")
test:is(ST.Crosses, point.crosses, "g1:crosses(g2)")

-- Within
status, reason = pcall(ST.Within)
test:like(reason, "Usage", "Within()")
test:ok(ST.Within(ST.Point({1, 1}, 0),
                  ST.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0)),
        "WithIn(g1, g2)")
test:ok(not ST.Within(ST.Point({0, 0}, 0),
                  ST.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0)),
        "WithIn(g1, g2)")
test:is(ST.Within, point.within, "g1:within(g2)")

-- Contains
status, reason = pcall(ST.Contains)
test:like(reason, "Usage", "Contains()")
test:ok(ST.Contains(ST.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0),
        ST.Point({1, 1}, 0)), "Contains(g1, g2)")
test:ok(not ST.Contains(ST.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0),
        ST.Point({0, 0}, 0)), "Contains(g1, g2)")
test:is(ST.Contains, point.contains, "g1:contains(g2)")

-- Overlaps
status, reason = pcall(ST.Overlaps)
test:like(reason, "Usage", "Overlaps()")
test:ok(ST.Overlaps(
        ST.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0),
        ST.Polygon({{{1, 1}, {1, 3}, {3, 3}, {3, 1}, {1, 1}}}, 0)),
        "Overlaps(g1, g2)")
test:ok(not ST.Overlaps(
        ST.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0),
        ST.Polygon({{{2, 2}, {2, 3}, {3, 3}, {3, 2}, {2, 2}}}, 0)),
        "Overlaps(g1, g2)")
test:is(ST.Overlaps, point.overlaps, "g1:overlaps(g2)")

-- Covers
status, reason = pcall(ST.Covers)
test:like(reason, "Usage", "Covers()")
test:ok(ST.Covers(
        ST.Polygon({{{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}}}, 0),
        ST.Polygon({{{1, 1}, {1, 3}, {3, 3}, {3, 1}, {1, 1}}}, 0)),
        "Covers(g1, g2)")
test:ok(not ST.Covers(
        ST.Polygon({{{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}}}, 0),
        ST.Polygon({{{1, 1}, {1, 3}, {3, 3}, {5, 1}, {1, 1}}}, 0)),
        "Covers(g1, g2)")
test:is(ST.Covers, point.covers, "g1:covers(g2)")

-- CoveredBy
status, reason = pcall(ST.CoveredBy)
test:like(reason, "Usage", "CoveredBy()")
test:ok(ST.CoveredBy(
        ST.Polygon({{{1, 1}, {1, 3}, {3, 3}, {3, 1}, {1, 1}}}, 0),
        ST.Polygon({{{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}}}, 0)),
        "CoveredBy(g1, g2)")
test:ok(not ST.CoveredBy(
        ST.Polygon({{{1, 1}, {1, 3}, {3, 3}, {5, 1}, {1, 1}}}, 0),
        ST.Polygon({{{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}}}, 0)),
        "CoveredBy(g1, g2)")
test:is(ST.CoveredBy, point.coveredby, "g1:coveredby(g2)")

os.exit(test:check() == true and 0 or -1)
