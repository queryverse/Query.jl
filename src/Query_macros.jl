# import NamedTupleUtilities

"""
    @select(args...)
Select columns from a table using commands in order.
```
julia> df = (foo=[1,2,3], bar=[3.0,2.0,1.0], bat=["a","b","c"]) |> DataFrame
3×3 DataFrame
│ Row │ foo   │ bar     │ bat    │
│     │ Int64 │ Float64 │ String │
├─────┼───────┼─────────┼────────┤
│ 1   │ 1     │ 3.0     │ a      │
│ 2   │ 2     │ 2.0     │ b      │
│ 3   │ 3     │ 1.0     │ c      │

julia> df |> Query.@select(startswith(b), -bar) |> DataFrame
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
    # Use QueryOperators
    foo = :_
    for arg in args
        if startswith(string(arg), '-')
            arg = string(arg)[2:end]
            foo = :( remove($foo, Val($(QuoteNode(Symbol(arg))))) )
        elseif startswith(string(arg), "startswith(")
            arg = string(arg)[12:(end-1)]
            foo = :( startswith($foo, Val($(QuoteNode(Symbol(arg))))) )
        elseif startswith(string(arg), "endswith(")
            arg = string(arg)[10:(end-1)]
            foo = :( endswith($foo, Val($(QuoteNode(Symbol(arg))))) )
        elseif startswith(string(arg), "occursin(")
            arg = string(arg)[10:(end-1)]
            foo = :( occursin($foo, Val($(QuoteNode(Symbol(arg))))) )
        elseif startswith(string(arg), "rangeat(")
            arg1, arg2 = split(string(arg)[9:(end-1)], ',')
            foo = :( rangeat($foo, Val($(QuoteNode(Symbol(arg1)))), Val($(QuoteNode(Symbol(arg2))))) )
        end
    end
    return :(Query.@map( $foo ) )
end

"""
    @rename(args...)
Replace column names in a table with new given names.
```
julia> df = (foo=[1,2,3], bar=[3.0,2.0,1.0], bat=["a","b","c"]) |> DataFrame
3×3 DataFrame
│ Row │ foo   │ bar     │ bat    │
│     │ Int64 │ Float64 │ String │
├─────┼───────┼─────────┼────────┤
│ 1   │ 1     │ 3.0     │ a      │
│ 2   │ 2     │ 2.0     │ b      │
│ 3   │ 3     │ 1.0     │ c      │

julia> df |> Query.@rename(foo = fat, bar = ban) |> DataFrame
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
    foo = :_
    for arg in args
        name, replace = split(string(arg), " = ")
        foo = :( Query.rename($foo, Val($(QuoteNode(Symbol(name)))), Val($(QuoteNode(Symbol(replace))))) )
    end
    return :(Query.@map( $foo ) )
end


macro mutate(args...)
    return args
end
    

@generated function remove(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = (filter(item -> item != bn, [n for n in an])...,)
    types = Tuple{Any[ fieldtype(a, n) for n in names ]...}
    vals = Any[ :(getfield(a, $(QuoteNode(n)))) for n in names ]
    :( NamedTuple{$names,$types}(($(vals...),)) )
end

@generated function Base.startswith(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if startswith(String(i), String(bn)))...,)
    types = Tuple{(fieldtype(a ,n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

@generated function Base.endswith(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if endswith(String(i), String(bn)))...,)
    types = Tuple{(fieldtype(a ,n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

@generated function Base.occursin(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if occursin(String(bn), String(i)))...,)
    types = Tuple{(fieldtype(a ,n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

@generated function rename(a::NamedTuple{an}, ::Val{bn}, ::Val{cn}) where {an, bn, cn}
    names = Symbol[]
    typesArray = DataType[]
    vals = Expr[]
    for n in an
        if n == bn
            push!(names, cn)
        else
            push!(names, n)
        end
        push!(typesArray, fieldtype(a, n))
        push!(vals, :(getfield(a, $(QuoteNode(n)))))
    end
    types = Tuple{typesArray...}
    return :(NamedTuple{$(names...,),$types}(($(vals...),)))
end