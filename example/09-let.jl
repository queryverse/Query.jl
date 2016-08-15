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
	@let count = length(i.name)
	@where count > 4
    @select @NT(Name=>i.name, Count=>count)
    @collect DataFrame
end

println(x)
