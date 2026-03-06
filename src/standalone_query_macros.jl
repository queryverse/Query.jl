macro count(source, f)
    q = Expr(:quote, f)
    :(QueryOperators.count(QueryOperators.query($(esc(source))), $(esc(f)), $(esc(q))))
end

macro count(source)
    :(QueryOperators.count(QueryOperators.query($(esc(source)))))
end

macro count()
    :( i -> QueryOperators.count(QueryOperators.query(i)))
end

macro groupby(source, elementSelector, resultSelector)
    elementSelector_as_anonym_func = helper_replace_anon_func_syntax(elementSelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

 	q_elementSelector = Expr(:quote, elementSelector_as_anonym_func)
	q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :(QueryOperators.groupby(QueryOperators.query($(esc(source))), $(esc(elementSelector_as_anonym_func)), $(esc(q_elementSelector)), $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)))) |>
        helper_namedtuples_replacement
end

macro groupby(elementSelector, resultSelector)
    elementSelector_as_anonym_func = helper_replace_anon_func_syntax(elementSelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

 	q_elementSelector = Expr(:quote, elementSelector_as_anonym_func)
	q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :( i -> QueryOperators.groupby(QueryOperators.query(i), $(esc(elementSelector_as_anonym_func)), $(esc(q_elementSelector)), $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)))) |>
        helper_namedtuples_replacement
end

macro groupby(elementSelector)
    elementSelector_as_anonym_func = helper_replace_anon_func_syntax(elementSelector)
    resultSelector_as_anonym_func = :(i->i)

 	q_elementSelector = Expr(:quote, elementSelector_as_anonym_func)
	q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :( i -> QueryOperators.groupby(QueryOperators.query(i), $(esc(elementSelector_as_anonym_func)), $(esc(q_elementSelector)), $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)))) |>
        helper_namedtuples_replacement
end

macro groupjoin(outer, inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :(QueryOperators.groupjoin(QueryOperators.query($(esc(outer))), 
            QueryOperators.query($(esc(inner))), 
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro groupjoin(inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :( outer -> QueryOperators.groupjoin(QueryOperators.query(outer), 
            QueryOperators.query($(esc(inner))), 
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro join(outer, inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :(QueryOperators.join(QueryOperators.query($(esc(outer))), 
            QueryOperators.query($(esc(inner))), 
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro join(inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :( outer -> QueryOperators.join(QueryOperators.query(outer), 
            QueryOperators.query($(esc(inner))), 
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro orderby(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.orderby(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro orderby(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, helper_replace_anon_func_syntax(f_as_anonym_func))
    return :( i -> QueryOperators.orderby(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro orderby_descending(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.orderby_descending(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro orderby_descending(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, helper_replace_anon_func_syntax(f_as_anonym_func))
    return :( i -> QueryOperators.orderby_descending(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro thenby(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.thenby($(esc(source)), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro thenby(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, helper_replace_anon_func_syntax(f_as_anonym_func))
    return :( i -> QueryOperators.thenby(i, $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro thenby_descending(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.thenby_descending($(esc(source)), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro thenby_descending(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, helper_replace_anon_func_syntax(f_as_anonym_func))
    return :( i -> QueryOperators.thenby_descending(i, $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro map(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.map(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro map(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i-> QueryOperators.map(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q))) ) |>
        helper_namedtuples_replacement
end

macro mapmany(source, collectionSelector,resultSelector)
    collectionSelector_as_anonym_func = helper_replace_anon_func_syntax(collectionSelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    collectionSelector_q = Expr(:quote, collectionSelector_as_anonym_func)
    resultSelector_q = Expr(:quote, resultSelector_as_anonym_func)

    return :(QueryOperators.mapmany(QueryOperators.query($(esc(source))),
            $(esc(collectionSelector_as_anonym_func)), $(esc(collectionSelector_q)),
            $(esc(resultSelector_as_anonym_func)), $(esc(resultSelector_q)))) |>
        helper_namedtuples_replacement
end

macro mapmany(collectionSelector,resultSelector)
    collectionSelector_as_anonym_func = helper_replace_anon_func_syntax(collectionSelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    collectionSelector_q = Expr(:quote, collectionSelector_as_anonym_func)
    resultSelector_q = Expr(:quote, resultSelector_as_anonym_func)

    return :( i-> QueryOperators.mapmany(QueryOperators.query(i),
            $(esc(collectionSelector_as_anonym_func)), $(esc(collectionSelector_q)),
            $(esc(resultSelector_as_anonym_func)), $(esc(resultSelector_q)))) |>
        helper_namedtuples_replacement
end

macro filter(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.filter(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro filter(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, helper_replace_anon_func_syntax(f_as_anonym_func))
    return :( i -> QueryOperators.filter(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro take(source, n)
    return :(QueryOperators.take(QueryOperators.query($(esc(source))), $(esc(n))))
end

macro take(n)
    return :( i -> QueryOperators.take(QueryOperators.query(i), $(esc(n))))
end

macro drop(source, n)
    return :(QueryOperators.drop(QueryOperators.query($(esc(source))), $(esc(n))))
end

macro drop(n)
    return :( i -> QueryOperators.drop(QueryOperators.query(i), $(esc(n))))
end

macro unique()
    return :( i -> QueryOperators.unique(QueryOperators.query(i), q->q, :(q->q))) |>
        helper_namedtuples_replacement
end

macro unique(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, helper_replace_anon_func_syntax(f_as_anonym_func))
    return :( i -> QueryOperators.unique(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

# Returns true when a macro argument looks like a column selector (not a data source).
function _is_pivot_selector(arg)
    arg isa QuoteNode && return true
    arg isa Int && return true
    # Negative selector: -:col or -(pred(...))
    if arg isa Expr && arg.head == :call && length(arg.args) == 2 && arg.args[1] == :-
        return true
    end
    # Logical NOT: !(pred(...))
    if arg isa Expr && arg.head == :call && length(arg.args) == 2 && arg.args[1] == :!
        return true
    end
    # Predicate call: startswith("x"), endswith("x"), occursin("x")
    if arg isa Expr && arg.head == :call && length(arg.args) == 2 &&
            arg.args[1] ∈ (:startswith, :endswith, :occursin)
        return true
    end
    # Range: :a::b or 1:3  (parsed as Expr(:call, :(:), a, b))
    if arg isa Expr && arg.head == :call && length(arg.args) == 3 &&
            arg.args[1] == Symbol(":")
        return true
    end
    # everything()
    arg isa Expr && string(arg) == "everything()" && return true
    return false
end

# Converts a single selector AST argument into a (op, arg) instruction tuple.
function _pivot_selector_to_instruction(arg)
    # :col — include by name
    if arg isa QuoteNode
        return (:include_name, arg.value)
    end
    # Positive integer — include by position
    if arg isa Int && arg > 0
        return (:include_position, arg)
    end
    # Negative integer — exclude by position
    if arg isa Int && arg < 0
        return (:exclude_position, -arg)
    end
    # everything() — include all
    if arg isa Expr && string(arg) == "everything()"
        return (:include_all, :_)
    end
    if arg isa Expr
        # -:col or -(pred(...))
        if arg.head == :call && length(arg.args) == 2 && arg.args[1] == :-
            inner = arg.args[2]
            if inner isa QuoteNode
                return (:exclude_name, inner.value)
            elseif inner isa Expr && inner.head == :call && length(inner.args) == 2 &&
                    inner.args[1] ∈ (:startswith, :endswith, :occursin)
                fn, str = inner.args[1], inner.args[2]
                str isa AbstractString || error("@pivot_longer: argument to $fn must be a string literal")
                return (Symbol("exclude_$(fn)"), Symbol(str))
            end
        end
        # !(pred(...))
        if arg.head == :call && length(arg.args) == 2 && arg.args[1] == :!
            inner = arg.args[2]
            if inner isa Expr && inner.head == :call && length(inner.args) == 2 &&
                    inner.args[1] ∈ (:startswith, :endswith, :occursin)
                fn, str = inner.args[1], inner.args[2]
                str isa AbstractString || error("@pivot_longer: argument to $fn must be a string literal")
                return (Symbol("exclude_$(fn)"), Symbol(str))
            end
        end
        # startswith("x"), endswith("x"), occursin("x")
        if arg.head == :call && length(arg.args) == 2 &&
                arg.args[1] ∈ (:startswith, :endswith, :occursin)
            fn, str = arg.args[1], arg.args[2]
            str isa AbstractString || error("@pivot_longer: argument to $fn must be a string literal")
            return (Symbol("include_$(fn)"), Symbol(str))
        end
        # Range: :a::b or 1:3
        if arg.head == :call && length(arg.args) == 3 && arg.args[1] == Symbol(":")
            a, b = arg.args[2], arg.args[3]
            if a isa Int && b isa Int
                return (:include_range_idx, (a, b))
            elseif a isa QuoteNode && b isa QuoteNode
                return (:include_range, (a.value, b.value))
            end
        end
    end
    error("@pivot_longer: unrecognised selector argument: $arg")
end

macro pivot_longer(args...)
    isempty(args) && error("@pivot_longer requires at least one column selector argument")

    # Detect pipe form vs direct form:
    # pipe form  — all args are selectors (first arg looks like a selector)
    # direct form — first arg is the data source, rest are selectors
    local source_expr, selector_args
    if _is_pivot_selector(args[1])
        source_expr  = nothing          # will use `i` as the piped source
        selector_args = args
    else
        source_expr  = args[1]
        selector_args = args[2:end]
        isempty(selector_args) && error("@pivot_longer requires at least one column selector")
    end

    # Build instruction tuple (evaluated at macro-expansion time)
    instructions = Tuple(_pivot_selector_to_instruction(a) for a in selector_args)

    # Generate the call expression
    function make_call(src_expr)
        :(QueryOperators.pivot_longer(
            $src_expr,
            QueryOperators._resolve_pivot_cols(eltype($src_expr), Val($instructions))
        ))
    end

    if source_expr === nothing
        call = make_call(:(QueryOperators.query(i)))
        return :(i -> $call)
    else
        call = make_call(:(QueryOperators.query($(esc(source_expr)))))
        return call
    end
end

macro pivot_wider(source, names_from, values_from)
    return :(QueryOperators.pivot_wider(QueryOperators.query($(esc(source))), $(esc(names_from)), $(esc(values_from))))
end

macro pivot_wider(names_from, values_from)
    return :(i -> QueryOperators.pivot_wider(QueryOperators.query(i), $(esc(names_from)), $(esc(values_from))))
end
