function collect{T}(enumerable::Enumerable, ::Type{T})
    return T(enumerable)
end

function collect(enumerable::Enumerable, f::Function)
    return f(enumerable)
end

function collect{T, TS,Provider}(source::Queryable{TS,Provider}, ::Type{T})
    collect(QueryOperators.query(collect(source)), T)
end
