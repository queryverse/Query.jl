using Query
using DataFrames
using TypedTables

tt = @Table(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in tt begin
    @where i.age>30. && i.children >2
    @select {Name=lowercase(i.name)}
    @collect DataFrame
end

println(x)
