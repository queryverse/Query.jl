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
