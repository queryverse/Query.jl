immutable EnumerableConvert2DataValue{T, S, Q<:Function} <: Enumerable
    source::S
    f::Q
end

Base.eltype{T,S,Q}(iter::EnumerableConvert2DataValue{T,S,Q}) = T

Base.eltype{T,S,Q}(iter::Type{EnumerableConvert2DataValue{T,S,Q}}) = T

function convert2datavalue(source::Enumerable)
    TS = eltype(source)
    if TS <: NamedTuple
        column_names = fieldnames(T)
        column_types = []
        col_expressions = Array{Expr,1}()
        for (i,t) in enumerate(TS.types)
            if t <: Nullable
                push!(column_types, DataValue{t.types[1]})
                push!(col_expressions, Expr(:(::), column_names[i], DataValue{t.types[1]}))
            else
                push!(column_types, t)
                push!(col_expressions, Expr(:(::), column_names[i], t))
            end
        end

        t_expr = NamedTuples.make_tuple(col_expressions)

        println(t_expr)

        # t2 = :(Query.EnumerableConvert2DataValue{Float64,Float64})
        # t2.args[2] = t_expr
        # t2.args[3] = df_columns_tuple_type

        # eval(NamedTuples, :(import Query))
        # t = eval(NamedTuples, t2)

        # e_df = t(df, (df.columns...))

        # return e_df


        S = typeof(source)
        Q = typeof(f)
        return EnumerableConvert2DataValue{T,S,Q}(source, f)
    else
        return source
    end
end

function start{T,S,Q}(iter::EnumerableConvert2DataValue{T,S,Q})
    s = start(iter.source)
    return s
end

function next{T,S,Q}(iter::EnumerableConvert2DataValue{T,S,Q}, s)
    x = next(iter.source, s)
    v = x[1]
    s_new = x[2]
    v_new = iter.f(v)::T
    return v_new, s_new
end

function done{T,S,Q}(iter::EnumerableConvert2DataValue{T,S,Q}, state)
    return done(iter.source, state)
end
