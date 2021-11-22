asdataframe(df::DataFrames.AbstractDataFrame) = df
asdataframe(table) = DataFrame(table)

const VegaLiteEltype = Union{AbstractString,Missing,Nothing,Number,Symbol}

function refineeltype(xs)
    if eltype(xs) <: VegaLiteEltype
        return xs
    else
        return identity.(xs)
    end
end

function Orihime.cleanup(table)
    df = asdataframe(table)
    size(df, 1) == 0 && return df

    # To use `eltype` below, refine `eltype` of all columns first:
    cols = map(refineeltype, eachcol(df))
    cnames = propertynames(df)

    idx = findall(c -> eltype(c) <: VegaLiteEltype , cols)
    df = DataFrame(cols[idx], cnames[idx])
    return df
end
