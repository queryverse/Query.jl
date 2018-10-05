using Query
using DataFrames
using VegaDatasets
using Test

@testset "Select Macro" begin
    
    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a", "b", "c"])

    @test df |> Query.@select(-foo) == DataFrame(bar=[3.,2.,1.], bat=["a", "b", "c"])
    @test df |> Query.@select(-far) == df
    @test_skip df |> Query.@select(startswith(b)) |> DataFrame(bar=[3.,2.,1.], bat=["a", "b", "c"])
    @test_skip df |> Query.@select(endswith(ar)) |> DataFrame(bar=[3.,2.,1.],)
    

end