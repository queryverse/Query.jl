using Query
using DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = @from i in df begin
    @select i into j
    @select j
    @collect DataFrame
end

println(x)
