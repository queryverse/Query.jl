# Experimental features

The following features are experimental, i.e. they might change significantly
in the future. You are advised to only use them if you are prepared to
deal with significant changes to these features in future versions of
Query.jl. At the same time any feedback on these features would be
especially welcome.

The `@select`, `@where`, `@groupby` and `@orderby` (and various variants)
commands can be used in standalone versions. Those standalone versions
are especially convenient in combination with the pipe syntax in julia.
Here is an example that demonstrates their use:

```julia
using Query, DataFrames

df = DataFrame(a=[1,1,2,3], b=[4,5,6,8])

df2 = df |>
    @groupby(_.a) |>
    @select({a=_.key, b=mean(_..b)}) |>
    @where(_.b > 5) |>
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
df = @groupbe(df, _.a)
```
both forms are equivalent.

The remaining arguments of each query demand are command specific.

The following discussion will present each command in the version that
accepts a source as the first argument.

### The `@select` command

The `@select` command has the form `@select(source, element_selector)`.
`source` can be any source that can be queried. `element_selector` must
be an anonymous function that accepts one element of the element type of
the source and applies some transformation to this single element.

### The `@where` command

The `@where` command has the form `@where(source, filter_condition)`.
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

## The `..` syntax

The syntax `a..b` is translated into `map(i->i.b, a)` in any query
expression. This is especially helpful when computing some reduction of
a given column of a grouped table.

## The `_` syntax

This syntax only works in the standalone query commands. Instead of writing
a full anonymous function, for example `@select(i->i.a)`, one can write
`@select(_.a)`, where `_` stands for the current element, i.e. has the
same role as the argument of the anonymous function.
