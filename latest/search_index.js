var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Overview-1",
    "page": "Introduction",
    "title": "Overview",
    "category": "section",
    "text": "Query is a package for querying julia data sources. It can filter, project, join and group data from any iterable data source. It has enhanced support for querying arrays, DataFrames, TypedTables, NDSparseData and any DataStream source (e.g. CSV, Feather, SQLite etc.).The package currenlty provides working implementations for in-memory data sources, but will eventually be able to translate queries into e.g. SQL. There is a prototype implementation of such a \"query provider\" for SQLite in the package, but it is experimental at this point and only works for a very small subset of queries.Query is heavily inspired by LINQ, in fact right now the package is largely an implementation of the LINQ part of the C# specification. Future versions of Query will most likely add features that are not found in the original LINQ design."
},

{
    "location": "index.html#Installation-1",
    "page": "Introduction",
    "title": "Installation",
    "category": "section",
    "text": "This package only works on julia 0.5- and newer. You can add it with:Pkg.add(\"Query\")"
},

{
    "location": "querycommands.html#",
    "page": "Query Commands",
    "title": "Query Commands",
    "category": "page",
    "text": ""
},

{
    "location": "querycommands.html#Query-Commands-1",
    "page": "Query Commands",
    "title": "Query Commands",
    "category": "section",
    "text": ""
},

{
    "location": "querycommands.html#Sorting-1",
    "page": "Query Commands",
    "title": "Sorting",
    "category": "section",
    "text": "The @orderby statement sorts the elements from a source by one or more element attributes. The syntax for the @orderby statement is @orderby <attribute>[, <attribute>]. <attribute> can be any julia expression that returns an attribute by which the source elements should be sorted. The default sort order is ascending. By wrapping an <attribute> in a call to descending(<attribute) one can reverse the sort order. The @orderby statement accepts multiple <attribute>s separated by ,s. With multiple sorting attributes, the elements are first sorted by the first attribute. Elements that can't be ranked by the first attribute are then sorted by the second attribute etc."
},

{
    "location": "querycommands.html#Example-1",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(a=[2,1,1,2,1,3],b=[2,2,1,1,3,2])\n\nx = @from i in df begin\n    @orderby descending(i.a), i.b\n    @select i\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n6×2 DataFrames.DataFrame\n│ Row │ a │ b │\n├─────┼───┼───┤\n│ 1   │ 3 │ 2 │\n│ 2   │ 2 │ 1 │\n│ 3   │ 2 │ 2 │\n│ 4   │ 1 │ 1 │\n│ 5   │ 1 │ 2 │\n│ 6   │ 1 │ 3 │"
},

{
    "location": "querycommands.html#Filtering-1",
    "page": "Query Commands",
    "title": "Filtering",
    "category": "section",
    "text": "The @where statement filters a source so that only those elements are returned that satisfy a filter condition. The syntax for the @where statement is @where <condition>. <condition> can be any arbitrary julia expression that evaluates to true or false."
},

{
    "location": "querycommands.html#Example-2",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age > 30. && i.children > 2\n    @select i\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×3 DataFrames.DataFrame\n│ Row │ name    │ age  │ children │\n├─────┼─────────┼──────┼──────────┤\n│ 1   │ \"Sally\" │ 42.0 │ 5        │\n"
},

{
    "location": "querycommands.html#Projecting-1",
    "page": "Query Commands",
    "title": "Projecting",
    "category": "section",
    "text": "The @select statement applies a transformation to each element of the source. The syntax for the @select statement is @select <condition>. <condition> can be any arbitrary julia expression that transforms an element from the source into the desired target format."
},

{
    "location": "querycommands.html#Example-3",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "The following example transforms each element from the source by squaring it.using Query\n\ndata = [1,2,3]\n\nx = @from i in data begin\n    @select i^2\n    @collect\nend\n\nprintln(x)\n\n# output\n\n[1,4,9]One of the most common patterns in Query is to transform elements into named tuples with a @select statement. There are two ways to create a named tuples in Query: a) using the standard syntax from the NamedTuples package, or b) an experimental syntax that only works in a Query @select statement. The experimental syntax is based on curly brackets {}. An example that highlights all options of the experimental syntax is this:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select {i.name, Age=i.age}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×2 DataFrames.DataFrame\n│ Row │ name    │ Age  │\n├─────┼─────────┼──────┤\n│ 1   │ \"John\"  │ 23.0 │\n│ 2   │ \"Sally\" │ 42.0 │\n│ 3   │ \"Kirk\"  │ 59.0 │The elements of the new named tuple are separated by commas ,. One can specify an explicit name for an individual element of a named tuple using the = syntax, where the name of the element is specified as the left argument and the value as the right argument. If the name of the element should be the same as the variable that is passed for the value, one doesn't have to specify a name explicitly, instead the {} syntax automatically infers the name."
},

{
    "location": "querycommands.html#Flattening-1",
    "page": "Query Commands",
    "title": "Flattening",
    "category": "section",
    "text": "One can project child elements from the elements of a source by using multiple @from statements. The nested child elements are flattened into one stream of results when multiple @from statements are used. The syntax for any additional @from statement (apart from the initial one that starts a query) is @from <range variable> in <selector>. <range variable is the name of the range variable to be used for the child elements, and <selector> is a julia expression that returns the child elements."
},

{
    "location": "querycommands.html#Example-4",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query, NamedTuples\n\nsource = Dict(:a=>[1,2,3], :b=>[4,5])\n\nq = @from i in source begin\n    @from j in i.second\n    @select {Key=i.first,Value=j}\n    @collect DataFrame\nend\n\nprintln(q)\n\n# output\n\n5×2 DataFrames.DataFrame\n│ Row │ Key │ Value │\n├─────┼─────┼───────┤\n│ 1   │ a   │ 1     │\n│ 2   │ a   │ 2     │\n│ 3   │ a   │ 3     │\n│ 4   │ b   │ 4     │\n│ 5   │ b   │ 5     │"
},

{
    "location": "querycommands.html#Joining-1",
    "page": "Query Commands",
    "title": "Joining",
    "category": "section",
    "text": "The @join statement combines data from two different sources. There are two variants of the statement: an inner join and a group join.The syntax for an inner join is @join <range variable> in <source> on <left key> equals <right key>. <range variable> is the name of the variable that should reference elements from the right source in the join. <source> is the name of the right source in the join operation. <left key> and <right key> are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values."
},

{
    "location": "querycommands.html#Example-5",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query, NamedTuples\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = DataFrame(c=[2.,4.,2.], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = @from i in df1 begin\n    @join j in df2 on i.a equals convert(Int,j.c)\n    @select {i.a,i.b,j.c,j.d}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×4 DataFrames.DataFrame\n│ Row │ a │ b   │ c   │ d       │\n├─────┼───┼─────┼─────┼─────────┤\n│ 1   │ 2 │ 2.0 │ 2.0 │ \"John\"  │\n│ 2   │ 2 │ 2.0 │ 2.0 │ \"Sally\" │The syntax for a group join is @join <range variable> in <source> on <left key> equals <right key> into <group variable>. <range variable> is the name of the variable that should reference elements from the right source in the join. <source> is the name of the right source in the join operation. <left key> and <right key> are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values. <group variable> is the name of the variable that will hold all the elements from the right source that are joined to a given element from the left source."
},

{
    "location": "querycommands.html#Example-6",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query, NamedTuples\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = DataFrame(c=[2.,4.,2.], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = @from i in df1 begin\n    @join j in df2 on i.a equals convert(Int,j.c) into k\n    @select {t1=i,t2=length(k)}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×2 DataFrames.DataFrame\n│ Row │ t1                 │ t2 │\n├─────┼────────────────────┼────┤\n│ 1   │ (a => 1, b => 1.0) │ 0  │\n│ 2   │ (a => 2, b => 2.0) │ 2  │\n│ 3   │ (a => 3, b => 3.0) │ 0  │"
},

{
    "location": "querycommands.html#Grouping-1",
    "page": "Query Commands",
    "title": "Grouping",
    "category": "section",
    "text": "The @group statement groups elements from the source by some attribute. The syntax for the group statement is @group <element selector> by <key selector> [into <range variable>]. <element selector> is an arbitrary julia expression that determines the content of the group elements. <key selector> is an arbitrary julia expression that returns the values by which the elements are grouped. A @group statement without an into clause ends a query statement, i.e. no further @select statement is needed. When a @group statement has an into clause, the <range variable> sets the name of the range variable for the groups, and further query statements can operate on these groups by referencing that range variable."
},

{
    "location": "querycommands.html#Example-7",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "This is an example of a @group statement without a into clause:using DataFrames, Query, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @group i.name by i.children\n    @collect\nend\n\nprintln(x)\n\n# output\n\nQuery.Grouping{Int64,String}[String[\"John\"],String[\"Sally\",\"Kirk\"]]This is an example of a @group statement with an into clause:using DataFrames, Query, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @group i by i.children into g\n    @select {Key=g.key,Count=length(g)}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×2 DataFrames.DataFrame\n│ Row │ Key │ Count │\n├─────┼─────┼───────┤\n│ 1   │ 3   │ 1     │\n│ 2   │ 2   │ 2     │"
},

{
    "location": "querycommands.html#Range-variables-1",
    "page": "Query Commands",
    "title": "Range variables",
    "category": "section",
    "text": "The @let statement introduces new range variables in a query expression. The syntax for the range statement is @let <range variable> = <value selector>. <range variable> specifies the name of the new range variable and <value selector> is any julia expression that returns the value that should be assigned to the new range variable."
},

{
    "location": "querycommands.html#Example-8",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @let count = length(i.name)\n    @let kids_per_year = i.children / i.age\n    @where count > 4\n    @select {Name=i.name, Count=count, KidsPerYear=kids_per_year}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×3 DataFrames.DataFrame\n│ Row │ Name    │ Count │ KidsPerYear │\n├─────┼─────────┼───────┼─────────────┤\n│ 1   │ \"Sally\" │ 5     │ 0.047619    │"
},

{
    "location": "examples.html#",
    "page": "Examples",
    "title": "Examples",
    "category": "page",
    "text": ""
},

{
    "location": "examples.html#Examples-1",
    "page": "Examples",
    "title": "Examples",
    "category": "section",
    "text": ""
},

{
    "location": "examples.html#First-steps-1",
    "page": "Examples",
    "title": "First steps",
    "category": "section",
    "text": "You can use Query to filter and transform columns from a DataFrame and then create a new DataFrame for the output:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age>30. && i.children > 2\n    @select {Name=lowercase(i.name)}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×1 DataFrames.DataFrame\n│ Row │ Name    │\n├─────┼─────────┤\n│ 1   │ \"sally\" │You don't have to start with a DataFrame, you can also query a Dict and then collect the results into a DataFrame:using Query, DataFrames, NamedTuples\n\nsource = Dict(\"John\"=>34., \"Sally\"=>56.)\n\nresult = @from i in source begin\n         @where i.second>36.\n         @select {Name=lowercase(i.first)}\n         @collect DataFrame\nend\n\nprintln(result)\n\n# output\n\n1×1 DataFrames.DataFrame\n│ Row │ Name    │\n├─────┼─────────┤\n│ 1   │ \"sally\" │Or you can start with just an array that holds some self-defined type:using Query, DataFrames, NamedTuples\n\nimmutable Person\n    Name::String\n    Friends::Vector{String}\nend\n\nsource = Array(Person,0)\npush!(source, Person(\"John\", [\"Sally\", \"Miles\", \"Frank\"]))\npush!(source, Person(\"Sally\", [\"Don\", \"Martin\"]))\n\nresult = @from i in source begin\n         @where length(i.Friends) > 2\n         @select {i.Name, Friendcount=length(i.Friends)}\n         @collect DataFrame\nend\n\nprintln(result)\n\n# output\n\n1×2 DataFrames.DataFrame\n│ Row │ Name   │ Friendcount │\n├─────┼────────┼─────────────┤\n│ 1   │ \"John\" │ 3           │You also don't have to collect into a DataFrame, you can for example collect just one filtered column into an Array:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age>30. && i.children > 2\n    @select lowercase(i.name)\n    @collect\nend\n\nprintln(x)\n\n# output\n\nNullable{String}[\"sally\"]You can also not collect at all and instead just iterate over the results of your query:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age>30. && i.children > 2\n    @select {Name=lowercase(i.name), Kids=i.children}\nend\n\nfor j in x\n    println(\"$(get(j.Name)) has $(get(j.Kids)) children.\")\nend\n\n# output\n\nsally has 5 children."
},

{
    "location": "examples.html#@let-statement-1",
    "page": "Examples",
    "title": "@let statement",
    "category": "section",
    "text": "The @let statement allows you to define range variables inside your query:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @let name_length = length(i.name)\n    @where name_length <= 4\n    @select {Name=lowercase(i.name), Length=name_length}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n 2×2 DataFrames.DataFrame\n│ Row │ Name   │ Length │\n├─────┼────────┼────────┤\n│ 1   │ \"john\" │ 4      │\n│ 2   │ \"kirk\" │ 4      │"
},

{
    "location": "examples.html#@join-statement-1",
    "page": "Examples",
    "title": "@join statement",
    "category": "section",
    "text": "The @join statement implements an inner join between two data sources. You can use this to join sources of different types. For example, below data from a DataFrame and a TypedTable are joined and the results are collected into a DataFrame:using DataFrames, Query, NamedTuples, TypedTables\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = @Table(c=[2.,4.,2.], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = @from i in df1 begin\n    @join j in df2 on get(i.a) equals convert(Int,j.c)\n    @select {i.a,i.b,j.c,j.d,e=\"Name: $(j.d)\"}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×5 DataFrames.DataFrame\n│ Row │ a │ b   │ c   │ d       │ e             │\n├─────┼───┼─────┼─────┼─────────┼───────────────┤\n│ 1   │ 2 │ 2.0 │ 2.0 │ \"John\"  │ \"Name: John\"  │\n│ 2   │ 2 │ 2.0 │ 2.0 │ \"Sally\" │ \"Name: Sally\" │"
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
