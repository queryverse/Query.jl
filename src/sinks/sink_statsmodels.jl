@require StatsModels begin

import DataTables
import StatsBase

@traitfn function StatsModels.ModelFrame{X; IsIterableTable{X}}(f::StatsModels.Formula, d::X; kwargs...)
    StatsModels.ModelFrame(f, DataTables.DataTable(d); kwargs...)
end

@traitfn function StatsBase.fit{T<:StatsBase.StatisticalModel, X; IsIterableTable{X}}(::Type{T}, f::StatsModels.Formula, source::X, args...; contrasts::Dict = Dict(), kwargs...)
    mf = StatsModels.ModelFrame(f, source, contrasts=contrasts)
    mm = StatsModels.ModelMatrix(mf)
    y = StatsBase.model_response(mf)
    StatsModels.DataTableStatisticalModel(StatsBase.fit(T, mm.m, y, args...; kwargs...), mf, mm)
end

@traitfn function StatsBase.fit{T<:StatsBase.RegressionModel, X; IsIterableTable{X}}(::Type{T}, f::StatsModels.Formula, source::X, args...; contrasts::Dict = Dict(), kwargs...)
    mf = StatsModels.ModelFrame(f, source, contrasts=contrasts)
    mm = StatsModels.ModelMatrix(mf)
    y = StatsBase.model_response(mf)
    StatsModels.DataTableRegressionModel(StatsBase.fit(T, mm.m, y, args...; kwargs...), mf, mm)
end

end
