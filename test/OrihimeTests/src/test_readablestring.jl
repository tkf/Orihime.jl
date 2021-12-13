module TestReadablestring

using Orihime
using Orihime.Internal: format_with_thousands_separator
using Test

macro ex_str(str)
    expr = esc(Meta.parse(str))
    :($expr => $str)
end

macro tsep_str(str)
    value = parse(Int, replace(str, "," => ""))
    :($value => $str)
end

function test_int_expr()
    @testset "$str" for (value, str) in [
        ex"0",
        ex"512",
        ex"2^10",
        ex"2^12",
        ex"-2^10",
        ex"-2^12",
        ex"10^3",
        ex"10^4",
        ex"-10^3",
        ex"-10^4",
        tsep"1,234",
        tsep"12,345",
        tsep"123,456",
        tsep"1,234,567",
        tsep"1,234,567,890",
        tsep"10,101,010,101",
        tsep"101,010,101,010",
        tsep"-1,234",
        tsep"-12,345",
        tsep"-123,456",
        tsep"-1,234,567",
        tsep"-1,234,567,890",
        tsep"-101,010,101,010",
    ]
        @test Orihime.readablestring(value) == str
    end
end

function test_no_thousands_separator()
    @testset "$value" for value in [1:10; 0; -1:-1:-10; 100; -100]
        @test format_with_thousands_separator(value) == string(value)
    end
end

end  # module
