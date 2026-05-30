
local reader = {}

export type reader = {
    cur: number,
    buf: buffer
}

function reader.new(buf: buffer) 
    return {
        cur = 0,
        buf = buf
    }
end

function reader.readu8(self) 
    local r = buffer.readu8(self.buf, self.cur)
    self.cur += 1
    return r
end

function reader.readi8(self) 
    local r = buffer.readi8(self.buf, self.cur)
    self.cur += 1
    return r
end

function reader.readi16(self) 
    local r = buffer.readi16(self.buf, self.cur)
    self.cur += 2
    return r
end

function reader.readu16(self) 
    local r = buffer.readu16(self.buf, self.cur)
    self.cur += 2
    return r
end

function reader.readu32(self) 
    local r = buffer.readu32(self.buf, self.cur)
    self.cur += 4
    return r
end

function reader.readi32(self) 
    local r = buffer.readi32(self.buf, self.cur)
    self.cur += 4
    return r
end

function reader.readf32(self) 
    local r = buffer.readf32(self.buf, self.cur)
    self.cur += 4
    return r
end

function reader.readf64(self) 
    local r = buffer.readf64(self.buf, self.cur)
    self.cur += 8
    return r
end

function reader.readstring(self, count) 
    local r = buffer.readstring(self.buf, self.cur, count)
    self.cur += count
    return r
end

return reader