Tarantool/GIS
=============

**Tarantool/GIS** is a full-featured geospatial extension for
[Tarantool Database]. It's like PostGIS, but for Tarantool.

* `Point`, `LineString`, `Polygon`, `MultiPoint`, `GeometryCollection` and
  other geometric primitives.
* `Overlaps`, `Contains`, `Touches`, `Distance`, `Length`, `Area` and other
  geometric functions.
* Database of more than 5000 spatial reference systems (SRS) and conversion
  routines.
* Aims to implement ISO 19125-1:2004 and ISO/IEC 13249-3 standards.
* Full interoperability with ``WKT, WKB and GeoJSON formats.
* Fast **in-memory** spatial indexes using Tarantool's RTREE.

[Tarantool Database]: http://tarantool.org/

**Tarantool/GIS** is in an alpha stage. All feautures are documented and
fully covered by unit and functional tests.

[![Build Status](https://travis-ci.org/tarantool/gis.png)]
(https://travis-ci.org/tarantool/gis)

Example
-------

Here is an example how to work with geometric primitives in Tarantool:

    gis = require('gis')
    gis.install() -- create system tables
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

**Tarantool/GIS** allows to store any kinds of geometric objects in Lua table
and Tarantool spaces, perform kNN, OVERLAPS and other queries using the
high-speed in-memory indexes.

Please follow [Getting Started] guide for further instructions.
[Getting Started]: https://tarantool.github.io/gis/getting_started.html

See Also
--------

* [Documentation](http://tarantool.github.io/gis)
* [Examples](https://github.com/tarantool/gis/tree/master/examples)
* [Tests](https://github.com/tarantool/gis/tree/master/tests)
* [Packages](https://tarantool.org/download.html)
* [Maillist](https://groups.google.com/forum/#!forum/tarantool)
* [Facebook](http://facebook.com/TarantoolDatabase/)
* roman@tsisyk.com

----

**Tarantool/GIS** - manage geographics primitives as a professional with the
speed of Tarantool!
