using Query
using DataFrames
using NamedTuples

source = Dict("John"=>34., "Sally"=>56.)

result = @from i in source begin
         @where i.second>36.
         @select @NT(Name=>lowercase(i.first))
end collect(DataFrame)

println(result)

result = @from i in source begin
         @where i.second>36.
         @select @NT(Name=>lowercase(i.first))
end collect()

println(result)
