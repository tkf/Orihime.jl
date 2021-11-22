baremodule Orihime

macro plot end

function cleanup end
function readablestring end

module Internal

import ..Orihime: @plot
using ..Orihime: Orihime

import VegaLite
using DataFrames: DataFrames, DataFrame

include("utils.jl")
include("cleanup.jl")
include("plot.jl")

end  # module Internal

end  # baremodule Orihime
