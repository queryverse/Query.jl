immutable EnumerableSelectMany{T,SO,CS<:Function,RS<:Function} <: Enumerable
    source::SO
    collectionSelector::CS
    resultSelector::RS
end

Base.eltype{T,SO,CS,RS}(iter::EnumerableSelectMany{T,SO,CS,RS}) = T

Base.eltype{T,SO,CS,RS}(iter::Type{EnumerableSelectMany{T,SO,CS,RS}}) = T

# TODO Make sure this is actually correct. We might have to be more selective,
# i.e. only scan arguments for certain types of expression etc.
function expr_contains_ref_to(expr::Expr, var_name::Symbol)
    for sub_expr in expr.args
        if isa(sub_expr, Symbol)
            if sub_expr==var_name
                return true
            end
        else
            test_sub = expr_contains_ref_to(sub_expr, var_name)
            if test_sub
                return true
            end
        end
    end
    return false
end

function expr_contains_ref_to(expr::Symbol, var_name::Symbol)
    return expr==var_name
end

function expr_contains_ref_to(expr::QuoteNode, var_name::Symbol)
    return expr==var_name
end

function select_many(source::Enumerable, f_collectionSelector::Function, collectionSelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    TS = eltype(source)
    # First detect whether the collectionSelector return value depends at all
    # on the value of the anonymous function argument
    anon_var = collectionSelector.args[1]
    body = collectionSelector.args[2].args[2]
    crossJoin = !expr_contains_ref_to(body, anon_var)

    if crossJoin
        inner_collection = f_collectionSelector(nothing)
        input_type_collection_selector = typeof(inner_collection)
        TCE = input_type_collection_selector.parameters[1]
    else
        input_type_collection_selector = Base.return_types(f_collectionSelector, (TS,))[1]
        TCE = typeof(input_type_collection_selector)==Union || input_type_collection_selector==Any ? Any : input_type_collection_selector.parameters[1]
    end

    T = Base.return_types(f_resultSelector, (TS,TCE))[1]
    SO = typeof(source)

    CS = typeof(f_collectionSelector)
    RS = typeof(f_resultSelector)

    return EnumerableSelectMany{T,SO,CS,RS}(source,f_collectionSelector,f_resultSelector)
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
