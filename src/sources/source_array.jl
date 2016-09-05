# TODO Make work with multidimensional arrays
immutable EnumerableArray{T,S} <: Enumerable{T}
    source::S
end

function query{TS,N}(source::Array{TS,N})
    return EnumerableArray{TS,Array{TS,N}}(source)
end

function start{T,S}(iter::EnumerableArray{T,S})
    return 1
end

function next{T,S}(iter::EnumerableArray{T,S}, state)
    return iter.source[state], state+1
end

function done{T,S}(iter::EnumerableArray{T,S}, state)
    return state>length(iter.source)
end
