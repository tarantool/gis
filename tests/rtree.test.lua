#!/usr/bin/env tarantool

package.path = "../?/init.lua;../?.lua;./?/init.lua;./?.lua;"..package.path
package.cpath = "../?.so;../?.dylib;./?.so;./?.dylib;"..package.cpath

box.cfg({logger = 'tarantool.log'})

local json = require('json')
local yaml = require('yaml')
local gis = require('gis')
gis.install()
local ST = gis.ST

local work_dir = require('fio').dirname(arg[0])
local file = io.open(work_dir..'/PostOfficesMsk.json')
if file == nil then
    error('Failed to open json file')
end
local data = json.decode(file:read('*a'))
file:close()

if box.space.postoffices then
    box.space.postoffices:drop()
end
local postoffices = box.schema.space.create("postoffices")
postoffices:create_index('primary', { type = 'HASH', parts = {1, 'num'}})
postoffices:create_index('spatial', { type = 'RTREE', parts = {2, 'array'},
    unique = false, dimension=3})

local latlongid = 4326 -- WGS84
local utmid = 32644 -- 37N
local geocentid = 4328 -- WGS84

local function togeo(coords)
    return ST.Point(coords, latlongid):transform(geocentid)
end

for _, info in pairs(data) do
    local postalcode = tonumber(info.Cells.PostalCode)
    local x = tonumber((info.Cells.X_WGS84:gsub(",", ".")))
    local y = tonumber((info.Cells.Y_WGS84:gsub(",", ".")))
    local address = info.Cells.Address
    local point = togeo({x, y})
    postoffices:replace({postalcode, point:totable(), {x, y}, address})
end

local function neighbor(coords, count)
    local point = togeo(coords)
    local i = 1
    local results = {}
    for _, office in postoffices.index.spatial:pairs(point:totable(),
        { iterator = 'neighbor' }) do
        --[[
        print(yaml.encode({
            PostalCode = office[1];
            Address = office[4];
            Distance = point:distance(togeo(office[3]))
        }))
        --]]
        results[i] = office[1]
        i = i + 1
        if i > count then
            break
        end
    end
    return results
end

local test = require('tap').test('gis.ST.Polygon')
test:plan(2)

test:is_deeply(neighbor({37.479407, 55.862488}, 5),
    {125195,125445,125502,125581,125565}, "neighbor")
test:is_deeply(neighbor({37.537407875061, 55.7967821059873}, 5),
    {119334, 125167, 125319, 125190, 125057}, "neighbor")

postoffices:drop()
os.exit(test:check() == true and 0 or -1)
