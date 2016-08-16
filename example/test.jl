using Query
using NamedTuples

s = [1,2,3]
x = @from x in s begin
    @let y = -x
    @let z = x^2
    @select x,y,z
    @collect
end

println(x)
