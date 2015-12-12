using LINQ
using DataFrames
using NamedTuples
using TypedTables

tt = @Table(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in tt begin
    @where i.age>30. && i.children >2
    @select @NT(Name=>lowercase(i.name))
end collect(DataFrame)

println(x)
