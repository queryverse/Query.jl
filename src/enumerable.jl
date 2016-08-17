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

function where{T}(source::Enumerable{T}, filter::Function, filter_expr::Expr)
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

immutable EnumerableOrderby{T,S,KS,TKS} <: Enumerable{T}
    source::S
    keySelector::KS
    descending::Bool
end

function orderby{T}(source::Enumerable{T}, f::Function, f_expr::Expr)
    TKS = Base.return_types(f, (T,))[1]
    return EnumerableOrderby{T,typeof(source), FunctionWrapper{TKS,Tuple{T}},TKS}(source, f, false)
end

function orderby_descending{T}(source::Enumerable{T}, f::Function, f_expr::Expr)
    TKS = Base.return_types(f, (T,))[1]
    return EnumerableOrderby{T,typeof(source), FunctionWrapper{TKS,Tuple{T}},TKS}(source, f, true)
end


# TODO This should be changed to a lazy implementation
function start{T,S,KS,TKS}(iter::EnumerableOrderby{T,S,KS,TKS})
    dict = Dict{TKS,T}()
    for i in iter.source
        dict[iter.keySelector(i)] = i
    end

    sortedDict = SortedDict(dict, iter.descending ? Base.Reverse : Base.Forward)
    return sortedDict, start(sortedDict)
end

function next{T,S,KS,TKS}(iter::EnumerableOrderby{T,S,KS,TKS}, state)
    v, new_state = next(state[1], state[2])
    return v[2], (state[1], new_state)
end

done{T,S,KS,TKS}(f::EnumerableOrderby{T,S,KS,TKS}, state) = done(state[1], state[2])

immutable EnumerableJoin{T,TKey,TI,SO,SI,OKS,IKS,RS} <: Enumerable{T}
    outer::SO
    inner::SI
    outerKeySelector::OKS
    innerKeySelector::IKS
    resultSelector::RS
end

function join{TO,TI}(outer::Enumerable{TO}, inner::Enumerable{TI}, f_outerKeySelector::Function, outerKeySelector::Expr, f_innerKeySelector::Function, innerKeySelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    TKeyOuter = Base.return_types(f_outerKeySelector, (TO,))[1]
    TKeyInner = Base.return_types(f_innerKeySelector, (TI,))[1]

    if TKeyOuter!=TKeyInner
        error("The keys in the join clause have different types, $TKeyOuter and $TKeyInner.")
    end

    SO = typeof(outer)
    SI = typeof(inner)

    T = Base.return_types(f_resultSelector, (TO,TI))[1]

    return EnumerableJoin{T,TKeyOuter,TI,SO,SI,FunctionWrapper{TKeyOuter,Tuple{TO}},FunctionWrapper{TKeyInner,Tuple{TI}},FunctionWrapper{T,Tuple{TO,TI}}}(outer,inner,f_outerKeySelector,f_innerKeySelector,f_resultSelector)
end

# TODO This should be changed to a lazy implementation
function start{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS}(iter::EnumerableJoin{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS})
    results = Array(T,0)

    inner_dict = Dict{TKeyOuter,Array{TI,1}}()
    for i in iter.inner
        key = iter.innerKeySelector(i)
        if !haskey(inner_dict, key)
            inner_dict[key] = Array(TI,0)
        end
        push!(inner_dict[key], i)
    end

    for i in iter.outer
        outerKey = iter.outerKeySelector(i)
        if haskey(inner_dict,outerKey)
            for j in inner_dict[outerKey]
                push!(results, iter.resultSelector(i,j))
            end
        end
    end

    return results,1
end

function next{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS}(iter::EnumerableJoin{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS},state)
    results = state[1]
    curr_index = state[2]
    return results[curr_index], (results, curr_index+1)
end

function done{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS}(iter::EnumerableJoin{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS},state)
    results = state[1]
    curr_index = state[2]
    return curr_index > length(results)
end
