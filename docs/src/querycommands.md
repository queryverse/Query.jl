# Query Commands

## Sorting

The `@orderby` statement sorts the elements from a source by one or more element attributes. The syntax for the `@orderby` statement is `@orderby <attribute>[, <attribute>]`. `<attribute>` can be any julia expression that returns an attribute by which the source elements should be sorted. The default sort order is ascending. By wrapping an `<attribute>` in a call to `descending(<attribute)` one can reverse the sort order. The `@orderby` statement accepts multiple `<attribute>`s separated by `,`s. With multiple sorting attributes, the elements are first sorted by the first attribute. Elements that can't be ranked by the first attribute are then sorted by the second attribute etc.

#### Example

```jldoctest
using Query, DataFrames

df = DataFrame(a=[2,1,1,2,1,3],b=[2,2,1,1,3,2])

x = @from i in df begin
    @orderby descending(i.a), i.b
    @select i
    @collect DataFrame
end

println(x)

# output

6×2 DataFrames.DataFrame
│ Row │ a │ b │
├─────┼───┼───┤
│ 1   │ 3 │ 2 │
│ 2   │ 2 │ 1 │
│ 3   │ 2 │ 2 │
│ 4   │ 1 │ 1 │
│ 5   │ 1 │ 2 │
│ 6   │ 1 │ 3 │
```

## Filtering

The `@where` statement filters a source so that only those elements are returned that satisfy a filter condition. The syntax for the `@where` statement is `@where <condition>`. `<condition>` can be any arbitrary julia expression that evaluates to `true` or `false`.

#### Example

```jldoctest
using Query, DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @where i.age > 30. && i.children > 2
    @select i
    @collect DataFrame
end

println(x)

# output

1×3 DataFrames.DataFrame
│ Row │ name    │ age  │ children │
├─────┼─────────┼──────┼──────────┤
│ 1   │ "Sally" │ 42.0 │ 5        │

```

## Projecting

The `@select` statement applies a transformation to each element of the source. The syntax for the `@select` statement is `@select <condition>`. `<condition>` can be any arbitrary julia expression that transforms an element from the source into the desired target format.

#### Example

The following example transforms each element from the source by squaring it.

```jldoctest
using Query

data = [1,2,3]

x = @from i in data begin
    @select i^2
    @collect
end

println(x)

# output

[1,4,9]
```
One of the most common patterns in Query is to transform elements into [named tuples](https://github.com/blackrock/NamedTuples.jl) with a `@select` statement. There are two ways to create a [named tuples](https://github.com/blackrock/NamedTuples.jl) in Query: a) using the standard syntax from the [NamedTuples](https://github.com/blackrock/NamedTuples.jl) package, or b) an experimental syntax that *only* works in a Query `@select` statement. The experimental syntax is based on curly brackets `{}`. An example that highlights all options of the experimental syntax is this:

```jldoctest
using Query, DataFrames

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @select {i.name, Age=i.age}
    @collect DataFrame
end

println(x)

# output

3×2 DataFrames.DataFrame
│ Row │ name    │ Age  │
├─────┼─────────┼──────┤
│ 1   │ "John"  │ 23.0 │
│ 2   │ "Sally" │ 42.0 │
│ 3   │ "Kirk"  │ 59.0 │
```
The elements of the new named tuple are separated by commas `,`. One can specify an explicit name for an individual element of a named tuple using the `=` syntax, where the name of the element is specified as the left argument and the value as the right argument. If the name of the element should be the same as the variable that is passed for the value, one doesn't have to specify a name explicitly, instead the `{}` syntax automatically infers the name.

## Flattening

One can project child elements from the elements of a source by using multiple `@from` statements. The nested child elements are flattened into one stream of results when multiple `@from` statements are used. The syntax for any additional `@from` statement (apart from the initial one that starts a query) is `@from <range variable> in <selector>`. `<range variable>` is the name of the range variable to be used for the child elements, and `<selector>` is a julia expression that returns the child elements.

#### Example

```jldoctest
using DataFrames, Query

source = Dict(:a=>[1,2,3], :b=>[4,5])

q = @from i in source begin
    @from j in i.second
    @select {Key=i.first,Value=j}
    @collect DataFrame
end

println(q)

# output

5×2 DataFrames.DataFrame
│ Row │ Key │ Value │
├─────┼─────┼───────┤
│ 1   │ a   │ 1     │
│ 2   │ a   │ 2     │
│ 3   │ a   │ 3     │
│ 4   │ b   │ 4     │
│ 5   │ b   │ 5     │
```

## Joining

The `@join` statement combines data from two different sources. There are two variants of the statement: an inner join and a group join. The `@left_outer_join` statement provides a traditional left outer join option.

### Inner join

The syntax for an inner join is `@join <range variable> in <source> on <left key> equals <right key>`. `<range variable>` is the name of the variable that should reference elements from the right source in the join. `<source>` is the name of the right source in the join operation. `<left key>` and `<right key>` are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values.

#### Example

```jldoctest
using DataFrames, Query

df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
df2 = DataFrame(c=[2,4,2], d=["John", "Jim","Sally"])

x = @from i in df1 begin
    @join j in df2 on i.a equals j.c
    @select {i.a,i.b,j.c,j.d}
    @collect DataFrame
end

println(x)

# output

2×4 DataFrames.DataFrame
│ Row │ a │ b   │ c │ d       │
├─────┼───┼─────┼───┼─────────┤
│ 1   │ 2 │ 2.0 │ 2 │ "John"  │
│ 2   │ 2 │ 2.0 │ 2 │ "Sally" │
```

### Group join

The syntax for a group join is `@join <range variable> in <source> on <left key> equals <right key> into <group variable>`. `<range variable>` is the name of the variable that should reference elements from the right source in the join. `<source>` is the name of the right source in the join operation. `<left key>` and `<right key>` are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values. `<group variable>` is the name of the variable that will hold all the elements from the right source that are joined to a given element from the left source.

#### Example

```jldoctest
using DataFrames, Query

df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
df2 = DataFrame(c=[2,4,2], d=["John", "Jim","Sally"])

x = @from i in df1 begin
    @join j in df2 on i.a equals j.c into k
    @select {t1=i.a,t2=length(k)}
    @collect DataFrame
end

println(x)

# output

3×2 DataFrames.DataFrame
│ Row │ t1 │ t2 │
├─────┼────┼────┤
│ 1   │ 1  │ 0  │
│ 2   │ 2  │ 2  │
│ 3   │ 3  │ 0  │
```

### Left outer join

They syntax for a left outer join is `@left_outer_join <range variable> in <source> on <left key> equals <right key>`. `<range variable>` is the name of the variable that should reference elements from the right source in the join. `<source>` is the name of the right source in the join operation. `<left key>` and `<right key>` are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values. For elements in the left source that don't have any corresponding element in the right source, `<range variable>` is assigned the default value returned by the `default_if_empty` function based on the element types of `<source>`. If the right source has elements of type `NamedTuple`, and the fields of that named tuple are all of type `DataValue`, then an instance of that named tuple with all fields having NA values will be used.

#### Example

```jldoctest
using Query, DataFrames

source_df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
source_df2 = DataFrame(c=[2,4,2], d=["John", "Jim","Sally"])

q = @from i in source_df1 begin
    @left_outer_join j in source_df2 on i.a equals j.c
    @select {i.a,i.b,j.c,j.d}
    @collect DataFrame
end

println(q)

# output

4×4 DataFrames.DataFrame
│ Row │ a │ b   │ c  │ d       │
├─────┼───┼─────┼────┼─────────┤
│ 1   │ 1 │ 1.0 │ NA │ NA      │
│ 2   │ 2 │ 2.0 │ 2  │ "John"  │
│ 3   │ 2 │ 2.0 │ 2  │ "Sally" │
│ 4   │ 3 │ 3.0 │ NA │ NA      │
```

## Grouping

 The `@group` statement groups elements from the source by some attribute. The syntax for the group statement is `@group <element selector> by <key selector> [into <range variable>]`. `<element selector>` is an arbitrary julia expression that determines the content of the group elements. `<key selector>` is an arbitrary julia expression that returns the values by which the elements are grouped. A `@group` statement without an `into` clause ends a query statement, i.e. no further `@select` statement is needed. When a `@group` statement has an `into` clause, the `<range variable>` sets the name of the range variable for the groups, and further query statements can operate on these groups by referencing that range variable.

#### Example

 This is an example of a `@group` statement without a `into` clause:

 ```jldoctest
using DataFrames, Query

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = @from i in df begin
    @group i.name by i.children
    @collect
end

println(x)

# output

Query.Grouping{DataValue{Int64},DataValue{String}}[DataValue{String}["John"],DataValue{String}["Sally","Kirk"]]
```

This is an example of a `@group` statement with an `into` clause:

```jldoctest
using DataFrames, Query

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = @from i in df begin
    @group i by i.children into g
    @select {Key=g.key,Count=length(g)}
    @collect DataFrame
end

println(x)

# output

2×2 DataFrames.DataFrame
│ Row │ Key │ Count │
├─────┼─────┼───────┤
│ 1   │ 3   │ 1     │
│ 2   │ 2   │ 2     │
```

## Range variables

The `@let` statement introduces new range variables in a query expression. The syntax for the range statement is `@let <range variable> = <value selector>`. `<range variable>` specifies the name of the new range variable and `<value selector>` is any julia expression that returns the value that should be assigned to the new range variable.

#### Example

```jldoctest
using DataFrames, Query

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = @from i in df begin
    @let count = length(i.name)
    @let kids_per_year = i.children / i.age
    @where count > 4
    @select {Name=i.name, Count=count, KidsPerYear=kids_per_year}
    @collect DataFrame
end

println(x)

# output

1×3 DataFrames.DataFrame
│ Row │ Name    │ Count │ KidsPerYear │
├─────┼─────────┼───────┼─────────────┤
│ 1   │ "Sally" │ 5     │ 0.047619    │
```
