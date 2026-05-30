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
    })

})