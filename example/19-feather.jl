using Query, DataFrames, FileIO, FeatherFiles

testfile = joinpath(Pkg.dir("FeatherLib"),"test", "data", "airquality.feather")

results = @from i in load(testfile) begin
    @select i
    @collect DataFrame
end

println(results)
