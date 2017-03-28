immutable EnumerableIterable{T,S} <: Enumerable
    source::S
end

@traitfn function query{X; IsIterable{X}}(source::X)
    typed_source = getiterator(source)
	T = eltype(typed_source)
    S = typeof(typed_source)

    source_enumerable = EnumerableIterable{T,S}(typed_source)

    return convert2datavalue(source_enumerable)
end

Base.eltype{T,S}(iter::EnumerableIterable{T,S}) = T

Base.eltype{T,S}(iter::Type{EnumerableIterable{T,S}}) = T

function start{T,S}(iter::EnumerableIterable{T,S})
    return start(iter.source)
end

function next{T,S}(iter::EnumerableIterable{T,S}, state)
    source_value, source_next_state = next(iter.source, state)
    return source_value, source_next_state
end

function done{T,S}(iter::EnumerableIterable{T,S}, state)
    return done(iter.source, state)
end

