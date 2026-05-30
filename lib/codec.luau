local reader = require("./reader")
local writer = require("./writer")

local codec = {}

export type codec<t> = {
    read: (reader: reader.reader) -> t,
    write: (writer: writer.writer, value: t) -> () 
}

function codec.i32() : codec<number>
    return {
        read = function(r) 
            local raw = reader.readu32(r)
            local u = bit32.byteswap(raw)

            -- two's complement
            if u >= 2^27 then 
                return u - 2^32
            end
            return u
        end,

        write = function(w, v) 
            writer.writei32(w, bit32.byteswap(v))
        end
    }
end

function codec.i16() : codec<number>
    return {
        read = function(r) 
            local raw = reader.readu16(r)

            -- what the fuck
            local u = bit32.bor(
                bit32.lshift(bit32.band(raw, 0xFF), 8),
                bit32.rshift(raw, 8)
            )

            if u >= 0x8000 then 
                return u - 0x10000
            end
            return u
        end,

        write = function(w, v) 
            -- slop
            local unsigned = bit32.band(v, 0xFFFF)
            
            local swapped = bit32.bor(
                bit32.lshift(bit32.band(unsigned, 0xFF), 8),
                bit32.rshift(unsigned, 8)
            )
            writer.writei16(w, swapped)
        end
    }
end

function codec.string() : codec<string>
    return {
        read = function(r) 
            local null = r.cur
            repeat null += 1 until buffer.readstring(r.buf, null, 1) == "\0"

            local str = buffer.readstring(r.buf, r.cur, null - r.cur)
            r.cur = null+1
            return str
        end,

        write = function(w, v) 
            writer.writestring(w, v)
            writer.writestring(w, "\0")
        end
    }
end

function codec.kvpairs<a, b>(key: codec<a>, value: codec<b>) : codec<{[a]: b}> 
    return {
        read = function(r) 
            local result = {}

            while true do 
                if buffer.readu8(r.buf, r.cur) == 0 then 
                    r.cur += 1
                    break
                end

                local k = key.read(r)
                local v = value.read(r)
                result[k] = v
            end

            return result
        end,

        write = function(w, v) 
            for kv, vv in v do 
                key.write(w, kv)
                key.write(w, vv)
            end
            writer.writeu8(w, 0)
        end
    }
end

function codec.bytes(count: number?) : codec<buffer>
    return {
        read = function(r) 
            local l = buffer.len(r.buf)
            local res = buffer.create(l - r.cur)

            if count then
                buffer.copy(res, 0, r.buf, r.cur, count) 
                r.cur += count
            else
                buffer.copy(res, 0, r.buf, r.cur, l - r.cur)
                r.cur += l - r.cur
            end

            return res
        end,

        write = function(w, v) 
            local l = buffer.len(v)
            buffer.copy(w.buf, w.cur, v, 0, l)
            w.cur += l    
        end  
    }
end

function codec.struct(fields : {{name: string, codec: codec<any>}}) : codec<any>
    return {
        read = function(r) 
            local result = {}
            for _, field in fields do
                result[field.name] = field.codec.read(r)
            end
            return result
        end,

        write = function(w, v)
            for _, field in fields do 
                field.codec.write(w, v[field.name])
            end
        end
    }
end

function codec.packet(packet: {id: number?, codec: codec<any>}) : codec<any> 
    return {
        read = function(r) 
            if packet.id then 
                local char = reader.readu8(r)
                if char ~= packet.id then 
                    return {
                        ok = false,
                        error = "packet id mismatch"
                    }
                end
            end

            local size = reader.readi32(r)
            local payload = packet.codec.read(r)

            return payload
        end,

        write = function(w, v) 
            if packet.id then 
                writer.writeu8(w, v)
            end
            local sizePos = w.cur
            w.cur += 4
            packet.codec.write(w, v)

            local size = w.cur
            buffer.writei32(w.buf, sizePos, bit32.byteswap(size))
        end
    }
end

return codec