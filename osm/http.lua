--
-- Lua script for interface HTTP engine. Use https://github.com/pintsized/lua-resty-http to make
-- http requests.
--
--
-- Copyright (C) 2017, Pavel Podkorytov
-- Based on Tirex interface by Hiroshi Miura
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Affero General Public License as published by
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

local resty_http = require "resty.http"
local osm_tile = require 'osm.tile'

local ngx_root = ngx
local shmem = ngx.shared.osm_http
local time = ngx.time
local timerat = ngx.timer.at
local sleep = ngx.sleep

local format = string.format

local pairs = pairs
local tonumber = tonumber
local error = error
local setmetatable = setmetatable

local print = print

module(...)

_VERSION = '0.1'

local http_entrypoint = 'http://localhost'

-- ------------------------------------
-- Syncronize thread functions
--
--   thread(1)
--       get_handle(key)
--       do work
--       store work result somewhere
--       send_signal(key)
--       return result
--
--   thread(2)
--       get_handle(key) fails then
--       wait_singal(key, timeout)
--       return result what thread(1) done
--
--   to syncronize amoung nginx threads
--   we use ngx.shared.DICT interface.
--
--   Here we use ngx.shared.osm_http
--   you need to set /etc/conf.d/lua.conf
--      ngx_shared_dict osm_http 10m;

--   status definitions
--    key is not exist: no job exist for its x/y/z
--    key is exist: job exist
--
--       key := <map>:<x>:<y>:<zoom>
--       val := <req> | <result>
--       flag := <status>
--
--       <x>, <y>, <zoom> := <integer>
--       <req> := string: request command string
--       <result> := string: result string
--       <status> := <gothandle> | <request> | <send> | <succeeded> | <failed>
--
--    key will be expired in timeout(sec)
--
-- ------------------------------------
local GOTHANDLE  =   0
local REQUEST    = 100
local SEND       = 200
local SUCCEEDED  = 300
local FAILED     = 400
local SPECIAL    = 999

--  if key exist, it returns false
--  else it returns true
--
local function get_handle(key, val, timeout, flag)
    local success,err,forcible = shmem:add(key, val, timeout, flag)
    if success == false then
        if err == 'exists' then
            -- only live requests can overtake handle
            if flag == GOTHANDLE then
                local prev_val, prev_flag = shmem:get(key)
                local prev_flag = tonumber(prev_flag) or 0
                -- only background requests handles can be overtaken
                if prev_flag == REQUEST or prev_flag == SEND then
                    shmem:replace(key, val, timeout, flag)
                    return true
                else
                    return nil
                end
            end
        else
            return nil
        end
    else
        return true
    end
    return nil
end

-- function: send_signal
-- argument: string key
--           number timeout in sec
--           number flag to send
-- return nil when failed
--
local function send_signal(key, timeout, flag)
    local ok, err = shmem:set(key, 0, timeout, flag)
    if not ok then
        return nil
    end
    return true
end

local function round(num, idp)
  return tonumber(format("%." .. (idp or 0) .. "f", num))
end

-- function: wait signal
-- argument: string key
--           number timeout in second
-- return nil if timeout in wait
--
local function wait_signal(key, timeout)
    local timeout = round(timeout, 1) * 10
    for i=0, timeout do
        local val, flag = shmem:get(key)
        if val then
            if flag == SUCCEEDED then
                return true
            elseif flag == FAILED then
                print('wait failed ',key)
                return nil
            else
                -- do nothing
            end
            sleep(0.1)
        else
            print('wait notval ',key)
            return nil
        end
    end
    print('wait timeout ',key)
    return nil
end


-- function: serialize_msg
-- argument: table msg
-- return: string
--
local function serialize_msg (msg)
    local str = ''
    str = http_entrypoint..'/'..msg["map"]..'/'..msg["z"]..'/'..msg["x"]..'/'..msg["y"]..".png"
    return str
end


local function get_key(map, mx, my, mz)
    return format("%s:%d:%d:%d", map, mx, my, mz)
end


-- ========================================================
--  It does not share context and global vals/funcs
--
local http_bk_handler
http_bk_handler = function (premature)
    local http_entrypoint = 'http://localhost'
    local shmem = ngx.shared.osm_http

    local REQUEST   = 100
    local SEND      = 200
    local SUCCEEDED = 300
    local FAILED    = 400

    if premature then
        -- clean up
        shmem:delete('_http_handler')
        return
    end

    local httpc = resty_http.new()
    httpc:set_timeout(30000)

    while true do
        -- send requests first...
        local indexes = shmem:get_keys()
        for key,index in pairs(indexes) do
            local req, flag = shmem:get(index)
            if flag == REQUEST then
                local res, err = httpc:request_uri(req)
                if not res then
                    print('bkreq failed ',index)
                end
            end
        end

        sleep(0.1)

        -- then receive response
        if res == ngx_root.HTTP_OK then
            shmem:set(index, res, 300, SUCCEEDED)
        elseif res == ngx_root.HTTP_CREATED then
            -- TODO: try multiple times
            shmem:set(index, res, 300, SUCCEEDED)
        else
            print('bkres failed ',index)
            shmem:set(index, res, 300, FAILED)
        end
    end
end

local function background_enqueue_request(map, x, y, z)
    local mx = x - x % 8
    local my = y - y % 8
    local mz = z
    local id = time()
    local index = get_key(map, mx, my, mz)
    local req = serialize_msg({
        ["x"]   = mx,
        ["y"]   = my,
        ["z"]   = mz,
        ["map"] = map})
    local ok = get_handle(index, req, 300, REQUEST)
    if not ok then
        return nil
    end
    local handle = get_handle('_http_handler', 0, 0, SPECIAL)
    if handle then
        -- only single light thread can handle http
        timerat(0, http_bk_handler)
    end
    return true
end


-- function: send_http_request
-- return: resulted http status
--
local function send_http_request(req)
    local httpc = resty_http.new()
    httpc:set_timeout(30000)
    local res, err = httpc:request_uri(req)
    if not res then
        print('failed to request: ', err)
        return nil
    end
    return res.status
end

-- funtion: enqueue_request
-- argument: map, x, y, zoom
-- return:   true or nil
--
function enqueue_request (map, x, y, z)
    local mx = x - x % 8
    local my = y - y % 8
    local mz = z
    local id = time()
    local index = get_key(map, mx, my, mz)
    local req = serialize_msg({
        ["x"]   = mx,
        ["y"]   = my,
        ["z"]   = mz,
        ["map"] = map})

    local ok = get_handle(index, req, 300, GOTHANDLE)

    if not ok then
        return wait_signal(index, 30)
    end

    local status = send_http_request(req)
    if not status then
        print('req failed ',index)
        return send_signal(index, 300, FAILED)
    end

    if status == ngx_root.HTTP_OK then
        return send_signal(index, 300, SUCCEEDED)
    else
        print('status failed ',index)
        return send_signal(index, 300, FAILED)
    end
end

-- funtion: request
-- argument: map, x, y, zoom, maxzoom
-- return:   true or nil
--
function request (map, x, y, z1, z2)
    local z2 = tonumber(z2)
    local z1 = tonumber(z1)
    if z1 > z2 then
        return nil
    end

    local res = enqueue_request(map, x, y, z1)
    if not res then
        return nil
    end
    if z1 == z2 then
        return true
    end
    for i = 1, z2 - z1 do
        local nx, ny = osm_tile.zoom_num(x, y, z1, z1 + i)
        background_enqueue_request(map, nx, ny, z1 + i)
    end
    return true
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
