using Query
using TypedTables
using DataFrames

df = @Table(name=Nullable{String}["John", "Sally", "Kirk"], age=Nullable{Float64}[23., 42., 59.], children=Nullable{Int64}[3,5,2])

x = @from i in df begin
    @where i.age>30 && i.children >2
    @select {Name=lowercase(get(i.name))}
    @collect DataFrame
end

println(x)
