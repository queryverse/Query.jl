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
```

## Standalone query operators

All standalone query commands can either take a source as their first argument, or one can pipe the source into the command, as in the above example. For example, one can either write

```julia
df = df |> @groupby(_.a)
```
or
```julia
df = @groupby(df, _.a)
```
both forms are equivalent.

The remaining arguments of each query demand are command specific.

The following discussion will present each command in the version where a source is piped into the command.

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

1×3 DataFrames.DataFrame
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

2×2 DataFrames.DataFrame
│ Row │ Key   │ Count │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 3     │ 1     │
│ 2   │ 2     │ 2     │
```

## The `@orderby`, `@orderby_descending`, `@thenby` and `@thenby_descending` command

There are four commands that are used to sort data. Any sorting has to start with either a `@orderby` or `@orderby_descending` command. `@thenby` and `@thenby_descending` commands can only directly follow a previous sorting command. They specify how ties in the previous sorting condition are to be resolved.

The general sorting command form is `source |> @orderby(key_selector)`. `source` can be any source than can be queried. `key_selector` must be an anonymous function that returns a value for each element of `source`. The elements of the source are then sorted is ascending order by the value returned from the `key_selector` function. The `@orderby_descending` command works in the same way, but sorts things in descending order. The `@thenby` and `@thenby_descending` command only accept the return value of any of the four sorting commands as their `source`, otherwise they have the same syntax as the `@orderby` and `@orderby_descending` commands.

#### Example

```jldoctest
using Query, DataFrames

df = DataFrame(a=[2,1,1,2,1,3],b=[2,2,1,1,3,2])

x = df |> @orderby_descending(_.a) |> @thenby(_.b) |> DataFrame

println(x)

# output

6×2 DataFrames.DataFrame
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

3×2 DataFrames.DataFrame
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

2×4 DataFrames.DataFrame
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

5×2 DataFrames.DataFrame
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

## The `@select` command

The `@select` command has the form `source |> @select(selectors...)`. `source` can be any source that can be queried. Each selector of `selectors...` can either select elements from `source` and add them to the result set, or select elements from the result set and remove them. A selector may select or remove an element by name, by position, or using a predicate function. All `selectors...` are executed in order and may not commute.

```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q1 = df |> @select(2:3, occursin("ui"), -:amount) |> DataFrame

println(q1)

# output

3×2 DataFrames.DataFrame
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

3×3 DataFrames.DataFrame
│ Row │ price   │ isyellow │ fruit  │
│     │ Float64 │ Bool     │ String │
├─────┼─────────┼──────────┼────────┤
│ 1   │ 1.2     │ false    │ Apple  │
│ 2   │ 2.0     │ true     │ Banana │
│ 3   │ 0.4     │ false    │ Cherry │
```

## The `@rename` command

The `@rename` command has the form `source |> @rename(args...)`. `source` can be any source that can be queried. Each argument from `args...` must specify the name or index of the element, as well as the new name for the element. All `args...` are executed in order, and the result set of the previous renaming is the source of each current operation.

```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q = df |> @rename(:fruit => :food, :price => :cost, :food => :name) |> DataFrame

println(q)

# output

3×4 DataFrames.DataFrame
│ Row │ name   │ amount │ cost    │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 2      │ 1.2     │ false    │
│ 2   │ Banana │ 6      │ 2.0     │ true     │
│ 3   │ Cherry │ 1000   │ 0.4     │ false    │
```

## The `@mutate` command
The `@mutate` command has the form `source |> @mutate(args...)`. `source` can be any source that can be queried. Each argument from `args...` must specify the name of the element and the formula to which its values are transformed. The formula can contain elements of `source`. All `args...` are executed in order, and the result set of the previous mutation is the source of each current mutation.
```jldoctest
using Query, DataFrames

df = DataFrame(fruit=["Apple","Banana","Cherry"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])

q = df |> @mutate(price = 2 * _.price + _.amount, isyellow = _.fruit == "Apple") |> DataFrame

println(q)

# output

3×4 DataFrames.DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 2      │ 4.4     │ true     │
│ 2   │ Banana │ 6      │ 10.0    │ false    │
│ 3   │ Cherry │ 1000   │ 1000.8  │ false    │
``` 
