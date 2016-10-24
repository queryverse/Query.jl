# Getting Started

The basic structure of a query statement is

```julia
q = @from <range variable> in <source> begin
    <query statements>
end
```

Multiple `<query statements>` are separated by line breaks. Probably the most simple example is a query that filters a `DataFrame` and returns a subset of its columns:

```jldoctest
using Query, DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @where i.age>50
    @select {i.name, i.children}
    @collect DataFrame
end

println(x)

# output

1×2 DataFrames.DataFrame
│ Row │ name   │ children │
├─────┼────────┼──────────┤
│ 1   │ "Kirk" │ 2        │
```

## Result types

A query that is not terminated with a `@collect` statement will return an iterator that can be used to iterate over the individual elements of the result set. A `@collect` statement on the other hand materializes the results of a query into a specific data structure, e.g. an array or a `DataFrame`. The Data Sinks section describes all the available formats for query materialization.

## Tables

The Query package does not require data sources or sinks to have a table like structure (i.e. rows and columns). When a table like structure is queried, it is treated as a set of `NamedTuples`, where the set elements correspond to the rows of the source, and the fields of the `NamedTuple` correspond to the columns. Data sinks that have a table like structure typically require the results of the query to be projected into a `NamedTuple`. The experimental `{}` syntax in the Query package provides a simplified way to construct `NamedTuples` in a `@select` statement.

## Missing values

Missing values are represented as `NAable` types. Query.jl currently provides a set of lifted methods for common operations on values that work with ``NAable``, but the eventual goal is to move all of that into its own package. ``NAable`` is only used within Query.jl, the package can without problem work with data sources that use ``Nullable`` as their type to represent potentially missing values.
