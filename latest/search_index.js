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
    "text": "Query is a package for querying julia data sources. It can filter, project, join and group data from any iterable data source. It has enhanced support for querying arrays, DataFrames, TypedTables, IndexedTables and any DataStream source (e.g. CSV, Feather, SQLite etc.).The package currenlty provides working implementations for in-memory data sources, but will eventually be able to translate queries into e.g. SQL. There is a prototype implementation of such a \"query provider\" for SQLite in the package, but it is experimental at this point and only works for a very small subset of queries.Query is heavily inspired by LINQ, in fact right now the package is largely an implementation of the LINQ part of the C# specification. Future versions of Query will most likely add features that are not found in the original LINQ design."
},

{
    "location": "index.html#Installation-1",
    "page": "Introduction",
    "title": "Installation",
    "category": "section",
    "text": "This package only works on julia 0.5 and newer. You can add it with:Pkg.add(\"Query\")"
},

{
    "location": "index.html#Highlights-1",
    "page": "Introduction",
    "title": "Highlights",
    "category": "section",
    "text": "Query is an almost complete implementation of the query expression section of the C# specification, with some additional julia specific features added in.\nThe package supports a large number of data sources: DataFrames, TypedTables, normal arrays, any DataStream source (this includes CSV, Feather, SQLite), IndexedTables structures and any type that can be iterated.\nThe results of a query can be materialized into a range of different data structures: iterators, DataFrames, arrays, dictionaries or any DataStream sink (this includes CSV and Feather files).\nOne can mix and match almost all sources and sinks within one query. For example, one can easily perform a join of a DataFrame with a CSV file and write the results into a Feather file, all within one query.\nThe type instability problems that one can run into with DataFrames do not affect Query, i.e. queries against DataFrames are completely type stable.\nThere are three different APIs that package authors can use to make their data sources queryable with this package. The most simple API only requires a data source to provide an iterator. Another API provides a data source with a complete graph representation of the query and the data source can e.g. rewrite that query graph as a SQL statement to execute the query. The final API allows a data source to provide its own data structures that can represent a query graph.\nThe package is completely documented."
},

{
    "location": "gettingstarted.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "gettingstarted.html#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": "The basic structure of a query statement isq = @from <range variable> in <source> begin\n    <query statements>\nendMultiple <query statements> are separated by line breaks. Probably the most simple example is a query that filters a DataFrame and returns a subset of its columns:using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age>50\n    @select {i.name, i.children}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×2 DataFrames.DataFrame\n│ Row │ name   │ children │\n├─────┼────────┼──────────┤\n│ 1   │ \"Kirk\" │ 2        │"
},

{
    "location": "gettingstarted.html#Result-types-1",
    "page": "Getting Started",
    "title": "Result types",
    "category": "section",
    "text": "A query that is not terminated with a @collect statement will return an iterator that can be used to iterate over the individual elements of the result set. A @collect statement on the other hand materializes the results of a query into a specific data structure, e.g. an array or a DataFrame. The Data Sinks section describes all the available formats for query materialization."
},

{
    "location": "gettingstarted.html#Tables-1",
    "page": "Getting Started",
    "title": "Tables",
    "category": "section",
    "text": "The Query package does not require data sources or sinks to have a table like structure (i.e. rows and columns). When a table like structure is queried, it is treated as a set of NamedTuples, where the set elements correspond to the rows of the source, and the fields of the NamedTuple correspond to the columns. Data sinks that have a table like structure typically require the results of the query to be projected into a NamedTuple. The experimental {} syntax in the Query package provides a simplified way to construct NamedTuples in a @select statement."
},

{
    "location": "gettingstarted.html#Null-values-1",
    "page": "Getting Started",
    "title": "Null values",
    "category": "section",
    "text": "Missing values are represented as Nullable types. The eventual goal of the Query package is to not provide any special casing of null value handling, but instead rely entirely on julia base semantics for dealing with Nullable types. Currently support for Nullable types is sparse in julia base, and therefore Query provides a number of methods that make working with Nullable types easier, mostly in the form of lifted versions of standard operators."
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
    "text": "One can project child elements from the elements of a source by using multiple @from statements. The nested child elements are flattened into one stream of results when multiple @from statements are used. The syntax for any additional @from statement (apart from the initial one that starts a query) is @from <range variable> in <selector>. <range variable> is the name of the range variable to be used for the child elements, and <selector> is a julia expression that returns the child elements."
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
    "text": "The @join statement combines data from two different sources. There are two variants of the statement: an inner join and a group join. The @left_outer_join statement provides a traditional left outer join option."
},

{
    "location": "querycommands.html#Inner-join-1",
    "page": "Query Commands",
    "title": "Inner join",
    "category": "section",
    "text": "The syntax for an inner join is @join <range variable> in <source> on <left key> equals <right key>. <range variable> is the name of the variable that should reference elements from the right source in the join. <source> is the name of the right source in the join operation. <left key> and <right key> are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values."
},

{
    "location": "querycommands.html#Example-5",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query, NamedTuples\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = DataFrame(c=[2,4,2], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = @from i in df1 begin\n    @join j in df2 on i.a equals j.c\n    @select {i.a,i.b,j.c,j.d}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×4 DataFrames.DataFrame\n│ Row │ a │ b   │ c │ d       │\n├─────┼───┼─────┼───┼─────────┤\n│ 1   │ 2 │ 2.0 │ 2 │ \"John\"  │\n│ 2   │ 2 │ 2.0 │ 2 │ \"Sally\" │"
},

{
    "location": "querycommands.html#Group-join-1",
    "page": "Query Commands",
    "title": "Group join",
    "category": "section",
    "text": "The syntax for a group join is @join <range variable> in <source> on <left key> equals <right key> into <group variable>. <range variable> is the name of the variable that should reference elements from the right source in the join. <source> is the name of the right source in the join operation. <left key> and <right key> are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values. <group variable> is the name of the variable that will hold all the elements from the right source that are joined to a given element from the left source."
},

{
    "location": "querycommands.html#Example-6",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query, NamedTuples\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = DataFrame(c=[2,4,2], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = @from i in df1 begin\n    @join j in df2 on i.a equals j.c into k\n    @select {t1=i.a,t2=length(k)}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×2 DataFrames.DataFrame\n│ Row │ t1 │ t2 │\n├─────┼────┼────┤\n│ 1   │ 1  │ 0  │\n│ 2   │ 2  │ 2  │\n│ 3   │ 3  │ 0  │"
},

{
    "location": "querycommands.html#Left-outer-join-1",
    "page": "Query Commands",
    "title": "Left outer join",
    "category": "section",
    "text": "They syntax for a left outer join is @left_outer_join <range variable> in <source> on <left key> equals <right key>. <range variable> is the name of the variable that should reference elements from the right source in the join. <source> is the name of the right source in the join operation. <left key> and <right key> are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values. For elements in the left source that don't have any corresponding element in the right source, <range variable> is assigned the default value returned by the default_if_empty function based on the element types of <source>. If the right source has elements of type NamedTuple, and the fields of that named tuple are all of type Nullable, then an instance of that named tuple with all fields having null values will be used."
},

{
    "location": "querycommands.html#Example-7",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames, NamedTuples\nsource_df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\nsource_df2 = DataFrame(c=[2,4,2], d=[\"John\", \"Jim\",\"Sally\"])\n\nq = @from i in source_df1 begin\n    @left_outer_join j in source_df2 on i.a equals j.c\n    @select {i.a,i.b,j.c,j.d}\n    @collect DataFrame\nend\n\nprintln(q)\n\n# output\n\n4×4 DataFrames.DataFrame\n│ Row │ a │ b   │ c  │ d       │\n├─────┼───┼─────┼────┼─────────┤\n│ 1   │ 1 │ 1.0 │ NA │ NA      │\n│ 2   │ 2 │ 2.0 │ 2  │ \"John\"  │\n│ 3   │ 2 │ 2.0 │ 2  │ \"Sally\" │\n│ 4   │ 3 │ 3.0 │ NA │ NA      │"
},

{
    "location": "querycommands.html#Grouping-1",
    "page": "Query Commands",
    "title": "Grouping",
    "category": "section",
    "text": "The @group statement groups elements from the source by some attribute. The syntax for the group statement is @group <element selector> by <key selector> [into <range variable>]. <element selector> is an arbitrary julia expression that determines the content of the group elements. <key selector> is an arbitrary julia expression that returns the values by which the elements are grouped. A @group statement without an into clause ends a query statement, i.e. no further @select statement is needed. When a @group statement has an into clause, the <range variable> sets the name of the range variable for the groups, and further query statements can operate on these groups by referencing that range variable."
},

{
    "location": "querycommands.html#Example-8",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "This is an example of a @group statement without a into clause:using DataFrames, Query, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @group i.name by i.children\n    @collect\nend\n\nprintln(x)\n\n# output\n\nQuery.Grouping{Nullable{Int64},Nullable{String}}[Nullable{String}[\"John\"],Nullable{String}[\"Sally\",\"Kirk\"]]This is an example of a @group statement with an into clause:using DataFrames, Query, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @group i by i.children into g\n    @select {Key=g.key,Count=length(g)}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×2 DataFrames.DataFrame\n│ Row │ Key │ Count │\n├─────┼─────┼───────┤\n│ 1   │ 3   │ 1     │\n│ 2   │ 2   │ 2     │"
},

{
    "location": "querycommands.html#Range-variables-1",
    "page": "Query Commands",
    "title": "Range variables",
    "category": "section",
    "text": "The @let statement introduces new range variables in a query expression. The syntax for the range statement is @let <range variable> = <value selector>. <range variable> specifies the name of the new range variable and <value selector> is any julia expression that returns the value that should be assigned to the new range variable."
},

{
    "location": "querycommands.html#Example-9",
    "page": "Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @let count = length(i.name)\n    @let kids_per_year = i.children / i.age\n    @where count > 4\n    @select {Name=i.name, Count=count, KidsPerYear=kids_per_year}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×3 DataFrames.DataFrame\n│ Row │ Name    │ Count │ KidsPerYear │\n├─────┼─────────┼───────┼─────────────┤\n│ 1   │ \"Sally\" │ 5     │ 0.047619    │"
},

{
    "location": "sources.html#",
    "page": "Data Sources",
    "title": "Data Sources",
    "category": "page",
    "text": ""
},

{
    "location": "sources.html#Data-Sources-1",
    "page": "Data Sources",
    "title": "Data Sources",
    "category": "section",
    "text": "Query supports many different types of data sources, and you can often mix and match different source types in one query. This section describes all the currently supported data source types."
},

{
    "location": "sources.html#DataFrame-1",
    "page": "Data Sources",
    "title": "DataFrame",
    "category": "section",
    "text": "DataFrames are probably the most common data source in Query. They are implemented as an Enumerable data source type, and can therefore be combined with any other Enuermable data source type within one query. The range variable in a query that has a DataFrame as its source is a NamedTuple that has fields for each column of the DataFrame. The implementation of DataFrame sources gets around all problems of type stability that are sometimes associated with the DataFrames package."
},

{
    "location": "sources.html#Example-1",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select i\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×3 DataFrames.DataFrame\n│ Row │ name    │ age  │ children │\n├─────┼─────────┼──────┼──────────┤\n│ 1   │ \"John\"  │ 23.0 │ 3        │\n│ 2   │ \"Sally\" │ 42.0 │ 5        │\n│ 3   │ \"Kirk\"  │ 59.0 │ 2        │"
},

{
    "location": "sources.html#TypedTable-1",
    "page": "Data Sources",
    "title": "TypedTable",
    "category": "section",
    "text": "The TypedTables package provides an alternative implementation of a DataFrame-like data structure. Support for TypedTable data sources works in the same way as normal DataFrame sources, i.e. columns are represented as fields of NamedTuples. TypedTable sources are implemented as  Enumerable data source and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources.html#Example-2",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames, TypedTables\n\ntt = @Table(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in tt begin\n    @select i\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×3 DataFrames.DataFrame\n│ Row │ name    │ age  │ children │\n├─────┼─────────┼──────┼──────────┤\n│ 1   │ \"John\"  │ 23.0 │ 3        │\n│ 2   │ \"Sally\" │ 42.0 │ 5        │\n│ 3   │ \"Kirk\"  │ 59.0 │ 2        │"
},

{
    "location": "sources.html#Arrays-1",
    "page": "Data Sources",
    "title": "Arrays",
    "category": "section",
    "text": "Any array can be a data source for a query. The range variables are of the element type of the array and the elements are iterated in the order of the standard iterator of the array. Array sources are implemented as Enumerable data sources and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources.html#Example-3",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames, NamedTuples\n\nimmutable Person\n    Name::String\n    Friends::Vector{String}\nend\n\nsource = Array(Person,0)\npush!(source, Person(\"John\", [\"Sally\", \"Miles\", \"Frank\"]))\npush!(source, Person(\"Sally\", [\"Don\", \"Martin\"]))\n\nresult = @from i in source begin\n         @where length(i.Friends) > 2\n         @select {i.Name, Friendcount=length(i.Friends)}\n         @collect\nend\n\nprintln(result)\n\n# output\n\nNamedTuples._NT_NameFriendcount{String,Int64}[(Name => John, Friendcount => 3)]"
},

{
    "location": "sources.html#DataStream-1",
    "page": "Data Sources",
    "title": "DataStream",
    "category": "section",
    "text": "Any DataStream source can be a source in a query. This includes CSV.jl, Feather.jl and SQLite.jl sources (these are currenlty tested as part of Query.jl). Individual rows of these sources are represented as NamedTuple elements that have fields for all the columns of the data source. DataStreams sources are implemented as Enumerable data sources and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources.html#Example-4",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "This example reads a CSV file:using Query, DataStreams, CSV\n\nq = @from i in CSV.Source(joinpath(Pkg.dir(\"Query\"),\"example\", \"data.csv\")) begin\n    @where i.Children > 2\n    @select i.Name\n    @collect\nend\n\nprintln(q)\n\n# output\n\nNullable{String}[\"John\",\"Kirk\"]This example reads a Feather file:using Query, DataStreams, Feather\n\nq = @from i in Feather.Source(joinpath(Pkg.dir(\"Feather\"),\"test\", \"data\", \"airquality.feather\")) begin\n    @where i.Day==2\n    @select i.Month\n    @collect\nend\n\nprintln(q)\n\n# output\n\nWARNING: This Feather file is old and will not be readable beyond the 0.3.0 release\nInt32[5,6,7,8,9]"
},

{
    "location": "sources.html#IndexedTables-1",
    "page": "Data Sources",
    "title": "IndexedTables",
    "category": "section",
    "text": "NDSparse data sources can be a source in a query. Individual rows are represented as a NamedTuple with two fields. The index field holds the index data for this row. If the source has named columns, the type of the index field is a NamedTuple, where the fieldnames correspond to the names of the index columns. If the source doesn't use named columns, the type of the index field is a regular tuple. The second field is named value and holds the value of the row in the original source. NDSparse sources are implemented as Enumerable data sources and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources.html#Example-5",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "using Query, IndexedTables\n\nsource_ndsparsearray = NDSparse(Columns(city = [fill(\"New York\",3); fill(\"Boston\",3)], date = repmat(Date(2016,7,6):Date(2016,7,8), 2)), [91,89,91,95,83,76])\n\nq = @from i in source_ndsparsearray begin\n    @where i.index.city==\"New York\"\n    @select i.value\n    @collect\nend\n\nprintln(q)\n\n# output\n\n[91,89,91]"
},

{
    "location": "sources.html#Any-iterable-type-1",
    "page": "Data Sources",
    "title": "Any iterable type",
    "category": "section",
    "text": "Any data source type that implements the standard julia iterator protocoll (i.e. a start, next and done method) can be a query data source. Iterable data sources are implemented as Enumerable data sources and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources.html#Example-6",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "[TODO]"
},

{
    "location": "sinks.html#",
    "page": "Data Sinks",
    "title": "Data Sinks",
    "category": "page",
    "text": ""
},

{
    "location": "sinks.html#Data-Sinks-1",
    "page": "Data Sinks",
    "title": "Data Sinks",
    "category": "section",
    "text": "Query supports a number of different data sink types. One can materialize the results of a query into a specific sink by using the @collect statement. Queries that don't end with a @collect statement return an iterator that can be used to iterate over the results of the query."
},

{
    "location": "sinks.html#Array-1",
    "page": "Data Sinks",
    "title": "Array",
    "category": "section",
    "text": "Using the @collect statement without any further argument will materialize the query results into an array. The array will be a vector, and the element type of the array is the type of the elements returned by the last projection statement."
},

{
    "location": "sinks.html#Example-1",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select i.name\n    @collect\nend\n\nprintln(x)\n\n# output\n\nNullable{String}[\"John\",\"Sally\",\"Kirk\"]"
},

{
    "location": "sinks.html#DataFrame-1",
    "page": "Data Sinks",
    "title": "DataFrame",
    "category": "section",
    "text": "The statement @collect DataFrame will materialize the query results into a new DataFrame instance. This statement only works if the last projection statement transformed the results into a NamedTuple, for example by using the {} syntax."
},

{
    "location": "sinks.html#Example-2",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select {i.name, i.age, Children=i.children}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×3 DataFrames.DataFrame\n│ Row │ name    │ age  │ Children │\n├─────┼─────────┼──────┼──────────┤\n│ 1   │ \"John\"  │ 23.0 │ 3        │\n│ 2   │ \"Sally\" │ 42.0 │ 5        │\n│ 3   │ \"Kirk\"  │ 59.0 │ 2        │"
},

{
    "location": "sinks.html#Dict-1",
    "page": "Data Sinks",
    "title": "Dict",
    "category": "section",
    "text": "The statement @collect Dict will materialize the query results into a new Dict instance. This statement only works if the last projection statement transformed the results into a Pair, for example by using the => syntax."
},

{
    "location": "sinks.html#Example-3",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames, NamedTuples\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select get(i.name)=>get(i.children)\n    @collect Dict\nend\n\nprintln(x)\n\n# output\n\nDict(\"Sally\"=>5,\"John\"=>3,\"Kirk\"=>2)"
},

{
    "location": "sinks.html#CSV-file-1",
    "page": "Data Sinks",
    "title": "CSV file",
    "category": "section",
    "text": "The statement @collect CsvFile(filename) will write the results of the query into a CSV file with the name filename. This statement only works if the last projection statement transformed the results into a NamedTuple, for example by using the {} syntax. The CsvFile constructor call takes a number of optional arguments: delim_char, quote_char, escape_char and header. These arguments control the format of the CSV file that is created by the statement."
},

{
    "location": "sinks.html#Example-4",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "[TODO]"
},

{
    "location": "sinks.html#DataStram-sink-1",
    "page": "Data Sinks",
    "title": "DataStram sink",
    "category": "section",
    "text": "If a DataStreams sink is passed to the @collect statement, the results of the query will be written into that sink. The syntax for this is @collect sink, where sink can be any DataStreams sink instance. This statement only works if the last projection statement transformed the results into a NamedTuple, for example by using the {} syntax. Currently sinks of type CSV and Feather are regularly tested."
},

{
    "location": "sinks.html#Example-5",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "[TODO]"
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
