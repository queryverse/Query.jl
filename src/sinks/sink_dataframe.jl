@require DataFrames begin

@generated function _filldf(columns, enumerable)
    n = length(columns.types)
    push_exprs = Expr(:block)
    for i in 1:n
        if columns.parameters[i] <: DataArray
            ex = :( push!(columns[$i], isnull(i[$i]) ? NA : get(i[$i])) )
        else
            ex = :( push!(columns[$i], i[$i]) )
        end
        push!(push_exprs.args, ex)
    end

    quote
        for i in enumerable
            $push_exprs
        end
    end
end

function collect{T<:NamedTuple}(enumerable::Enumerable{T}, ::Type{DataFrames.DataFrame})
    columns = []
    for t in T.types
        if isa(t, TypeVar)
            push!(columns, Array(Any,0))
        elseif t <: Nullable
            push!(columns, DataArray(t.parameters[1],0))
        else
            push!(columns, Array(t,0))
        end
    end
    df = DataFrames.DataFrame(columns, fieldnames(T))
    _filldf((df.columns...), enumerable)
    return df
end

function collect{TS,Provider}(source::Queryable{TS,Provider}, ::Type{DataFrames.DataFrame})
    collect(query(collect(source)), DataFrames.DataFrame)
end

end
