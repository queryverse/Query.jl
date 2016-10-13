function _count{T}(source::Enumerable{T}, filter::Function, state)
    count_val = 0
    while !done(source, state)
        ret_val = next(source, state)
        state = ret_val[2]
        if filter(ret_val[1])
            count_val += 1
        end
    end
    return count_val
end

function count{T}(source::Enumerable{T}, filter::Function, filter_expr::Expr)
    count_val = 0
    state = start(source)
    return _count(source, filter, state)
end

function _count(source::Enumerable, state)
    count_val = 0
    while !done(source, state)
        ret_val = next(source, state)
        state = ret_val[2]
        count_val += 1
    end
    return count_val
end

function count(source::Enumerable)
    state = start(source)
    return _count(source, state)
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
