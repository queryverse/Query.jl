function Base.collect(enumerable::QueryOperators.Enumerable, ::Type{T}) where {T}
    return T(enumerable)
end

function Base.collect(enumerable::QueryOperators.Enumerable, f::Function)
    return f(enumerable)
end
