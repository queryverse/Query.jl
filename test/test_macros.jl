using Query
using DataFrames
using Test

@testset "Select Macro" begin
    
    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])

    @test DataFrame(df |> @select(:bat)) == DataFrame(bat=["a","b","c"],)
    @test DataFrame(df |> @select(-:foo)) == DataFrame(bar=[3.,2.,1.], bat=["a","b","c"])
    @test DataFrame(df |> @select(-:far)) == df
    @test DataFrame(df |> @select(startswith("b"))) == DataFrame(bar=[3.,2.,1.], bat=["a","b","c"])
    @test DataFrame(df |> @select(endswith("ar"))) == DataFrame(bar=[3.,2.,1.],)
    @test DataFrame(df |> @select(occursin("a"))) == DataFrame(bar=[3.,2.,1.], bat=["a","b","c"])
    @test DataFrame(df |> @select(rangeat(:foo, :bar))) == DataFrame(foo=[1,2,3], bar=[3.,2.,1.])

    @test DataFrame(df |> @select(:foo, :bar, :bat)) == df
    @test DataFrame(df |> @select(startswith("f"), endswith("t"))) == DataFrame(foo=[1,2,3], bat=["a","b","c"])
    @test DataFrame(df |> @select(-1, 1)) == DataFrame(bar=[3.,2.,1.],bat=["a","b","c"], foo=[1,2,3])
    @test DataFrame(df |> @select(rangeat(:bar, :bat), -2)) == DataFrame(bar=[3.,2.,1.],)

end

@testset "Rename Macro" begin

    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])

    @test DataFrame(df |> @rename(:foo => :far)) == DataFrame(far=[1,2,3], bar=[3.,2.,1.], bat=["a","b","c"])
    @test DataFrame(df |> @rename(:voo => :var)) == df
    @test DataFrame(df |> @rename(:bar => :ban, :bat => :far)) == DataFrame(foo=[1,2,3], ban=[3.,2.,1.], far=["a","b","c"])
    @test DataFrame(df |> @rename(:bar => :ban, :ban => :far)) == DataFrame(foo=[1,2,3], far=[3.,2.,1.], bat=["a","b","c"])
    @test DataFrame(df |> @rename(3 => :three)) == DataFrame(foo=[1,2,3], bar=[3.,2.,1.], three=["a","b","c"])

    @test DataFrame(df |> @rename(:bar => :far) |> @select(startswith("f"))) == DataFrame(foo=[1,2,3], far=[3.,2.,1.])

end

@testset "Mutate Macro" begin

    df = DataFrame(foo=[1,2,3], bar=[3.,2.,1.], bat=["a", "b", "c"])

    @test DataFrame(df |> @mutate(foo = 1)) == DataFrame(foo=[1,1,1], bar=[3.,2.,1.], bat=["a","b","c"])
    @test DataFrame(df |> @mutate(bar = _.foo - 2 * _.bar, fat = _.bat * _.bat)) == DataFrame(foo=[1,2,3], bar=[-5.,-2.,1.], bat=["a","b","c"], fat=["aa","bb","cc"])

end
