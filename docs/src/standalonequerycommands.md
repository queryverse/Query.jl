# Standalone query operators

The standalone query operators are typically combined via the pipe operator. Here is an example that
demonstrates their use:

```jldoctest
using Query, DataFrames, Statistics

df = DataFrame(a=[1,1,2,3], b=[4,5,6,8])

df2 = df |>
    @groupby(_.a) |>
    @map({a=key(_), b=mean(_.b)}) |>
    @filter(_.b > 5) |>
    @orderby_descending(_.b) |>
    DataFrame

# output

2×2 DataFrame
│ Row │ a     │ b       │
│     │ Int64 │ Float64 │
├─────┼───────┼─────────┤
│ 1   │ 3     │ 8.0     │
│ 2   │ 2     │ 6.0     │
```

## Standalone query operators

## The `@map` command

The `@map` command has the form `source |> @map(element_selector)`. `source` can be any source that can be queried. `element_selector` must be an anonymous function that accepts one element of the element type of the source and applies some transformation to this single element.

#### Example

```jldoctest
using Query

data = [1,2,3]

x = data |> @map(_^2) |> collect

println(x)

# output

[1, 4, 9]

```

## The `@filter` command

The `@filter` command has the form `source |> @filter(filter_condition)`. `source` can be any source that can be queried. `filter_condition` must be an anonymous function that accepts one element of the element type of the source and returns `true` if that element should be retained, and `false` if that element should be filtered out.

#### Example

```jldoctest
using Query, DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = df |> @filter(_.age > 30 && _.children > 2) |> DataFrame

println(x)

# output

1×3 DataFrame
│ Row │ name   │ age     │ children │
│     │ String │ Float64 │ Int64    │
├─────┼────────┼─────────┼──────────┤
│ 1   │ Sally  │ 42.0    │ 5        │
```

## The `@groupby` command

There are two versions of the `@groupby` command. The simple version has the form `source |> @groupby(key_selector)`. `source` can be any source that can be queried. `key_selector` must be an anonymous function that returns a value for each element of `source` by which the source elements should be grouped.

The second variant has the form `source |> @groupby(source, key_selector, element_selector)`. The definition of `source` and `key_selector` is the same as in the simple variant. `element_selector` must be an anonymous function that is applied to each element of the `source` before that element is placed into a group, i.e. this is a projection function.

The return value of `@groupby` is an iterable of groups. Each group is itself a collection of data rows, and has a `key` field that is equal to the value the rows were grouped by. Often the next step in the pipeline will be to use `@map` with a function that acts on each group, summarizing it in a new data row.

#### Example

```jldoctest
using DataFrames, Query

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = df |>
    @groupby(_.children) |>
    @map({Key=key(_), Count=length(_)}) |>
    DataFrame

println(x)

# output

2×2 DataFrame
│ Row │ Key   │ Count │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 3     │ 1     │
│ 2   │ 2     │ 2     │
```

## The `@orderby`, `@orderby_descending`, `@thenby` and `@thenby_descending` command

There are four commands that are used to sort data. Any sorting has to start with either a `@orderby` or `@orderby_descending` command. `@thenby` and `@thenby_descending` commands can only directly follow a previous sorting command. They specify how ties in the previous sorting condition are to be resolved.

The general sorting command form is `source |> @orderby(key_selector)`. `source` can be any source than can be queried. `key_selector` must be an anonymous function that returns a value for each element of `source`. The elements of the source are then sorted is in ascending order by the value returned from the `key_selector` function. The `@orderby_descending` command works in the same way, but sorts things in descending order. The `@thenby` and `@thenby_descending` command only accept the return value of any of the four sorting commands as their `source`, otherwise they have the same syntax as the `@orderby` and `@orderby_descending` commands.

#### Example

```jldoctest
using Query, DataFrames

df = DataFrame(a=[2,1,1,2,1,3],b=[2,2,1,1,3,2])

x = df |> @orderby_descending(_.a) |> @thenby(_.b) |> DataFrame

println(x)

# output

6×2 DataFrame
│ Row │ a     │ b     │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 3     │ 2     │
│ 2   │ 2     │ 1     │
│ 3   │ 2     │ 2     │
│ 4   │ 1     │ 1     │
│ 5   │ 1     │ 2     │
│ 6   │ 1     │ 3     │
```

## The `@groupjoin` command

The `@groupjoin` command has the form `outer |> @groupjoin(inner, outer_selector, inner_selector, result_selector)`. `outer` and `inner` can be any source that can be queried. `outer_selector` and `inner_selector` must be an anonymous function that extracts the value from the outer and inner source respectively on which the join should be run. The `result_selector` must be an anonymous function that takes two arguments, first the element from the `outer` source, and second an array of those elements from the second source that are grouped together.

#### Example

```jldoctest
using DataFrames, Query

df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
df2 = DataFrame(c=[2,4,2], d=["John", "Jim","Sally"])

x = df1 |> @groupjoin(df2, _.a, _.c, {t1=_.a, t2=length(__)}) |> DataFrame

println(x)

# output

3×2 DataFrame
│ Row │ t1    │ t2    │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 0     │
│ 2   │ 2     │ 2     │
│ 3   │ 3     │ 0     │
```

## The `@join` command

The `@join` command has the form `outer |> @join(inner, outer_selector, inner_selector, result_selector)`. `outer` and `inner` can be any source that can be queried. `outer_selector` and `inner_selector` must be an anonymous function that extracts the value from the outer and inner source respectively on which the join should be run. The `result_selector` must be an anonymous function that takes two arguments. It will be called for each element in the result set, and the first argument will hold the element from the outer source and the second argument will hold the element from the inner source.

#### Example

```jldoctest
using DataFrames, Query

df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
df2 = DataFrame(c=[2,4,2], d=["John", "Jim","Sally"])

x = df1 |> @join(df2, _.a, _.c, {_.a, _.b, __.c, __.d}) |> DataFrame

println(x)

# output

2×4 DataFrame
│ Row │ a     │ b       │ c     │ d      │
│     │ Int64 │ Float64 │ Int64 │ String │
├─────┼───────┼─────────┼───────┼────────┤
│ 1   │ 2     │ 2.0     │ 2     │ John   │
│ 2   │ 2     │ 2.0     │ 2     │ Sally  │
```

## The `@mapmany` command

The `@mapmany` command has the form `source |> @mapmany(collection_selector, result_selector)`. `source` can be any source that can be queried. `collection_selector` must be an anonymous function that takes one argument and returns a collection. `result_selector` must be an anonymous function that takes two arguments. It will be applied to each element of the intermediate collection.

#### Example

```jldoctest
using DataFrames, Query

source = Dict(:a=>[1,2,3], :b=>[4,5])

q = source |> @mapmany(_.second, {Key=_.first, Value=__}) |> DataFrame

println(q)

# output

5×2 DataFrame
│ Row │ Key    │ Value │
│     │ Symbol │ Int64 │
├─────┼────────┼───────┤
│ 1   │ a      │ 1     │
│ 2   │ a      │ 2     │
│ 3   │ a      │ 3     │
│ 4   │ b      │ 4     │
│ 5   │ b      │ 5     │
```

## The `@take` command

The `@take` command has the form `source |> @take(n)`. `source` can be any source that can be queried. `n` must be an integer, and it specifies how many elements from the beginning of the source should be kept.

#### Example

```jldoctest
using Query

source = [1,2,3,4,5]

q = source |> @take(3) |> collect

println(q)

# output

[1, 2, 3]
```

## The `@drop` command

The `@drop` command has the form `source |> @drop(n)`. `source` can be any source that can be queried. `n` must be an integer, and it specifies how many elements from the beginning of the source should be dropped from the results.

#### Example

```jldoctest
using Query

source = [1,2,3,4,5]

q = source |> @drop(3) |> collect

println(q)

# output

[4, 5]
```

## The `@unique` command

The `@unique` command has the form `source |> @unique()`. `source` can be any source that can be queried. The command will filter out any duplicates from the input source. Note that there is also an experimental version of this command that accepts a key selector, see the experimental section in the documentation.

#### Exmample

```jldoctest
using Query

source = [1,1,2,2,3]

q = source |> @unique() |> collect

println(q)

# output

[1, 2, 3]
```

## The `@select` command

The `@select` command has the form `source |> @select(selectors...)`. `source` can be any source that can be queried. Each selector of `selectors...` can either select elements from `source` and add them to the result set, or select elements from the result set and remove them. A selector may select or remove an element by name, by position, or using a predicate function. All `selectors...` are executed in order and may not commute.

```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q1 = df |> @select(2:3, occursin("ui"), -:amount) |> DataFrame

println(q1)

# output

3×2 DataFrame
│ Row │ price   │ fruit  │
│     │ Float64 │ String │
├─────┼─────────┼────────┤
│ 1   │ 1.2     │ Apple  │
│ 2   │ 2.0     │ Banana │
│ 3   │ 0.4     │ Cherry │
```

```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q2 = df |> @select(!endswith("t"), 1) |> DataFrame

println(q2)

# output

3×3 DataFrame
│ Row │ price   │ isyellow │ fruit  │
│     │ Float64 │ Bool     │ String │
├─────┼─────────┼──────────┼────────┤
│ 1   │ 1.2     │ 0        │ Apple  │
│ 2   │ 2.0     │ 1        │ Banana │
│ 3   │ 0.4     │ 0        │ Cherry │
```

## The `@rename` command

The `@rename` command has the form `source |> @rename(args...)`. `source` can be any source that can be queried. Each argument from `args...` must specify the name or index of the element, as well as the new name for the element. All `args...` are executed in order, and the result set of the previous renaming is the source of each current operation.

```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q = df |> @rename(:fruit => :food, :price => :cost, :food => :name) |> DataFrame

println(q)

# output

3×4 DataFrame
│ Row │ name   │ amount │ cost    │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 2      │ 1.2     │ 0        │
│ 2   │ Banana │ 6      │ 2.0     │ 1        │
│ 3   │ Cherry │ 1000   │ 0.4     │ 0        │
```

## The `@mutate` command
The `@mutate` command has the form `source |> @mutate(args...)`. `source` can be any source that can be queried. Each argument from `args...` must specify the name of the element and the formula to which its values are transformed. The formula can contain elements of `source`. All `args...` are executed in order, and the result set of the previous mutation is the source of each current mutation.
```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q = df |> @mutate(price = 2 * _.price + _.amount, isyellow = _.fruit == "Apple") |> DataFrame

println(q)

# output

3×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 2      │ 4.4     │ 1        │
│ 2   │ Banana │ 6      │ 10.0    │ 0        │
│ 3   │ Cherry │ 1000   │ 1000.8  │ 0        │
``` 

## The `@dropna` command

The `@dropna` command has the form `source |> @dropna(columns...)`. `source` can be any source that can be queried and that has a table structure. If `@dropna()` is called without any arguments, it will drop any row from `source` that has a missing `NA` value in _any_ of its columns. Alternatively one can pass a list of column names to `@dropna`, in which case it will only drop rows that have a `NA` value in one of those columns.

Our first example uses the simple version of `@dropna()` that drops rows that have a missing value in any column:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,3], b=[4,missing,5])

q = df |> @dropna() |> DataFrame

println(q)

# output

2×2 DataFrame
│ Row │ a     │ b     │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 4     │
│ 2   │ 3     │ 5     │
```

The next example only drops rows that have a missing value in the `b` column:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,3], b=[4,missing,5])

q = df |> @dropna(:b) |> DataFrame

println(q)

# output

2×2 DataFrame
│ Row │ a     │ b     │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 4     │
│ 2   │ 3     │ 5     │
```

We can specify as many columns as we want:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,3], b=[4,missing,5])

q = df |> @dropna(:b, :a) |> DataFrame

println(q)

# output

2×2 DataFrame
│ Row │ a     │ b     │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 4     │
│ 2   │ 3     │ 5     │
```

## The `@disallowna` command

The `@disallowna` command has the form `source |> @disallowna(columns...)`. `source` can be any source that can be queried and that has a table structure. If `@disallowna()` is called without any arguments, it will check that there are no missing `NA` values in any column in any row of the input table and convert the element type of each column to one that cannot hold missing values. Alternatively one can pass a list of column names to `@disallowna`, in which case it will only check for `NA` values in those columns, and only convert those columns to a type that cannot hold missing values.

Our first example uses the simple version of `@disallowna()` that makes sure there are no missing values anywhere in the table. Note how the column type for column `a` is changed to `Int64` in this example, i.e. an element type that does not support missing values:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,missing,3], b=[4,5,6])

q = df |> @filter(!isna(_.a)) |> @disallowna() |> DataFrame

println(q)

# output

2×2 DataFrame
│ Row │ a     │ b     │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 4     │
│ 2   │ 3     │ 6     │
```

The next example only checks the `b` column for missing values:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,missing], b=[4,missing,5])

q = df |> @filter(!isna(_.b)) |> @disallowna(:b) |> DataFrame

println(q)

# output

2×2 DataFrame
│ Row │ a       │ b     │
│     │ Int64⍰  │ Int64 │
├─────┼─────────┼───────┤
│ 1   │ 1       │ 4     │
│ 2   │ missing │ 5     │
```

## The `@replacena` command

The `@replacena` command has a simple and full version.

The simple form is `source |> @replacena(replacement_value)`. `source` can be any source that can be queried and that has a table structure. In this case all missing `NA` values in the source table will be replaced with `replacement_value`. Not that this version only works properly, if all columns that contain missing values have the same element type.

The full version has the form `source |> @replacena(replacement_specifier...)`. `source` can again be any source that can be queried that has a table structure. Each `replacement_specifier` should be a `Pair` of the form `column_name => replacement_value`. For example `:b => 3` means that all missing values in column `b` should be replaced with the value 3. One can specify as many `replacement_specifier`s as one wishes.

The first example uses the simple form:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,missing,3], b=[4,5,6])

q = df |> @replacena(0) |> DataFrame

println(q)

# output

3×2 DataFrame
│ Row │ a     │ b     │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 4     │
│ 2   │ 0     │ 5     │
│ 3   │ 3     │ 6     │
```

The next example uses a different replacement value for column `a` and `b`:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,missing], b=["One",missing,"Three"])

q = df |> @replacena(:b=>"Unknown", :a=>0) |> DataFrame

println(q)

# output

3×2 DataFrame
│ Row │ a     │ b       │
│     │ Int64 │ String  │
├─────┼───────┼─────────┤
│ 1   │ 1     │ One     │
│ 2   │ 2     │ Unknown │
│ 3   │ 0     │ Three   │
```
