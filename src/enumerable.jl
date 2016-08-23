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
    elements = Array(T,0)
    for i in iter.source
        push!(elements, i)
    end

    sort!(elements, by=iter.keySelector, rev=iter.descending)

    return elements, 1
end

function next{T,S,KS,TKS}(iter::EnumerableOrderby{T,S,KS,TKS}, state)
    elements = state[1]
    i = state[2]
    return elements[i], (elements, i+1)
end

done{T,S,KS,TKS}(f::EnumerableOrderby{T,S,KS,TKS}, state) = state[2] > length(state[1])

immutable EnumerableThenBy{T,S,KS,TKS} <: Enumerable{T}
    source::S
    keySelector::KS
    descending::Bool
end

function thenby{T}(source::Enumerable{T}, f::Function, f_expr::Expr)
    TKS = Base.return_types(f, (T,))[1]
    return EnumerableThenBy{T,typeof(source), FunctionWrapper{TKS,Tuple{T}},TKS}(source, f, false)
end

function thenby_descending{T}(source::Enumerable{T}, f::Function, f_expr::Expr)
    TKS = Base.return_types(f, (T,))[1]
    return EnumerableThenBy{T,typeof(source), FunctionWrapper{TKS,Tuple{T}},TKS}(source, f, true)
end

# TODO This should be changed to a lazy implementation
function start{T,S,KS,TKS}(iter::EnumerableThenBy{T,S,KS,TKS})
    # Find start of ordering sequence
    source = iter.source
    keySelectors = [source.keySelector,iter.keySelector]
    directions = [source.descending, iter.descending]
    while !isa(source, EnumerableOrderby)
        source = source.source
        insert!(keySelectors,1,source.keySelector)
        insert!(directions,1,source.descending)
    end
    keySelector = element->[i(element) for i in keySelectors]

    lt = (t1,t2) -> begin
        n1, n2 = length(t1), length(t2)
        for i = 1:min(n1, n2)
            a, b = t1[i], t2[i]
            descending = directions[i]
            if !isequal(a, b)
                return descending ? !isless(a, b) : isless(a, b)
            end
        end
        return n1 < n2
    end

    elements = Array(T,0)
    for i in source
        push!(elements, i)
    end

    sort!(elements, by=keySelector, lt=lt)

    return elements, 1
end

function next{T,S,KS,TKS}(iter::EnumerableThenBy{T,S,KS,TKS}, state)
    elements = state[1]
    i = state[2]
    return elements[i], (elements, i+1)
end

done{T,S,KS,TKS}(f::EnumerableThenBy{T,S,KS,TKS}, state) = state[2] > length(state[1])

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

    inner_dict = OrderedDict{TKeyOuter,Array{TI,1}}()
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

immutable EnumerableGroupJoin{T,TKey,TI,SO,SI,OKS,IKS,RS} <: Enumerable{T}
    outer::SO
    inner::SI
    outerKeySelector::OKS
    innerKeySelector::IKS
    resultSelector::RS
end

function group_join{TO,TI}(outer::Enumerable{TO}, inner::Enumerable{TI}, f_outerKeySelector::Function, outerKeySelector::Expr, f_innerKeySelector::Function, innerKeySelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    TKeyOuter = Base.return_types(f_outerKeySelector, (TO,))[1]
    TKeyInner = Base.return_types(f_innerKeySelector, (TI,))[1]

    if TKeyOuter!=TKeyInner
        error("The keys in the join clause have different types, $TKeyOuter and $TKeyInner.")
    end

    SO = typeof(outer)
    SI = typeof(inner)

    T = Base.return_types(f_resultSelector, (TO,Array{TI,1}))[1]

    return EnumerableGroupJoin{T,TKeyOuter,TI,SO,SI,FunctionWrapper{TKeyOuter,Tuple{TO}},FunctionWrapper{TKeyInner,Tuple{TI}},FunctionWrapper{T,Tuple{TO,Array{TI,1}}}}(outer,inner,f_outerKeySelector,f_innerKeySelector,f_resultSelector)
end

# TODO This should be changed to a lazy implementation
function start{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS}(iter::EnumerableGroupJoin{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS})
    results = Array(T,0)

    inner_dict = OrderedDict{TKeyOuter,Array{TI,1}}()
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
            g = inner_dict[outerKey]
        else
            g = Array(TI,0)
        end
        push!(results, iter.resultSelector(i,g))
    end

    return results,1
end

function next{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS}(iter::EnumerableGroupJoin{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS},state)
    results = state[1]
    curr_index = state[2]
    return results[curr_index], (results, curr_index+1)
end

function done{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS}(iter::EnumerableGroupJoin{T,TKeyOuter,TI,SO,SI,OKS,IKS,RS},state)
    results = state[1]
    curr_index = state[2]
    return curr_index > length(results)
end

immutable EnumerableSelectMany{T,SO,CS,RS} <: Enumerable{T}
    source::SO
    collectionSelector::CS
    resultSelector::RS
end

function select_many{TS}(source::Enumerable{TS}, f_collectionSelector::Function, collectionSelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    # First detect whether the collectionSelector return value depends at all
    # on the value of the anonymous function argument
    anon_var = collectionSelector.args[1]
    body = collectionSelector.args[2].args[2]
    # TODO improve this test by traversing the whole expression tree looking for any occurance
    # of anon_var
    crossJoin = !(isa(body, Expr) && body.head==:. && body.args[1]==anon_var)

    if crossJoin
        inner_collection = f_collectionSelector(nothing)
        TCE = typeof(inner_collection).parameters[1]
    else
        TCE = Base.return_types(f_collectionSelector, (TS,))[1].parameters[1]
    end

    T = Base.return_types(f_resultSelector, (TS,TCE))[1]
    SO = typeof(source)

    return EnumerableSelectMany{T,SO,FunctionWrapper{Enumerable{TCE},Tuple{TS}},FunctionWrapper{T,Tuple{TS,TCE}}}(source,f_collectionSelector,f_resultSelector)
end

# TODO This should be changed to a lazy implementation
function start{T,SO,CS,RS}(iter::EnumerableSelectMany{T,SO,CS,RS})
    results = Array(T,0)
    for i in iter.source
        for j in iter.collectionSelector(i)
            push!(results,iter.resultSelector(i,j))
        end
    end

    return results,1
end

function next{T,SO,CS,RS}(iter::EnumerableSelectMany{T,SO,CS,RS},state)
    results = state[1]
    curr_index = state[2]
    return results[curr_index], (results, curr_index+1)
end

function done{T,SO,CS,RS}(iter::EnumerableSelectMany{T,SO,CS,RS},state)
    results = state[1]
    curr_index = state[2]
    return curr_index > length(results)
end

immutable EnumerableGroupBySimple{T,TKey,TS,SO,ES} <: Enumerable{T}
    source::SO
    elementSelector::ES
end

immutable Grouping{TKey,T}
    key::TKey
    elements::Array{T,1}
end

function group_by{TS}(source::Enumerable{TS}, f_elementSelector::Function, elementSelector::Expr)
    TKey = Base.return_types(f_elementSelector, (TS,))[1]

    SO = typeof(source)

    T = Grouping{TKey,TS}

    return EnumerableGroupBySimple{T,TKey,TS,SO,FunctionWrapper{TKey,Tuple{TS}}}(source,f_elementSelector)
end

# TODO This should be rewritten as a lazy iterator
function start{T,TKey,TS,SO,ES}(iter::EnumerableGroupBySimple{T,TKey,TS,SO,ES})
    result = OrderedDict{TKey,T}()
    for i in iter.source
        key = iter.elementSelector(i)
        if !haskey(result, key)
            result[key] = Grouping(key,Array(TS,0))
        end
        push!(result[key].elements,i)
    end
    return collect(values(result)),1
end

function next{T,TKey,TS,SO,ES}(iter::EnumerableGroupBySimple{T,TKey,TS,SO,ES}, state)
    results = state[1]
    curr_index = state[2]
    return results[curr_index], (results, curr_index+1)
end

function done{T,TKey,TS,SO,ES}(iter::EnumerableGroupBySimple{T,TKey,TS,SO,ES}, state)
    results = state[1]
    curr_index = state[2]
    return curr_index > length(results)
end

immutable EnumerableGroupBy{T,TKey,TR,SO,ES,RS} <: Enumerable{T}
    source::SO
    elementSelector::ES
    resultSelector::RS
end

function group_by{TS}(source::Enumerable{TS}, f_elementSelector::Function, elementSelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    TKey = Base.return_types(f_elementSelector, (TS,))[1]

    SO = typeof(source)

    TR = Base.return_types(f_resultSelector, (TS,))[1]

    T = Grouping{TKey,TR}

    return EnumerableGroupBy{T,TKey,TR,SO,FunctionWrapper{TKey,Tuple{TS}},FunctionWrapper{TR,Tuple{TS}}}(source,f_elementSelector,f_resultSelector)
end

# TODO This should be rewritten as a lazy iterator
function start{T,TKey,TR,SO,ES}(iter::EnumerableGroupBy{T,TKey,TR,SO,ES})
    result = OrderedDict{TKey,T}()
    for i in iter.source
        key = iter.elementSelector(i)
        if !haskey(result, key)
            result[key] = Grouping(key,Array(TR,0))
        end
        push!(result[key].elements,iter.resultSelector(i))
    end
    return collect(values(result)),1
end

function next{T,TKey,TR,SO,ES}(iter::EnumerableGroupBy{T,TKey,TR,SO,ES}, state)
    results = state[1]
    curr_index = state[2]
    return results[curr_index], (results, curr_index+1)
end

function done{T,TKey,TR,SO,ES}(iter::EnumerableGroupBy{T,TKey,TR,SO,ES}, state)
    results = state[1]
    curr_index = state[2]
    return curr_index > length(results)
end