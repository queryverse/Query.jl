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

# Note that we are using a local julia variable that
# has the same name as the column in the DataFrame
children = 2

x = @from i in df begin
    @where i.age>30. && i.children > children
    @select @NT(Name=>lowercase(i.name))
end collect(DataFrame)

println(x)
