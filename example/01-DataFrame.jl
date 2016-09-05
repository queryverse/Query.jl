using Query
using DataFrames
using NamedTuples

# We want a DataFrame without Nullable's, so
# we need to construct a DataFrame with columns of Array
columns=[]
push!(columns, ["John", "Sally", "Kirk"])
push!(columns, [23., 42., 59.])
push!(columns, [3,5,2])
df = DataFrame(columns, [:name, :age, :children])

x = @from i in df begin
    @where i.age>30. && i.children > 2
    @select {Name=lowercase(i.name)}
    @collect DataFrame
end

println(x)
