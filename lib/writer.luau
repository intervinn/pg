local writer = {}

export type writer = {
    cur: number,
    buf: buffer
}

function writer.new(buf) 
    return {
        cur = 0,
        buf = buf
    }
end

function writer.writei8(self, value)
    buffer.writei8(self.buf, self.cur, value)
    self.cur += 1
end

function writer.writeu8(self, value)
    buffer.writeu8(self.buf, self.cur, value)
    self.cur += 1
end

function writer.writei16(self, value)
    buffer.writei16(self.buf, self.cur, value)
    self.cur += 2
end

function writer.writei32(self, value) 
    buffer.writei32(self.buf, self.cur, value)
    self.cur += 4
end

function writer.writef32(self, value)
    buffer.writef32(self.buf, self.cur, value)
    self.cur += 4
end

function writer.writef64(self, value)
    buffer.writef64(self.buf, self.cur, value)
    self.cur += 8
end

function writer.writestring(self, str: string, count: number?)
    local len = count or #str
    buffer.writestring(self.buf, self.cur, str, len)
    self.cur += len
end

function writer.len(self) 
    return self.cur
end

function writer.cap(self) 
    return buffer.len(self.buf)
end

return writer