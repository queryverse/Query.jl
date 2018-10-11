using NamedTupleUtils

macro select(args...)
    # Use QueryOperators
    foo = :_
    for arg in args
        # arg must not contain certain characters
        if startswith(string(arg), '-')
            arg = string(arg)[2:end]
            foo = :( remove($foo, Val{$(QuoteNode(Symbol(arg)))}()) )
        elseif startswith(string(arg), "startswith(")
            arg = string(arg)[12:(end-1)]
            foo = :( NamedTupleUtils.startswith($foo, Val{$(QuoteNode(Symbol(arg)))}()) )
        elseif startswith(string(arg), "endswith(")
            arg = string(arg)[10:(end-1)]
            foo = :( NamedTupleUtils.endswith($foo, Val{$(QuoteNode(Symbol(arg)))}()) )
        elseif startswith(string(arg), "contains(")
            arg = string(arg)[10:(end-1)]
            foo = :( NamedTupleUtils.contains($foo, Val{$(QuoteNode(Symbol(arg)))}()) )
        elseif startswith(string(arg), "rangeat(")
            arg1, arg2 = split(string(arg)[9:(end-1)], ',')
            foo = :( NamedTupleUtils.rangeat($foo, Val{$(QuoteNode(Symbol(arg1)))}(), Val{$(QuoteNode(Symbol(arg2)))}()) )
        end
    end
    return :(Query.@map( $foo ) )
end


function findfirst(s::String, c::Char)
    for i in 1:length(s)
        if c == s[i]
            return i
        end
    end
    return -1
end


@generated function remove(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = (filter(item -> item != bn, [n for n in an])...,)
    types = Tuple{Any[ fieldtype(a, n) for n in names ]...}
    vals = Any[ :(getfield(a, $(QuoteNode(n)))) for n in names ]
    :( NamedTuple{$names,$types}(($(vals...),)) )
end