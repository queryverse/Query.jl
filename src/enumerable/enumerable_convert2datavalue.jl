immutable EnumerableConvert2DataValue{T, S} <: Enumerable
    source::S
end

Base.eltype{T,S}(iter::EnumerableConvert2DataValue{T,S}) = T

Base.eltype{T,S}(iter::Type{EnumerableConvert2DataValue{T,S}}) = T

@generated function convert2datavalue{S<:Enumerable}(source::S)
    TS = eltype(source)
    # TODO Right now this will only convert things if all the columns in
    # the source are of type Nullable. We could probably be more flexible
    # there.
    if TS <: NamedTuple && all(i->i<:Nullable, TS.types)
        column_names = fieldnames(TS)
        column_types = []
        col_expressions = Array{Expr,1}()
        for (i,t) in enumerate(TS.types)
            if t <: Nullable
                push!(column_types, DataValue{t.parameters[1]})
                push!(col_expressions, Expr(:(::), column_names[i], DataValue{t.parameters[1]}))
            else
                push!(column_types, t)
                push!(col_expressions, Expr(:(::), column_names[i], t))
            end
        end
        t_expr = NamedTuples.make_tuple(col_expressions)
        t_expr.args[1] = Expr(:., :NamedTuples, QuoteNode(t_expr.args[1]))
        expr = :( return EnumerableConvert2DataValue{Float64,$source}(source) )
        expr.args[1].args[1].args[2] = t_expr
        return expr
    else
        return :(return source)
    end
end

function start{T,S}(iter::EnumerableConvert2DataValue{T,S})
    s = start(iter.source)
    return s
end

@generated function next{T,S}(iter::EnumerableConvert2DataValue{T,S}, state)
    constructor_call = Expr(:call, :($T))
    tuple_names = fieldnames(iter.parameters[1])
    for i in 1:length(iter.parameters[1].types)
        if iter.parameters[1].parameters[i] <: DataValue
            push!(constructor_call.args, :(DataValue(v.$(tuple_names[i]))))
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

function done{T,S}(iter::EnumerableConvert2DataValue{T,S}, state)
    return done(iter.source, state)
end
