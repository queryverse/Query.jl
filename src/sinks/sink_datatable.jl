@require DataTables begin
using NullableArrays

function collect(enumerable::Enumerable, ::Type{DataTables.DataTable})
    return DataTables.DataTable(enumerable)
end

function collect{TS,Provider}(source::Queryable{TS,Provider}, ::Type{DataTables.DataTable})
    collect(query(collect(source)), DataTables.DataTable)
end

end
