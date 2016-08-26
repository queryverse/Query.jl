var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Welcome-to-Query-1",
    "page": "Home",
    "title": "Welcome to Query",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Overview-1",
    "page": "Home",
    "title": "Overview",
    "category": "section",
    "text": "Query is a package for querying julia data sources. It can filter, project, join and group data from any iterable data source. It has enhanced support for querying arrays, DataFrames, TypedTables, NDSparseData and any DataStream source (e.g. CSV, Feather, SQLite etc.).The package currenlty provides working implementations for in-memory data sources, but will eventually be able to translate queries into e.g. SQL. There is a prototype implementation of such a \"query provider\" for SQLite in the package, but it is experimental at this point and only works for a very small subset of queries.Query is heavily inspired by LINQ, in fact right now the package is largely an implementation of the LINQ part of the C# specification. Future versions of Query will most likely add features that are not found in the original LINQ design."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "This package only works on julia 0.5- and newer. It is currently not registered, so you need to clone it:Pkg.clone(\"https://github.com/davidanthoff/Query.jl.git\")"
},

{
    "location": "tutorial.html#",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "page",
    "text": ""
},

{
    "location": "tutorial.html#Tutorial-1",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "section",
    "text": ""
},

{
    "location": "tutorial.html#First-steps-1",
    "page": "Tutorial",
    "title": "First steps",
    "category": "section",
    "text": "You can use Query to filter and transform columns from a DataFrame and then create a new DataFrame for the output:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age>30. && i.children > 2\n    @select @NT(Name=>lowercase(i.name))\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×1 DataFrames.DataFrame\n│ Row │ Name    │\n├─────┼─────────┤\n│ 1   │ \"sally\" │You don't have to start with a DataFrame, you can also query a Dict and then collect the results into a DataFrame:using Query, DataFrames, NamedTuples\n\nsource = Dict(\"John\"=>34., \"Sally\"=>56.)\n\nresult = @from i in source begin\n         @where i.second>36.\n         @select @NT(Name=>lowercase(i.first))\n         @collect DataFrame\nend\n\nprintln(result)\n\n# output\n\n1×1 DataFrames.DataFrame\n│ Row │ Name    │\n├─────┼─────────┤\n│ 1   │ \"sally\" │Or you can start with just an array that holds some self-defined type:using Query, DataFrames, NamedTuples\n\nimmutable Person\n    Name::String\n    Friends::Vector{String}\nend\n\nsource = Array(Person,0)\npush!(source, Person(\"John\", [\"Sally\", \"Miles\", \"Frank\"]))\npush!(source, Person(\"Sally\", [\"Don\", \"Martin\"]))\n\nresult = @from i in source begin\n         @where length(i.Friends) > 2\n         @select @NT( Name=>i.Name, Friendcount=>length(i.Friends))\n         @collect DataFrame\nend\n\nprintln(result)\n\n# output\n\n1×2 DataFrames.DataFrame\n│ Row │ Name   │ Friendcount │\n├─────┼────────┼─────────────┤\n│ 1   │ \"John\" │ 3           │You also don't have to collect into a DataFrame, you can for example collect just one filtered column into an Array:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age>30. && i.children > 2\n    @select lowercase(i.name)\n    @collect\nend\n\nprintln(x)\n\n# output\n\nString[\"sally\"]You can also not collect at all and instead just iterate over the results of your query:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age>30. && i.children > 2\n    @select @NT(Name=>lowercase(i.name), Kids=>i.children)\nend\n\nfor j in x\n    println(\"$(j.Name) has $(j.Kids) children.\")\nend\n\n# output\n\nsally has 5 children."
},

{
    "location": "tutorial.html#@let-statement-1",
    "page": "Tutorial",
    "title": "@let statement",
    "category": "section",
    "text": "The @let statement allows you to define range variables inside your query:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @let name_length = length(i.name)\n    @where name_length <= 4\n    @select @NT(Name=>lowercase(i.name), Length=>name_length)\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n 2×2 DataFrames.DataFrame\n│ Row │ Name   │ Length │\n├─────┼────────┼────────┤\n│ 1   │ \"john\" │ 4      │\n│ 2   │ \"kirk\" │ 4      │"
},

{
    "location": "tutorial.html#@join-statement-1",
    "page": "Tutorial",
    "title": "@join statement",
    "category": "section",
    "text": "The @join statement implements an inner join between two data sources. You can use this to join sources of different types. For example, below data from a DataFrame and a TypedTable are joined and the results are collected into a DataFrame:using DataFrames, Query, NamedTuples, TypedTables\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = @Table(c=[2.,4.,2.], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = @from i in df1 begin\n    @join j in df2 on i.a equals convert(Int,j.c)\n    @select @NT(a=>i.a,b=>i.b,c=>j.c,d=>j.d,e=>\"Name: $(j.d)\")\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×5 DataFrames.DataFrame\n│ Row │ a │ b   │ c   │ d       │ e             │\n├─────┼───┼─────┼─────┼─────────┼───────────────┤\n│ 1   │ 2 │ 2.0 │ 2.0 │ \"John\"  │ \"Name: John\"  │\n│ 2   │ 2 │ 2.0 │ 2.0 │ \"Sally\" │ \"Name: Sally\" │"
},

{
    "location": "internals.html#",
    "page": "Internals",
    "title": "Internals",
    "category": "page",
    "text": ""
},

{
    "location": "internals.html#Internals-1",
    "page": "Internals",
    "title": "Internals",
    "category": "section",
    "text": ""
},

{
    "location": "internals.html#Overview-1",
    "page": "Internals",
    "title": "Overview",
    "category": "section",
    "text": "This package is modeled closely after LINQ. If you are not familiar with LINQ, this is a great overview. It is especially recommended if you associate LINQ mainly with a query syntax in a language and don't know about the underlying language features and architecture, for example how anonymous types, lambdas and lots of other language features all play together. The query syntax is really just the tip of the iceberg.The core idea of this package right now is to iterate over NamedTuples for table like data structures. Starting with a DataFrame, query will create an iterator that produces a NamedTuple that has a field for each column, and the collect method can turn a stream of NamedTuples back into a DataFrame.If one starts with a queryable data source (like SQLite), the query will automatically be translated into SQL and executed in the database.The wording of methods and types currently follows LINQ, not julia conventions. This is mainly to prevent clashes while Query.jl is in development."
},

{
    "location": "internals.html#Nullable-1",
    "page": "Internals",
    "title": "Nullable",
    "category": "section",
    "text": "This package implements the C# spec semantics for lifting and handling Nullables. It currently overrides the definitions for various operators that are in NullableArrays."
},

{
    "location": "internals.html#Readings-1",
    "page": "Internals",
    "title": "Readings",
    "category": "section",
    "text": "The original LINQ document is still a good read.The The Wayward WebLog has some excellent posts about writing query providers:LINQ: Building an IQueryable Provider – Part I\nLINQ: Building an IQueryable Provider – Part II\nLINQ: Building an IQueryable Provider – Part III\nLINQ: Building an IQueryable Provider – Part IV\nLINQ: Building an IQueryable Provider – Part V\nLINQ: Building an IQueryable Provider – Part VI\nLINQ: Building an IQueryable provider – Part VII\nLINQ: Building an IQueryable Provider – Part VIII\nLINQ: Building an IQueryable Provider – Part IX\nLINQ: Building an IQueryable Provider – Part X\nLINQ: Building an IQueryable Provider – Part XI\nBuilding a LINQ IQueryable Provider – Part XII\nBuilding a LINQ IQueryable Provider – Part XIII\nBuilding a LINQ IQueryable provider – Part XIV\nBuilding a LINQ IQueryable provider – Part XV (IQToolkit v0.15)\nBuilding a LINQ IQueryable Provider – Part XVI (IQToolkit 0.16)\nBuilding a LINQ IQueryable Provider – Part XVII (IQToolkit 0.17)Joe Duffy wrote an interesting article about iterator protocolls:Joe Duffy on enumerating in .NetOn NULL values and 3VL in .Net."
},

]}
