immutable EnumerableSelect{T, S, Q<:Function} <: Enumerable
    source::S
    f::Q
end

IterableTables.iteratorsize2{T,S,Q}(::Type{EnumerableSelect{T,S,Q}}) = IterableTables.iteratorsize2(S)

Base.iteratorsize{T,S,Q}(::Type{EnumerableSelect{T,S,Q}}) = Base.iteratorsize(S)

Base.eltype{T,S,Q}(iter::EnumerableSelect{T,S,Q}) = T

Base.eltype{T,S,Q}(iter::Type{EnumerableSelect{T,S,Q}}) = T

Base.length{T,S,Q}(iter::EnumerableSelect{T,S,Q}) = length(iter.source)

Base.length{T,S,Q}(iter::EnumerableSelect{T,S,Q}, state) = length(iter.source, state)

function select(source::Enumerable, f::Function, f_expr::Expr)
    TS = eltype(source)
    T = Base.return_types(f, (TS,))[1]
    S = typeof(source)
    Q = typeof(f)
    return EnumerableSelect{T,S,Q}(source, f)
end

macro select_internal(source, f)
    q = Expr(:quote, f)
    :(select($(esc(source)), $(esc(f)), $(esc(q))))
end

macro select(source, f)
    q = Expr(:quote, f)
    :(select(Query.query($(esc(source))), $(esc(f)), $(esc(q))))
end

function start{T,S,Q}(iter::EnumerableSelect{T,S,Q})
    s = start(iter.source)
    return s
end

function next{T,S,Q}(iter::EnumerableSelect{T,S,Q}, s)
    x = next(iter.source, s)
    v = x[1]
    s_new = x[2]
    v_new = iter.f(v)::T
    return v_new, s_new
end

function done{T,S,Q}(iter::EnumerableSelect{T,S,Q}, state)
    return done(iter.source, state)
end
