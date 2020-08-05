# Authors: Clemens Brunner
# License: BSD (3-clause)

# module XDF

using Logging


CHUNK_TYPE = Dict(1=>"FileHeader",
                  2=>"StreamHeader",
                  3=>"Samples",
                  4=>"ClockOffset",
                  5=>"Boundary",
                  6=>"StreamFooter")


"""
    read_xdf(filename::AbstractString)

Read XDF file.
"""
function read_xdf(filename::AbstractString)
    open(filename) do io
        String(read(io, 4)) == "XDF:" || error("invalid magic bytes sequence")
        n = 1  # chunk number
        while true
            len = try
                len = read_varlen_int(io)
            catch e
                isa(e, EOFError) && break
            end
            tag = read(io, UInt16)
            @debug "##### Chunk $n: $(CHUNK_TYPE[tag]) (tag $tag), length $len bytes"
            len -= 2
            if tag == 1  # FileHeader
                xml = String(read(io, len))
                @debug xml
            elseif tag == 2 || tag == 6  # StreamHeader or StreamFooter
                id = read(io, Int32)  # TODO: should this be UInt32?
                len -= 4
                @debug "StreamID: $id"
                xml = String(read(io, len))
                @debug xml
            else
                skip(io, len)  # TODO: read chunk-specific contents
            end
            n += 1
        end
    end
end


"Read variable-length integer."
function read_varlen_int(io::IO)
    nbytes = read(io, Int8)
    if nbytes == 1
        read(io, UInt8)
    elseif nbytes == 4
        read(io, UInt32)
    elseif nbytes == 8
        read(io, UInt64)
    end
end


read_xdf("/Users/clemens/Downloads/testfiles/minimal.xdf")

# end
