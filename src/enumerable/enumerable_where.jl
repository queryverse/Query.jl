# T is the type of the elements produced by this iterator
immutable EnumerableWhere{T,S,Q} <: Enumerable
    source::S
    filter::Q
end

Base.eltype{T,S,Q}(iter::EnumerableWhere{T,S,Q}) = T

immutable EnumerableWhereState{T,S}
    done::Bool
    next_value::Nullable{T}
    source_state::S
end

function where(source::Enumerable, filter::Function, filter_expr::Expr)
    T = eltype(source)
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
