local bufpool = require("./bufpool")
local debug = require("./debug")
local protocol = require("./protocol")
local codec = require("./codec")
local writer = require("./writer")
local reader = require("./reader")

local sha256 = require("@vendor/dekkonot/sha256")

local net = zune.net

local PROTOCOL_VER = bit32.lshift(3, 16) + 0 -- 3.0

local connection = {}
connection.__index = connection

function connection.new() 
    return setmetatable({

    }, connection)
end

function connection._createpacket(self, codec, data) 
    local temp = bufpool.take(1024)
    local tempw = writer.new(temp)
    codec.write(tempw, data)
    local trim = bufpool.take(tempw.cur)
    buffer.copy(trim, 0, temp, 0, tempw.cur)

    bufpool.release(temp)
    return trim
end

function connection._sendpacket(self, codec, data) 
    local pack = self:_createpacket(codec, data)
    self.sock:send(pack)
    bufpool.release(pack)
end

function connection._recvpacket(self, codec) 
    local res = self.sock:recv()
    local resr = reader.new(res)
    return codec.read(resr)
end

function connection._readpacket(self, codec, buf) 
    local r = reader.new(buf)
    return codec.read(r)
end

function connection._authenticate(self) 
    local respbuf = self.sock:recv()
    local resp = self:_readpacket(protocol._AuthenticationGeneric, respbuf)
    local method = resp.method

    if method == 0 then 
        -- AuthenticationOk
        return {
            ok = true
        }
    elseif method == 2 then
        -- AuthenticationKerberosV5
        return {
            ok = false,
            error = "AuthenticationKerberosV5 not implemented"
        }
    elseif method == 3 then
        -- AuthenticationClearTextPassword
        return {
            ok = false,
            error = "AuthenticationClearTextPassword not implemented"
        }
    elseif method == 5 then
        -- AuthenticationMD5Password
        return {
            ok = false,
            error = "AuthenticationMD5Password not implemented"
        }
    elseif method == 7 then
        -- AuthenticationGSS
        return {
            ok = false,
            error = "AuthenticationGSS not implemented"
        }
    elseif method == 9 then
        -- AuthenticationSSPI
        return {
            ok = false,
            error = "AuthenticationSSPI not implemented"
        }
    elseif method == 10 then
        -- AuthenticationSASL
        local packet = self:_readpacket(protocol.AuthenticationSASL, respbuf)
        
        if packet.mechanism == "SCRAM-SHA-256" then 
            -- 1. send initial response
            
        end

        return {
            ok = false,
            error = "AuthenticationSASL: unsupported mechanism"
        }
    end
end

function connection.connect(self, opts) 
    self.sock = net.createSocket(net.ADDRF.INET, net.SOCKF.STREAM, 0)
    self.sock:connect(opts.addr, opts.port)

    local startup = self:_sendpacket(protocol.StartupMessage, {
        protocol = PROTOCOL_VER,
        params = {
            user = opts.username,
            database = opts.database
        }
    })

    local status = self:_authenticate()
end

return connection