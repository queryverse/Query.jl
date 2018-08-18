function Base.collect(enumerable::Enumerable, ::Type{T}) where {T}
    return T(enumerable)
end

function Base.collect(enumerable::Enumerable, f::Function)
    return f(enumerable)
end
