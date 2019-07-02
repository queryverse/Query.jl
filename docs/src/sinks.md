# Data Sinks

Query supports a number of different data sink types. One can materialize the results of a query into a specific sink by using the `@collect` statement. Queries that don't end with a `@collect` statement return an iterator that can be used to iterate over the results of the query.

## Array

Using the `@collect` statement without any further argument will materialize the query results into an array. The array will be a vector, and the element type of the array is the type of the elements returned by the last projection statement.

### Example

```jldoctest
using Query, DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @select i.name
    @collect
end

println(x)

# output

["John", "Sally", "Kirk"]
```

## DataFrame, DataTable and TypedTable

The statement `@collect TableType` (with `TableType` being one of `DatFrame`, `DataTable` or `TypedTable`) will materialize the query results into a new instance of that type. This statement only works if the last projection statement transformed the results into a `NamedTuple`, for example by using the `{}` syntax.

### Example

```jldoctest
using Query, DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @select {i.name, i.age, Children=i.children}
    @collect DataFrame
end

println(x)

# output

3×3 DataFrame
│ Row │ name   │ age     │ Children │
│     │ String │ Float64 │ Int64    │
├─────┼────────┼─────────┼──────────┤
│ 1   │ John   │ 23.0    │ 3        │
│ 2   │ Sally  │ 42.0    │ 5        │
│ 3   │ Kirk   │ 59.0    │ 2        │
```

## Dict

The statement `@collect Dict` will materialize the query results into a new `Dict` instance. This statement only works if the last projection statement transformed the results into a `Pair`, for example by using the `=>` syntax.

### Example

````jldoctest
using Query, DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @select i.name=>i.children
    @collect Dict
end

println(x)

# output

Dict("Sally"=>5,"John"=>3,"Kirk"=>2)
````

## TimeArray

The statement `@collect TimeArray` will materialize the query results into
a new `TimeSeries.TimeArray` instance. This statement only works if the
last projection statement transformed the results into a `NamedTuple`,
for example by using the `{}` syntax, and this `NamedTuple` has one field
named `timestamp` that is of a type that can be used as a time index in
the `TimeArray` type.

### Example

[TODO]

## Temporal

The statement `@collect TS` will materialize the query results into
a new `Temporal.TS` instance. This statement only works if the
last projection statement transformed the results into a `NamedTuple`,
for example by using the `{}` syntax, and this `NamedTuple` has one field
named `Index` that is of a type that can be used as a time index in
the `TS` type.

### Example

[TODO]

## IndexedTable

The statement `@collect IndexedTable` will materialize the query results
into a new `IndexedTables.IndexedTable` instance. This statement only
works if the last projection statement transformed the results into a
`NamedTuple`, for example by using the `{}` syntax. The last column of
the result table will be the data column, all other columns will be index
columns.

### Example

[TODO]
