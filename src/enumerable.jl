abstract Enumerable{T}

# T is the type of the elements produced by this iterator
immutable EnumerableWhere{T,S,Q} <: Enumerable{T}
    source::S
    filter::Q
end

immutable EnumerableWhereState{T,S}
    done::Bool
    next_value::Nullable{T}
    source_state::S
end

function where{T}(source::Enumerable{T}, filter::Function)
    S = typeof(source)
    return EnumerableWhere{T,S,FunctionWrapper{Bool,Tuple{T}}}(source, filter)
end

function where{T}(source::Enumerable{T}, filter_expr::Expr)
    filter = eval(filter_expr)
    S = typeof(source)
    return EnumerableWhere{T,S,FunctionWrapper{Bool,Tuple{T}}}(source, filter)
end

function start{T,S,Q}(iter::EnumerableWhere{T,S,Q})
    s = start(iter.source)
    while !done(iter.source, s)
        v,t = next(iter.source, s)
        if iter.filter(v)
            return EnumerableWhereState(false, Nullable(v), t)
        end
        s = t
    end
    # The s we return here is fake, just to make sure we
    # return something of the right type
    return EnumerableWhereState(true, Nullable{T}(), s)
end

function next{T,S,Q}(iter::EnumerableWhere{T,S,Q}, state)
    v = get(state.next_value)
    s = state.source_state
    while !done(iter.source,s)
        temp = next(iter.source,s)
        w = temp[1]
        t = temp[2]
        if iter.filter(w)::Bool
            temp2 = Nullable(w)
            new_state = EnumerableWhereState(false, temp2, t)
            return v, new_state
        end
        s=t
    end
    # The s we return here is fake, just to make sure we
    # return something of the right type
    v, EnumerableWhereState(true,Nullable{T}(), s)
end

done{T,S,Q}(f::EnumerableWhere{T,S,Q}, state) = state.done

immutable EnumerableSelect{T, S, Q} <: Enumerable{T}
    source::S
    f::Q
end

function select{TS}(source::Enumerable{TS}, f::Function)
    T = Base.return_types(f, (TS,))[1]
    S = typeof(source)
    return EnumerableSelect{T,S,FunctionWrapper{T,Tuple{TS}}}(source, f)
end

function select{TS}(source::Enumerable{TS}, f_expr::Expr)
    f = eval(f_expr)
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
