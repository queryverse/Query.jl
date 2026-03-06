using Query
using DataFrames
using DataValues
using Test

@testset "Standalone Syntax" begin

@testset "@take operator" begin
    df = DataFrame(a=[1,2,3], b=[3.,2.,1.], c=["a", "b", "c"])

    df2 = df |> @take(2) |> DataFrame

    @test df2 isa DataFrame
    @test size(df2) == (2,3)
    @test df2[!, :a] == [1,2]
    @test df2[!, :b] == [3.,2.]
    @test df2[!, :c] == ["a", "b"]

    df2 = DataFrame(@take(df, 2))

    @test df2 isa DataFrame
    @test size(df2) == (2,3)
    @test df2[!, :a] == [1,2]
    @test df2[!, :b] == [3.,2.]
    @test df2[!, :c] == ["a", "b"]
end

@testset "@drop operator" begin
    df = DataFrame(a=[1,2,3], b=[3.,2.,1.], c=["a", "b", "c"])

    df2 = df |> @drop(1) |> DataFrame

    @test df2 isa DataFrame
    @test size(df2) == (2,3)
    @test df2[!, :a] == [2,3]
    @test df2[!, :b] == [2.,1.]
    @test df2[!, :c] == ["b","c"]

    df2 = DataFrame(@drop(df, 1))

    @test df2 isa DataFrame
    @test size(df2) == (2,3)
    @test df2[!, :a] == [2,3]
    @test df2[!, :b] == [2.,1.]
    @test df2[!, :c] == ["b","c"]
end

@testset "@unique operator" begin
    df = DataFrame(a=[1,2,1], b=[3.,3.,3.])

    @test df |> @unique() |> collect == [(a=1,b=3.), (a=2,b=3.)]
    @test df |> @unique(_.b) |> collect == [(a=1,b=3.)]
end

@testset "@pivot_longer operator" begin
    df = DataFrame(year=[2017,2018], US=[1,3], EU=[2,4])

    # Pipe form
    result = df |> @pivot_longer(:US, :EU) |> collect
    @test length(result) == 4
    @test eltype(result) == NamedTuple{(:year, :variable, :value), Tuple{Int64, Symbol, Int64}}
    @test result[1] == (year=2017, variable=:US, value=1)
    @test result[2] == (year=2017, variable=:EU, value=2)
    @test result[3] == (year=2018, variable=:US, value=3)
    @test result[4] == (year=2018, variable=:EU, value=4)

    # Direct form
    result2 = @pivot_longer(df, :US, :EU) |> collect
    @test result2 == result

    # Collects into a DataFrame
    df2 = df |> @pivot_longer(:US, :EU) |> DataFrame
    @test df2 isa DataFrame
    @test size(df2) == (4, 3)
    @test names(df2) == ["year", "variable", "value"]

    # Custom output column names (pipe form)
    result3 = df |> @pivot_longer(:US, :EU, names_to=:country, values_to=:sales) |> collect
    @test length(result3) == 4
    @test fieldnames(eltype(result3)) == (:year, :country, :sales)
    @test result3[1] == (year=2017, country=:US, sales=1)
    @test result3[4] == (year=2018, country=:EU, sales=4)

    # Custom output column names (direct form)
    result4 = @pivot_longer(df, :US, :EU, names_to=:country, values_to=:sales) |> collect
    @test result4 == result3

    # Only names_to (values_to defaults to :value)
    result5 = df |> @pivot_longer(:US, :EU, names_to=:country) |> collect
    @test fieldnames(eltype(result5)) == (:year, :country, :value)

    # Only values_to (names_to defaults to :variable)
    result6 = df |> @pivot_longer(:US, :EU, values_to=:amount) |> collect
    @test fieldnames(eltype(result6)) == (:year, :variable, :amount)
end

@testset "@pivot_longer selector syntax" begin
    # startswith selector
    df = DataFrame(year=[2017,2018], wk1=[1,3], wk2=[2,4], total=[10,20])

    result = df |> @pivot_longer(startswith("wk")) |> collect
    @test length(result) == 4
    @test fieldnames(eltype(result)) == (:year, :total, :variable, :value)
    @test result[1] == (year=2017, total=10, variable=:wk1, value=1)
    @test result[2] == (year=2017, total=10, variable=:wk2, value=2)

    # endswith selector
    df2 = DataFrame(sales_2017=[1,2], cost_2017=[3,4], sales_2018=[5,6])
    result2 = df2 |> @pivot_longer(endswith("2017")) |> collect
    @test length(result2) == 4
    @test fieldnames(eltype(result2)) == (:sales_2018, :variable, :value)

    # occursin selector
    result3 = df2 |> @pivot_longer(occursin("sales")) |> collect
    @test length(result3) == 4
    @test fieldnames(eltype(result3)) == (:cost_2017, :variable, :value)

    # Explicit symbols still work (backward compat)
    result4 = df |> @pivot_longer(:wk1, :wk2) |> collect
    @test result4 == result

    # startswith + exclude by name
    result5 = df |> @pivot_longer(startswith("wk"), -:wk2) |> collect
    @test length(result5) == 2
    @test all(r.variable == :wk1 for r in result5)

    # Negated predicate !(startswith(...)) — "all except wk*" pivots :year and :total
    result6 = df |> @pivot_longer(!(startswith("wk"))) |> collect
    @test length(result6) == 4   # 2 non-wk cols × 2 rows
    @test fieldnames(eltype(result6)) == (:wk1, :wk2, :variable, :value)
    @test result6[1].variable == :year

    # Direct form with predicate
    result7 = @pivot_longer(df, startswith("wk")) |> collect
    @test result7 == result
end

@testset "@pivot_wider operator" begin
    long = DataFrame(
        year = [2017, 2017, 2018, 2018],
        country = [:US, :EU, :US, :EU],
        value = [1, 2, 3, 4]
    )

    # Pipe form
    result = long |> @pivot_wider(:country, :value) |> collect
    @test length(result) == 2
    @test fieldnames(eltype(result)) == (:year, :US, :EU)
    @test result[1].year == 2017
    @test result[1].US == DataValue(1)
    @test result[1].EU == DataValue(2)
    @test result[2].year == 2018
    @test result[2].US == DataValue(3)
    @test result[2].EU == DataValue(4)

    # Direct form
    result2 = @pivot_wider(long, :country, :value) |> collect
    @test result2 == result

    # Collects into a DataFrame
    df2 = long |> @pivot_wider(:country, :value) |> DataFrame
    @test df2 isa DataFrame
    @test size(df2) == (2, 3)
    @test names(df2) == ["year", "US", "EU"]
end

end
