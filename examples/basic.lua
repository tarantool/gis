#!/usr/bin/env tarantool

box.cfg({logger = 'tarantool.log'})

local gis = require('gis')
gis.install()
-- https://source.opennews.org/en-US/learning/choosing-right-map-projection/
local wgs84 = 4326 -- WGS84 World-wide Projection (Lon/Lat)
local nationalmap = 2163 -- US National Atlas Equal Area projection (meters)
local calif5 = 2770 -- California zone 5 projection (meters)
local nevada = gis.Polygon({{
     {-120.000000, 42.000000};
     {-114.000000, 42.000000};
     {-114.000000, 34.687427};
     {-120.000000, 39.000000};
     {-120.000000, 42.000000};
}}, wgs84)

print(nevada:wkt())
-- "POLYGON ((-120 42, -114 42, -114 34.687427, -120 39, -120 42))"

local lasvegas = gis.Point({-115.136389, 36.175}, wgs84)
local losangeles = gis.Point({-118.25, 34.05}, wgs84)

print(nevada:contains(lasvegas))
-- true
print(nevada:contains(losangeles))
-- false
local line = gis.LineString({lasvegas, losangeles}, wgs84)
print(line:transform(calif5):length())
-- 368.94277529796 - km
print(nevada:transform(nationalmap):area() * 1e-6)
-- 293496.74070953 -- km^2
os.exit(0)
