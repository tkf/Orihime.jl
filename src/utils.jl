const VLSpec = typeof(VegaLite.@vlplot())

"""
    Orihime.readablestring(x) -> str::AbstractString

DWIM-formatter.
"""
Orihime.readablestring
Orihime.readablestring(x) = string(x)

function Orihime.readablestring(x::Integer)
    if abs(x) >= 2^10
        e = round(Int, log2(abs(x)))
        if 2^e == abs(x)
            if x > 0
                return "2^$e"
            else
                return "-2^$e"
            end
        end
    end
    if abs(x) >= 1_000
        e = round(Int, log10(abs(x)))
        if 10^e == abs(x)
            if x > 0
                return "10^$e"
            else
                return "-10^$e"
            end
        end
    end
    if abs(x) > 1000
        return format_with_thousands_separator(x)
    end
    return string(x)
end

function format_with_thousands_separator(x::Integer)
    isnegative = x < 0
    nd = ndigits(x)
    ngroups = (nd - 1) ÷ 3
    buffer = Vector{UInt8}(undef, nd + isnegative + ngroups)
    fill!(buffer, 0)  # TODO: remove
    buffer[1] = '-'  # will be overwritten if !isnegative
    x = abs(x)
    i = lastindex(buffer)
    c = 0
    while true
        if c == 3
            buffer[i] = ','
            c = 0
            i -= 1
        end
        c += 1

        d, r = divrem(x, 10)
        buffer[i] = '0' + r
        i -= 1
        d == 0 && break
        x = d
    end
    @assert all(>(0), buffer)  # TODO: remove
    return String(buffer)
end
