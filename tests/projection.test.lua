#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})
local gis = require('gis')
gis.install()
local projection = require('gis.projection')
local test = require('tap').test('gis.projection')
test:plan(23)

local status, reason
local latlong = projection[4326]
local geocent = projection[4328]
local utm44n = projection[32644]

test:ok(latlong, "EPSG:4326 (WGS84 latlong)")
test:ok(geocent, "EPSG:4328 (WGS84 geocent)")
test:ok(utm44n, "EPSG:32644 (WGS84 utm44n)")

status, reason = pcall(latlong.islatlong)
test:like(reason, "Usage", "islatlong()")
test:ok(latlong:islatlong(), "islatlong(latlong)")
test:ok(not geocent:islatlong(), "islatlong(geocent)")
test:ok(not utm44n:islatlong(), "islatlong(utm)")

status, reason = pcall(latlong.isgeocent)
test:like(reason, "Usage", "isgeocent()")
test:ok(not latlong:isgeocent(), "isgeocent(latlong)")
test:ok(geocent:isgeocent(), "isgeocent(geocent)")
test:ok(not utm44n:isgeocent(), "isgeocent(utm)")

status, reason = pcall(latlong.def)
test:like(reason, "Usage", "def()")
test:like(latlong:def(), "+proj=longlat", "def(latlong)")

test:like(tostring(latlong), "+proj=longlat", "tostring(latlong)")
test:like(tostring(geocent), "+proj=geocent", "tostring(geocent)")
test:like(tostring(utm44n), "+proj=utm", "tostring(utm)")

status, reason = pcall(latlong.transform, latlong, utm44n)
test:like(reason, "Usage", "transform()")

local function dist(x, y, z)
    z = z or 0.0
    return math.sqrt(x * x + y * y + z * z)
end

local lon, lat = 83.6863374710083, 53.2515552815204

--
-- longlat <-> utm
--

local a, b = latlong:transform(utm44n, lon, lat)
test:ok(dist(a - 679212.9, b - 5903622) < 1.0,
    "transform(longlat, utm)")

local lon1, lat1 = utm44n:transform(latlong, a, b)
test:ok(dist(lon - lon1, lat - lat1) < 1e-6, "transform(utm, longlat)")

--
-- longlat <-> geocent
--

local x, y, z = latlong:transform(geocent, lon, lat)
test:ok(dist(x - 420562, y - 3801090, z - 5087342) < 1.0,
    "transform(longlat, geocent)")

local lon2, lat2 = geocent:transform(latlong, x, y, z)
test:ok(dist(lon - lon2, lat - lat2) < 1e-6, "transform(geocent, longlat)")

--
-- utm <-> geocent
--

local x1, y1, z1 = utm44n:transform(geocent, a, b)
test:ok(dist(x - x1, y - y1, z - z1) < 1e-3, "transform(utm, geocent)")

local a1, b1 = geocent:transform(utm44n, x, y, z)
test:ok(dist(a - a1, b - b1) < 1e-3, "transform(geocent, utm)")

os.exit(test:check() == true and 0 or -1)
