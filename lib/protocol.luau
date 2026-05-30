local codec = require("./codec")

-- packets prefixed with _ aren't actually present in the protocol
-- they're used for lib's internal stuff

return table.freeze({
    StartupMessage = codec.packet({
        codec = codec.struct({
            {name = "protocol", codec = codec.i32()},
            {name = "params", codec = codec.kvpairs(codec.string(), codec.string())}
        })
    }),

    _AuthenticationGeneric = codec.packet({
        id = string.byte("R"),
        codec = codec.struct({
            {name = "method", codec = codec.i32()},
            {name = "other", codec = codec.bytes()}
        })
    }),

    AuthenticationSASL = codec.packet({
        id = string.byte("R"),
        codec = codec.struct({
            {name = "method", codec = codec.i32()},
            {name = "mechanism", codec = codec.string()}
        })
    }),

    SASLInitialResponse = codec.packet({
        id = string.byte("p"),
        codec = codec.struct({
            {name = "name", codec = codec.string()},
            {name = "length", codec = codec.i32()},
            {name = "response", codec = codec.bytes()}
        })
    })
})