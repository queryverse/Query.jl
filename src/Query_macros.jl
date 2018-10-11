# import NamedTupleUtilities

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

macro rename(args...)
    foo = :_
    for arg in args
        name, replace = split(string(arg), " = ")
        foo = :( Query.rename($foo, Val($(QuoteNode(Symbol(name)))), Val($(QuoteNode(Symbol(replace))))) )
    end
    return :(Query.@map( $foo ) )
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