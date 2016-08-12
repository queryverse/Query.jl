using Query
using TypedTables
using NamedTuples

df = @Table(name=Nullable{String}["John", "Sally", "Kirk"], age=Nullable{Float64}[23., 42., 59.], children=Nullable{Int64}[3,5,2])

# The generaly philosophy here is to not offer anything beyond standard julia
# Nullables
x = @from i in df begin
    @where get(i.age)>30. && get(i.children) >2
    @select @NT(Name=>lowercase(get(i.name)))
end collect(DataFrame)

println(x)
