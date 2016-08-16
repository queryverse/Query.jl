# Tutorial

```@meta
DocTestSetup = quote
    Pkg.add("DataFrames")
    using Query
    using DataFrames
    using NamedTuples
end
```

You can use Query to filter and select from a ``DataFrame``:

```jldoctest
using Query
using DataFrames
using NamedTuples

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @where i.age>30. && i.children > 2
    @select @NT(Name=>lowercase(i.name))
    @collect DataFrame
end

println(x)

# output

1×1 DataFrames.DataFrames
│ Row │ Name    │
├─────┼─────────┤
│ 1   │ "sally" │
```

```@meta
DocTestSetup = nothing
```
