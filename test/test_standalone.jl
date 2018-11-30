using Query
using DataFrames
using Test

@testset "Standalone Syntax" begin

@testset "@take operator" begin
    df = DataFrame(a=[1,2,3], b=[3.,2.,1.], c=["a", "b", "c"])

    df2 = df |> @take(2) |> DataFrame

    @test df2 isa DataFrame
    @test size(df2) == (2,3)
    @test df2[:a] == [1,2]
    @test df2[:b] == [3.,2.]
    @test df2[:c] == ["a", "b"]

    df2 = DataFrame(@take(df, 2))

    @test df2 isa DataFrame
    @test size(df2) == (2,3)
    @test df2[:a] == [1,2]
    @test df2[:b] == [3.,2.]
    @test df2[:c] == ["a", "b"]
end

@testset "@drop operator" begin
    df = DataFrame(a=[1,2,3], b=[3.,2.,1.], c=["a", "b", "c"])

    df2 = df |> @drop(1) |> DataFrame

    @test df2 isa DataFrame
    @test size(df2) == (2,3)
    @test df2[:a] == [2,3]
    @test df2[:b] == [2.,1.]
    @test df2[:c] == ["b","c"]

    df2 = DataFrame(@drop(df, 1))

    @test df2 isa DataFrame
    @test size(df2) == (2,3)
    @test df2[:a] == [2,3]
    @test df2[:b] == [2.,1.]
    @test df2[:c] == ["b","c"]
end

@testset "@gather operator" begin

    @test iterate((Year=[2017,2018,2019], US=[1,2,3], EU=[1,2,3], CN=[1,2,3]) |> @gather) == nothing
    @test iterate((Year=[2017,2018,2019], US=[1,2,3], EU=[1,2,3], CN=[1,2,3]) |> @gather(:US, :EU, :CN)) == ((key = :US, value = 1, Year = 2017), (Any[(key = :US, value = 1, Year = 2017), (key = :EU, value = 1, Year = 2017), (key = :CN, value = 1, Year = 2017), (key = :US, value = 2, Year = 2018), (key = :EU, value = 2, Year = 2018), (key = :CN, value = 2, Year = 2018), (key = :US, value = 3, Year = 2019), (key = :EU, value = 3, Year = 2019), (key = :CN, value = 3, Year = 2019)], 2))
    @test eltype((Year=[2017,2018,2019], US=[1,2,3], EU=[1,2,3], CN=[1,2,3]) |> @gather(:US, :EU, :CN)) == NamedTuple{(:key, :value, :Year),Tuple{Symbol,Int64,Int64}}

end

end
