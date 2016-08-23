immutable EnumerableSelect{T, S, Q} <: Enumerable{T}
    source::S
    f::Q
end

function select{TS}(source::Enumerable{TS}, f::Function, f_expr::Expr)
    T = Base.return_types(f, (TS,))[1]
    S = typeof(source)
    return EnumerableSelect{T,S,FunctionWrapper{T,Tuple{TS}}}(source, f)
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
