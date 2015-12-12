@generated function _filldf(columns, enumerable)
    n = length(columns.types)
    push_exprs = Expr(:block)
    for i in 1:n
        ex = :( push!(columns[$i], i[$i]) )
        push!(push_exprs.args, ex)
    end

    quote
        for i in enumerable
            $push_exprs
        end
    end
end

function collect{T<:NamedTuple}(enumerable::Enumerable{T}, ::Type{DataFrame})
    columns = []
    for t in T.types
        push!(columns, Array(t,0))
    end
    df = DataFrame(columns, fieldnames(T))
    _filldf((df.columns...), enumerable)
    return df
end

function collect{T}(enumerable::Enumerable{T})
    ret = Array(T,0)
    for i in enumerable
        push!(ret, i)
    end
    return ret
end

function collect{TS,Provider}(source::Queryable{TS,Provider})
    collect(Provider, source)
end

function collect{TS,Provider}(source::Queryable{TS,Provider}, ::Type{DataFrame})
    collect(query(collect(source)), DataFrame)
end
