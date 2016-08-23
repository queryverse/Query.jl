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
