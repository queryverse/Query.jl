# Experimental features

The following features are experimental, i.e. they might change significantly
in the future. You are advised to only use them if you are prepared to
deal with significant changes to these features in future versions of
Query.jl. At the same time any feedback on these features would be
especially welcome.

The `@map`, `@filter`, `@groupby`, `@orderby` (and various variants),
`@groupjoin`, `@join`, `@mapmany`, `@take` and `@drop` commands can be used in standalone
versions. Those standalone versions are especially convenient in
combination with the pipe syntax in julia. Here is an example that
demonstrates their use:

```julia
using Query, DataFrames

df = DataFrame(a=[1,1,2,3], b=[4,5,6,8])

df2 = df |>
    @groupby(_.a) |>
    @map({a=_.key, b=mean(_..b)}) |>
    @filter(_.b > 5) |>
    @orderby_descending(_.b) |>
    DataFrame
```

This example makes use of three experimental features: 1) the standalone
query commands, 2) the `..` syntax and 3) the `_` anonymous function syntax.

## Standalone query operators

All standalone query commands can either take a source as their first
argument, or one can pipe the source into the command, as in the above
example. For example, one can either write

```julia
df = df |> @groupby(_.a)
```
or
```julia
df = @groupby(df, _.a)
```
both forms are equivalent.

The remaining arguments of each query demand are command specific.

The following discussion will present each command in the version that
accepts a source as the first argument.

### The `@map` command

The `@map` command has the form `@map(source, element_selector)`.
`source` can be any source that can be queried. `element_selector` must
be an anonymous function that accepts one element of the element type of
the source and applies some transformation to this single element.

### The `@filter` command

The `@filter` command has the form `@filter(source, filter_condition)`.
`source` can be any source that can be queried. `filter_condition` must
be an anonymous function that accepts one element of the element type of
the source and returns `true` if that element should be retained, and
`false` if that element should be filtered out.

### The `@groupby` command

There are two versions of the `@groupby` command. The simple version has
the form `@groupby(source, key_selector)`. `source` can be any source
that can be queried. `key_selector` must be an anonymous function that
returns a value for each element of `source` by which the source elements
should be grouped.

The second variant has the form `@groupby(source, key_selector, element_selector)`.
The definition of `source` and `key_selector` is the same as in the simple
variant. `element_selector` must be an anonymous function that is applied
to each element of the `source` before that element is placed into a group,
i.e. this is a projection function.

The return value of `@groupby` is an iterable of groups. Each group is itself a
collection of data rows, and has a `key` field that is equal to the value the
rows were grouped by. Often the next step in the pipeline will be to use `@map`
with a function that acts on each group, summarizing it in a new data row.

### The `@orderby`, `@orderby_descending`, `@thenby` and `@thenby_descending` command

There are four commands that are used to sort data. Any sorting has to
start with either a `@orderby` or `@orderby_descending` command. `@thenby`
and `@thenby_descending` commands can only directly follow a previous sorting
command. They specify how ties in the previous sorting condition are to be
resolved.

The general sorting command form is `@orderby(source, key_selector)`.
`source` can be any source than can be queried. `key_selector` must be an
anonymous function that returns a value for each element of `source`. The
elements of the source are then sorted is ascending order by the value
returned from the `key_selector` function. The `@orderby_descending`
command works in the same way, but sorts things in descending order. The
`@thenby` and `@thenby_descending` command only accept the return value
of any of the four sorting commands as their `source`, otherwise they have
the same syntax as the `@orderby` and `@orderby_descending` commands.

### The `@groupjoin` command

The `@groupjoin` command has the form `@groupjoin(outer, inner, outer_selector, inner_selector, result_selector)`.
`outer` and `inner` can be any source that can be queried. `outer_selector`
and `inner_selector` must be an anonymous function that extracts the value
from the outer and inner source respectively on which the join should
be run. The `result_selector` must be an anonymous function that takes two
arguments, first the element from the `outer` source, and second an array
of those elements from the second source that are grouped together.

### The `@join` command

The `@join` command has the form `@join(outer, inner, outer_selector, inner_selector, result_selector)`.
`outer` and `inner` can be any source that can be queried. `outer_selector`
and `inner_selector` must be an anonymous function that extracts the value
from the outer and inner source respectively on which the join should
be run. The `result_selector` must be an anonymous function that takes two
arguments. It will be called for each element in the result set, and the
first argument will hold the element from the outer source and the second
argument will hold the element from the inner source.

### The `@mapmany` command

The `@mapmany` command has the form `@mapmany(source, collection_selector, result_selector)`.
`source` can be any source that can be queried. `collection_selector` must
be an anonymous function that takes one argument and returns a collection.
`result_selector` must be an anonymous function that takes two arguments.
It will be applied to each element of the intermediate collection.

### The `@take` command

The `@take` command has the form `@take(source, n)`. `source` can be any source that can be queried. `n` must be an integer, and it specifies how many elements from the beginning of the source should be kept.

### The `@drop` command

The `@drop` command has the form `@drop(source, n)`. `source` can be any source that can be queried. `n` must be an integer, and it specifies how many elements from the beginning of the source should be dropped from the results.

## The `..` syntax

The syntax `a..b` is translated into `map(i->i.b, a)` in any query
expression. This is especially helpful when computing some reduction of
a given column of a grouped table.

For example, the following command groups a table by column `a`, and then
computes the mean of the `b` column for each group:

```julia
using DataFrames, Query

df = DataFrame(a=[1,1,2,3], b=[4,5,6,8])

@from i in df begin
    @group i by i.a into g
    @select {a=i.key, b=mean(g..b)}
    @collect DataFrame
end
```

The `@group` command here creates a list of tables, i.e. `g` will hold
a full table for each group. The syntax `g..b` then extracts a single
column from that table.

## The `_` and `__` syntax

This syntax only works in the standalone query commands. Instead of writing
a full anonymous function, for example `@map(i->i.a)`, one can write
`@map(_.a)`, where `_` stands for the current element, i.e. has the
same role as the argument of the anonymous function.

If one uses both `_` and `__`, Query will automatically create an anonymous
function with two arguments. For example, the result selector in the
`@join` command requires an anonymous function that takes two arguments.
This can be written succinctly like this:

```julia
using DataFrames, Query

df_parents = DataFrame(Name=["John", "Sally"])
df_children = DataFrame(Name=["Bill", "Joe", "Mary"], Parent=["John", "John", "Sally"])

df_parents |> @join(df_children, _.Name, _.Parent, {Parent=_.Name, Child=__.Name}) |> DataFrame
```
