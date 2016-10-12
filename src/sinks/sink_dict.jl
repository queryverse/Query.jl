function collect{T<:Pair}(enumerable::Enumerable{T}, ::Type{Dict})
    return Dict(enumerable)
end
