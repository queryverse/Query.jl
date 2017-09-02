immutable EnumerableGroupBySimple{T,TKey,TS,SO,ES<:Function} <: Enumerable
    source::SO
    elementSelector::ES
end

immutable Grouping{TKey,T} <: AbstractArray{T,1}
    key::TKey
    elements::Array{T,1}
end

import Base.size
size{TKey,T}(A::Grouping{TKey,T}) = size(A.elements)
import Base.getindex
getindex{TKey,T}(A::Grouping{TKey,T},i) = A.elements[i]
import Base.length
length{TKey,T}(A::Grouping{TKey,T}) = length(A.elements)

Base.eltype{T,TKey,TS,SO,ES}(iter::EnumerableGroupBySimple{T,TKey,TS,SO,ES}) = T

Base.eltype{T,TKey,TS,SO,ES}(iter::Type{EnumerableGroupBySimple{T,TKey,TS,SO,ES}}) = T

function group_by(source::Enumerable, f_elementSelector::Function, elementSelector::Expr)
    TS = eltype(source)
    TKey = Base._return_type(f_elementSelector, Tuple{TS,})

    SO = typeof(source)

    T = Grouping{TKey,TS}

    ES = typeof(f_elementSelector)

    return EnumerableGroupBySimple{T,TKey,TS,SO,ES}(source,f_elementSelector)
end

# TODO This should be rewritten as a lazy iterator
function start{T,TKey,TS,SO,ES}(iter::EnumerableGroupBySimple{T,TKey,TS,SO,ES})
    result = OrderedDict{TKey,T}()
    for i in iter.source
        key = iter.elementSelector(i)
        if !haskey(result, key)
            result[key] = Grouping(key,Array{TS}(0))
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

immutable EnumerableGroupBy{T,TKey,TR,SO,ES<:Function,RS<:Function} <: Enumerable
    source::SO
    elementSelector::ES
    resultSelector::RS
end

Base.eltype{T,TKey,TR,SO,ES}(iter::EnumerableGroupBy{T,TKey,TR,SO,ES}) = T

Base.eltype{T,TKey,TR,SO,ES}(iter::Type{EnumerableGroupBy{T,TKey,TR,SO,ES}}) = T

function group_by(source::Enumerable, f_elementSelector::Function, elementSelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    TS = eltype(source)
    TKey = Base._return_type(f_elementSelector, Tuple{TS,})

    SO = typeof(source)

    TR = Base._return_type(f_resultSelector, Tuple{TS,})

    T = Grouping{TKey,TR}

    ES = typeof(f_elementSelector)
    RS = typeof(f_resultSelector)

    return EnumerableGroupBy{T,TKey,TR,SO,ES,RS}(source,f_elementSelector,f_resultSelector)
end

# TODO This should be rewritten as a lazy iterator
function start{T,TKey,TR,SO,ES}(iter::EnumerableGroupBy{T,TKey,TR,SO,ES})
    result = OrderedDict{TKey,T}()
    for i in iter.source
        key = iter.elementSelector(i)
        if !haskey(result, key)
            result[key] = Grouping(key,Array{TR}(0))
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

macro group_by_internal(source,elementSelector,resultSelector)
	q_elementSelector = Expr(:quote, elementSelector)
	q_resultSelector = Expr(:quote, resultSelector)

	:(group_by($(esc(source)), $(esc(elementSelector)), $(esc(q_elementSelector)), $(esc(resultSelector)), $(esc(q_resultSelector))))
end

macro group_by_internal_simple(source,elementSelector)
	q_elementSelector = Expr(:quote, elementSelector)

	:(group_by($(esc(source)), $(esc(elementSelector)), $(esc(q_elementSelector))))
end

macro groupby(source, elementSelector, resultSelector)
    elementSelector_as_anonym_func = helper_replace_anon_func_syntax(elementSelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

 	q_elementSelector = Expr(:quote, elementSelector_as_anonym_func)
	q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :(group_by(Query.query($(esc(source))), $(esc(elementSelector_as_anonym_func)), $(esc(q_elementSelector)), $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)))) |>
        helper_namedtuples_replacement |>
        helper_replace_field_extraction_syntax
end

macro groupby(elementSelector, resultSelector)
    elementSelector_as_anonym_func = helper_replace_anon_func_syntax(elementSelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

 	q_elementSelector = Expr(:quote, elementSelector_as_anonym_func)
	q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :( i -> group_by(Query.query(i), $(esc(elementSelector_as_anonym_func)), $(esc(q_elementSelector)), $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)))) |>
        helper_namedtuples_replacement |>
        helper_replace_field_extraction_syntax
end

end
