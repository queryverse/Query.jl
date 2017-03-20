# TODO Make work with multidimensional arrays
immutable ArrayIterator{T,S}
    source::S
end

Base.eltype{T,S}(iter::ArrayIterator{T,S}) = T

Base.eltype{T,S}(iter::Type{ArrayIterator{T,S}}) = T

function getiterator{TS,N}(source::Array{TS,N})
    return ArrayIterator{TS,Array{TS,N}}(source)
end

function start{T,S}(iter::ArrayIterator{T,S})
    return 1
end

function next{T,S}(iter::ArrayIterator{T,S}, state)
    return iter.source[state], state+1
end

function done{T,S}(iter::ArrayIterator{T,S}, state)
    return state>length(iter.source)
end
