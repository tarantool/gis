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

local ffi = require('ffi')
require('gis.proj4_cdef')

local proj_path  = package.search ~= nil and
                   package.search('gis.lib') or
                   package.searchpath('gis.lib', package.cpath)
if proj_path == nil then
    error("Failed to find internal library")
end
local lib = ffi.load(proj_path)
local ctx = lib.pj_ctx_alloc()
if ctx == nil then
     error('Failed to create proj4 context')
end
ffi.gc(ctx, lib.pj_ctx_free)

local projections = {}

local PROJ_VERSION = ffi.string(lib.libproj_version())
projections.PROJ_VERSION = PROJ_VERSION

local function ctx_raise_errno(errno)
    assert(errno ~= 0)
    local errstr = lib.pj_strerrno(errno)
    local errstr = errstr ~= nil and ffi.string(errstr) or "Unknown error"
    error('PROJ: '..errstr)
end

local function ctx_raise()
    local errno = lib.pj_ctx_get_errno(ctx)
    return ctx_raise_errno(errno)
end

local proj_t = ffi.typeof('struct PJ')
local proj_methods = {}

local function proj_is(proj)
    if proj == nil or not ffi.istype(proj_t, proj) then
        return false
    end
    return true
end

local function proj_arg(proj)
    if proj_is(proj) then
        return
    end
    error(string.format("Usage: proj:%s()", debug.getinfo(2).name))
end

local function proj_def(proj)
    proj_arg(proj)
    local buf = lib.pj_get_def(proj, 0);
    if buf == nil then
        ctx_raise()
    end
    ffi.gc(buf, lib.pj_dalloc)
    return ffi.string(buf)
end
proj_methods.def = proj_def

local function proj_tostring(proj)
    return string.format("Projection('%s')", proj_def(proj))
end

local function proj_islatlong(proj)
    proj_arg(proj)
    return lib.pj_is_latlong(proj) ~= 0
end
proj_methods.islatlong = proj_islatlong

local function proj_isgeocent(proj)
    proj_arg(proj)
    return lib.pj_is_geocent(proj) ~= 0
end
proj_methods.isgeocent = proj_isgeocent

local function proj_tolatlong(proj)
    proj_arg(proj)
    local latlong = lib.pj_latlong_from_proj(proj)
    if latlong == nil then
        ctx_raise()
    end
    return ffi.gc(latlong, lib.pj_free)
end
proj_methods.tolatlong = proj_tolatlong

local function proj_transformv(src, dst, count, xvec, yvec, zvec)
    if not proj_is(src) or not proj_is(dst) or xvec == nil or yvec == nil then
        error("Usage: proj:transformv(dst: projection, count: number, "..
              "xvec: double[], yvec: double[], zvec: double[])")
    end
    proj_arg(src)
    local errno = lib.pj_transform(src, dst, count, 1, xvec, yvec, zvec)
    if errno ~= 0 then
        ctx_raise_errno(errno)
    end
    return true
end

local function torad(degree)
    return degree * 0.0174532925199432958
end

local function todeg(rad)
    return rad * 57.29577951308232
end

local xyzbuf = ffi.new('double[3]')
local function proj_transform(src, dst, x, y, z)
    if not proj_is(src) or not proj_is(dst) or x == nil or y == nil then
        error("Usage: projection:transform(dst: projection, x: number, "..
              "y: number, [z: number])")
    end
    -- humans use degree
    if proj_islatlong(src) then
        xyzbuf[0] = torad(x)
        xyzbuf[1] = torad(y)
        xyzbuf[2] = 0.0
    else
        xyzbuf[0] = x
        xyzbuf[1] = y
        xyzbuf[2] = z or 0.0
    end
    proj_transformv(src, dst, 1, xyzbuf + 0, xyzbuf + 1, xyzbuf + 2)
    if proj_isgeocent(dst) then
        return tonumber(xyzbuf[0]), tonumber(xyzbuf[1]), tonumber(xyzbuf[2])
    elseif proj_islatlong(dst) then
        return todeg(tonumber(xyzbuf[0])), todeg(tonumber(xyzbuf[1]))
    else
        return tonumber(xyzbuf[0]), tonumber(xyzbuf[1])
    end
end
proj_methods.transform = proj_transform

ffi.metatype(proj_t, {
    __index = proj_methods;
    __tostring = proj_tostring;
})

local function proj_get(projections, srid)
    local proj = rawget(projections, srid)
    if proj ~= nil then
        return proj
    end
    local info = box.space.spatial_ref_sys:get(srid)
    if info == nil then
        return nil
    end
    -- proj = lib.pj_init_plus_ctx(ctx, info[5])
    proj = lib.pj_init_plus(info[5])
    if proj == nil then
        ctx_raise()
    end
    ffi.gc(proj, lib.pj_free)
    rawset(projections, srid, proj)
    return proj
end

return setmetatable(projections, {
    __index = proj_get;
})
