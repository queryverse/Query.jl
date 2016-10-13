function count{T}(source::Enumerable{T}, filter::Function, filter_expr::Expr)
    count_val = 0
    state = start(source)
    while !done(source, state)
        value, state = next(source, state)
        if filter(value)
            count_val += 1
        end
    end
    return count_val
end

function count(source::Enumerable)
    count_val = 0
    state = start(source)
    while !done(source, state)
        value, state = next(source, state)
        count_val += 1
    end
    return count_val
end

macro count_internal(source, f)
    q = Expr(:quote, f)
    :(count($(esc(source)), $(esc(f)), $(esc(q))))
end

macro count_internal(source)
    :(count($(esc(source))))
end

macro count(source, f)
    q = Expr(:quote, f)
    :(count(Query.query($(esc(source))), $(esc(f)), $(esc(q))))
end

macro count(source)
    :(count(Query.query($(esc(source)))))
end
