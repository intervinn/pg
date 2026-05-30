local bufpool = {}

local _pool = {} :: {[number]: {}}
local _sizes = {} :: {[number]: number}

function bufpool.take(size: number)
    local bucket = _pool[size]

    if not bucket then
        _pool[size] = {}
        _sizes[size] = 0
        return buffer.create(size)
    end

    local count = _sizes[size]
    if count == 0 then
        return buffer.create(size)
    end

    local buf = bucket[count]
    bucket[count] = nil
    _sizes[size] = count - 1

    return buf
end

function bufpool.release(buf: buffer) 
    local size = buffer.len(buf)

    local bucket = _pool[size]
    local count = _sizes[size]

    if not bucket then 
        bucket = {}
        _pool[size] = bucket
        count = 0
        _sizes[size] = count
    end

    bucket[count+1] = buf
    _sizes[size] = count + 1
end

return bufpool