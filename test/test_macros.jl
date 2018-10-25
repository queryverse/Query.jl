using Query
using DataFrames
using Test

@testset "Select Macro" begin
    
    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])

    @test_skip df |> Query.@select(:bat) |> DataFrame == DataFrame((bat=["a","b","c"],))
    @test_skip df |> Query.@select(-:foo) |> DataFrame == DataFrame(bar=[3.,2.,1.], bat=["a","b","c"])
    @test_skip df |> Query.@select(-:far) |> DataFrame == df
    @test_skip df |> Query.@select(startswith("b")) |> DataFrame == DataFrame(bar=[3.,2.,1.], bat=["a","b","c"])
    @test_skip df |> Query.@select(endswith("ar")) |> DataFrame == DataFrame(bar=[3.,2.,1.],)
    @test_skip df |> Query.@select(occursin("a")) |> DataFrame == DataFrame(bar=[3.,2.,1.],bat=["a","b","c"])
    @test_skip df |> Query.@select(rangeat(:foo, :bar)) |> DataFrame == DataFrame(foo=[1,2,3], bar=[3.,2.,1.])

    @test_skip df |> Query.@select(:foo, :bar, :bat) |> DataFrame == df
    @test_skip df |> Query.@select(startswith("f"), endswith("t")) |> DataFrame == DataFrame(foo=[1,2,3], bat=["a","b","c"])

end

@testset "Rename Macro" begin

    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])

    @test df |> Query.@rename(:foo => :far) |> DataFrame == DataFrame(far=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])
    @test df |> Query.@rename(:voo => :var) |> DataFrame == df
    @test df |> Query.@rename(:bar => :ban, :bat => :far) |> DataFrame == DataFrame(foo=[1,2,3], ban=[3.,2.,1.], far=["a","b","c"])
    @test df |> Query.@rename(:bar => :ban, :ban => :far) |> DataFrame == DataFrame(foo=[1,2,3], far=[3.,2.,1.], bat=["a","b","c"])

    @test_skip df |> Query.@rename(:bar => :far) |> Query.@select(startswith("f")) |> DataFrame == DataFrame(foo=[1,2,3], far=[3.,2.,1.])

end

@testset "Mutate Macro" begin

    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a", "b", "c"])

    @test df |> Query.@mutate(foo = 1) |> DataFrame == (foo=[1,1,1], bar=[3.,2.,1.], bat=["a","b","c"]) |> DataFrame
    @test df |> Query.@mutate(bar = _.foo - 2 * _.bar, fat = _.bat * _.bat) |> DataFrame == (foo=[1,2,3], bar=[-5.,-2.,1.], bat=["a","b","c"], fat=["aa","bb","cc"]) |> DataFrame

end