using Query
using DataFrames
using NamedTuples

# We want a DataFrame without Nullable's, so
# we need to construct a DataFrame with columns of Array
columns=[]
push!(columns, ["John", "Sally", "Kirk"])
push!(columns, [34., 23., 59.])
push!(columns, [3,5,2])
df = DataFrame(columns, [:name, :age, :children])

x = @from i in df begin
    @orderby i.age
    @select @NT(Name=>lowercase(i.name))
    @collect DataFrame
end

println(x)

x = @from i in df begin
    @orderby descending(i.age)
    @select @NT(Name=>lowercase(i.name))
    @collect DataFrame
end

println(x)

x = @from i in df begin
    @orderby ascending(i.age)
    @select @NT(Name=>lowercase(i.name))
    @collect DataFrame
end

println(x)
