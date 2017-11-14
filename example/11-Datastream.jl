using Query
using DataStreams
using CSV

q = @from i in CSV.Source("data.csv", categorical=false) begin
    @where i.Children > 2
    @select i.Name
    @collect
end

println(q)
