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

function Data.isdone{TSource,TE}(source::DataStreamSource{TSource,TE}, row, col)
    row==source.current_row || row==source.current_row+1 || error()

    if source.current_row==0
        source.iterate_state = start(source.data)
    end

    if row==source.current_row+1
        if done(source.data, source.iterate_state)
            return true
        else
            (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
            source.current_row = source.current_row+1
        end
    end

    return false
end

Data.streamtype{T<:DataStreamSource}(::Type{T}, ::Type{Data.Field}) = true

function Data.streamfrom{T}(source::DataStreamSource, ::Type{Data.Field}, ::Type{T}, row, col)
    row==source.current_row || row==source.current_row+1 || error()

    if source.current_row==0
        source.iterate_state = start(source.data)
    end

    if row==source.current_row+1
        (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
        source.current_row = source.current_row+1
    end

    return source.current_val[col]::T
end

function Data.streamfrom{T}(source::DataStreamSource, ::Type{Data.Field}, ::Type{Nullable{T}}, row, col)
    row==source.current_row || row==source.current_row+1 || error()

    if source.current_row==0
        source.iterate_state = start(source.data)
    end

    if row==source.current_row+1
        (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
        source.current_row = source.current_row+1
    end

    val = source.current_val[col]

    if typeof(val) <: DataValue
        if isnull(val)
            return Nullable{T}()
        else
            return Nullable{T}(get(val))
        end
    else
        return Nullable{T}(val)
    end
end

function Data.schema(source::DataStreamSource)
    return source.schema
end

function Data.schema(source::DataStreamSource, ::Type{Data.Field})
    return Data.schema(source)
end

function collect{TSink<:Data.Sink}(enumerable::Enumerable, sink::TSink)
    T = eltype(enumerable)
    if !(T<:NamedTuple)
        error("Can only collect a NamedTuple iterator into a Data.Sink.")
    end

    schema = Data.Schema(fieldnames(T),[i <: DataValue ? Nullable{i.parameters[1]} : i for i in T.parameters],-1)
    source = DataStreamSource{typeof(enumerable),T}(schema, enumerable)
    Data.stream!(source, sink)
    return sink
end

end
