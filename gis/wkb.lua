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

local ST = require('gis.ST')

local wkb = {}
wkb.decode = ST.GeomFromWKB
wkb.encode = ST.AsWKB
wkb.decode_hex = ST.GeomFromHEXWKB
wkb.encode_hex = ST.AsHEXWKB
return wkb
