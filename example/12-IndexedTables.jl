using Query
using IndexedTables

source_ndsparsearray1 = NDSparse([fill("New York",3); fill("Boston",3)],
                            repmat(Date(2016,7,6):Date(2016,7,8), 2),
                            [91,89,91,95,83,76])

q = @from i in source_ndsparsearray1 begin
    @where i.index[1]=="Boston"
    @select i.value
    @collect
end

println(q)

source_ndsparsearray2 = NDSparse(Columns(city = [fill("New York",3); fill("Boston",3)],
                            date = repmat(Date(2016,7,6):Date(2016,7,8), 2)),
                            [91,89,91,95,83,76])

q = @from i in source_ndsparsearray2 begin
    @where i.index.city=="New York"
    @select i.value
    @collect
end

println(q)
