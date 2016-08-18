using Query
using DataStreams
using CSV

q = @from i in CSV.Source("data.csv") begin
    @where get(i.Children) > 2
    @select get(i.Name)
    @collect
end

println(q)
