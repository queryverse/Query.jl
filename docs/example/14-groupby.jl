using Query
using DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = @from i in df begin
    @group i.name by i.children
    @collect
end

println(x)

x = @from i in df begin
    @group i by i.children
    @collect
end

println(x)
