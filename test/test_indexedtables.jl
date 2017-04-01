using IndexedTables

source_indexedtable = IndexedTable(Columns(city = [fill("New York",3); fill("Boston",3)],
    date = repmat(Date(2016,7,6):Date(2016,7,8), 2)),
    Columns(value=[91,89,91,95,83,76]))

q = @from i in source_indexedtable begin
    @where i.city=="New York"
    @select i.value
    @collect
end

@test isa(q, Array{Int,1})
@test length(q)==3
@test q==[91,89,91]
