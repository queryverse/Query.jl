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
    # Keyword argument (names_to=:x, values_to=:x) — not a selector
    if arg isa Expr && (arg.head == :(=) || arg.head == :kw)
        return false
    end
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

# Returns true when a macro argument is a keyword argument (name=value).
function _is_pivot_kwarg(arg)
    arg isa Expr && (arg.head == :(=) || arg.head == :kw) &&
        length(arg.args) == 2 && arg.args[1] ∈ (:names_to, :values_to)
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

    # Separate keyword arguments (names_to=, values_to=) from column selectors
    col_selectors = filter(a -> !_is_pivot_kwarg(a), selector_args)
    kw_args = filter(_is_pivot_kwarg, selector_args)
    isempty(col_selectors) && error("@pivot_longer requires at least one column selector")

    # Extract keyword values
    kwargs_exprs = Expr[]
    for kw in kw_args
        name = kw.args[1]
        val  = kw.args[2]
        push!(kwargs_exprs, Expr(:kw, name, esc(val)))
    end

    # Build instruction tuple (evaluated at macro-expansion time)
    instructions = Tuple(_pivot_selector_to_instruction(a) for a in col_selectors)

    # Generate the call expression
    function make_call(src_expr)
        call_expr = :(QueryOperators.pivot_longer(
            $src_expr,
            QueryOperators._resolve_pivot_cols(eltype($src_expr), Val($instructions))
        ))
        if !isempty(kwargs_exprs)
            # Insert keyword arguments into the function call
            call_expr.args = [call_expr.args[1]; Expr(:parameters, kwargs_exprs...); call_expr.args[2:end]...]
        end
        call_expr
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

# Outer joins. As with @join, the direct form takes the outer sequence first and
# the piped form supplies it.

macro left_join(outer, inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :(QueryOperators.left_join(QueryOperators.query($(esc(outer))),
            QueryOperators.query($(esc(inner))),
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro left_join(inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :( outer -> QueryOperators.left_join(QueryOperators.query(outer),
            QueryOperators.query($(esc(inner))),
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro right_join(outer, inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :(QueryOperators.right_join(QueryOperators.query($(esc(outer))),
            QueryOperators.query($(esc(inner))),
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro right_join(inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :( outer -> QueryOperators.right_join(QueryOperators.query(outer),
            QueryOperators.query($(esc(inner))),
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro full_join(outer, inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :(QueryOperators.full_join(QueryOperators.query($(esc(outer))),
            QueryOperators.query($(esc(inner))),
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

macro full_join(inner, outerKeySelector, innerKeySelector, resultSelector)
    outerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(outerKeySelector)
    innerKeySelector_as_anonym_func = helper_replace_anon_func_syntax(innerKeySelector)
    resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)

    q_outerKeySelector = Expr(:quote, outerKeySelector_as_anonym_func)
    q_innerKeySelector = Expr(:quote, innerKeySelector_as_anonym_func)
    q_resultSelector = Expr(:quote, resultSelector_as_anonym_func)

    return :( outer -> QueryOperators.full_join(QueryOperators.query(outer),
            QueryOperators.query($(esc(inner))),
            $(esc(outerKeySelector_as_anonym_func)), $(esc(q_outerKeySelector)),
            $(esc(innerKeySelector_as_anonym_func)), $(esc(q_innerKeySelector)),
            $(esc(resultSelector_as_anonym_func)), $(esc(q_resultSelector)),)) |>
        helper_namedtuples_replacement
end

# Set operations over two sequences.

macro concat(source, other)
    return :(QueryOperators.concat(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other)))))
end

macro concat(other)
    return :( i -> QueryOperators.concat(QueryOperators.query(i), QueryOperators.query($(esc(other)))))
end

macro union(source, other)
    return :(QueryOperators.union(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other)))))
end

macro union(other)
    return :( i -> QueryOperators.union(QueryOperators.query(i), QueryOperators.query($(esc(other)))))
end

macro except(source, other)
    return :(QueryOperators.except(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other)))))
end

macro except(other)
    return :( i -> QueryOperators.except(QueryOperators.query(i), QueryOperators.query($(esc(other)))))
end

macro intersect(source, other)
    return :(QueryOperators.intersect(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other)))))
end

macro intersect(other)
    return :( i -> QueryOperators.intersect(QueryOperators.query(i), QueryOperators.query($(esc(other)))))
end

# Set operations that compare a key rather than whole elements. Unlike
# Enumerable.ExceptBy and IntersectBy, whose second argument is a bare sequence
# of keys, the selector here applies to both sequences.

macro union_by(source, other, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.union_by(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other))),
            $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro union_by(other, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.union_by(QueryOperators.query(i), QueryOperators.query($(esc(other))),
            $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro except_by(source, other, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.except_by(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other))),
            $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro except_by(other, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.except_by(QueryOperators.query(i), QueryOperators.query($(esc(other))),
            $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro intersect_by(source, other, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.intersect_by(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other))),
            $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro intersect_by(other, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.intersect_by(QueryOperators.query(i), QueryOperators.query($(esc(other))),
            $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

# Partitioning.

macro take_while(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.take_while(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro take_while(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.take_while(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro drop_while(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.drop_while(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro drop_while(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.drop_while(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro take_last(source, n)
    return :(QueryOperators.take_last(QueryOperators.query($(esc(source))), $(esc(n))))
end

macro take_last(n)
    return :( i -> QueryOperators.take_last(QueryOperators.query(i), $(esc(n))))
end

macro drop_last(source, n)
    return :(QueryOperators.drop_last(QueryOperators.query($(esc(source))), $(esc(n))))
end

macro drop_last(n)
    return :( i -> QueryOperators.drop_last(QueryOperators.query(i), $(esc(n))))
end

# Ordering and row position. @order sorts by whole elements, so it takes no
# selector; @thenby can still follow it.

macro order(source)
    return :(QueryOperators.order(QueryOperators.query($(esc(source)))))
end

macro order()
    return :( i -> QueryOperators.order(QueryOperators.query(i)))
end

macro order_descending(source)
    return :(QueryOperators.order_descending(QueryOperators.query($(esc(source)))))
end

macro order_descending()
    return :( i -> QueryOperators.order_descending(QueryOperators.query(i)))
end

macro reverse(source)
    return :(QueryOperators.reverse(QueryOperators.query($(esc(source)))))
end

macro reverse()
    return :( i -> QueryOperators.reverse(QueryOperators.query(i)))
end

macro index(source)
    return :(QueryOperators.index(QueryOperators.query($(esc(source)))))
end

macro index()
    return :( i -> QueryOperators.index(QueryOperators.query(i)))
end

# Combining sequences. @append and @prepend add a single element.

macro append(source, element)
    return :(QueryOperators.append(QueryOperators.query($(esc(source))), $(esc(element))))
end

macro append(element)
    return :( i -> QueryOperators.append(QueryOperators.query(i), $(esc(element))))
end

macro prepend(source, element)
    return :(QueryOperators.prepend(QueryOperators.query($(esc(source))), $(esc(element))))
end

macro prepend(element)
    return :( i -> QueryOperators.prepend(QueryOperators.query(i), $(esc(element))))
end

# Keyed aggregation and batching.

macro count_by(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.count_by(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro count_by(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.count_by(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro chunk(source, n)
    return :(QueryOperators.chunk(QueryOperators.query($(esc(source))), $(esc(n))))
end

macro chunk(n)
    return :( i -> QueryOperators.chunk(QueryOperators.query(i), $(esc(n))))
end

# Type filtering.

macro of_type(source, T)
    return :(QueryOperators.of_type(QueryOperators.query($(esc(source))), $(esc(T))))
end

macro of_type(T)
    return :( i -> QueryOperators.of_type(QueryOperators.query(i), $(esc(T))))
end

macro cast(source, T)
    return :(QueryOperators.cast(QueryOperators.query($(esc(source))), $(esc(T))))
end

macro cast(T)
    return :( i -> QueryOperators.cast(QueryOperators.query(i), $(esc(T))))
end

# Terminal operators, which return a value rather than another query.

macro all(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.all(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro all(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.all(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro min_by(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.min_by(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro min_by(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.min_by(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro max_by(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.max_by(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro max_by(f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :( i -> QueryOperators.max_by(QueryOperators.query(i), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro contains(source, value)
    return :(QueryOperators.contains(QueryOperators.query($(esc(source))), $(esc(value))))
end

macro contains(value)
    return :( i -> QueryOperators.contains(QueryOperators.query(i), $(esc(value))))
end

macro element_at(source, n)
    return :(QueryOperators.element_at(QueryOperators.query($(esc(source))), $(esc(n))))
end

macro element_at(n)
    return :( i -> QueryOperators.element_at(QueryOperators.query(i), $(esc(n))))
end

macro sequence_equal(source, other)
    return :(QueryOperators.sequence_equal(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other)))))
end

macro sequence_equal(other)
    return :( i -> QueryOperators.sequence_equal(QueryOperators.query(i), QueryOperators.query($(esc(other)))))
end

macro any(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.any(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro any(source)
    return :(QueryOperators.any(QueryOperators.query($(esc(source)))))
end

macro any()
    return :( i -> QueryOperators.any(QueryOperators.query(i)))
end

macro first(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.first(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro first(source)
    return :(QueryOperators.first(QueryOperators.query($(esc(source)))))
end

macro first()
    return :( i -> QueryOperators.first(QueryOperators.query(i)))
end

macro last(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.last(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro last(source)
    return :(QueryOperators.last(QueryOperators.query($(esc(source)))))
end

macro last()
    return :( i -> QueryOperators.last(QueryOperators.query(i)))
end

macro single(source, f)
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)
    return :(QueryOperators.single(QueryOperators.query($(esc(source))), $(esc(f_as_anonym_func)), $(esc(q)))) |>
        helper_namedtuples_replacement
end

macro single(source)
    return :(QueryOperators.single(QueryOperators.query($(esc(source)))))
end

macro single()
    return :( i -> QueryOperators.single(QueryOperators.query(i)))
end

# Returns true when a macro argument is the keyword argument `name = value`.
function _is_named_kwarg(arg, name::Symbol)
    return arg isa Expr && (arg.head == :(=) || arg.head == :kw) &&
        length(arg.args) == 2 && arg.args[1] == name
end

# Splits macro arguments into positional ones and the value of a single
# optional keyword argument. The keyword form is what makes the piped and
# direct calls of @shuffle and @aggregate tell each other apart: a lone
# positional argument is always the source, never an rng or a seed.
function _split_kwarg(macro_name, args, name::Symbol)
    kwargs = filter(a -> _is_named_kwarg(a, name), args)
    positional = filter(a -> !_is_named_kwarg(a, name), args)

    length(kwargs) <= 1 || error("$macro_name accepts at most one `$name` argument")
    for a in positional
        if a isa Expr && (a.head == :(=) || a.head == :kw)
            error("$macro_name does not accept the keyword argument `$(a.args[1])`")
        end
    end

    return positional, isempty(kwargs) ? nothing : kwargs[1].args[2]
end

macro shuffle(args...)
    positional, rng = _split_kwarg("@shuffle", args, :rng)
    length(positional) <= 1 || error("@shuffle accepts at most one positional argument, the source")

    make_call(src) = rng === nothing ?
        :(QueryOperators.shuffle(QueryOperators.query($src))) :
        :(QueryOperators.shuffle(QueryOperators.query($src), $(esc(rng))))

    if isempty(positional)
        return :( i -> $(make_call(:i)) )
    else
        return make_call(:($(esc(positional[1]))))
    end
end

macro aggregate(args...)
    positional, seed = _split_kwarg("@aggregate", args, :seed)
    1 <= length(positional) <= 2 ||
        error("@aggregate takes the accumulator, optionally preceded by the source, plus an optional `seed=` argument")

    f = positional[end]
    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    q = Expr(:quote, f_as_anonym_func)

    make_call(src) = seed === nothing ?
        :(QueryOperators.aggregate(QueryOperators.query($src), $(esc(f_as_anonym_func)), $(esc(q)))) :
        :(QueryOperators.aggregate(QueryOperators.query($src), $(esc(seed)), $(esc(f_as_anonym_func)), $(esc(q))))

    result = length(positional) == 1 ?
        :( i -> $(make_call(:i)) ) :
        make_call(:($(esc(positional[1]))))

    return result |> helper_namedtuples_replacement
end

macro aggregate_by(args...)
    3 <= length(args) <= 4 ||
        error("@aggregate_by takes a key selector, a seed and an accumulator, optionally preceded by the source")

    f, seed, accumulator = args[end-2], args[end-1], args[end]

    f_as_anonym_func = helper_replace_anon_func_syntax(f)
    accumulator_as_anonym_func = helper_replace_anon_func_syntax(accumulator)
    q = Expr(:quote, f_as_anonym_func)

    make_call(src) = :(QueryOperators.aggregate_by(QueryOperators.query($src),
        $(esc(f_as_anonym_func)), $(esc(q)), $(esc(seed)), $(esc(accumulator_as_anonym_func))))

    result = length(args) == 3 ?
        :( i -> $(make_call(:i)) ) :
        make_call(:($(esc(args[1]))))

    return result |> helper_namedtuples_replacement
end

# @zip(other) / @zip(source, other) / @zip(source, other, resultSelector).
# There is deliberately no two-argument piped form with a result selector: it
# would be indistinguishable from the direct form, and `|> @zip(other) |> @map(...)`
# expresses the same thing.
macro zip(args...)
    1 <= length(args) <= 3 ||
        error("@zip takes the second sequence, optionally preceded by the source and optionally followed by a result selector")

    if length(args) == 1
        other = args[1]
        return :( i -> QueryOperators.zip(QueryOperators.query(i), QueryOperators.query($(esc(other)))))
    elseif length(args) == 2
        source, other = args
        return :(QueryOperators.zip(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other)))))
    else
        source, other, resultSelector = args
        resultSelector_as_anonym_func = helper_replace_anon_func_syntax(resultSelector)
        q = Expr(:quote, resultSelector_as_anonym_func)
        return :(QueryOperators.zip(QueryOperators.query($(esc(source))), QueryOperators.query($(esc(other))),
                $(esc(resultSelector_as_anonym_func)), $(esc(q)))) |>
            helper_namedtuples_replacement
    end
end
