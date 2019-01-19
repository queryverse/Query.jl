# Experimental features

The following features are experimental, i.e. they might change significantly
in the future. You are advised to only use them if you are prepared to
deal with significant changes to these features in future versions of
Query.jl. At the same time any feedback on these features would be
especially welcome.

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

## Key selector in the `@unique` standalone command

As an experimental feature, one can specify a key selector for the `@unique` command. In that case uniqueness is tested based on that key.

```jldoctest
using Query

source = [1,-1,2,2,3]

q = source |> @unique(abs(_)) |> collect

println(q)

# output

[1, 2, 3]
```
