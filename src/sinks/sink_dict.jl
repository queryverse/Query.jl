function collect(enumerable::Enumerable, ::Type{Dict})
    T = eltype(enumerable)
    if !(T<:Pair)
        error("Can only collect a Pair iterator into a Dict.")
    end
    return Dict(enumerable)
end
