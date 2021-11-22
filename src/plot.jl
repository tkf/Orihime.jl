"""
    Orihime.@plot(vega_lite_spec...)

A `@vlplot` wrapper for extra functionalities:

* `data` is trimmed down using `Orihime.cleanup`
* `extra_facets` (a list of column names) can be passed as the top-level named
   argument to group by data by these columns. The plots for these groups are
   concatenated vertically.
"""
macro plot(vega_lite_spec...)
    vlexprs = []
    options = []
    for ex in vega_lite_spec
        if Meta.isexpr(ex, :(=), 2) && ex.args[1] in (:extra_facets, :data, :title)
            push!(options, Expr(:kw, ex.args...))
        else
            push!(vlexprs, insert_cleanup_expr(ex))
        end
    end
    @gensym orihime_plot_body
    quote
        function $orihime_plot_body(data, title)
            return $VegaLite.@vlplot(data = data, title = title, $(vlexprs...))
        end
        $plot_impl($orihime_plot_body; $(options...))
    end |> esc
end

function plot_impl(
    @nospecialize(orihime_plot_body);
    data = nothing,
    extra_facets = nothing,
    title = "",
)
    if extra_facets === nothing || isempty(extra_facets)
        return orihime_plot_body(data, title)
    end
    if data === nothing
        error("`extra_facets` requires `data` as the top-level argument")
    end
    df = Orihime.cleanup(data)
    plots = mapfoldl(
        push!,
        pairs(DataFrames.groupby(df, extra_facets; sort = true));
        init = VLSpec[],
    ) do (groupkey, subdata)
        title_values = join(
            ("$k=$(Orihime.readablestring(v))" for (k, v) in pairs(groupkey)),
            ", ",
        )
        if title == ""
            subtitle = title_values
        else
            subtitle = "$title $title_values"
        end
        return orihime_plot_body(subdata, subtitle)
    end
    # `reduce(vcat, plots)` does not work with vlplot?
    return vcat(plots...)
end

insert_cleanup_expr(@nospecialize(x)) = x
function insert_cleanup_expr(ex::Expr)
    if Meta.isexpr(ex, :meta) && Meta.isexpr(ex, :call) && Meta.isexpr(ex, :ref)
        return ex
    elseif Meta.isexpr(ex, :(=), 2) && ex.args[1] == :data
        # Convert `data = $rhs` to `data = cleanup($rhs)` when it's not at the
        # top level (i.e., not handled by `plot_impl`)
        return Expr(ex.head, ex.args[1], :($Orihime.cleanup($(ex.args[2]))))
    else
        return Expr(ex.head, Iterators.map(insert_cleanup_expr, ex.args)...)
    end
end
