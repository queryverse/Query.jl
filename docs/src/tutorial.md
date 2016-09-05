# Tutorial

## First steps

You can use Query to filter and transform columns from a `DataFrame` and then create a new `DataFrame` for the output:

```jldoctest
using Query, DataFrames, NamedTuples

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @where i.age>30. && i.children > 2
    @select {Name=lowercase(i.name)}
    @collect DataFrame
end

println(x)

# output

1×1 DataFrames.DataFrame
│ Row │ Name    │
├─────┼─────────┤
│ 1   │ "sally" │
```

You don't have to start with a `DataFrame`, you can also query a `Dict` and then collect the results into a `DataFrame`:

```jldoctest
using Query, DataFrames, NamedTuples

source = Dict("John"=>34., "Sally"=>56.)

result = @from i in source begin
         @where i.second>36.
         @select {Name=lowercase(i.first)}
         @collect DataFrame
end

println(result)

# output

1×1 DataFrames.DataFrame
│ Row │ Name    │
├─────┼─────────┤
│ 1   │ "sally" │
```

Or you can start with just an array that holds some self-defined type:

```jldoctest
using Query, DataFrames, NamedTuples

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
         @collect DataFrame
end

println(result)

# output

1×2 DataFrames.DataFrame
│ Row │ Name   │ Friendcount │
├─────┼────────┼─────────────┤
│ 1   │ "John" │ 3           │
```

You also don't have to collect into a `DataFrame`, you can for example collect just one filtered column into an `Array`:

```jldoctest
using Query, DataFrames, NamedTuples

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @where i.age>30. && i.children > 2
    @select lowercase(i.name)
    @collect
end

println(x)

# output

String["sally"]
```

You can also not collect at all and instead just iterate over the results of your query:

```jldoctest
using Query, DataFrames, NamedTuples

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @where i.age>30. && i.children > 2
    @select {Name=lowercase(i.name), Kids=i.children}
end

for j in x
    println("$(j.Name) has $(j.Kids) children.")
end

# output

sally has 5 children.
```

## @let statement

The `@let` statement allows you to define range variables inside your query:

```jldoctest
using Query, DataFrames, NamedTuples

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @let name_length = length(i.name)
    @where name_length <= 4
    @select {Name=lowercase(i.name), Length=name_length}
    @collect DataFrame
end

println(x)

# output

 2×2 DataFrames.DataFrame
│ Row │ Name   │ Length │
├─────┼────────┼────────┤
│ 1   │ "john" │ 4      │
│ 2   │ "kirk" │ 4      │
```

## @join statement

The `@join` statement implements an inner join between two data sources. You can use this to join sources of different types. For example, below data from a `DataFrame` and a `TypedTable` are joined and the results are collected into a `DataFrame`:

```jldoctest
using DataFrames, Query, NamedTuples, TypedTables

df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
df2 = @Table(c=[2.,4.,2.], d=["John", "Jim","Sally"])

x = @from i in df1 begin
    @join j in df2 on i.a equals convert(Int,j.c)
    @select {i.a,i.b,j.c,j.d,e="Name: $(j.d)"}
    @collect DataFrame
end

println(x)

# output

2×5 DataFrames.DataFrame
│ Row │ a │ b   │ c   │ d       │ e             │
├─────┼───┼─────┼─────┼─────────┼───────────────┤
│ 1   │ 2 │ 2.0 │ 2.0 │ "John"  │ "Name: John"  │
│ 2   │ 2 │ 2.0 │ 2.0 │ "Sally" │ "Name: Sally" │
```
