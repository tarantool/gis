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

local log = require('log')
local ffi = require('ffi')
local table_new = require('table.new')

local projection = require('gis.projection')
local exports = {}

--------------------------------------------------------------------------------
-- GEOS clue
--------------------------------------------------------------------------------

local geos_path = package.searchpath('gis.lib', package.cpath)
if geos_path == nil then
    error("Failed to find internal library")
end
local geos = ffi.load(geos_path)
require('gis.geos_cdef')

local POINT = ffi.C.GEOS_POINT
local LINESTRING = ffi.C.GEOS_LINESTRING
local LINEARRING = ffi.C.GEOS_LINEARRING
local POLYGON = ffi.C.GEOS_POLYGON
local MULTIPOINT = ffi.C.GEOS_MULTIPOINT
local MULTILINESTRING = ffi.C.GEOS_MULTILINESTRING
local MULTIPOLYGON = ffi.C.GEOS_MULTIPOLYGON
local GEOMETRYCOLLECTION = ffi.C.GEOS_GEOMETRYCOLLECTION

local GEOS_VERSION = ffi.string(geos.GEOSversion())
exports.GEOS_VERSION = GEOS_VERSION

local handle = geos.libgeos_init_r()
ffi.gc(handle, geos.libgeos_finish_r)

local function geos_raise()
    local message = geos.libgeos_last_error()
    error(ffi.string(message))
end

local function checknil(obj)
    if obj == nil then
        geos_raise()
    end
    return obj
end

local function checkzero(rc)
    if rc == 0 then
        geos_raise()
    end
    return rc
end

local function checkbool(rc)
    if rc == 2 then
        geos_raise()
    end
    return rc ~= 0
end

local function checkneg(rc)
    if rc < 0 then
        geos_raise()
    end
    return rc
end

local function geos_gc(string)
    geos.GEOSFree_r(handle, string)
end

local function coordseq_gc(coordseq)
    geos.GEOSCoordSeq_destroy_r(handle, coordseq)
end

local geom_t = ffi.typeof('struct GEOSGeom_t')
local geom_methods = {}

local function geom_gc(geom)
    geos.GEOSGeom_destroy_r(handle, geom)
end

local function geom_bless(geom)
    return ffi.gc(checknil(geom), geom_gc)
end

local function geom_is(g)
    return ffi.istype(geom_t, g)
end

local function geom_arg(g)
    if geom_is(g) then
        return
    end
    error(string.format("Usage: %s(g: geometry)",
        debug.getinfo(2).name))
end

local function geom_args(g, args, usage)
    if geom_is(g) and args ~= false then
        return
    end
    error(string.format("Usage: %s(g: geometry, %s)",
        debug.getinfo(2).name, usage))
end

local function geom_relarg(g1, g2)
    if geom_is(g1) and geom_is(g2) then
        return
    end
    error(string.format("Usage: ST.%s(g1: geometry, g2: geometry)",
        debug.getinfo(2).name))
end

local wkt_reader = checknil(geos.GEOSWKTReader_create_r(handle))
ffi.gc(wkt_reader, function(r) geos.GEOSWKTReader_destroy_r(handle, r) end)

local wkt_writer = checknil(geos.GEOSWKTWriter_create_r(handle))
ffi.gc(wkt_writer, function(w) geos.GEOSWKTWriter_destroy_r(handle, w) end)
geos.GEOSWKTWriter_setTrim_r(handle, wkt_writer, 1)

local wkb_reader = checknil(geos.GEOSWKBReader_create_r(handle))
ffi.gc(wkt_reader, function(w) geos.GEOSWKBReader_destroy_r(handle, w) end)

local wkb_writer = checknil(geos.GEOSWKBWriter_create_r(handle))
ffi.gc(wkt_writer, function(w) geos.GEOSWKBWriter_destroy_r(handle, w) end)

local sizeptr = ffi.new('size_t[1]')
local doubleptr = ffi.new('double[1]')
local uintptr = ffi.new('unsigned int[1]')

--------------------------------------------------------------------------------
-- WKT and WKB
--------------------------------------------------------------------------------

local function ST_GeomFromWKT(wkt, srid)
    if type(wkt) ~= 'string' or srid == nil then
        error("Usage: GeomFromWKT(wkt: string, srid: int)")
    end
    local g = geom_bless(geos.GEOSWKTReader_read_r(handle, wkt_reader, wkt))
    geos.GEOSSetSRID_r(handle, g, srid)
    return g
end
exports.GeomFromWKT = ST_GeomFromWKT

local function ST_AsWKT(g)
    geom_arg(g)
    local dim = geos.GEOSGeom_getCoordinateDimension_r(handle, g)
    geos.GEOSWKTWriter_setOutputDimension_r(handle, wkt_writer, dim);
    local wkt = checknil(geos.GEOSWKTWriter_write_r(handle, wkt_writer, g))
    ffi.gc(wkt, geos_gc)
    return ffi.string(wkt)
end
exports.AsText = ST_AsWKT
exports.AsWKT = ST_AsWKT
geom_methods.wkt = ST_AsWKT

local function ST_GeomFromWKB(wkb, srid)
    if type(wkb) ~= 'string' or srid == nil then
        error("Usage: GeomFromWKB(wkb: string, srid: int)")
    end
    local g = geom_bless(geos.GEOSWKBReader_read_r(handle, wkb_reader, wkb, #wkb))
    geos.GEOSSetSRID_r(handle, g, srid)
    return g
end
exports.GeomFromWKB = ST_GeomFromWKB

local function ST_AsWKB(g)
    geom_arg(g)
    local bin = ffi.gc(checknil(geos.GEOSWKBWriter_write_r(handle, wkb_writer,
        g, sizeptr)), geos_gc)
    return ffi.string(bin, sizeptr[0])
end
exports.AsWKB = ST_AsWKB
exports.AsBinary = ST_AsWKB
geom_methods.wkb = ST_AsWKB
geom_methods.bin = ST_AsWKB

local function ST_GeomFromHEXWKB(hexwkb, srid)
    if type(hexwkb) ~= 'string' or srid == nil then
        error("Usage: GeomFromHEXWKB(hexwkb: string, srid: int)")
    end
    local g = geom_bless(geos.GEOSWKBReader_readHEX_r(handle, wkb_reader,
        hexwkb, #hexwkb))
    geos.GEOSSetSRID_r(handle, g, srid)
    return g
end
exports.GeomFromHEXWKB = ST_GeomFromHEXWKB

local function ST_AsHEXWKB(g)
    geom_arg(g)
    local hex = ffi.gc(checknil(geos.GEOSWKBWriter_writeHEX_r(handle,
        wkb_writer, g, sizeptr)), geos_gc)
    return ffi.string(hex, sizeptr[0])
end
exports.AsHEXWKB = ST_AsHEXWKB
geom_methods.hexwkb = ST_AsHEXWKB
geom_methods.hex = ST_AsHEXWKB

--------------------------------------------------------------------------------
-- Geometry Constructors
--------------------------------------------------------------------------------

local function ST_Point(coords, srid)
    if type(coords) ~= 'table' or srid == nil then
        error("Usage: ST_Point({x: number, y: number, [z: number]}, srid: int)")
    end
    local x, y, z = coords[1], coords[2], coords[3]
    local dim = 2
    if z ~= nil then
        dim = 3
    end
    local seq = checknil(geos.GEOSCoordSeq_create_r(handle, 1, dim))
    ffi.gc(seq, coordseq_gc)
    checkzero(geos.GEOSCoordSeq_setX_r(handle, seq, 0, x))
    checkzero(geos.GEOSCoordSeq_setY_r(handle, seq, 0, y))
    if z ~= nil then
        checkzero(geos.GEOSCoordSeq_setZ_r(handle, seq, 0, z))
    end
    local point = geom_bless(geos.GEOSGeom_createPoint_r(handle, seq))
    ffi.gc(seq, nil) -- seq is owned by point
    geos.GEOSSetSRID_r(handle, point, srid)
    return point
end
exports.Point = ST_Point

local function ST_CoordSeq(points)
    local seq
    if ffi.istype(geom_t, points) and
        (geos.GEOSGeomTypeId_r(handle, points) == LINESTRING or
         geos.GEOSGeomTypeId_r(handle, points) == LINEARRING) then
        local origseq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, points))
        return checknil(geos.GEOSCoordSeq_clone_r(handle, origseq))
    elseif type(points) ~= 'table' then
        return nil
    end

    -- calculate size and dimension
    local dim = 2
    local size = 0

    for _, point in ipairs(points) do
        size = size + 1
        if type(point) == 'table' then
            local pointdim = #point
            if pointdim ~= 3 and pointdim ~= 2 then
                error('Invalid point #'..size)
            end
            dim = math.max(dim, pointdim)
        elseif ffi.istype(geom_t, point) and
               geos.GEOSGeomTypeId_r(handle, point) == POINT then
            local pointseq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, point))
            checkzero(geos.GEOSCoordSeq_getDimensions_r(handle, pointseq, uintptr))
            dim = math.max(dim, tonumber(uintptr[0]))
        else
            error('Invalid point #'..size)
        end
    end
    local seq = checknil(geos.GEOSCoordSeq_create_r(handle, size, dim))
    ffi.gc(seq, coordseq_gc)
    for i, point in ipairs(points) do
        if type(point) == 'table' then
            local x, y, z = point[1], point[2], point[3]
            checkzero(geos.GEOSCoordSeq_setX_r(handle, seq, i - 1, x))
            checkzero(geos.GEOSCoordSeq_setY_r(handle, seq, i - 1, y))
            if z ~= nil then
                checkzero(geos.GEOSCoordSeq_setZ_r(handle, seq, i - 1, z))
            end
        else
            assert(ffi.istype(geom_t, point))
            assert(geos.GEOSGeomTypeId_r(handle, point) == POINT)
            local pointseq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, point))
            checkzero(geos.GEOSCoordSeq_getDimensions_r(handle, pointseq, uintptr))
            local pointdim = tonumber(uintptr[0])
            checkzero(geos.GEOSCoordSeq_getX_r(handle, pointseq, 0, doubleptr))
            checkzero(geos.GEOSCoordSeq_setX_r(handle, seq, i - 1, doubleptr[0]))
            checkzero(geos.GEOSCoordSeq_getY_r(handle, pointseq, 0, doubleptr))
            checkzero(geos.GEOSCoordSeq_setY_r(handle, seq, i - 1, doubleptr[0]))
            if pointdim > 2 then
                checkzero(geos.GEOSCoordSeq_getZ_r(handle, pointseq, 0, doubleptr))
                checkzero(geos.GEOSCoordSeq_setZ_r(handle, seq, i - 1, doubleptr[0]))
            end
        end
    end
    return seq
end

local function ST_LineString(points, srid)
    local seq = ST_CoordSeq(points)
    if seq == nil or srid == nil then
        error("Usage: ST_LineString({{x, y, z}, ..., Point(...), ...}, srid: int)")
    end
    local linestring = geom_bless(geos.GEOSGeom_createLineString_r(handle, seq))
    ffi.gc(seq, nil) -- seq is owned by linestring
    geos.GEOSSetSRID_r(handle, linestring, srid)
    return linestring
end
exports.LineString = ST_LineString

local function ST_LinearRing(points, srid)
    local seq = ST_CoordSeq(points)
    if seq == nil or srid == nil then
        error("Usage: ST_LinearRing({{x, y, z}, ..., Point(...), ...}, srid: int)")
    end
    local linearring = geom_bless(geos.GEOSGeom_createLinearRing_r(handle, seq))
    ffi.gc(seq, nil) -- seq is owned by linestring
    geos.GEOSSetSRID_r(handle, linearring, srid)
    return linearring
end
exports.LinearRing = ST_LinearRing

local function ST_Polygon(geoms, srid)
    if type(geoms) ~= 'table' or #geoms == 0 or srid == nil then
        error("Usage: ST_Polygon({shell: Geometry, [hole: Geometry, ...]},"..
            "srid: int)")
    end
    local shell = ST_LinearRing(geoms[1], srid)
    local holes = nil
    local numholes = #geoms - 1
    if numholes > 0 then
        holes = ffi.new('struct GEOSGeom_t *[?]', numholes)
        for i=1,numholes,1 do
            holes[i-1] = ST_LinearRing(geoms[i + 1], srid)
        end
    end
    local polygon = geom_bless(geos.GEOSGeom_createPolygon_r(handle, shell,
        holes, numholes))
    ffi.gc(shell, nil) -- shell is owned by polygon
    for i=1,numholes,1 do
        ffi.gc(holes[i-1], nil) -- holes are owned by polygon
    end
    geos.GEOSSetSRID_r(handle, polygon, srid)
    return polygon
end
exports.Polygon = ST_Polygon

local function ST_MultiPoint(points, srid)
    -- TODO: remove needs in the intermediate LineString
    local line = ST_LineString(points, srid)
    local ngeoms = tonumber(checkneg(geos.GEOSGeomGetNumPoints_r(handle, line)))
    local geoms = ffi.new('struct GEOSGeom_t *[?]', ngeoms)
    for i=1,ngeoms do
        local point = geom_bless(geos.GEOSGeomGetPointN_r(handle, line, i - 1))
        geos.GEOSSetSRID_r(handle, point, geos.GEOSGetSRID_r(handle, line))
        geoms[i - 1] = point
    end
    line = nil
    local collection = geom_bless(geos.GEOSGeom_createCollection_r(handle,
        MULTIPOINT, geoms, ngeoms))
    geos.GEOSSetSRID_r(handle, collection, srid)
    for i=1,ngeoms do
        ffi.gc(geoms[i - 1], nil) -- points are owned by MultiPoint
    end
    return collection
end
exports.MultiPoint = ST_MultiPoint

local function ST_MultiLineString(linestrings, srid)
    if type(linestrings) ~= 'table' or #linestrings == 0 or srid == nil then
        error("Usage: MultiLineString({linestring: LineString, ...},"..
            "srid: int)")
    end
    local ngeoms = #linestrings
    local geoms = ffi.new('struct GEOSGeom_t *[?]', ngeoms)
    for i=1,ngeoms do
        geoms[i - 1] = ST_LineString(linestrings[i], srid)
    end
    local collection = geom_bless(geos.GEOSGeom_createCollection_r(handle,
        MULTILINESTRING, geoms, ngeoms))
    geos.GEOSSetSRID_r(handle, collection, srid)
    for i=1,ngeoms do
        ffi.gc(geoms[i - 1], nil) -- linestrings are owned by MultiLineString
    end
    return collection
end
exports.MultiLineString = ST_MultiLineString

local function ST_MultiPolygon(polygons, srid)
    if type(polygons) ~= 'table' or #polygons == 0 or srid == nil then
        error("Usage: MultiPolygon({polygon: Polygon, ...},"..
            "srid: int)")
    end
    local ngeoms = #polygons
    local geoms = ffi.new('struct GEOSGeom_t *[?]', ngeoms)
    for i=1,ngeoms do
        geoms[i - 1] = ST_Polygon(polygons[i], srid)
    end
    local collection = geom_bless(geos.GEOSGeom_createCollection_r(handle,
        MULTIPOLYGON, geoms, ngeoms))
    geos.GEOSSetSRID_r(handle, collection, srid)
    for i=1,ngeoms do
        ffi.gc(geoms[i - 1], nil) -- linestrings are owned by the collection
    end
    return collection
end
exports.MultiPolygon = ST_MultiPolygon

local function ST_GeometryCollection(geometries, srid)
    if type(geometries) ~= 'table' or #geometries == 0 or 
       not geom_is(geometries[1]) or srid == nil then
        error("Usage: GeometryCollection({geometry: Geometry, ...},"..
            "srid: int)")
    end
    local ngeoms = #geometries
    local geoms = ffi.new('struct GEOSGeom_t *[?]', ngeoms)
    for i=1,ngeoms do
        geoms[i - 1] = geometries[i]
    end
    local collection = geom_bless(geos.GEOSGeom_createCollection_r(handle,
        GEOMETRYCOLLECTION, geoms, ngeoms))
    geos.GEOSSetSRID_r(handle, collection, srid)
    for i=1,ngeoms do
        ffi.gc(geoms[i - 1], nil) -- linestrings are owned by the collection
    end
    return collection
end
exports.GeometryCollection = ST_GeometryCollection

--------------------------------------------------------------------------------
-- Geometry Accessors
--------------------------------------------------------------------------------

local function ST_Boundary(g)
    geom_arg(g)
    return geom_bless(geos.GEOSBoundary_r(handle, g))
end
exports.Boundary = ST_Boundary
geom_methods.boundary = ST_Boundary;

local function ST_Envelope(g)
    geom_arg(g)
    return geom_bless(geos.GEOSEnvelope_r(handle, g))
end
exports.Envelope = ST_Envelope
geom_methods.envelope = ST_Envelope;

local function ST_GeometryType(g)
    geom_arg(g)
    local str = geos.GEOSGeomType_r(handle, g)
    ffi.gc(str, geos_gc)
    return ffi.string(str)
end
exports.GeometryType = ST_GeometryType
geom_methods.type = ST_GeometryType;

local function ST_GeometryTypeId(g)
    geom_arg(g)
    return tonumber(checkneg(geos.GEOSGeomTypeId_r(handle, g)))
end
exports.GeometryTypeId = ST_GeometryTypeId
geom_methods.typeid = ST_GeometryTypeId;

local function ST_IsCollection(g)
    geom_arg(g)
    local typeid = ST_GeometryTypeId(g)
    if typeid >= ffi.C.GEOS_MULTIPOINT then
        return true
    end
    return false
end
exports.IsCollection = ST_IsCollection
geom_methods.iscollection = ST_IsCollection

local function ST_NumGeometries(g)
    geom_arg(g)
    return tonumber(checkneg(geos.GEOSGetNumGeometries_r(handle, g)))
end
exports.NumGeometries = ST_NumGeometries
geom_methods.numgeometries = ST_NumGeometries

local function ST_GeometryN(g, idx)
    idx = tonumber(idx)
    geom_args(g, idx ~= nil, "idx: integer")
    if idx <= 0 or idx > geos.GEOSGetNumGeometries_r(handle, g) then
        return nil
    end
    local geom = checknil(geos.GEOSGetGeometryN_r(handle, g, idx - 1))
    return geom_bless(geos.GEOSGeom_clone_r(handle, geom))
end
exports.GeometryN = ST_GeometryN
exports.geometryn = ST_GeometryN
exports.geometry  = ST_GeometryN

local function ST_Geometries(g)
    local ngeoms = ST_NumGeometries(g)
    local result = table_new(ngeoms, 0)
    for idx=1,ngeoms do
        local geom = checknil(geos.GEOSGetGeometryN_r(handle, g, idx - 1))
        result[idx] = geom_bless(geos.GEOSGeom_clone_r(handle, geom))
    end
    return result
end
exports.ST_Dump = ST_Geometries
geom_methods.geometries = ST_Geometries

local function ST_IterGeometriesGen(g, idx)
    local result = ST_GeometryN(g, idx + 1)
    if result == nil then
        return nil
    end
    return idx + 1, result
end

local function ST_IterGeometries(g)
    return ST_IterGeometriesGen, g, 0 -- iterator
end
geom_methods.itergeometries = ST_IterGeometries

local function ST_NumPoints(g)
    geom_arg(g)
    return tonumber(checkneg(geos.GEOSGeomGetNumPoints_r(handle, g)))
end
exports.NumPoints = ST_NumPoints
geom_methods.numpoints = ST_NumPoints

local function ST_PointN(g, idx)
    idx = tonumber(idx)
    geom_args(g, idx ~= nil, "idx: integer")
    if idx <= 0 or idx > geos.GEOSGeomGetNumPoints_r(handle, g) then
        return nil
    end
    local point = geom_bless(geos.GEOSGeomGetPointN_r(handle, g, idx - 1))
    geos.GEOSSetSRID_r(handle, point, geos.GEOSGetSRID_r(handle, g))
    return point
end
exports.PointN = ST_PointN
geom_methods.pointn = ST_PointN
geom_methods.point  = ST_PointN

local function ST_Points(g)
    local npoints = ST_NumPoints(g)
    local result = table_new(npoints, 0)
    for idx=1,npoints do
        local point = checknil(geos.GEOSGeomGetPointN_r(handle, g, idx - 1))
        result[idx] = geom_bless(point)
    end
    return result
end
geom_methods.points = ST_Points

-- A part of ST_IterPoints
local function ST_IterPointsGen(g, idx)
    local result = ST_PointN(g, idx + 1)
    if result == nil then
        return nil
    end
    return idx + 1, result
end

local function ST_IterPoints(g)
    geom_arg(g)
    return ST_IterPointsGen, g, 0 -- iterator
end
geom_methods.iterpoints = ST_IterPoints

local function ST_NumInteriorRings(g)
    geom_arg(g)
    return tonumber(checkneg(geos.GEOSGetNumInteriorRings_r(handle, g)))
end
exports.NumInteriorRings = ST_NumInteriorRings
geom_methods.numinteriorrings = ST_NumInteriorRings
geom_methods.numholes = ST_NumInteriorRings

local function ST_InteriorRingN(g, idx)
    idx = tonumber(idx)
    geom_args(g, idx ~= nil, "idx: integer")
    if idx <= 0 or idx > geos.GEOSGetNumInteriorRings_r(handle, g) then
        return nil
    end
    return geom_bless(geos.GEOSGeom_clone_r(handle,
        geos.GEOSGetInteriorRingN_r(handle, g, idx - 1)))
end
exports.InteriorRingN = ST_InteriorRingN
geom_methods.interiorringn = ST_InteriorRingN
geom_methods.interiorring = ST_InteriorRingN
geom_methods.hole = ST_InteriorRingN

local function ST_InteriorRings(g)
    local nholes = ST_NumInteriorRings(g)
    local result = table_new(nholes, 0)
    for idx=1,nholes do
        result[idx] = geom_bless(geos.GEOSGeom_clone_r(handle,
            geos.GEOSGetInteriorRingN_r(handle, g, idx - 1)))
    end
    return result
end
geom_methods.interiorrings = ST_InteriorRings
geom_methods.holes = ST_InteriorRings

-- A part of ST_IterInteriorRings
local function ST_IterInteriorRingsGen(g, idx)
    local result = ST_InteriorRingN(g, idx + 1)
    if result == nil then
        return nil
    end
    return idx + 1, result
end

local function ST_IterInteriorRings(g)
    geom_arg(g)
    return ST_IterInteriorRingsGen, g, 0 -- iterator
end
geom_methods.iterinteriorrings = ST_IterInteriorRings
geom_methods.iterholes = ST_IterInteriorRings

local function ST_ExteriorRing(g)
    geom_arg(g)
    local shell = checknil(geos.GEOSGetExteriorRing_r(handle, g))
    return geom_bless(geos.GEOSGeom_clone_r(handle, shell))
end
exports.ExteriorRing = ST_ExteriorRing
geom_methods.exteriorring = ST_ExteriorRing
geom_methods.shell = ST_ExteriorRing

local function ST_SRID(g)
    geom_arg(g)
    return tonumber(geos.GEOSGetSRID_r(handle, g))
end
exports.SRID = ST_SRID
geom_methods.srid = ST_SRID

local function ST_X(point)
    geom_arg(point)
    checkneg(geos.GEOSGeomGetX_r(handle, point, doubleptr))
    return tonumber(doubleptr[0])
end
exports.X = ST_X
geom_methods.x = ST_X

local function ST_Y(point)
    geom_arg(point)
    checkneg(geos.GEOSGeomGetY_r(handle, point, doubleptr))
    return tonumber(doubleptr[0])
end
exports.Y = ST_Y
geom_methods.y = ST_Y

local function ST_Z(point)
    geom_arg(point)
    local seq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, point))
    checkzero(geos.GEOSCoordSeq_getSize_r(handle, seq, uintptr))
    local size = tonumber(uintptr[0])
    checkzero(geos.GEOSCoordSeq_getDimensions_r(handle, seq, uintptr))
    local dim = tonumber(uintptr[0])
    if size < 1 or dim < 3 then
        return nil -- follow PostGIS implementation
    end
    checkzero(geos.GEOSCoordSeq_getZ_r(handle, seq, 0, doubleptr))
    return tonumber(doubleptr[0])
end
exports.Z = ST_Z
geom_methods.z = ST_Z

--------------------------------------------------------------------------------
-- Geometry Transformations
--------------------------------------------------------------------------------

local function checkproj(srid)
    local proj = projection[srid]
    if proj == nil then
        error(string.format("Missing SRID=%d in spatial_ref_sys", srid))
    end
    return proj
end

local function ST_TransformSeq(seq, proj, toproj)
    checkzero(geos.GEOSCoordSeq_getSize_r(handle, seq, uintptr))
    local size = tonumber(uintptr[0])
    checkzero(geos.GEOSCoordSeq_getDimensions_r(handle, seq, uintptr))
    local dim = tonumber(uintptr[0])
    local todim = 2
    if toproj:isgeocent() then
        todim = 3
    end
    local toseq = checknil(geos.GEOSCoordSeq_create_r(handle, size, todim))
    ffi.gc(toseq, coordseq_gc)
    for idx=0,size-1 do
        local x, y, z
        checkzero(geos.GEOSCoordSeq_getX_r(handle, seq, idx, doubleptr))
        x = tonumber(doubleptr[0])
        checkzero(geos.GEOSCoordSeq_getY_r(handle, seq, idx, doubleptr))
        y = tonumber(doubleptr[0])
        if dim > 2 then
            checkzero(geos.GEOSCoordSeq_getZ_r(handle, seq, idx, doubleptr))
            z = tonumber(doubleptr[0])
        end

        x, y, z = proj:transform(toproj, x, y, z)

        checkzero(geos.GEOSCoordSeq_setX_r(handle, toseq, idx, x))
        checkzero(geos.GEOSCoordSeq_setY_r(handle, toseq, idx, y))
        if todim > 2 then
            checkzero(geos.GEOSCoordSeq_setZ_r(handle, toseq, idx, z))
        end
    end
    return toseq
end

local ST_TransformHandlers = {}

local function ST_TransformPoint(g, proj, toproj)
    local seq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, g))
    local toseq = ST_TransformSeq(seq, proj, toproj)
    local point = geom_bless(geos.GEOSGeom_createPoint_r(handle, toseq))
    ffi.gc(toseq, nil) -- toseq is owned by geom
    return point
end
ST_TransformHandlers[POINT] = ST_TransformPoint

local function ST_TransformLineString(g, proj, toproj)
    local seq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, g))
    local toseq = ST_TransformSeq(seq, proj, toproj)
    local linestring = geom_bless(geos.GEOSGeom_createLineString_r(handle, toseq))
    ffi.gc(toseq, nil) -- toseq is owned by linestring
    return linestring
end
ST_TransformHandlers[LINESTRING] = ST_TransformLineString

local function ST_TransformLinearRing(g, proj, toproj)
    local seq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, g))
    local toseq = ST_TransformSeq(seq, proj, toproj)
    local linearring = geom_bless(geos.GEOSGeom_createLinearRing_r(handle, toseq))
    ffi.gc(toseq, nil) -- toseq is owned by linearring
    return linearring
end
ST_TransformHandlers[LINEARRING] = ST_TransformLineString

local function ST_TransformPolygon(g, proj, toproj)
    local shell = ST_TransformLinearRing(geos.GEOSGetExteriorRing_r(handle, g),
        proj, toproj)
    local holes = nil
    local numholes = ST_NumInteriorRings(g)
    if numholes > 0 then
        holes = ffi.new('struct GEOSGeom_t *[?]', numholes)
        for i=1,numholes,1 do
            holes[i-1] = ST_TransformLinearRing(
                geos.GEOSGetInteriorRingN_r(handle, g, i - 1),
                proj, toproj)
        end
    end
    local polygon = geom_bless(geos.GEOSGeom_createPolygon_r(handle, shell,
        holes, numholes))
    ffi.gc(shell, nil) -- shell is owned by polygon
    for i=1,numholes,1 do
        ffi.gc(holes[i-1], nil) -- holes are owned by polygon
    end
    return polygon
end
ST_TransformHandlers[POLYGON] = ST_TransformPolygon

local function ST_Transform(g, tosrid)
    geom_args(g, tosrid ~= 0, "tosrid: srid")
    local srid = ST_SRID(g)
    local proj = checkproj(srid)
    local toproj = checkproj(tosrid)
    local typeid = ST_GeometryTypeId(g)
    local handler = ST_TransformHandlers[typeid]
    if handler == nil then
        error(string.format('Not yet implemented: ST_Transform(%s)',
            ST_GeometryType(g)))
    end
    local g1 = handler(g, proj, toproj)
    geos.GEOSSetSRID_r(handle, g1, tosrid)
    return g1
end
exports.Transform = ST_Transform
geom_methods.transform = ST_Transform

--------------------------------------------------------------------------------
-- Measurements
--------------------------------------------------------------------------------

local function ST_Area(g)
    geom_arg(g)
    checkzero(geos.GEOSArea_r(handle, g, doubleptr))
    return tonumber(doubleptr[0])
end
exports.Area = ST_Area
geom_methods.area = ST_Area

local function ST_Length(g)
    geom_arg(g)
    checkzero(geos.GEOSLength_r(handle, g, doubleptr))
    return tonumber(doubleptr[0])
end
exports.Length = ST_Length
geom_methods.length = ST_Length

local function ST_Distance(g1, g2)
    geom_relarg(g1, g2)
    checkzero(geos.GEOSDistance_r(handle, g1, g2, doubleptr))
    return tonumber(doubleptr[0])
end
exports.Distance = ST_Distance
geom_methods.distance = ST_Distance

--------------------------------------------------------------------------------
-- Measurements
--------------------------------------------------------------------------------

local function ST_Equals(g1, g2, tolerance)
    geom_relarg(g1, g2)
    if tolerance == nil then
        return geos.GEOSEquals_r(handle, g1, g2) ~= 0
    else
        return geos.GEOSEqualsExact_r(handle, g1, g2, tolerance) ~= 0
    end
    checkzero(geos.GEOSDistance_r(handle, g1, g2, doubleptr))
    return tonumber(doubleptr[0])
end
exports.Equals = ST_Equals
geom_methods.equals = ST_Equals

local function ST_Disjoint(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSDisjoint_r(handle, g1, g2))
end
exports.Disjoint = ST_Disjoint
geom_methods.disjoint = ST_Disjoint

local function ST_Touches(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSTouches_r(handle, g1, g2))
end
exports.Touches = ST_Touches
geom_methods.touches = ST_Touches

local function ST_Intersects(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSIntersects_r(handle, g1, g2))
end
exports.Intersects = ST_Intersects
geom_methods.intersects = ST_Intersects

local function ST_Crosses(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSCrosses_r(handle, g1, g2))
end
exports.Crosses = ST_Crosses
geom_methods.crosses = ST_Crosses

local function ST_Within(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSWithin_r(handle, g1, g2))
end
exports.Within = ST_Within
geom_methods.within = ST_Within

local function ST_Contains(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSContains_r(handle, g1, g2))
end
exports.Contains = ST_Contains
geom_methods.contains = ST_Contains

local function ST_Overlaps(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSOverlaps_r(handle, g1, g2))
end
exports.Overlaps = ST_Overlaps
geom_methods.overlaps = ST_Overlaps

local function ST_Covers(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSCovers_r(handle, g1, g2))
end
exports.Covers = ST_Covers
geom_methods.covers = ST_Covers

local function ST_CoveredBy(g1, g2)
    geom_relarg(g1, g2)
    return checkbool(geos.GEOSCoveredBy_r(handle, g1, g2))
end
exports.CoveredBy = ST_CoveredBy
geom_methods.coveredby = ST_CoveredBy

local function ST_HausdorffDistance(g1, g2, densifyFrac)
    geom_relarg(g1, g2)
    if densifyFrac == nil then
        checkzero(geos.GEOSHausdorffDistance_r(handle, g1, g2, doubleptr))
        return tonumber(doubleptr[0])
    else
        checkzero(geos.GEOSHausdorffDistanceDensify_r(handle, g1, g2,
            densifyFrac, doubleptr))
        return tonumber(doubleptr[0])
    end
end
exports.HausdorffDistance = ST_HausdorffDistance
geom_methods.hausdorffdistance = ST_HausdorffDistance
geom_methods.hausdorff = ST_HausdorffDistance

--------------------------------------------------------------------------------
-- Geometry Outputs
--------------------------------------------------------------------------------

local ST_AsTableHandlers = {}

-- part of ST_AsTable
local function ST_CoordAsTable(seq, dim, i)
    checkzero(geos.GEOSCoordSeq_getX_r(handle, seq, i, doubleptr))
    local x = tonumber(doubleptr[0])
    checkzero(geos.GEOSCoordSeq_getY_r(handle, seq, i, doubleptr))
    local y = tonumber(doubleptr[0])
    if dim > 2 then
        checkzero(geos.GEOSCoordSeq_getZ_r(handle, seq, i, doubleptr))
        local z = tonumber(doubleptr[0])
        return {x, y, z}
    else
        return {x, y}
    end
end

-- part of ST_AsTable
local function ST_CoordSeqAsTable(seq)
    checkzero(geos.GEOSCoordSeq_getSize_r(handle, seq, uintptr))
    local size = tonumber(uintptr[0])
    checkzero(geos.GEOSCoordSeq_getDimensions_r(handle, seq, uintptr))
    local dim = tonumber(uintptr[0])
    local result = {}
    for i=1,size do
        result[i] = ST_CoordAsTable(seq, dim, i - 1)
    end
    return result
end

-- part of ST_AsTable
local function ST_PointAsTable(point)
    local seq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, point))
    checkzero(geos.GEOSCoordSeq_getDimensions_r(handle, seq, uintptr))
    local dim = tonumber(uintptr[0])
    return ST_CoordAsTable(seq, dim, 0)
end
ST_AsTableHandlers[POINT] = ST_PointAsTable

-- part of ST_AsTable
local function ST_LineStringAsTable(linestring)
    local seq = checknil(geos.GEOSGeom_getCoordSeq_r(handle, linestring))
    return ST_CoordSeqAsTable(seq)
end
ST_AsTableHandlers[LINESTRING] = ST_LineStringAsTable
ST_AsTableHandlers[LINEARRING] = ST_LineStringAsTable

-- A part of ST_AsTable
local function ST_PolygonAsTable(polygon)
    local nholes = ST_NumInteriorRings(polygon)
    local rings = table_new(nholes + 1, 0)
    rings[1] = ST_LineStringAsTable(ST_ExteriorRing(polygon))
    for i=1,nholes do
        rings[i + 1] = ST_LineStringAsTable(ST_InteriorRingN(polygon, i))
    end
    return rings
end
ST_AsTableHandlers[POLYGON] = ST_PolygonAsTable

-- A part of ST_AsTable
local function ST_MultiPointAsTable(multipoint)
    local ngeoms = ST_NumGeometries(multipoint)
    local result = table_new(ngeoms, 0)
    for i=1,ngeoms do
        result[i] = ST_PointAsTable(ST_GeometryN(multipoint, i))
    end
    return result
end
ST_AsTableHandlers[MULTIPOINT] = ST_MultiPointAsTable

-- A part of ST_AsTable
local function ST_MultiLineStringAsTable(multilinestring)
    local ngeoms = ST_NumGeometries(multilinestring)
    local result = table_new(ngeoms, 0)
    for i=1,ngeoms do
        result[i] = ST_LineStringAsTable(ST_GeometryN(multilinestring, i))
    end
    return result
end
ST_AsTableHandlers[MULTILINESTRING] = ST_MultiLineStringAsTable

-- A part of ST_AsTable
local function ST_MultiPolygonAsTable(multipolygon)
    local ngeoms = ST_NumGeometries(multipolygon)
    local result = table_new(ngeoms, 0)
    for i=1,ngeoms do
        result[i] = ST_PolygonAsTable(ST_GeometryN(multipolygon, i))
    end
    return result
end
ST_AsTableHandlers[MULTIPOLYGON] = ST_MultiPolygonAsTable

local ST_AsTable
-- A part of ST_AsTable
local function ST_GeometryCollectionAsTable(collection)
    local ngeoms = ST_NumGeometries(collection)
    local result = table_new(ngeoms, 0)
    for i=1,ngeoms do
        result[i] = ST_AsTable(ST_GeometryN(collection, i))
    end
    return result
end
ST_AsTableHandlers[GEOMETRYCOLLECTION] = ST_GeometryCollectionAsTable

function ST_AsTable(g)
    geom_arg(g)
    local typeid = ST_GeometryTypeId(g)
    local handler = ST_AsTableHandlers[typeid]
    if handler == nil then
        error(string.format('Not yet implemented: AsTable(%s)',
            ST_GeometryType(g)))
    end
    return setmetatable(handler(g), {
        __serialize = 'seq'
    }), tonumber(geos.GEOSGetSRID_r(handle, g))
end
exports.AsTable = ST_AsTable
geom_methods.totable = ST_AsTable
geom_methods.table = ST_AsTable

--------------------------------------------------------------------------------
-- Lua Stuff
--------------------------------------------------------------------------------

geom_methods.geometry = setmetatable({}, {
    __call = function(_, geom, ...)
        print('call', geom, 'x', ...)
    end;
    __index = function(...)
        print('index', ...)
    end
})

ffi.metatype(geom_t, {
    __serialize = ST_AsWKT;
    __tostring = ST_AsWKT;
    __eq = ST_Equals;
    __index = geom_methods;
})

return exports
