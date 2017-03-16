@require DataFrames begin

@generated function _filldf(columns, enumerable)
    n = length(columns.types)
    push_exprs = Expr(:block)
    for i in 1:n
        if columns.parameters[i] <: DataArray
            ex = :( push!(columns[$i], isnull(i[$i]) ? NA : get(i[$i])) )
        else
            ex = :( push!(columns[$i], i[$i]) )
        end
        push!(push_exprs.args, ex)
    end

    quote
        for i in enumerable
            $push_exprs
        end
    end
end

function collect(enumerable::Enumerable, ::Type{DataFrames.DataFrame})
    return DataFrames.DataFrame(enumerable)
end

@traitfn function DataFrames.DataFrame{X; IsTypedIterable{X}}(x::X)
    iter = get_typed_iterator(x)

    T = eltype(iter)
    if !(T<:NamedTuple)
        error("Can only collect a NamedTuple iterator into a DataFrame")
    end

    columns = []
    for t in T.types
        if isa(t, TypeVar)
            push!(columns, Array(Any,0))
        elseif t <: DataValue
            push!(columns, DataArray(t.parameters[1],0))
        else
            push!(columns, Array(t,0))
        end
    end
    df = DataFrames.DataFrame(columns, fieldnames(T))
    _filldf((df.columns...), iter)
    return df
end

function collect{TS,Provider}(source::Queryable{TS,Provider}, ::Type{DataFrames.DataFrame})
    collect(query(collect(source)), DataFrames.DataFrame)
end

@traitfn DataFrames.ModelFrame{X; IsTypedIterable{X}}(f::DataFrames.Formula, d::X; kwargs...) = DataFrames.ModelFrame(f, DataFrames.DataFrame(d); kwargs...)

@traitfn function StatsBase.fit{T<:StatsBase.StatisticalModel, X; IsTypedIterable{X}}(::Type{T}, f::DataFrames.Formula, source::X, args...; contrasts::Dict = Dict(), kwargs...)
    mf = DataFrames.ModelFrame(f, source, contrasts=contrasts)
    mm = DataFrames.ModelMatrix(mf)
    y = model_response(mf)
    DataFrames.DataFrameStatisticalModel(fit(T, mm.m, y, args...; kwargs...), mf, mm)
end

@traitfn function StatsBase.fit{T<:StatsBase.RegressionModel, X; IsTypedIterable{X}}(::Type{T}, f::DataFrames.Formula, source::X, args...; contrasts::Dict = Dict(), kwargs...)
    mf = DataFrames.ModelFrame(f, source, contrasts=contrasts)
    mm = DataFrames.ModelMatrix(mf)
    y = model_response(mf)
    DataFrames.DataFrameRegressionModel(fit(T, mm.m, y, args...; kwargs...), mf, mm)
end

end
