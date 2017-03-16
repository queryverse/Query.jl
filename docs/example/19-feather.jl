using Query, DataFrames, Feather

testfile = joinpath(Pkg.dir("Feather"),"test", "data", "airquality.feather")

results = @from i in Feather.Source(testfile) begin
    @select i
    @collect DataFrame
end

println(results)
