@require IndexedTables begin
using IndexedTables: NDSparse

immutable NDSparseIterator{T, S<:NDSparse}
    source::S
end

immutable IndexedTablesRow{TIndex,TValue}
    index::TIndex
    value::TValue
end

@traitimpl IsIterable{IndexedTables.NDSparse}

function getiterator{S<:NDSparse}(source::S)
    TValue = S.parameters[1]
    if S.parameters[3]<:NamedTuples.NamedTuple
        col_expressions = Array{Expr,1}()
        columns_tuple_type = Expr(:curly, :Tuple)

        for (i,fieldname) in enumerate(fieldnames(S.parameters[3]))
            col_type = S.parameters[2].parameters[i]
            push!(col_expressions, Expr(:(::), fieldname, col_type))
            push!(columns_tuple_type.args, col_type)
        end
        t_expr = NamedTuples.make_tuple(col_expressions)
        TIndex = eval(NamedTuples, t_expr)
    else
        TIndex = S.parameters[2]
    end

    e_df = NDSparseIterator{IndexedTablesRow{TIndex,TValue},S}(source)

    return e_df
end

Base.eltype{T,S<:NDSparse}(iter::NDSparseIterator{T,S}) = T

Base.eltype{T,S<:NDSparse}(iter::Type{NDSparseIterator{T,S}}) = T

function start{T,S<:NDSparse}(iter::NDSparseIterator{T,S})
    return 1
end

@generated function next{T,S<:NDSparse}(iter::NDSparseIterator{T,S}, state)
    if T.parameters[1]<:NamedTuples.NamedTuple
        constructor_call = Expr(:call, :IndexedTablesRow, Expr(:call,T.parameters[1]),:(iter.source.data[row]))
        for i in 1:length(S.parameters[2].parameters)
            push!(constructor_call.args[2].args, :( iter.source.index.columns[$i][row] ))
        end
    else
        constructor_call = Expr(:call, :IndexedTablesRow,:((1,)),:(iter.source.data[row]))
        constructor_call.args[2].args[1] = :( iter.source.index.columns[1][row] )
        for i in 2:length(S.parameters[2].parameters)
            push!(constructor_call.args[2].args, :( iter.source.index.columns[$i][row] ))
        end
    end

    quote
        source = iter.source
        row = state
        a = $constructor_call
        return a, state+1
    end
end

function done{T,S<:NDSparse}(iter::NDSparseIterator{T,S}, state)
    return state>length(iter.source)
end

end
