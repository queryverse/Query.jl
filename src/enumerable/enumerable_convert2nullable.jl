immutable EnumerableConvert2Nullable{T, S} <: Enumerable
    source::S
end

Base.iteratorsize{T,S}(::Type{EnumerableConvert2Nullable{T,S}}) = Base.iteratorsize(S)

Base.eltype{T,S}(iter::EnumerableConvert2Nullable{T,S}) = T

Base.eltype{T,S}(iter::Type{EnumerableConvert2Nullable{T,S}}) = T

Base.length{T,S}(iter::EnumerableConvert2Nullable{T,S}) = length(iter.source)

IterableTables.isiterable(x::EnumerableConvert2Nullable) = true
IterableTables.isiterabletable(x::EnumerableConvert2Nullable) = true

function convert2nullable(source::Enumerable)
    TS = eltype(source)
    if TS <: NamedTuple
        column_names = fieldnames(TS)
        column_types = []
        col_expressions = Array{Expr,1}()
        for (i,t) in enumerate(TS.types)
            if t <: DataValue
                push!(column_types, Nullable{t.parameters[1]})
                push!(col_expressions, Expr(:(::), column_names[i], Nullable{t.parameters[1]}))
            else
                push!(column_types, t)
                push!(col_expressions, Expr(:(::), column_names[i], t))
            end
        end

        t_expr = NamedTuples.make_tuple(col_expressions)
        T = eval(NamedTuples, t_expr)

        S = typeof(source)
        return EnumerableConvert2Nullable{T,S}(source)
    else
        return source
    end
end

function start{T,S}(iter::EnumerableConvert2Nullable{T,S})
    s = start(iter.source)
    return s
end

@generated function next{T,S}(iter::EnumerableConvert2Nullable{T,S}, state)
    constructor_call = Expr(:call, :($T))
    tuple_names = fieldnames(iter.parameters[1])
    for i in 1:length(iter.parameters[1].types)
        if iter.parameters[1].parameters[i] <: Nullable
            push!(constructor_call.args, :(Nullable(v.$(tuple_names[i]))))
        else
            push!(constructor_call.args, :(v.$(tuple_names[i])))
        end
    end

    q = quote
        x = next(iter.source, state)
        v = x[1]
        s_new = x[2]
        v_new = $constructor_call
        return v_new, s_new
    end

    return q
end

function done{T,S}(iter::EnumerableConvert2Nullable{T,S}, state)
    return done(iter.source, state)
end
