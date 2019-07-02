# Data Sources

Query supports many different types of data sources, and you can often mix and match different source types in one query. This section describes all the currently supported data source types.

## DataFrame

`DataFrame`s are probably the most common data source in Query. They are implemented as an `Enumerable` data source type, and can therefore be combined with any other `Enumerable` data source type within one query. The range variable in a query that has a `DataFrame` as its source is a `NamedTuple` that has fields for each column of the `DataFrame`. The implementation of `DataFrame` sources gets around all problems of type stability that are sometimes associated with the `DataFrames` package.

### Example

```jldoctest
using Query, DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @select i
    @collect DataFrame
end

println(x)

# output

3×3 DataFrame
│ Row │ name   │ age     │ children │
│     │ String │ Float64 │ Int64    │
├─────┼────────┼─────────┼──────────┤
│ 1   │ John   │ 23.0    │ 3        │
│ 2   │ Sally  │ 42.0    │ 5        │
│ 3   │ Kirk   │ 59.0    │ 2        │
```

## TypedTable

The `TypedTables` package provides an alternative implementation of a DataFrame-like data structure. Support for `TypedTable` data sources works in the same way as normal `DataFrame` sources, i.e. columns are represented as fields of `NamedTuples`. `TypedTable` sources are implemented as  `Enumerable` data source and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

```jldoctest
using Query, DataFrames, TypedTables

tt = Table(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in tt begin
    @select i
    @collect DataFrame
end

println(x)

# output

3×3 DataFrame
│ Row │ name   │ age     │ children │
│     │ String │ Float64 │ Int64    │
├─────┼────────┼─────────┼──────────┤
│ 1   │ John   │ 23.0    │ 3        │
│ 2   │ Sally  │ 42.0    │ 5        │
│ 3   │ Kirk   │ 59.0    │ 2        │
```

## Arrays

Any array can be a data source for a query. The range variables are of the element type of the array and the elements are iterated in the order of the standard iterator of the array. Array sources are implemented as `Enumerable` data sources and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

```jldoctest
using Query, DataFrames

struct Person
    Name::String
    Friends::Vector{String}
end

source = [
    Person("John", ["Sally", "Miles", "Frank"]),
    Person("Sally", ["Don", "Martin"])]

result = @from i in source begin
         @where length(i.Friends) > 2
         @select {i.Name, Friendcount=length(i.Friends)}
         @collect
end

println(result)

# output

NamedTuple{(:Name, :Friendcount),Tuple{String,Int64}}[(Name = "John", Friendcount = 3)]
```

## IndexedTables

`IndexedTable` data sources can be a source in a query. Individual rows are represented as a `NamedTuple` with two fields. The `index` field holds the index data for this row. If the source has named columns, the type of the `index` field is a `NamedTuple`, where the fieldnames correspond to the names of the index columns. If the source doesn't use named columns, the type of the `index` field is a regular tuple. The second field is named `value` and holds the value of the row in the original source. `IndexedTable` sources are implemented as `Enumerable` data sources and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

```jldoctest
using Query, IndexedTables, Dates

source_indexedtable = table((city=[fill("New York",3); fill("Boston",3)], date=repeat(Date(2016,7,6):Day(1):Date(2016,7,8), 2), value=[91,89,91,95,83,76]))
q = @from i in source_indexedtable begin
    @where i.city=="New York"
    @select i.value
    @collect
end

println(q)

# output

[91, 89, 91]
```

## Any iterable type

Any data source type that implements the standard julia iterator protocoll (i.e. a `start`, `next` and `done` method) can be a query data source. Iterable data sources are implemented as `Enumerable` data sources and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

[TODO]
