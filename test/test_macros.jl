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
    @test DataFrame(df |> @select(!occursin("a"))) == DataFrame(foo=[1,2,3],)
    @test DataFrame(df |> @select(:foo : :bar)) == DataFrame(foo=[1,2,3], bar=[3.,2.,1.])
    @test DataFrame(df |> @select(2:3, -endswith("at"))) == DataFrame(bar=[3.,2.,1.],)
    @test DataFrame(df |> @select(1:3)) == DataFrame(df |> @select(everything()))

    @test DataFrame(df |> @select(:foo, :bar, :bat)) == df
    @test DataFrame(df |> @select(startswith("f"), endswith("t"))) == DataFrame(foo=[1,2,3], bat=["a","b","c"])
    @test DataFrame(df |> @select(-1, 1)) == DataFrame(bar=[3.,2.,1.],bat=["a","b","c"], foo=[1,2,3])
    @test DataFrame(df |> @select(:bar : :bat, -2)) == DataFrame(bar=[3.,2.,1.],)

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

    # test a closure

    closure_val = 1
    @test DataFrame(df |> @mutate(foo = closure_val)) == DataFrame(foo=[1,1,1], bar=[3.,2.,1.], bat=["a","b","c"])
end

@testset "@dropna" begin

    df = DataFrame(a=[1,missing,3], b=[1.,2.,3.])

    @test df |> @dropna() |> collect == [(a=1,b=1.), (a=3, b=3.)]
    @test df |> @filter(!any(isna, _)) |> @dropna() |> collect == [(a=1,b=1.), (a=3, b=3.)]
    @test df |> @select(:b) |> @dropna() |> collect == [(b=1.,),(b=2.,),(b=3.,)]

    @test df |> @dropna(:a) |> collect == [(a=1,b=1.), (a=3, b=3.)]
    @test df |> @dropna(:b) |> collect == [(a=DataValue(1),b=1.), (a=DataValue{Int}(),b=2.),(a=DataValue(3), b=3.)]
    @test df |> @dropna(:a, :b) |> collect == [(a=1,b=1.), (a=3, b=3.)]
end

@testset "@replacena" begin

    df = DataFrame(a=[1,missing,3], b=[1.,2.,3.])

    @test df |> @replacena(2) |> collect == [(a=1,b=1.), (a=2, b=2.), (a=3, b=3.)]
    @test df |> @dropna() |> @replacena(2) |> collect == [(a=1,b=1.), (a=3, b=3.)]
    @test df |> @select(:b) |> @replacena(2) |> collect == [(b=1.,),(b=2.,),(b=3.,)]

    @test df |> @replacena(:a=>2) |> collect == [(a=1,b=1.), (a=2, b=2.), (a=3, b=3.)]
    @test df |> @replacena(:b=>2) |> collect == [(a=DataValue(1),b=1.), (a=DataValue{Int}(),b=2.),(a=DataValue(3), b=3.)]
    @test df |> @replacena(:a=>2, :b=>8) |> collect == [(a=1,b=1.), (a=2, b=2.), (a=3, b=3.)]
end

@testset "@dissallowna" begin

    df = DataFrame(a=[1,missing,3], b=[1.,2.,3.])

    @test_throws DataValueException df |> @dissallowna() |> collect
    @test df |> @filter(!any(isna, _)) |> @dissallowna() |> collect == [(a=1,b=1.), (a=3, b=3.)]
    @test_throws DataValueException df |> @dissallowna(:a) |> collect
    @test df |> @dissallowna(:b) |> collect == [(a=DataValue(1),b=1.), (a=DataValue{Int}(),b=2.),(a=DataValue(3), b=3.)]
end
