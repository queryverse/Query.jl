immutable EnumerableDefaultIfEmpty{T,S} <: Enumerable{T}
    source::S
    default_value::T
end

function default_if_empty{S}(source::S)
    T = eltype(source)

    if T<:NamedTuple
        if !all(i->i<:NAable,T.parameters)
            error("default_if_empty requires a default value if the source element is a NamedTuple and at least one of its fields is not a NAable.")
        end
        default_value = T([i() for i in T.parameters]...)
    else
        if !(T<:NAable)
            error("default_if_empty requires a default value if the source element is not a NAable.")
        end
        default_value = T()
    end

    return EnumerableDefaultIfEmpty{T,S}(source, default_value)
end


function default_if_empty{S,TD}(source::S, default_value::TD)
    T = eltype(source)
    if T!=TD
        error("The default value must have the same type as the elements from the source.")
    end
    return EnumerableDefaultIfEmpty{T,S}(source, default_value)
end

function start{T,S}(iter::EnumerableDefaultIfEmpty{T,S})
    s = start(iter.source)
    return s, done(iter.source, s) ? Nullable(true) : Nullable{Bool}()
end

function next{T,S}(iter::EnumerableDefaultIfEmpty{T,S}, state)
    (s,status) = state

    if isnull(status)
        x = next(iter.source, s)
        v = x[1]
        s_new = x[2]
        return v, (s_new, Nullable{Bool}())
    elseif get(status)
        return iter.default_value, (s, Nullable(false))
    else !get(status)
        error()
    end
end

function done{T,S}(iter::EnumerableDefaultIfEmpty{T,S}, state)
    (s,status) = state
    if isnull(status)
        return done(iter.source, s)
    else
        return !get(status)
    end
end
