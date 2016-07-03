Introduction
============

.. module:: gis

**Tarantool GIS** is a full-featured geospatial extension for
`Tarantool Database`_. It's like PostGIS, but for Tarantool.

* :func:`Point`, :func:`LineString`, :func:`Polygon`, :func:`MultiPoint`,
  :func:`GeometryCollection` and other geometric primitives.
* :func:`Overlaps() <Geometry.overlaps>`, :func:`Contains() <Geometry.contains>`,
  :func:`Touches() <Geometry.touches>`, :func:`Distance() <Geometry.distance>`,
  :func:`Length() <Geometry.length>`, :func:`Area() <Geometry.area>` and other
  geometric functions.
* Database of more than 5000 spatial reference systems (SRS) and conversion
  routines.
* Aims to implement ISO 19125-1:2004 and ISO/IEC 13249-3 standards.
* Full interoperability with `WKT`_, `WKB`_ and `GeoJSON`_ formats.
* Fast **in-memory** spatial indexes using Tarantool's RTREE.

.. _Tarantool Database: http://tarantool.org/
.. _Simple Features: https://en.wikipedia.org/wiki/Simple_Features
.. _Spatial Reference Systems: https://www.epsg-registry.org/
.. _WKT: https://en.wikipedia.org/wiki/Well-known_text
.. _WKB: https://en.wikipedia.org/wiki/Well-known_text#Well-known_binary
.. _GeoJSON: http://geojson.org/

Here is an example how to work with geometric primitives in Tarantool:

.. code-block:: lua
   :emphasize-lines: 7, 17, 21, 23, 26, 28

    gis = require('gis')
    gis.install()
    -- https://source.opennews.org/en-US/learning/choosing-right-map-projection/
    wgs84 = 4326 -- WGS84 World-wide Projection (Lon/Lat)
    nationalmap = 2163 -- US National Atlas Equal Area projection (meters)
    calif5 = 2770 -- California zone 5 projection (meters)
    nevada = gis.Polygon({{
        {-120.000000, 42.000000};
        {-114.000000, 42.000000};
        {-114.000000, 34.687427};
        {-120.000000, 39.000000};
        {-120.000000, 42.000000};
    }}, wgs84)

    nevada:wkt()
    => "POLYGON ((-120 42, -114 42, -114 34.687427, -120 39, -120 42))"

    lasvegas = gis.Point({-115.136389, 36.175}, wgs84)
    losangeles = gis.Point({-118.25, 34.05}, wgs84)

    nevada:contains(lasvegas)
    => true
    nevada:contains(losangeles)
    => false
    line = gis.LineString({lasvegas, losangeles}, wgs84)
    line:transform(calif5):length()
    => 368.94277529796 - km
    nevada:transform(nationalmap):area() * 1e-6
    => 293496.74070953 -- km^2

Tarantool/GIS allows to store any kinds of geometric objects in Lua table and
Tarantool spaces, perform kNN, OVERLAPS and other queries using the
high-speed in-memory indexes.

Let's see a k-nearest neighbors example:

.. code-block:: lua
   :emphasize-lines: 7, 18-19, 22-23, 30, 36-37, 46, 55

    #!/usr/bin/env tarantool

    box.cfg({logger = 'tarantool.log'})
    local httpc = require('http.client')
    local json = require('json')
    local yaml = require('yaml')
    local gis = require('gis')
    gis.install() -- creates system tables in Tarantool, e.g. spatial_ref_sys

    local function tocube(coords)
        return gis.Point(coords, 4326):transform(4328) -- lonlat to geocentric (3D)
    end

    box.once("data", function()
        print('Creating spaces...')
        local postoffices = box.schema.space.create("postoffices")
        postoffices:create_index('primary', { type = 'HASH', parts = {1, 'num'}})
        postoffices:create_index('spatial', { type = 'RTREE', parts = {2, 'array'},
            unique = false, dimension = 3})

        print('Downloading source data...')
        local URL = 'http://api.data.mos.ru/v1/datasets/1095/rows'
        local sourcedata = json.decode(httpc.get(URL).body)
        print('Populating database...')
        for _, info in pairs(sourcedata) do
            local postalcode = tonumber(info.Cells.PostalCode)
            local lon = tonumber((info.Cells.X_WGS84:gsub(',', '.')))
            local lat = tonumber((info.Cells.Y_WGS84:gsub(',', '.')))
            local address = info.Cells.Address
            postoffices:replace({postalcode, tocube({lon, lat}):totable(), {lon, lat}, address})
        end
    end)

    local function nearby(coords, count)
        local point = tocube(coords)
        for _, office in box.space.postoffices.index.spatial:pairs(point:totable(),
            { iterator = 'neighbor' }):take(count) do
            print(json.encode({
                PostalCode = office[1];
                Address = office[4];
                Distance = math.ceil(point:distance(tocube(office[3])))
            }))
        end
    end

    nearby({37.479407, 55.862488}, 5)
    --[[
    {"Address":"Фестивальная улица, дом 39","Distance":463,"PostalCode":125195}
    {"Address":"Валдайский проезд, дом 8, строение 2","Distance":764,"PostalCode":125445}
    {"Address":"Петрозаводская улица, дом 9, корпус 2","Distance":985,"PostalCode":125502}
    {"Address":"улица Ляпидевского, дом 14","Distance":1154,"PostalCode":125581}
    {"Address":"Ленинградское шоссе, дом 84, корпус 2","Distance":1289,"PostalCode":125565}
    --]]

    nearby({37.537407, 55.796782}, 5)
    --[[
    {"Address":"Ленинский проспект, дом 41","Distance":150,"PostalCode":119334}
    {"Address":"Ленинградский проспект, дом 56","Distance":168,"PostalCode":125167}
    {"Address":"улица Черняховского, дом 6","Distance":696,"PostalCode":125319}
    {"Address":"улица Усиевича, дом 16","Distance":1232,"PostalCode":125190}
    {"Address":"Ленинградский проспект, дом 69","Distance":1357,"PostalCode":125057}
    --]]

The code above downloads JSON data from the public OpenData service, parses
it and stores into ``postoffices`` table. ``nearby({lon, lat}, count)``
function uses spatial index to find k-nearest neighbors. Three-dimensional
RTREE is used here together with EPSG:4328 WGS84 geocentric projection.

Manage geographics primitives as a professional with the speed of
Tarantool!
