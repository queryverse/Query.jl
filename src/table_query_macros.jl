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
        if typeof(arg) == QuoteNode
            # select
            prev = :( merge($prev, QueryOperators.NamedTupleUtilities.select(_, Val($(arg)))) )
        else
            arg = string(arg)
            # remove
            m1 = match(r"^-:(.+)", arg)
            #TODO: variable case
            # single-parameter functions
            m2 = match(r"^(startswith|endswith|occursin)\(\"(.+)\"\)", arg)
            # dual-parameter functions
            m3 = match(r"^(rangeat)\(:([^,]+), *:([^,]+)\)", arg)
            if m1 !== nothing
                if prev == NamedTuple()
                    prev = :( QueryOperators.NamedTupleUtilities.remove(_, Val($(QuoteNode(Symbol(m1[1]))))) )
                else
                    prev = :( QueryOperators.NamedTupleUtilities.remove($prev, Val($(QuoteNode(Symbol(m1[1]))))) )
                end
            elseif m2 !== nothing
                if m2[1] == "startswith"
                    prev = :( merge($prev, QueryOperators.NamedTupleUtilities.startswith(_, Val($(QuoteNode(Symbol(m2[2])))))) )
                elseif m2[1] == "endswith"
                    prev = :( merge($prev, QueryOperators.NamedTupleUtilities.endswith(_, Val($(QuoteNode(Symbol(m2[2])))))) )
                elseif m2[1] == "occursin"
                    prev = :( merge($prev, QueryOperators.NamedTupleUtilities.occursin(_, Val($(QuoteNode(Symbol(m2[2])))))) )
                end
            elseif m3 !== nothing
                prev = :( merge($prev, QueryOperators.NamedTupleUtilities.range(_, Val($(QuoteNode(Symbol(m3[2])))), Val($(QuoteNode(Symbol(m3[3])))))) )
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
        m = match(r"^:(.+) *=> *:(.+)", string(arg))
        m1, m2 = m[1], m[2]
        m1, m2 = strip(m1), strip(m2)
        if m !== nothing
            prev = :( QueryOperators.NamedTupleUtilities.rename($prev, Val($(QuoteNode(Symbol(m1)))), Val($(QuoteNode(Symbol(m2))))) )
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