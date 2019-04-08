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

@active Predicate(x) begin
    (op :: Any, x) = @match x begin
        :(-$x) => (:-, x)
        :(!$x) => (:!, x)
        _      => (nothing, x)
    end
    res = @match x begin
        :(startswith($arg)) => (:startswith, arg)
        :(endswith($arg)) => (:endswith, arg)
        :(occursin($arg)) => (:occursin, arg)
        _                 => nothing
    end
    if res !== nothing
        (kind, arg) = res
        if arg isa String
            arg = QuoteNode(Symbol(arg))
        end
        (op, kind, arg)
    end
end


@active QuoteNodeP(x) begin
    x isa QuoteNode ? x.value : nothing
end

macro select(args...)
    foldl(args, init=NamedTuple()) do prev, arg
        @match arg begin
            :(everything()) => :_

            ::Int && if arg > 0 end =>
                :( merge($prev, QueryOperators.NamedTupleUtilities.select(_, Val(keys(_)[$arg]))) )

            ::Int && if arg < 0 end =>
                let sel = ifelse(prev == NamedTuple(), :_, prev)
                    :( QueryOperators.NamedTupleUtilities.remove($sel, Val(keys($sel)[-$arg])) )
                end
            ::QuoteNode =>
                :( merge($prev, QueryOperators.NamedTupleUtilities.select(_, Val($(arg)))) )

            # remove by name
            :(-$(name :: QuoteNode)) && if name.value isa Symbol end =>
                let prev = ifelse(prev == NamedTuple(), :_, prev)
                    :( QueryOperators.NamedTupleUtilities.remove($prev, Val($name)) )
                end

            # select by element type
            :(::$typ) =>
                :( merge($prev, QueryOperators.NamedTupleUtilities.oftype(_, typ)) )

            # select by range, with multiple syntaxes supported
           :(rangeat($a, $b)) || :($a : $b) =>
                if a isa Int && b isa Int
                    :( merge($prev, QueryOperators.NamedTupleUtilities.range(_, Val(keys(_)[$a]), Val(keys(_)[$b]))) )
                else
                    :( merge($prev, QueryOperators.NamedTupleUtilities.range(_, Val($a), Val($b))) )
                end
            Predicate(op, kind, arg) =>
            let
                pos_f = @match kind begin
                        :startswith => :(QueryOperators.NamedTupleUtilities.startswith)
                        :endswith => :(QueryOperators.NamedTupleUtilities.endswith)
                        :occursin => :(QueryOperators.NamedTupleUtilities.occursin)
                end

                neg_f = @match kind begin
                        :startswith => :(QueryOperators.NamedTupleUtilities.not_startswith)
                        :endswith => :(QueryOperators.NamedTupleUtilities.not_endswith)
                        :occursin => :(QueryOperators.NamedTupleUtilities.not_occursin)
                end

                # select by predicate functions
                select_by_predicate(pred) = Expr(:call, merge, prev, Expr(:call, pred, :_, Expr(:call, Val, arg)))

                @match op begin
                    if op === nothing end => select_by_predicate(pos_f)
                    :!                    => select_by_predicate(neg_f)

                    # remove by predicate functions
                    :- =>
                        let prev = ifelse(prev == NamedTuple(), :_, prev)
                            Expr(:call, neg_f, prev, Expr(:call, Val, arg))
                        end

                end
            end
        end
    end |> prev ->
    :(Query.@map($prev))
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
    foldl(args, init = :_) do prev, arg
        @match arg begin
            :($(n1 :: Int) => $n2) =>
                :( QueryOperators.NamedTupleUtilities.rename($prev, Val(keys(_)[$n1]), Val($n2)) )
            :($m1 => $m2) =>
                :( QueryOperators.NamedTupleUtilities.rename($prev, Val($m1), Val($m2)))
        end
    end |> prev ->
    :(Query.@map( $prev ) )
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
    foldl(args, init=:_) do prev, arg
        @match arg begin
            :($alias = $expr) => :( merge($prev, ($(esc(alias)) = $(expr),)) )
        end
    end |> prev ->
    :( Query.@map( $prev ) )
end

macro datatype(str)
    :($(Symbol(str)))
end