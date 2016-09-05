using Query
using DataFrames
using NamedTuples

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = @from i in df begin
    @group i by i.children into g
    @select {Key=g.key,Count=length(g)}
    @collect DataFrame
end

println(x)
