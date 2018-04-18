--
-- Lua script for interface Renderd engine
--
--
-- Copyright (C) 2016, Mikhail Okhotin
-- Copyright (C) 2018, Pavel Podkorytov
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

local shmem = ngx.shared.osm_renderd

local tcp = ngx.socket.tcp
local time = ngx.time
local sleep = ngx.sleep

local format = string.format
local char = string.char
local rep = string.rep
local len = string.len
local sub = string.sub
local match = string.match

local floor = math.floor

local unpack = unpack
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local error = error
local setmetatable = setmetatable
local print = print

local osm_tile = require 'osm.tile'

module(...)

_VERSION = '0.3'

local renderd_sock       = 'unix:/var/run/renderd/renderd.socket'
local renderd_cmd_size   = 64
local renderd_timeout    = 300 -- 5m
local handle_success_ttl = 300 -- 5m
local handle_failed_ttl  = 1   -- 1s

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
--   Here we use ngx.shared.osm_renderd
--   you need to set /etc/conf.d/lua.conf
--      ngx_shared_dict osm_renderd 10m;

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

local PROT_RENDER   = 1
local PROT_DIRTY    = 2
local PROT_DONE     = 3
local PROT_NOT_DONE = 4

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
                print('wait failed ', key)
                return nil
            else
                -- do nothing
            end
            sleep(0.1)
        else
            print('wait notval ', key)
            return nil
        end
    end
    print('wait timeout ', key)
    return nil
end

-- function: ntob
--
local function ntob(n, len)
    local bytes = {}
    for i=1, len do
        bytes[i] = n % 256
        n = floor(n / 256)
    end
    return char(unpack(bytes))
end

-- function: bton
--
local function bton(s)
    local bytes, n = {s:byte(1,-1)}, 0
    for i=0, #s-1 do
        n = n + bytes[1+i] * 256^i
    end
    return n
end

-- function: serialize_msg
-- argument: table msg
-- return: string
--
local function serialize_msg (msg)
    local str = ''
    str = ntob(2,4)..ntob(msg["cmd"],4)..ntob(msg["x"],4)..ntob(msg["y"],4)..ntob(msg["z"],4)
    str = str..msg["map"]..rep('\0',44-len(msg["map"]))
    return str
end

-- function: deserialize_msg
-- argument: string str: recieved message from renderd
-- return: table
--
local function deserialize_msg (str)
    local msg = {
        ["cmd"] = bton(sub(str,5,8)),
        ["x"]   = bton(sub(str,9,12)),
        ["y"]   = bton(sub(str,13,16)),
        ["z"]   = bton(sub(str,17,20)),
        ["map"] = match(sub(str,21,61),'%Z*')}
    return msg
end

local function get_key(map, mx, my, mz)
    return format("%s:%d:%d:%d", map, mx, my, mz)
end

-- function: send_renderd_request
-- return: resulted msg{}
--
local function send_renderd_request(req)
    local tcpsock = tcp()
    tcpsock:settimeout(100)
    tcpsock:connect(renderd_sock)
    local ok,err=tcpsock:send(req)
    if not ok then
        print('send ', err)
        tcpsock:close()
        return nil
    end
    tcpsock:settimeout(renderd_timeout * 1000) -- ms
    local data, err = tcpsock:receive(renderd_cmd_size)
    tcpsock:close()
    if not data then
        print('recv ', err)
        return nil
    end
    local msg = deserialize_msg(data)
    return msg
end

-- funtion: enqueue_request
-- argument: map, x, y, zoom
-- return:   true or nil
--
function enqueue_request (map, x, y, z, priority)
    local mx = x - x % 8
    local my = y - y % 8
    local mz = z
    local priority = priority
    local id = time()
    local index = get_key(map, mx, my, mz)
    local req = serialize_msg({
        ["cmd"] = priority,
        ["x"]   = mx,
        ["y"]   = my,
        ["z"]   = mz,
        ["map"] = map})
    local ok = get_handle(index, req, 300, GOTHANDLE)
    if not ok then
        return wait_signal(index, 30)
    end
    local msg = send_renderd_request(req)
    if not msg then
        print('req failed (send_renderd_request returns empty msg or timeout is reached) ', index)
        return send_signal(index, handle_failed_ttl, FAILED)
    end
    local index = get_key(msg["map"], msg["x"], msg["y"], msg["z"])
    local res = msg["cmd"]
    -- "dirty" request returns PROT_NOT_DONE immediately
    if (priority == PROT_DIRTY and res == PROT_NOT_DONE) then
        return send_signal(index, handle_success_ttl, SUCCEEDED)
    -- "render" request waits for rendering complete
    elseif (priority == PROT_RENDER and res == PROT_DONE) then
        return send_signal(index, handle_success_ttl, SUCCEEDED)
    -- "render" request returns PROT_NOT_DONE if renderd backend failed
    elseif (priority == PROT_RENDER and res == PROT_NOT_DONE) then
        print('res failed (NOT_DONE responce) ', index)
        return send_signal(index, handle_failed_ttl, FAILED)
    else
        print('res failed (unknown responce) ', index)
        return send_signal(index, handle_failed_ttl, FAILED)
    end
end

-- funtion: request
-- argument: map (string), x, y, zoom, maxzoom (int), background (bool)
-- return:   true or nil
--
-- if background is true, send request with dirty priority (do not wait for results).
--
function request (map, x, y, z1, z2, background)
    local z2 = tonumber(z2)
    local z1 = tonumber(z1)
    if z1 > z2 then
        return nil
    end

    local priority = PROT_RENDER
    if background then
        priority = PROT_DIRTY
    end

    local res = enqueue_request(map, x, y, z1, priority)
    if not res then
        return nil
    end
    if z1 == z2 then
        return true
    end
    for i = 1, z2 - z1 do
        local nx, ny = osm_tile.zoom_num(x, y, z1, z1 + i)
        enqueue_request(map, nx, ny, z1 + i, PROT_DIRTY)
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
