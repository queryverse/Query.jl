# Data Sources

Query supports many different types of data sources, and you can often mix and match different source types in one query. This section describes all the currently supported data source types.

## DataFrame

`DataFrame`s are probably the most common data source in Query. They are implemented as an `Enumerable` data source type, and can therefore be combined with any other `Enuermable` data source type within one query. The range variable in a query that has a `DataFrame` as its source is a `NamedTuple` that has fields for each column of the `DataFrame`. The implementation of `DataFrame` sources gets around all problems of type stability that are sometimes associated with the `DataFrames` package.

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

3×3 DataFrames.DataFrame
│ Row │ name    │ age  │ children │
├─────┼─────────┼──────┼──────────┤
│ 1   │ "John"  │ 23.0 │ 3        │
│ 2   │ "Sally" │ 42.0 │ 5        │
│ 3   │ "Kirk"  │ 59.0 │ 2        │
```

## TypedTable

The `TypedTables` package provides an alternative implementation of a DataFrame-like data structure. Support for `TypedTable` data sources works in the same way as normal `DataFrame` sources, i.e. columns are represented as fields of `NamedTuples`. `TypedTable` sources are implemented as  `Enumerable` data source and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

```jldoctest
using Query, DataFrames, TypedTables

tt = @Table(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in tt begin
    @select i
    @collect DataFrame
end

println(x)

# output

3×3 DataFrames.DataFrame
│ Row │ name    │ age  │ children │
├─────┼─────────┼──────┼──────────┤
│ 1   │ "John"  │ 23.0 │ 3        │
│ 2   │ "Sally" │ 42.0 │ 5        │
│ 3   │ "Kirk"  │ 59.0 │ 2        │
```

## Arrays

Any array can be a data source for a query. The range variables are of the element type of the array and the elements are iterated in the order of the standard iterator of the array. Array sources are implemented as `Enumerable` data sources and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

```jldoctest
using Query, DataFrames

immutable Person
    Name::String
    Friends::Vector{String}
end

source = Array(Person,0)
push!(source, Person("John", ["Sally", "Miles", "Frank"]))
push!(source, Person("Sally", ["Don", "Martin"]))

result = @from i in source begin
         @where length(i.Friends) > 2
         @select {i.Name, Friendcount=length(i.Friends)}
         @collect
end

println(result)

# output

NamedTuples._NT_NameFriendcount{String,Int64}[(Name => John, Friendcount => 3)]
```

## DataStream

Any `DataStream` source can be a source in a query. This includes CSV.jl, Feather.jl and SQLite.jl sources (these are currenlty tested as part of Query.jl). Individual rows of these sources are represented as `NamedTuple` elements that have fields for all the columns of the data source. `DataStreams` sources are implemented as `Enumerable` data sources and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

This example reads a CSV file:

```jldoctest
using Query, DataStreams, CSV

q = @from i in CSV.Source(joinpath(Pkg.dir("Query"),"example", "data.csv")) begin
    @where i.Children > 2
    @select i.Name
    @collect
end

println(q)

# output

Query.DataValue{String}["John","Kirk"]
```

This example reads a Feather file:

```jldoctest
using Query, DataStreams, Feather

q = @from i in Feather.Source(joinpath(Pkg.dir("Feather"),"test", "data", "airquality.feather")) begin
    @where i.Day==2
    @select i.Month
    @collect
end

println(q)

# output

WARNING: This Feather file is old and will not be readable beyond the 0.3.0 release
Query.DataValue{Int32}[5,6,7,8,9]
```

## IndexedTables

`NDSparse` data sources can be a source in a query. Individual rows are represented as a `NamedTuple` with two fields. The `index` field holds the index data for this row. If the source has named columns, the type of the `index` field is a `NamedTuple`, where the fieldnames correspond to the names of the index columns. If the source doesn't use named columns, the type of the `index` field is a regular tuple. The second field is named `value` and holds the value of the row in the original source. `NDSparse` sources are implemented as `Enumerable` data sources and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

```jldoctest
using Query, IndexedTables

source_ndsparsearray = NDSparse(Columns(city = [fill("New York",3); fill("Boston",3)], date = repmat(Date(2016,7,6):Date(2016,7,8), 2)), [91,89,91,95,83,76])

q = @from i in source_ndsparsearray begin
    @where i.index.city=="New York"
    @select i.value
    @collect
end

println(q)

# output

[91,89,91]
```

## Any iterable type

Any data source type that implements the standard julia iterator protocoll (i.e. a `start`, `next` and `done` method) can be a query data source. Iterable data sources are implemented as `Enumerable` data sources and can therefore be combined with any other `Enumerable` data source in a single query.

### Example

[TODO]
