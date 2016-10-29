function collect(enumerable::Enumerable)
    T = eltype(enumerable)
    ret = Array(T,0)
    for i in enumerable
        push!(ret, i)
    end
    return ret
end

function collect{TS,Provider}(source::Queryable{TS,Provider})
    collect(Provider, source)
end
