--
-- OpenStreetMap tile handling library
--
--
-- Copyright (C) 2019, Pavel Podkorytov
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Affero General Public License for more details.
--
--    You should have received a copy of the GNU Affero General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

local _M = {
    _VERSION = '0.1',
    _METATILES_DIR = '/var/lib/mod_tile',
}

local mt = { __index = _M }

function mt.__tostring(self)
    return '{ x='..self.x..' y='..self.y..' z='..self.z..' map='..self.map..' ext='..self.ext..' }'
end

function mt.__concat(a, b)
    return tostring(a)..tostring(b)
end

local osm_tile = require 'osm.tile'

local match = string.match

-- Returns new tile object.
--
-- @param   str     tile uri (format: /mapname/x/y/z.ext)
-- @param   str     metatiles root directory
-- @return  table
function _M.new_from_uri(uri, metatiles_dir)
    local ext = 'png'
    local content_type = 'image/png'
    local is_vector = match(uri, '%.mvt$')
    if is_vector then
        ext = 'mvt'
        content_type = 'application/vnd.mapbox-vector-tile'
    end

    local map = osm_tile.get_mapname(uri, ext)
    local x, y, z = osm_tile.get_cordination(uri, map, ext)

    if metatiles_dir then
        _M._METATILES_DIR = metatiles_dir
    end

    return setmetatable({
        x = x,
        y = y,
        z = z,
        map = map,
        ext = ext,
        content_type = content_type,
        is_vector = is_vector,
    }, mt)
end

-- Checks if tile.map contains in maps list.
--
-- @param   table (array of str)    list with map names
-- @return  bool
function _M.is_inside_maps(self, maps)
    for _, map in pairs(maps) do
        if self.map == map then
            return true
        end
    end

    return false
end

-- see osm_tile.is_inside_region
function _M.is_inside_region(self, region)
    return osm_tile.is_inside_region(region, self.x, self.y, self.z)
end

-- see osm_tile.check_integrity_xyzm
function _M.check_integrity_xyzm(self, minz, maxz)
    return osm_tile.check_integrity_xyzm(self.x, self.y, self.z, minz, maxz)
end

-- see osm_tile.xyz_to_metatile_filename
function _M.xyz_to_metatile_filename(self)
    return osm_tile.xyz_to_metatile_filename(self.x, self.y, self.z)
end

-- Gets tile from metatile file.
--
-- @return  string or nil
-- @return  err
function _M.get_tile(self)
    local metatile = self:get_metatile_path()
    return osm_tile.get_tile(metatile, self.x, self.y, self.z)
end

-- Gets path to the metatile file for this tile object. Stores calculates value to tile.metatile
-- attribute.
--
-- @return  string  path to the meatatile file
function _M.get_metatile_path(self)
    local f = self._METATILES_DIR..'/'..self.map..'/'..self:xyz_to_metatile_filename()
    self.metatile = f
    return f
end

return _M
