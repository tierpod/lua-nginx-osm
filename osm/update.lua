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

local lfs = require "lfs"

-- you have to set: ngx_shared_dict osm_last_update 8k;
local shmem = ngx.shared.osm_last_update

local UPDATE_KEY = 'enabled'

local _M = {
    _VERSION = '0.3',
    FLAGFILE = '/var/lib/mod_tile/planet-import-complete',
    EXPTIME = 3600, -- one hour
}

-- returns: true if update is enabled
--          false or nil if update is disabled
--
function _M.get_state()
    return shmem:get(UPDATE_KEY)
end

-- checks if metatile file is outdated
-- args: metafilename, map (string),
--       offset (int) [optional, default=0]: offset in seconds, subtracted from metafilename mtime
-- returns: true if metafilename older than flagfilename.
--
function _M.is_outdated(metafilename, map, offset)
    if shmem == nil then
        return false
    end

    -- get last_update from shared memory cache
    local last_update = shmem:get(map)
    if last_update == nil then
        -- if not found in cache, get mtime for flag file
        local mtime = _M.get_mtime(_M.FLAGFILE)
        if mtime == nil then
            return false
        end

        -- store mtime of flag file to shared memory cache with key = map, value = last_update
        -- and expiration time = exptime
        last_update = mtime
        local success = shmem:set(map, last_update, _M.EXPTIME)
        if not success then
            return false
        end
    end

    -- get mtime for metafilename
    local mtime = _M.get_mtime(metafilename)

    -- if metafilename does not exist, mark it as outdated
    if mtime == nil then
        return true
    end

    local _offset = offset or 0
    return (last_update - _offset) > mtime
end

-- get last update time for map from nginx shared cache
-- args: map (string)
-- returns: last_update time (string)
--
function _M.get_last_update(map)
    if shmem == nil then
        return nil
    end

    local last_update = shmem:get(map)
    return last_update
end

-- enable update process
--
function _M.enable()
    local _, err = shmem:set(UPDATE_KEY, true)
    return err
end

-- disable update process
--
function _M.disable()
    local _, err = shmem:set(UPDATE_KEY, false)
    return err
end

-- enable update process only if current value is nil (unset)
--
function _M.safe_enable()
    local err = nil
    if shmem:get(UPDATE_KEY) == nil then
        local _, err = shmem:set(UPDATE_KEY, true)
    end

    return err
end

-- list all cached timestamps per map
-- returns: table of "map" => "timestamp"
--
function _M.get_list()
    local items = {}

    for _, key in pairs(shmem:get_keys()) do
        if key ~= UPDATE_KEY then
            items[key] = shmem:get(key)
        end
    end

    return items
end

-- get file modification time with 'lua-filesystem' module unixtime
-- args: filename (string)
-- returns: mtime (int) or nil
function _M.get_mtime(filename)
    return lfs.attributes(filename, "modification")
end

-- compare modification time of two files.
-- args: file1, file2 (string)
-- returns: true if file1 newer than file2, otherwise false.
function _M.is_file_newer(file1, file2)
    local mtime1 = _M.get_mtime(file1)
    if mtime1 == nil then
        return false
    end

    local mtime2 = _M.get_mtime(file2)
    if mtime2 == nil then
        return false
    end

    return mtime1 > mtime2
end

return _M
