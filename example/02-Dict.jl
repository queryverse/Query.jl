using Query
using DataFrames
using NamedTuples

source = Dict("John"=>34., "Sally"=>56.)

result = @from i in source begin
         @where i.second>36.
         @select @NT(Name=>lowercase(i.first))
         @collect DataFrame
end

println(result)

result = @from i in source begin
         @where i.second>36.
         @select @NT(Name=>lowercase(i.first))
         @collect
end

println(result)
