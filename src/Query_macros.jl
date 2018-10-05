macro select(args...)
    # Currently does not work
    foo = :_
    for arg in args
        if string(arg)[1] == '-'
            arg = ":" * string(arg)[2:end]
            foo = :( NamedTuple.remove($foo, Val{$(Symbol(arg))}()) )
        elseif string(arg)[1:10] == "startswith"
            arg = string(arg)[12:(end-1)]
            foo = :( NamedTuple.startswith($foo, Val{$(Symbol(arg))}()) )
        elseif string(arg)[1:8] == "endswith"
            arg = string(arg)[10:(end-1)]
            foo = :( NamedTuple.endswith($foo, Val{$(Symbol(arg))}()) )
        elseif string(arg)[1:7] == "rangeat"
            arg1 = string(arg)[9:findfirst(string(arg), ',')]
            arg2 = string(arg)[(findfirst(string(arg), ',')+1):end]
            foo = :( NamedTuple.rangeat($foo, Val{$(Symbol(arg1))}(), Val{$(Symbol(arg2))}()) )
        end
    end
    print(foo)
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