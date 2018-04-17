using IndexedTables

source_indexedtable = table([fill("New York",3); fill("Boston",3)],
    repmat(Date(2016,7,6):Date(2016,7,8), 2),[91,89,91,95,83,76], names=[:city, :date, :value])

q = @from i in source_indexedtable begin
    @where i.city=="New York"
    @select i.value
    @collect
end

@test isa(q, Array{Int,1})
@test length(q)==3
@test q==[91,89,91]
