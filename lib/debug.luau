local debug = {}

function debug.printbuf(buf: buffer) 
    local result = {}
    for i = 0, buffer.len(buf) - 1 do
        local byte = buffer.readi8(buf, i)
        if byte >= 32 and byte <= 126 then
            table.insert(result, string.char(byte))
        else
            table.insert(result, string.format("[%02X]", byte))
        end
    end

    print(table.concat(result))
end

return debug