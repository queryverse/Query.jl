@require StatsModels begin

import DataFrames

@traitfn function StatsModels.ModelFrame{X; IsIterableTable{X}}(f::StatsModels.Formula, d::X; kwargs...)
    StatsModels.ModelFrame(f, DataFrames.DataFrame(d); kwargs...)
    end

end
