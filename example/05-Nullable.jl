using Query
using TypedTables
using NamedTuples
using DataFrames

df = @Table(name=Nullable{String}["John", "Sally", "Kirk"], age=Nullable{Float64}[23., 42., 59.], children=Nullable{Int64}[3,5,2])

# The generaly philosophy here is to not offer anything beyond standard julia
# Nullables
x = @from i in df begin
    @where i.age>30 && i.children >2
    @select @NT(Name=>lowercase(i.name))
    @collect DataFrame
end

println(x)
