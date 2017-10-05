using Query
using TypedTables
using DataFrames
using NullableArrays

df = @Table(name=NullableArray(["John", "Sally", "Kirk"]), age=NullableArray([23., 42., 59.]), children=NullableArray([3,5,2]))

x = @from i in df begin
    @where i.age>30 && i.children >2
    @select {Name=lowercase(i.name)}
    @collect DataFrame
end

println(x)
