@require DataStreams begin
using DataStreams

type DataStreamSource{TSource,TE} <: Data.Source
    schema::Data.Schema
    data::TSource
    iterate_state
    current_row::Int
    current_val::TE
    function DataStreamSource(schema, data)
        x = new(schema, data)
        x.current_row = 0
        return x
    end
end

function Data.reset!(io::DataStreamSource)
    io.iterate_state = start(io.data)
    io.current_row = 0
    io.schema.rows=-1
end

function Data.isdone{TSource,TE}(source::DataStreamSource{TSource,TE}, row, col)
    if row<source.current_row
        error()
    elseif row==source.current_row+1
        if done(source.data, source.iterate_state)
            return true
        else
            (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
            source.current_row = source.current_row+1
        end
    elseif row>source.current_row
        error()
    end

    return false
end

Data.streamtype{T<:DataStreamSource}(::Type{T}, ::Type{Data.Field}) = true

function Data.getfield{T}(source::DataStreamSource, ::Type{T}, row, col)
    if row<source.current_row
        error()
    elseif row==source.current_row+1
        (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
        source.current_row = source.current_row+1
    elseif row>source.current_row
        error()
    end

    return source.current_val[col]::T
end

function Data.getfield{T}(source::DataStreamSource, ::Type{Nullable{T}}, row, col)
    if row<source.current_row
        error()
    elseif row==source.current_row+1
        (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
        source.current_row = source.current_row+1
    elseif row>source.current_row
        error()
    end

    return Nullable{T}(source.current_val[col])
end

function collect{T<:NamedTuple, TSink<:Data.Sink}(enumerable::Enumerable{T}, sink::TSink)
    schema = Data.Schema(fieldnames(T),[convert(DataType,i) for i in T.parameters],-1)
    source = DataStreamSource{typeof(enumerable),T}(schema, enumerable)
    Data.reset!(source)
    Data.stream!(source, sink)
    return sink
end

end
