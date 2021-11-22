module TestSamples

using DataFrames
using Orihime
using Test

function plot_lines(n = 100)
    df = DataFrame(
        a = repeat([1, 2, 3, 4], outer = [n]),
        b = repeat(1:n, outer = [4]),
        c = cumsum(randn(n * 4)),
    )
    plt = Orihime.@plot(
        :line,
        x = {:b, type = :quantitative},
        y = {:c, type = :quantitative},
        extra_facets = [:a],
        data = df
    )
    return plt
end

function plot_hists(n = 100)
    df = DataFrame(
        a = repeat([1, 2, 3, 4], outer = [n]),
        b = repeat(1:2, outer = [2n]),
        c = randn(n * 4),
    )
    plt = Orihime.@plot(
        :bar,
        x = {:c, bin = true},
        y = {aggregate = :count},
        extra_facets = [:a, :b],
        data = df
    )
    return plt
end

function check_smoke(f)
    plt = f()
    io = IOBuffer()
    show(io, "image/png", plt)
    @test position(io) > 0
end

function test_smoke()
    @testset for f in [plot_lines, plot_hists]
        check_smoke(f)
    end
end

end  # module
