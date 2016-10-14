using Query
using DataFrames

# We want a DataFrame without Nullable's, so
# we need to construct a DataFrame with columns of Array
columns=[]
push!(columns, ["John", "Sally", "Kirk"])
push!(columns, [23., 42., 59.])
push!(columns, [3,5,2])
df = DataFrame(columns, [:name, :age, :children])

# It happens that the whole thing also works fairly well
# with standard julia generator syntax. Probably would make
# sense to think hard how that could be integrated better...
# In some way the generator syntax right now is a little bit
# like a "query syntax light".

x = collect(i.name for i in Query.query(df) if i.age>30.)
println(x)

x = collect(@NT(Name=>i.name) for i in Query.query(df) if i.age>30.)
println(x)

x = collect(Query.query(x), DataFrame)
println(x)
