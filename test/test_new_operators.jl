@testitem "@left_join, @right_join and @full_join" begin
    using DataFrames
    using DataValues

    people = DataFrame(id=[1, 2, 3], name=["a", "b", "c"])
    pets = DataFrame(owner=[1, 3], pet=["cat", "dog"])

    left = people |> @left_join(pets, _.id, _.owner, {_.name, __.pet}) |> DataFrame
    @test size(left) == (3, 2)
    @test left[!, :name] == ["a", "b", "c"]
    @test isequal(left[!, :pet], ["cat", missing, "dog"])

    right = people |> @right_join(pets, _.id, _.owner, {_.name, __.pet}) |> DataFrame
    @test size(right) == (2, 2)
    @test right[!, :pet] == ["cat", "dog"]

    full = people |> @full_join(pets, _.id, _.owner, {_.name, __.pet}) |> DataFrame
    @test size(full) == (3, 2)

    # Direct form.
    direct = DataFrame(@left_join(people, pets, _.id, _.owner, {_.name, __.pet}))
    @test size(direct) == (3, 2)
end

@testitem "outer joins produce DataValue, not missing, before the sink" begin
    using DataFrames
    using DataValues

    people = DataFrame(id=[1, 2], name=["a", "b"])
    pets = DataFrame(owner=[1], pet=["cat"])

    rows = people |> @left_join(pets, _.id, _.owner, {_.name, __.pet}) |> collect

    @test length(rows) == 2
    @test rows[1].pet isa DataValue
    @test isna(rows[2].pet)
    @test !any(r -> ismissing(r.pet), rows)
end

@testitem "@concat, @union, @except and @intersect" begin
    using DataFrames

    a = DataFrame(x=[1, 2, 3])
    b = DataFrame(x=[3, 4])

    @test (a |> @concat(b) |> DataFrame)[!, :x] == [1, 2, 3, 3, 4]
    @test (a |> @union(b) |> DataFrame)[!, :x] == [1, 2, 3, 4]
    @test (a |> @except(b) |> DataFrame)[!, :x] == [1, 2]
    @test (a |> @intersect(b) |> DataFrame)[!, :x] == [3]

    # Direct form.
    @test DataFrame(@union(a, b))[!, :x] == [1, 2, 3, 4]
end

@testitem "@union_by, @except_by and @intersect_by" begin
    using DataFrames

    a = DataFrame(k=[1, 2, 3], v=["a", "b", "c"])
    b = DataFrame(k=[2, 3], v=["B", "C"])

    u = a |> @union_by(b, _.k) |> DataFrame
    @test u[!, :k] == [1, 2, 3]
    @test u[!, :v] == ["a", "b", "c"]

    @test (a |> @except_by(b, _.k) |> DataFrame)[!, :k] == [1]
    @test (a |> @intersect_by(b, _.k) |> DataFrame)[!, :k] == [2, 3]

    @test DataFrame(@except_by(a, b, _.k))[!, :k] == [1]
end

@testitem "@take_while and @drop_while" begin
    using DataFrames

    df = DataFrame(x=[1, 2, 3, 4, 1])

    @test (df |> @take_while(_.x < 3) |> DataFrame)[!, :x] == [1, 2]
    @test (df |> @drop_while(_.x < 3) |> DataFrame)[!, :x] == [3, 4, 1]

    @test DataFrame(@take_while(df, _.x < 3))[!, :x] == [1, 2]
end

@testitem "@take_last and @drop_last" begin
    using DataFrames

    df = DataFrame(x=[1, 2, 3, 4, 5])

    @test (df |> @take_last(2) |> DataFrame)[!, :x] == [4, 5]
    @test (df |> @drop_last(2) |> DataFrame)[!, :x] == [1, 2, 3]

    @test DataFrame(@take_last(df, 2))[!, :x] == [4, 5]
end

@testitem "@order and @order_descending" begin
    using DataFrames

    df = DataFrame(x=[3, 1, 2])

    @test (df |> @order() |> DataFrame)[!, :x] == [1, 2, 3]
    @test (df |> @order_descending() |> DataFrame)[!, :x] == [3, 2, 1]

    @test DataFrame(@order(df))[!, :x] == [1, 2, 3]
end

@testitem "@thenby can follow @order" begin
    using DataFrames

    df = DataFrame(a=[1, 1, 0], b=[2, 1, 9])

    res = df |> @order() |> @thenby(_.b) |> DataFrame

    @test res[!, :a] == [0, 1, 1]
    @test res[!, :b] == [9, 1, 2]
end

@testitem "@reverse, @shuffle and @index" begin
    using DataFrames
    using Random

    df = DataFrame(x=[1, 2, 3])

    @test (df |> @reverse() |> DataFrame)[!, :x] == [3, 2, 1]
    @test DataFrame(@reverse(df))[!, :x] == [3, 2, 1]

    @test sort((df |> @shuffle() |> DataFrame)[!, :x]) == [1, 2, 3]

    # The rng is a keyword, so a lone positional argument is still the source.
    a = df |> @shuffle(rng=MersenneTwister(42)) |> DataFrame
    b = df |> @shuffle(rng=MersenneTwister(42)) |> DataFrame
    @test a[!, :x] == b[!, :x]
    @test sort(a[!, :x]) == [1, 2, 3]
    @test sort(DataFrame(@shuffle(df))[!, :x]) == [1, 2, 3]

    indexed = df |> @index() |> collect
    @test [i.index for i in indexed] == [1, 2, 3]
    @test [i.item.x for i in indexed] == [1, 2, 3]
end

@testitem "@append and @prepend" begin
    using DataFrames

    df = DataFrame(x=[2, 3])

    @test (df |> @append((x=4,)) |> DataFrame)[!, :x] == [2, 3, 4]
    @test (df |> @prepend((x=1,)) |> DataFrame)[!, :x] == [1, 2, 3]
    @test DataFrame(@append(df, (x=4,)))[!, :x] == [2, 3, 4]
end

@testitem "@zip" begin
    using DataFrames

    a = DataFrame(x=[1, 2, 3])
    b = DataFrame(y=["a", "b"])

    # Truncates to the shorter source.
    zipped = a |> @zip(b) |> collect
    @test length(zipped) == 2
    @test zipped[1] == ((x=1,), (y="a",))

    with_selector = @zip(a, b, {v = _.x, w = __.y}) |> DataFrame
    @test size(with_selector) == (2, 2)
    @test with_selector[!, :v] == [1, 2]
    @test with_selector[!, :w] == ["a", "b"]
end

@testitem "@count_by, @aggregate_by and @chunk" begin
    using DataFrames

    df = DataFrame(k=["a", "b", "a"], v=[1, 2, 3])

    counted = df |> @count_by(_.k) |> DataFrame
    @test counted[!, :key] == ["a", "b"]
    @test counted[!, :count] == [2, 1]

    aggregated = df |> @aggregate_by(_.k, 0, (acc, cur) -> acc + cur.v) |> DataFrame
    @test aggregated[!, :key] == ["a", "b"]
    @test aggregated[!, :value] == [4, 2]

    chunks = df |> @chunk(2) |> collect
    @test length(chunks) == 2
    @test length(chunks[1]) == 2
    @test length(chunks[2]) == 1

    @test DataFrame(@count_by(df, _.k))[!, :count] == [2, 1]
end

@testitem "@count_by agrees with @groupby plus a count" begin
    using DataFrames

    df = DataFrame(k=[1, 2, 1, 3, 1])

    by_count = df |> @count_by(_.k) |> DataFrame
    by_group = df |> @groupby(_.k) |> @map({key = key(_), count = length(_)}) |> DataFrame

    @test by_count == by_group
end

@testitem "@of_type and @cast" begin
    source = Any[1, "a", 2]

    @test (source |> @of_type(Int) |> collect) == [1, 2]
    @test (source |> @of_type(Int) |> @cast(Float64) |> collect) == [1.0, 2.0]
    @test (@of_type(source, String) |> collect) == ["a"]
end

@testitem "terminal operators" begin
    using DataFrames

    df = DataFrame(x=[1, 2, 3, 4])

    @test (df |> @any()) == true
    @test @any(df, _.x > 3) == true
    @test @any(df, _.x > 9) == false
    @test (df |> @all(_.x > 0)) == true
    @test (df |> @all(_.x > 1)) == false

    @test (df |> @first()).x == 1
    @test (df |> @last()).x == 4
    @test (df |> @element_at(2)).x == 2
    @test (df |> @min_by(_.x)).x == 1
    @test (df |> @max_by(_.x)).x == 4
    @test @single(df, _.x == 3).x == 3

    @test (df |> @contains((x=2,))) == true
    @test (df |> @contains((x=9,))) == false
    @test (df |> @sequence_equal(df)) == true
    @test (df |> @sequence_equal(DataFrame(x=[1, 2]))) == false
end

@testitem "@aggregate with and without a seed" begin
    using DataFrames

    df = DataFrame(x=[1, 2, 3])

    # Without a seed the fold starts from the first element, so it folds rows.
    @test (df |> @aggregate((acc, cur) -> (x = acc.x + cur.x,))).x == 6

    # The seed is a keyword, which is what keeps the piped and direct forms apart.
    @test (df |> @aggregate((acc, cur) -> acc + cur.x, seed=100)) == 106
    @test @aggregate(df, (acc, cur) -> acc + cur.x, seed=0) == 6
    @test @aggregate(df, (acc, cur) -> (x = acc.x + cur.x,)).x == 6
end

@testitem "new operators compose in a pipeline" begin
    using DataFrames

    df = DataFrame(k=["a", "b", "a", "c"], v=[1, 2, 3, 4])

    res = df |>
        @filter(_.v < 4) |>
        @count_by(_.k) |>
        @order_descending() |>
        @take_last(1) |>
        DataFrame

    @test size(res) == (1, 2)
end

@testitem "new operators work downstream of @groupby" begin
    using DataFrames

    df = DataFrame(k=[1, 1, 2], v=[1, 2, 3])

    groups = df |> @groupby(_.k) |> @reverse() |> collect
    @test [key(g) for g in groups] == [2, 1]

    biggest = df |> @groupby(_.k) |> @max_by(length(_))
    @test key(biggest) == 1
end
