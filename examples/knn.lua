#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

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
print('--')
nearby({37.537407, 55.796782}, 5)

os.exit(0)
