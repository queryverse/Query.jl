# Tutorial

```@meta
DocTestSetup = quote
    Pkg.add("DataFrames")
    using Query
    using DataFrames
    using NamedTuples
end
```

You can use Query to filter and transform columns from a ``DataFrame`` and then create a new ``DataFrame`` for the output:

```jldoctest
using Query, DataFrames, NamedTuples

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @where i.age>30. && i.children > 2
    @select @NT(Name=>lowercase(i.name))
    @collect DataFrame
end

println(x)

# output

1×1 DataFrames.DataFrame
│ Row │ Name    │
├─────┼─────────┤
│ 1   │ "sally" │
```

You don't have to start with a ``DataFrame``, you can also query a ``Dict`` and then collect the results into a ``DataFrame``:

```jldoctest
using Query, DataFrames, NamedTuples

source = Dict("John"=>34., "Sally"=>56.)

result = @from i in source begin
         @where i.second>36.
         @select @NT(Name=>lowercase(i.first))
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
         @select @NT( Name=>i.Name, Friendcount=>length(i.Friends))
         @collect DataFrame
end

println(result)

# output

1×2 DataFrames.DataFrame
│ Row │ Name   │ Friendcount │
├─────┼────────┼─────────────┤
│ 1   │ "John" │ 3           │
```

You also don't have to collect into a ``DataFrame``, you can for example collect just one filted column into an ``Array``:

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
    @select @NT(Name=>lowercase(i.name), Kids=>i.children)
end

for j in x
    println("$(j.Name) has $(j.Kids) children.")
end

# output

sally has 5 children.
```

```@meta
DocTestSetup = nothing
```
