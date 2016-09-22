@require DataFrames begin
using DataArrays

# T is the type of the elements produced
# TS is a tuple type that stores the columns of the DataFrame
immutable EnumerableDF{T, TS} <: Enumerable{T}
    df::DataFrames.DataFrame
    # This field hols a tuple with the columns of the DataFrame.
    # Having a tuple of the columns here allows the iterator
    # functions to access the columns in a type stable way.
    columns::TS
end

function query(df::DataFrames.DataFrame)
    col_expressions = Array{Expr,1}()
    df_columns_tuple_type = Expr(:curly, :Tuple)
    for i in 1:length(df.columns)
        if isa(df.columns[i], DataArray)
            push!(col_expressions, Expr(:(::), names(df)[i], Nullable{eltype(df.columns[i])}))
        else
            push!(col_expressions, Expr(:(::), names(df)[i], eltype(df.columns[i])))
        end
        push!(df_columns_tuple_type.args, typeof(df.columns[i]))
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(Query.EnumerableDF{Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = df_columns_tuple_type

    eval(NamedTuples, :(import Query))
    t = eval(NamedTuples, t2)

    e_df = t(df, (df.columns...))

    return e_df
end

function length{T,TS}(iter::EnumerableDF{T,TS})
    return size(iter.df,1)
end

function eltype{T,TS}(iter::EnumerableDF{T,TS})
    return T
end

function start{T,TS}(iter::EnumerableDF{T,TS})
    return 1
end

@generated function next{T,TS}(iter::EnumerableDF{T,TS}, state)
    constructor_call = Expr(:call, :($T))
    for i in 1:length(iter.types[2].types)
        if iter.parameters[1].parameters[i] <: Nullable
            push!(constructor_call.args, :(isna(columns[$i][i]) ? $(iter.parameters[1].parameters[i])() : columns[$i][i]))
        else
            push!(constructor_call.args, :(columns[$i][i]))
        end
    end

    quote
        i = state
        columns = iter.columns
        a = $constructor_call
        return a, state+1
    end
end

function done{T,TS}(iter::EnumerableDF{T,TS}, state)
    return state>size(iter.df,1)
end

end
