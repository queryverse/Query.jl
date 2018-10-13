using Query
using DataFrames
using Test

@testset "Select Macro" begin
    
    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])

    @test df |> Query.@select(:bat) |> DataFrame == DataFrame((bat=["a","b","c"],))
    @test df |> Query.@select(-:foo) |> DataFrame == DataFrame(bar=[3.,2.,1.], bat=["a","b","c"])
    @test df |> Query.@select(-:far) |> DataFrame == df
    @test df |> Query.@select(startswith("b")) |> DataFrame == DataFrame(bar=[3.,2.,1.], bat=["a","b","c"])
    @test df |> Query.@select(endswith("ar")) |> DataFrame == DataFrame(bar=[3.,2.,1.],)
    @test df |> Query.@select(occursin("a")) |> DataFrame == DataFrame(bar=[3.,2.,1.],bat=["a","b","c"])
    @test df |> Query.@select(rangeat(:foo, :bar)) |> DataFrame == DataFrame(foo=[1,2,3], bar=[3.,2.,1.])

    @test df |> Query.@select(startswith("b"), endswith("r")) |> DataFrame == DataFrame(bar=[3.,2.,1.],)
    @test df |> Query.@select(occursin("o"), startswith("ba")) |> DataFrame == DataFrame()

end

@testset "Rename Macro" begin

    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])

    @test df |> Query.@rename(foo = far) |> DataFrame == DataFrame(far=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])
    @test df |> Query.@rename(voo = var) |> DataFrame == df
    @test df |> Query.@rename(bar = ban, bat = far) |> DataFrame == DataFrame(foo=[1,2,3], ban=[3.,2.,1.], far=["a","b","c"])
    @test df |> Query.@rename(bar = ban, ban = far) |> DataFrame == DataFrame(foo=[1,2,3], far=[3.,2.,1.], bat=["a","b","c"])

    @test df |> Query.@rename(bar = far) |> Query.@select(startswith("f")) |> DataFrame == DataFrame(foo=[1,2,3], far=[3.,2.,1.])

end

@testset "Mutate Macro" begin

    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a", "b", "c"])

end