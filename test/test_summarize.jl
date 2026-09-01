@testitem "Summarize Macro grouped" begin
    using DataFrames, Statistics

    df = DataFrame(k=[1,1,2], x=[1.,2.,4.])

    # single scalar key: key column named `key`, aggregates correct
    @test df |> @groupby(_.k) |> @summarize(m = mean(_.x)) |> collect ==
        [(key=1, m=1.5), (key=2, m=4.0)]

    # length(_) and key(_) inside aggregate expressions
    @test df |> @groupby(_.k) |> @summarize(n = length(_), k10 = key(_) * 10) |> collect ==
        [(key=1, n=2, k10=10), (key=2, n=1, k10=20)]

    # multi-key (NamedTuple key): key fields splat as columns in order
    df2 = DataFrame(a=[1,1,2], b=["x","y","x"], v=[1,2,3])
    @test df2 |> @groupby({_.a, _.b}) |> @summarize(s = sum(_.v)) |> collect ==
        [(a=1, b="x", s=1), (a=1, b="y", s=2), (a=2, b="x", s=3)]

    # collision: aggregate named `key` (scalar key case) — aggregate wins
    @test df |> @groupby(_.k) |> @summarize(key = sum(_.x)) |> collect ==
        [(key=3.0,), (key=4.0,)]

    # collision: aggregate named like a key field (multi-key case) — aggregate wins
    @test df2 |> @groupby({_.a, _.b}) |> @summarize(a = sum(_.v)) |> collect ==
        [(a=1, b="x"), (a=2, b="y"), (a=3, b="x")]

    # chaining after @summarize
    @test df |> @groupby(_.k) |> @summarize(m = mean(_.x)) |>
        @filter(_.m > 2) |> @orderby(_.m) |> collect == [(key=2, m=4.0)]

    # closure over a local variable in an aggregate expression
    c = 2.0
    @test df |> @groupby(_.k) |> @summarize(m = mean(_.x) * c) |> collect ==
        [(key=1, m=3.0), (key=2, m=8.0)]

    # type stability: concrete NamedTuple eltype
    r = df |> @groupby(_.k) |> @summarize(m = mean(_.x)) |> collect
    @test eltype(r) == typeof((key=1, m=1.5))
    @test isconcretetype(eltype(r))

    # collect into a DataFrame
    @test DataFrame(df |> @groupby(_.k) |> @summarize(m = mean(_.x))) ==
        DataFrame(key=[1,2], m=[1.5,4.0])
end

@testitem "Summarize Macro ungrouped" begin
    using DataFrames, Statistics

    df = DataFrame(k=[1,1,2], x=[1.,2.,4.])

    # exactly one row, no key columns
    @test df |> @summarize(m = mean(_.x), n = length(_)) |> collect ==
        [(m=7/3, n=3)]

    # result is still a composable stream
    @test df |> @summarize(n = length(_)) |> @mutate(n2 = _.n * 2) |> collect ==
        [(n=3, n2=6)]

    # empty source: aggregates see an empty collection
    empty_df = DataFrame(x=Float64[])
    @test empty_df |> @summarize(n = length(_)) |> collect == [(n=0,)]

    # type stability: concrete NamedTuple eltype
    r = df |> @summarize(m = mean(_.x)) |> collect
    @test eltype(r) == typeof((m=1.5,))
    @test isconcretetype(eltype(r))

    # collect into a DataFrame
    @test DataFrame(df |> @summarize(n = length(_))) == DataFrame(n=[3])
end

@testitem "Summarize Macro source-first form" begin
    using DataFrames, Statistics

    df = DataFrame(k=[1,1,2], x=[1.,2.,4.])

    # ungrouped source-first form
    @test @summarize(df, m = mean(_.x), n = length(_)) |> collect == [(m=7/3, n=3)]

    # grouped source-first form
    g = df |> @groupby(_.k)
    @test @summarize(g, m = mean(_.x)) |> collect == [(key=1, m=1.5), (key=2, m=4.0)]
end

@testitem "Summarize Macro error cases" begin
    using DataFrames, Statistics

    df = DataFrame(k=[1,1,2], x=[1.,2.,4.])

    # no arguments at all
    err = try
        @eval df |> @summarize()
        nothing
    catch e
        e
    end
    @test err isa LoadError
    @test occursin("requires at least one name = expression argument", sprint(showerror, err.error))

    # argument that is not name = expression (treated as source, no aggregates follow)
    err = try
        @eval df |> @summarize(mean(_.x))
        nothing
    catch e
        e
    end
    @test err isa LoadError
    @test occursin("requires at least one name = expression argument", sprint(showerror, err.error))

    # invalid aggregate argument alongside a valid one
    err = try
        @eval df |> @summarize(m = mean(_.x), length(_))
        nothing
    catch e
        e
    end
    @test err isa LoadError
    @test occursin("must have the form `name = expression`", sprint(showerror, err.error))
end
