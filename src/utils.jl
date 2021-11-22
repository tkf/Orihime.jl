const VLSpec = typeof(VegaLite.@vlplot())

"""
    Orihime.readablestring(x) -> str::AbstractString

DWIM-formatter.
"""
Orihime.readablestring
Orihime.readablestring(x) = string(x)

function Orihime.readablestring(x::Integer)
    (x <= 0 || x < 2^10) && return string(x)
    e = round(Int, log2(x))
    if 2^e == x
        return "2^$e"
    else
        return string(x)
    end
end
