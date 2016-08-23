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
