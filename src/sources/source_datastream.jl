@require DataStreams begin
using DataStreams
using WeakRefStrings

immutable EnumerableDataStream{T, S<:DataStreams.Data.Source, TC} <: Enumerable{T}
    source::S
    schema::DataStreams.Data.Schema
end

function query{S<:DataStreams.Data.Source}(source::S)
	schema = Data.schema(source)

    col_expressions = Array{Expr,1}()
    columns_tuple_type = Expr(:curly, :Tuple)

    for i in 1:schema.cols
        if schema.types[i] <: WeakRefString
            col_type = String
        elseif schema.types[i] <: Nullable && schema.types[i].parameters[1] <: WeakRefString
            col_type = Nullable{String}
        else
            col_type = schema.types[i]
        end

        push!(col_expressions, Expr(:(::), schema.header[i], col_type))
        push!(columns_tuple_type.args, col_type)
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(Query.EnumerableDataStream{Float64,Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = typeof(source)
    t2.args[4] = columns_tuple_type

    eval(NamedTuples, :(import Query))
    t = eval(NamedTuples, t2)

    e_df = t(source, schema)

    return e_df
end

function length{T, S<:DataStreams.Data.Source, TC}(iter::EnumerableDataStream{T,S,TC})
    return iter.schema.rows
end

function eltype{T, S<:DataStreams.Data.Source, TC}(iter::EnumerableDataStream{T,S,TC})
    return T
end

function start{T, S<:DataStreams.Data.Source, TC}(iter::EnumerableDataStream{T,S,TC})
    return 1
end

@generated function next{T, S<:DataStreams.Data.Source, TC}(iter::EnumerableDataStream{T,S,TC}, state)
    constructor_call = Expr(:call, :($T))
    for i in 1:length(TC.types)
    	col_type = TC.types[i] <: WeakRefString ? String : TC.types[i]
        push!(constructor_call.args, :(Data.getfield(source, $col_type, row, $i)))
    end

    quote
    	source = iter.source
        row = state
        a = $constructor_call
        return a, state+1
    end
end

function done{T, S<:DataStreams.Data.Source, TC}(iter::EnumerableDataStream{T,S,TC}, state)
    return Data.isdone(iter.source,state,1)
end

end
