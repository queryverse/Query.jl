@require DataFrames begin

function collect(enumerable::Enumerable, ::Type{DataFrames.DataFrame})
    return DataFrames.DataFrame(enumerable)
end

function collect{TS,Provider}(source::Queryable{TS,Provider}, ::Type{DataFrames.DataFrame})
    collect(query(collect(source)), DataFrames.DataFrame)
end

end
