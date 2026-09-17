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
 Row │ a      b
     │ Int64  Float64
─────┼────────────────
   1 │     3      8.0
   2 │     2      6.0
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
 Row │ name    age      children
     │ String  Float64  Int64
─────┼───────────────────────────
   1 │ Sally      42.0         5
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
 Row │ Key    Count
     │ Int64  Int64
─────┼──────────────
   1 │     3      1
   2 │     2      2
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
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     3      2
   2 │     2      1
   3 │     2      2
   4 │     1      1
   5 │     1      2
   6 │     1      3
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
 Row │ t1     t2
     │ Int64  Int64
─────┼──────────────
   1 │     1      0
   2 │     2      2
   3 │     3      0
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
 Row │ a      b        c      d
     │ Int64  Float64  Int64  String
─────┼───────────────────────────────
   1 │     2      2.0      2  John
   2 │     2      2.0      2  Sally
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
 Row │ Key     Value
     │ Symbol  Int64
─────┼───────────────
   1 │ a           1
   2 │ a           2
   3 │ a           3
   4 │ b           4
   5 │ b           5
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
 Row │ price    fruit
     │ Float64  String
─────┼─────────────────
   1 │     1.2  Apple
   2 │     2.0  Banana
   3 │     0.4  Cherry
```

```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q2 = df |> @select(!endswith("t"), 1) |> DataFrame

println(q2)

# output

3×3 DataFrame
 Row │ price    isyellow  fruit
     │ Float64  Bool      String
─────┼───────────────────────────
   1 │     1.2     false  Apple
   2 │     2.0      true  Banana
   3 │     0.4     false  Cherry
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
 Row │ name    amount  cost     isyellow
     │ String  Int64   Float64  Bool
─────┼───────────────────────────────────
   1 │ Apple        2      1.2     false
   2 │ Banana       6      2.0      true
   3 │ Cherry    1000      0.4     false
```

## The `@mutate` command
The `@mutate` command has the form `source |> @mutate(args...)`. `source` can be any source that can be queried. Each argument from `args...` must specify the name of the element and the formula to which its values are transformed. The formula can contain elements of `source`.
```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q = df |> @mutate(price = 2 * _.price + _.amount, isyellow = _.fruit == "Apple") |> DataFrame

println(q)

# output

3×4 DataFrame
 Row │ fruit   amount  price    isyellow
     │ String  Int64   Float64  Bool
─────┼───────────────────────────────────
   1 │ Apple        2      4.4      true
   2 │ Banana       6     10.0     false
   3 │ Cherry    1000   1000.8     false
``` 

## The `@summarize` command

The `@summarize` command has the form `source |> @summarize(args...)`. `source` can be any source that can be queried. Each argument from `args...` must have the form `name = expression`. Inside each expression, `_` refers to the collection of rows that is being aggregated, so functions that operate on a whole column or group like `mean(_.age)`, `length(_)` or `key(_)` can be used.

When `source` is the output of a `@groupby` command, `@summarize` returns one row per group. The grouping key columns are automatically prepended to the aggregate columns: a scalar grouping key becomes a column named `key`, and a grouping key that is a named tuple contributes one column per field. If an aggregate has the same name as a key column, the aggregate replaces that key column.

When `source` is not grouped, the whole table is treated as a single group and `@summarize` returns a stream with exactly one row and no key columns.

#### Example

```jldoctest
using Query, DataFrames, Statistics

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = df |>
    @groupby(_.children) |>
    @summarize(n = length(_), mean_age = mean(_.age)) |>
    DataFrame

println(x)

# output

2×3 DataFrame
 Row │ key    n      mean_age
     │ Int64  Int64  Float64
─────┼────────────────────────
   1 │     3      1      23.0
   2 │     2      2      50.5
```

The next example applies `@summarize` to an ungrouped source, which aggregates the whole table into a single row:

```jldoctest
using Query, DataFrames, Statistics

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = df |> @summarize(n = length(_), mean_age = mean(_.age)) |> DataFrame

println(x)

# output

1×2 DataFrame
 Row │ n      mean_age
     │ Int64  Float64
─────┼─────────────────
   1 │     3   41.3333
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
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      4
   2 │     3      5
```

The next example only drops rows that have a missing value in the `b` column:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,3], b=[4,missing,5])

q = df |> @dropna(:b) |> DataFrame

println(q)

# output

2×2 DataFrame
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      4
   2 │     3      5
```

We can specify as many columns as we want:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,3], b=[4,missing,5])

q = df |> @dropna(:b, :a) |> DataFrame

println(q)

# output

2×2 DataFrame
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      4
   2 │     3      5
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
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      4
   2 │     3      6
```

The next example only checks the `b` column for missing values:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,missing], b=[4,missing,5])

q = df |> @filter(!isna(_.b)) |> @disallowna(:b) |> DataFrame

println(q)

# output

2×2 DataFrame
 Row │ a        b
     │ Int64?   Int64
─────┼────────────────
   1 │       1      4
   2 │ missing      5
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
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      4
   2 │     0      5
   3 │     3      6
```

The next example uses a different replacement value for column `a` and `b`:

```jldoctest
using Query, DataFrames

df = DataFrame(a=[1,2,missing], b=["One",missing,"Three"])

q = df |> @replacena(:b=>"Unknown", :a=>0) |> DataFrame

println(q)

# output

3×2 DataFrame
 Row │ a      b
     │ Int64  String
─────┼────────────────
   1 │     1  One
   2 │     2  Unknown
   3 │     0  Three
```

## The `@pivot_longer` command

The `@pivot_longer` command reshapes data from wide format to long format. Each row in the source is expanded into one output row per pivot column. Non-pivot columns are retained as-is, and two new columns are added: `:variable` (holding the original column name as a `Symbol`) and `:value` (holding the cell value).

Columns to pivot are selected with the same rich selector syntax as `@select`:

| Syntax                    | Meaning                                             |
|---------------------------|-----------------------------------------------------|
| `:col`                    | Include column by name                              |
| `startswith("prefix")`    | Include columns whose name starts with `"prefix"`  |
| `endswith("suffix")`      | Include columns whose name ends with `"suffix"`    |
| `occursin("sub")`         | Include columns whose name contains `"sub"`        |
| `!(startswith("prefix"))` | Exclude columns whose name starts with `"prefix"`  |
| `-(startswith("prefix"))` | Same as above                                       |
| `-:col`                   | Exclude column by name                              |
| `n` (integer)             | Include column at position `n`                      |
| `:from::to`               | Include a name range (inclusive)                    |
| `a:b` (integers)          | Include a positional range (inclusive)              |

When only exclusion selectors are given (all starting with `-` or `!`), the starting set is all columns and the exclusions are removed.

The names of the output columns can be customised with the `names_to` and `values_to` keyword arguments. Both accept a `Symbol` and default to `:variable` and `:value` respectively.

#### Examples

```julia
using Query, DataFrames

df = DataFrame(year=[2017,2018], US=[1,3], EU=[2,4])

# Explicit column names
result = df |> @pivot_longer(:US, :EU) |> DataFrame
# 4×3 DataFrame: year | variable | value

# Custom output column names
result = df |> @pivot_longer(:US, :EU, names_to=:country, values_to=:sales) |> DataFrame
# 4×3 DataFrame: year | country | sales

# Predicate — pivot all columns starting with "U"
result = df |> @pivot_longer(startswith("U")) |> DataFrame

# Predicate with exclusion — pivot wk* columns except wk_total
df2 = DataFrame(id=[1,2], wk1=[10,20], wk2=[30,40], wk_total=[40,60])
result = df2 |> @pivot_longer(startswith("wk"), -:wk_total) |> DataFrame
# pivots :wk1 and :wk2 only

# Negated predicate — pivot everything except id columns
result = df2 |> @pivot_longer(!(startswith("id"))) |> DataFrame
```

## The `@pivot_wider` command

The `@pivot_wider` command reshapes data from long format to wide format. It has the form `source |> @pivot_wider(names_from, values_from)`, where `names_from` is the quoted name of the column whose values become new column names, and `values_from` is the quoted name of the column whose values populate those new columns. All other columns are used as identifier columns. Absent combinations are represented as `DataValues.DataValue{T}()` (NA).

#### Example

```julia
using Query, DataFrames

long = DataFrame(
    year    = [2017, 2017, 2018, 2018],
    country = [:US, :EU, :US, :EU],
    value   = [1, 2, 3, 4]
)

result = long |> @pivot_wider(:country, :value) |> DataFrame

# 2×3 DataFrame
#  Row │ year   US                   EU
#      │ Int64  Union{Missing, Int64} Union{Missing, Int64}
# ─────┼──────────────────────────────────────────────────
#    1 │  2017  1                    2
#    2 │  2018  3                    4
```

## The `@left_join`, `@right_join` and `@full_join` commands

These commands have the form `source |> @left_join(inner, outerKeySelector, innerKeySelector, resultSelector)`, and correspond to `Enumerable.LeftJoin`, `RightJoin` and `FullJoin` in .NET. They take the same arguments as the `@join` command, but keep rows that have no match on the other side.

`@left_join` keeps every row of `source`, `@right_join` keeps every row of `inner`, and `@full_join` keeps every row of both. Where there is no match, the missing side is filled with a `DataValue` that has no value — never with `missing`. `@full_join` emits the rows of `source` first, in source order, followed by the rows of `inner` whose key never appeared in `source`.

#### Example

```jldoctest
using Query

people = [(id=1, name="John"), (id=2, name="Sally"), (id=3, name="Kirk")]
pets = [(owner=1, pet="Judy"), (owner=3, pet="Ruff")]

q = people |> @left_join(pets, _.id, _.owner, {_.name, __.pet}) |> collect

for row in q
    println(row.name, ": ", row.pet)
end

# output

John: DataValue{String}("Judy")
Sally: DataValue{String}()
Kirk: DataValue{String}("Ruff")
```

## The `@concat`, `@union`, `@except` and `@intersect` commands

These commands have the form `source |> @union(other)`, and correspond to `Enumerable.Concat`, `Union`, `Except` and `Intersect`. Both sequences must have the same element type.

`@concat` appends `other` to `source`, keeping duplicates. The other three return distinct results, as they do in .NET: `@union` yields every element of either sequence, `@except` the elements of `source` that do not occur in `other`, and `@intersect` the elements that occur in both. Elements are compared with `isequal`, so two `DataValue`s that hold no value count as equal.

#### Example

```jldoctest
using Query

a = [1,2,2,3]
b = [3,4]

println(a |> @concat(b) |> collect)
println(a |> @union(b) |> collect)
println(a |> @except(b) |> collect)
println(a |> @intersect(b) |> collect)

# output

[1, 2, 2, 3, 3, 4]
[1, 2, 3, 4]
[1, 2]
[3]
```

## The `@union_by`, `@except_by` and `@intersect_by` commands

These commands have the form `source |> @union_by(other, keySelector)`, and are the key-based versions of `@union`, `@except` and `@intersect`: two elements count as the same when their keys are equal.

Note that this deviates from .NET. `Enumerable.ExceptBy` and `IntersectBy` take a sequence of *keys* as their second argument, while `UnionBy` takes a sequence of elements. Here all three take a sequence of elements and apply the key selector to both sequences, which keeps them consistent with each other and matches the equivalent SQL.

`@union_by` keeps the first element seen for each key.

#### Example

```jldoctest
using Query

a = [(k=1, v="a"), (k=2, v="b"), (k=3, v="c")]
b = [(k=2, v="B")]

println(a |> @except_by(b, _.k) |> collect)
println(a |> @intersect_by(b, _.k) |> collect)

# output

[(k = 1, v = "a"), (k = 3, v = "c")]
[(k = 2, v = "b")]
```

## The `@take_while` and `@drop_while` commands

These commands have the form `source |> @take_while(condition)`, and correspond to `Enumerable.TakeWhile` and `SkipWhile`.

`@take_while` yields elements until `condition` first fails and then stops, so later elements are not returned even if they would satisfy it. `@drop_while` discards that same leading run and yields everything after it.

#### Example

```jldoctest
using Query

source = [1,2,3,4,1,2]

println(source |> @take_while(_ < 3) |> collect)
println(source |> @drop_while(_ < 3) |> collect)

# output

[1, 2]
[3, 4, 1, 2]
```

## The `@take_last` and `@drop_last` commands

These commands have the form `source |> @take_last(n)`, and correspond to `Enumerable.TakeLast` and `SkipLast`. `@take_last` keeps the last `n` elements and `@drop_last` discards them.

A count of zero or less yields nothing for `@take_last` and leaves the source unchanged for `@drop_last`, as in .NET.

#### Example

```jldoctest
using Query

source = [1,2,3,4,5]

println(source |> @take_last(2) |> collect)
println(source |> @drop_last(2) |> collect)

# output

[4, 5]
[1, 2, 3]
```

## The `@order` and `@order_descending` commands

These commands have the form `source |> @order()`, and correspond to `Enumerable.Order` and `OrderDescending`. They sort by the elements themselves rather than by a key, so unlike `@orderby` they take no selector. `@thenby` and `@thenby_descending` can still follow them.

#### Example

```jldoctest
using Query

source = [3,1,2]

println(source |> @order() |> collect)
println(source |> @order_descending() |> collect)

# output

[1, 2, 3]
[3, 2, 1]
```

## The `@reverse` command

The `@reverse` command has the form `source |> @reverse()`, and corresponds to `Enumerable.Reverse`. It yields the elements of the source in the opposite order. The whole source has to be read before the first element can be returned.

#### Example

```jldoctest
using Query

source = [1,2,3]

println(source |> @reverse() |> collect)

# output

[3, 2, 1]
```

## The `@shuffle` command

The `@shuffle` command has the form `source |> @shuffle()`, and corresponds to `Enumerable.Shuffle`. It yields the elements of the source in a random order, using a random number generator that is not cryptographically secure.

An explicit generator can be passed as the keyword argument `rng`, which makes a shuffle reproducible: `source |> @shuffle(rng=MersenneTwister(42))`. It is a keyword rather than a positional argument so that a single positional argument is unambiguously the source.

#### Example

```jldoctest
using Query
using Random

source = [1,2,3,4,5]

q = source |> @shuffle(rng=MersenneTwister(42)) |> collect

println(sort(q))

# output

[1, 2, 3, 4, 5]
```

## The `@index` command

The `@index` command has the form `source |> @index()`, and corresponds to `Enumerable.Index`. It pairs each element with its position, yielding named tuples of the form `(index=..., item=...)`. Indices start at 1, matching the rest of Julia rather than .NET's zero-based `Index()`.

#### Example

```jldoctest
using Query

source = ["a","b","c"]

println(source |> @index() |> collect)

# output

[(index = 1, item = "a"), (index = 2, item = "b"), (index = 3, item = "c")]
```

## The `@append` and `@prepend` commands

These commands have the form `source |> @append(element)`, and correspond to `Enumerable.Append` and `Prepend`. They add a single element after or before the elements of the source. The element is converted to the source's element type, so appending an `Int` to a sequence of `Float64` works.

#### Example

```jldoctest
using Query

source = [2,3]

println(source |> @append(4) |> collect)
println(source |> @prepend(1) |> collect)

# output

[2, 3, 4]
[1, 2, 3]
```

## The `@zip` command

The `@zip` command has the form `source |> @zip(other)`, and corresponds to `Enumerable.Zip`. It pairs elements of the two sequences by position, yielding tuples, and stops at the shorter of the two — nothing is padded.

A result selector can be given in the direct form, `@zip(source, other, resultSelector)`, where `_` refers to the element of `source` and `__` to the element of `other`. There is deliberately no piped form with a result selector, because it would be indistinguishable from the direct form without one; `source |> @zip(other) |> @map(...)` expresses the same thing.

#### Example

```jldoctest
using Query

a = [1,2,3]
b = ["a","b"]

println(a |> @zip(b) |> collect)

# output

[(1, "a"), (2, "b")]
```

## The `@count_by` command

The `@count_by` command has the form `source |> @count_by(keySelector)`, and corresponds to `Enumerable.CountBy`. It counts how often each key occurs, without building the intermediate groups that `@groupby` would.

The key columns are named as `@summarize` names them: a scalar key becomes a column called `key`, and a named tuple key contributes one column per field. The count is added as a column called `count`.

#### Example

```jldoctest
using Query

source = [(k="a", v=1), (k="b", v=2), (k="a", v=3)]

println(source |> @count_by(_.k) |> collect)

# output

[(key = "a", count = 2), (key = "b", count = 1)]
```

## The `@aggregate_by` command

The `@aggregate_by` command has the form `source |> @aggregate_by(keySelector, seed, accumulator)`, and corresponds to `Enumerable.AggregateBy`. It folds the elements of each key into a single value, starting from `seed`. The accumulator is called as `accumulator(accumulated, element)`, matching .NET's argument order.

Key columns are named as for `@count_by`, and the folded value is added as a column called `value`. For anything beyond a simple fold, `@summarize` is the more general and more idiomatic command.

#### Example

```jldoctest
using Query

source = [(id="0", score=42), (id="1", score=5), (id="0", score=25)]

println(source |> @aggregate_by(_.id, 0, (total, cur) -> total + cur.score) |> collect)

# output

[(key = "0", value = 67), (key = "1", value = 5)]
```

## The `@chunk` command

The `@chunk` command has the form `source |> @chunk(n)`, and corresponds to `Enumerable.Chunk`. It splits the source into batches of at most `n` elements; the final batch is shorter when the source does not divide evenly. `n` must be at least 1.

#### Example

```jldoctest
using Query

source = [1,2,3,4,5]

println(source |> @chunk(2) |> collect)

# output

[[1, 2], [3, 4], [5]]
```

## The `@of_type` and `@cast` commands

These commands have the form `source |> @of_type(T)`, and correspond to `Enumerable.OfType` and `Cast`.

`@of_type` keeps only the elements that are instances of `T` and narrows the element type to `T`, which is useful when the source's element type is `Any` or a `Union`. `@cast` converts every element to `T`; .NET's `Cast` is a type assertion, but the Julia counterpart is a conversion, so it fails the way `convert` would on an element that cannot be represented as `T`.

#### Example

```jldoctest
using Query

source = Any[1, "a", 2]

println(source |> @of_type(Int) |> collect)
println(source |> @of_type(Int) |> @cast(Float64) |> collect)

# output

[1, 2]
[1.0, 2.0]
```

## The `@any`, `@all` and `@contains` commands

These commands return a `Bool` rather than another query, and correspond to `Enumerable.Any`, `All` and `Contains`.

`@any()` reports whether the source has any elements, and `@any(source, condition)` whether any element satisfies the condition. `@all(condition)` reports whether every element does, and is vacuously true for an empty source. `@contains(value)` reports whether the source contains `value`, comparing with `isequal`.

As with `@count`, `@any` has no piped form taking a condition; write `source |> @filter(condition) |> @any()` instead.

#### Example

```jldoctest
using Query

source = [1,2,3]

println(source |> @any())
println(@any(source, _ > 2))
println(source |> @all(_ > 0))
println(source |> @contains(2))

# output

true
true
true
true
```

## The `@first`, `@last`, `@single` and `@element_at` commands

These commands return a single element rather than another query, and correspond to `Enumerable.First`, `Last`, `Single` and `ElementAt`.

`@first()` and `@last()` return the first and last element, and error if the source is empty. `@single()` returns the only element and errors unless there is exactly one. Each also has a direct form taking a condition, such as `@first(source, condition)`. `@element_at(n)` returns the element at position `n`, counting from 1 as the rest of Julia does rather than from 0 as .NET's `ElementAt` does.

#### Example

```jldoctest
using Query

source = [1,2,3,4]

println(source |> @first())
println(source |> @last())
println(source |> @element_at(2))
println(@single(source, _ == 3))

# output

1
4
2
3
```

## The `@min_by` and `@max_by` commands

These commands have the form `source |> @min_by(keySelector)`, and correspond to `Enumerable.MinBy` and `MaxBy`. They return the *element* whose key is smallest or largest, not the key itself. Ties keep the first such element, as in .NET, and an empty source is an error.

#### Example

```jldoctest
using Query

source = [(a=2, x="b"), (a=1, x="a"), (a=3, x="c")]

println(source |> @min_by(_.a))
println(source |> @max_by(_.a))

# output

(a = 1, x = "a")
(a = 3, x = "c")
```

## The `@aggregate` command

The `@aggregate` command has the form `source |> @aggregate(accumulator)`, and corresponds to `Enumerable.Aggregate`. It folds the source into a single value, calling `accumulator(accumulated, element)`.

Without a seed the fold starts from the first element and an empty source is an error. A seed can be given as the keyword argument `seed`, as in `source |> @aggregate(accumulator, seed=0)`, in which case an empty source yields the seed. It is a keyword rather than a positional argument so that the piped and direct forms can be told apart.

For aggregating a table, `@summarize` is the more idiomatic command.

#### Example

```jldoctest
using Query

source = [1,2,3,4]

println(source |> @aggregate((acc, cur) -> acc + cur))
println(source |> @aggregate((acc, cur) -> acc + cur, seed=100))

# output

10
110
```

## The `@sequence_equal` command

The `@sequence_equal` command has the form `source |> @sequence_equal(other)`, and corresponds to `Enumerable.SequenceEqual`. It reports whether the two sequences have the same elements in the same order, comparing with `isequal`.

#### Example

```jldoctest
using Query

source = [1,2,3]

println(source |> @sequence_equal([1,2,3]))
println(source |> @sequence_equal([1,2]))

# output

true
false
```
