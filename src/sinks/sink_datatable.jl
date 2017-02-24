@require DataTables begin
using NullableArrays

@generated function _filldt(columns, enumerable)
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

function collect(enumerable::Enumerable, ::Type{DataTables.DataTable})
    T = eltype(enumerable)
    if !(T<:NamedTuple)
        error("Can only collect a NamedTuple iterator into a DataFrame")
    end

    columns = []
    for t in T.types
        if isa(t, TypeVar)
            push!(columns, Array(Any,0))
        elseif t <: Nullable
            push!(columns, NullableArray(t.parameters[1],0))
        else
            push!(columns, Array(t,0))
        end
    end
    df = DataTables.DataTable(columns, fieldnames(T))
    _filldt((df.columns...), enumerable)
    return df
end

function collect{TS,Provider}(source::Queryable{TS,Provider}, ::Type{DataTables.DataTable})
    collect(query(collect(source)), DataTables.DataTable)
end

end
