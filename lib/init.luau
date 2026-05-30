local connection = require("./lib/connection")

local connection = connection.new()
connection:connect({
    username = "postgres",
    database = "postgres",
    addr = "127.0.0.1",
    port = 5432
})

--[[

local sock = net.createSocket(net.ADDRF.INET, net.SOCKF.STREAM, 0)
sock:connect("127.0.0.1", 5432)
sock:send(startup)

local buf = sock:recv()
debug.printBuf(buf)

sock:close()

]]