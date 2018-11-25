using QueryOperators

"""
    @select(args...)
Select columns from a table using commands in order.
```
julia> df = DataFrame(foo=[1,2,3], bar=[3.0,2.0,1.0], bat=["a","b","c"])
3×3 DataFrame
│ Row │ foo   │ bar     │ bat    │
│     │ Int64 │ Float64 │ String │
├─────┼───────┼─────────┼────────┤
│ 1   │ 1     │ 3.0     │ a      │
│ 2   │ 2     │ 2.0     │ b      │
│ 3   │ 3     │ 1.0     │ c      │

julia> df |> @select(startswith("b"), -:bar) |> DataFrame
3×1 DataFrame
│ Row │ bat    │
│     │ String │
├─────┼────────┤
│ 1   │ a      │
│ 2   │ b      │
│ 3   │ c      │
```
"""
macro select(args...)
    prev = NamedTuple()
    for arg in args
        if typeof(arg) == Int
            # select by index
            if arg > 0
                prev = :( merge($prev, QueryOperators.NamedTupleUtilities.select(_, Val(keys(_)[$arg]))) )
            # remove by index
            elseif arg < 0
                s = ifelse(prev == NamedTuple(), :_, prev)
                prev = :( QueryOperators.NamedTupleUtilities.remove($s, Val(keys($s)[-$arg])) )
            end
        elseif typeof(arg) == QuoteNode
            # select by name
            prev = :( merge($prev, QueryOperators.NamedTupleUtilities.select(_, Val($(arg)))) )
        else
            arg = string(arg)
            # remove by name
            m_rem = match(r"^-:(.+)", arg)
            # select by range
            m_rangen = match(r"^:([^,:]+) *: *:([^,:]+)", arg)
            m_ranger = match(r"^rangeat\(:([^,]+), *:([^,]+)\)", arg)
            # select by predicate functions
            m_pred = match(r"^(startswith|endswith|occursin)\(\"(.+)\"\)", arg)
            m_neg_pred = match(r"^!(startswith|endswith|occursin)\(\"(.+)\"\)", arg)
            if m_rem !== nothing
                s = ifelse(prev == NamedTuple(), :_, prev)
                prev = :( QueryOperators.NamedTupleUtilities.remove($s, Val($(QuoteNode(Symbol(m_rem[1]))))) )
            elseif m_rangen !== nothing || m_ranger !== nothing
                m_range = ifelse(m_rangen !== nothing, m_rangen, m_ranger)
                prev = :( merge($prev, QueryOperators.NamedTupleUtilities.range(_, Val($(QuoteNode(Symbol(m_range[1])))), Val($(QuoteNode(Symbol(m_range[2])))))) )
            elseif m_pred !== nothing
                if m_pred[1] == "startswith"
                    prev = :( merge($prev, QueryOperators.NamedTupleUtilities.startswith(_, Val($(QuoteNode(Symbol(m_pred[2])))))) )
                elseif m_pred[1] == "endswith"
                    prev = :( merge($prev, QueryOperators.NamedTupleUtilities.endswith(_, Val($(QuoteNode(Symbol(m_pred[2])))))) )
                elseif m_pred[1] == "occursin"
                    prev = :( merge($prev, QueryOperators.NamedTupleUtilities.occursin(_, Val($(QuoteNode(Symbol(m_pred[2])))))) )
                end
            end
        end
    end

    return :(Query.@map( $prev ) )
end

"""
    @rename(args...)
Replace column names in a table with new given names.
```
julia> df = DataFrame(foo=[1,2,3], bar=[3.0,2.0,1.0], bat=["a","b","c"])
3×3 DataFrame
│ Row │ foo   │ bar     │ bat    │
│     │ Int64 │ Float64 │ String │
├─────┼───────┼─────────┼────────┤
│ 1   │ 1     │ 3.0     │ a      │
│ 2   │ 2     │ 2.0     │ b      │
│ 3   │ 3     │ 1.0     │ c      │

julia> df |> @rename(:foo => :fat, :bar => :ban) |> DataFrame
3×3 DataFrame
│ Row │ fat   │ ban     │ bat    │
│     │ Int64 │ Float64 │ String │
├─────┼───────┼─────────┼────────┤
│ 1   │ 1     │ 3.0     │ a      │
│ 2   │ 2     │ 2.0     │ b      │
│ 3   │ 3     │ 1.0     │ c      │
```
"""
macro rename(args...)
    prev = :_
    for arg in args
        n = match(r"^(.+) *=> *:(.+)", string(arg))
        try
            n1 = parse(Int, n[1])
            n2 = strip(n[2])
            prev = :( QueryOperators.NamedTupleUtilities.rename($prev, Val(keys(_)[$n1]), Val($(QuoteNode(Symbol(n2))))) )
        catch
            m = match(r"^:(.+) *=> *:(.+)", string(arg))
            m1, m2 = strip(m[1]), strip(m[2])
            if m !== nothing
                prev = :( QueryOperators.NamedTupleUtilities.rename($prev, Val($(QuoteNode(Symbol(m1)))), Val($(QuoteNode(Symbol(m2))))) )
            end
        end
    end
    return :(Query.@map( $prev ) )
end

"""
    @mutate(args...)
Replace all elements in selected columns with specified formulae.
```
julia> df = DataFrame(foo=[1,2,3], bar=[3.0,2.0,1.0], bat=["a","b","c"])
3×3 DataFrame
│ Row │ foo   │ bar     │ bat    │
│     │ Int64 │ Float64 │ String │
├─────┼───────┼─────────┼────────┤
│ 1   │ 1     │ 3.0     │ a      │
│ 2   │ 2     │ 2.0     │ b      │
│ 3   │ 3     │ 1.0     │ c      │

julia> df |> @mutate(bar = _.foo + 2 * _.bar, bat = "com" * _.bat) |> DataFrame
3×3 DataFrame
│ Row │ foo   │ bar     │ bat    │
│     │ Int64 │ Float64 │ String │
├─────┼───────┼─────────┼────────┤
│ 1   │ 1     │ 7.0     │ coma   │
│ 2   │ 2     │ 6.0     │ comb   │
│ 3   │ 3     │ 5.0     │ comc   │
```
"""
macro mutate(args...)
    foo = :_
    for arg in args
        foo = :( merge($foo, ($(esc(arg.args[1])) = $(arg.args[2]),)) )
    end
    return :( Query.@map( $foo ) )
end