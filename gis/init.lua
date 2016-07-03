--------------------------------------------------------------------------------
--- Tarantool/GIS - a full-featured geospatial extension for Tarantool
--- (c) 2016 Roman Tsisyk <roman@tsisyk.com>
--------------------------------------------------------------------------------
--
--- This library is free software; you can redistribute it and/or
--- modify it under the terms of the GNU Lesser General Public
--- License as published by the Free Software Foundation; either
--- version 2.1 of the License, or (at your option) any later version.
---
--- This library is distributed in the hope that it will be useful,
--- but WITHOUT ANY WARRANTY; without even the implied warranty of
--- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--- Lesser General Public License for more details.
---
--- The full text of the GNU Lesser General Public License version 2.1
--- can be found under the `COPYING.LGPL-2.1` file of this distribution.
---
--------------------------------------------------------------------------------

local projection = require('gis.projection')
local ST = require('gis.ST')
local wkt = require('gis.wkt')
local wkb = require('gis.wkb')

local function install()
    box.cfg({})
    box.once("gis:0.1.0", function()
        box.schema.space.create("spatial_ref_sys")
        box.space.spatial_ref_sys:create_index("primary", { type = 'HASH' })
    end)
    require('gis.data.spatial_ref_sys').install()
end

return {
    GEOS_VERSION = ST.GEOS_VERSION;
    PROJ_VERSION = projection.PROJ_VERSION;

    install = install;
    ST = ST;
    wkt = wkt;
    wkb = wkb;

    Point = ST.Point;
    LineString = ST.LineString;
    LinearRing = ST.LinearRing;
    Polygon = ST.Polygon;
    MultiPoint = ST.MultiPoint;
    MultiLineString = ST.MultiLineString;
    MultiPolygon = ST.MultiPolygon;
    GeometryCollection = ST.GeometryCollection;
}
