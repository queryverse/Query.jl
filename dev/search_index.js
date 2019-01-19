var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": ""
},

{
    "location": "#Overview-1",
    "page": "Introduction",
    "title": "Overview",
    "category": "section",
    "text": "Query is a package for querying julia data sources. It can filter, project, join, sort and group data from any iterable data source, including all the sources that support the TableTraits.jl interface (this includes everything listed in IterableTables.jl).Query is heavily inspired by LINQ and dplyr."
},

{
    "location": "#Installation-1",
    "page": "Introduction",
    "title": "Installation",
    "category": "section",
    "text": "You can install the package at the Pkg REPL-mode with:(v1.0) pkg> add Query"
},

{
    "location": "#Highlights-1",
    "page": "Introduction",
    "title": "Highlights",
    "category": "section",
    "text": "Query contains an almost complete implementation of the query expression section of the C# specification, with some additional julia specific features added in.\nThe package supports a large number of data sources: DataFrames.jl, Pandas.jl, IndexedTables.jl, JuliaDB.jl, TimeSeries.jl, Temporal.jl, CSVFiles.jl, ExcelFiles.jl, FeatherFiles.jl, ParquetFiles.jl, BedgraphFiles.jl, StatFiles.jl, DifferentialEquations (any DESolution), arrays and any type that can be iterated.\nThe results of a query can be materialized into a range of different data structures: iterators, DataFrames.jl, IndexedTables.jl, JuliaDB.jl, TimeSeries.jl, Temporal.jl, Pandas.jl, StatsModels.jl, CSVFiles.jl, FeatherFiles.jl, ExcelFiles.jl, StatPlots.jl, VegaLite.jl, TableView.jl, DataVoyager.jl, arrays, dictionaries or any array.\nOne can mix and match almost all sources and sinks within one query. For example, one can easily perform a join of a DataFrame with a CSV file and write the results into a Feather file, all within one query.\nThe type instability problems that one can run into with DataFrames do not affect Query, i.e. queries against DataFrames are completely type stable.\nThere are three different APIs that package authors can use to make their data sources queryable with this package. The most simple API only requires a data source to provide an iterator. Another API provides a data source with a complete graph representation of the query and the data source can e.g. rewrite that query graph as a SQL statement to execute the query. The final API allows a data source to provide its own data structures that can represent a query graph.\nThe package is completely documented."
},

{
    "location": "gettingstarted/#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "gettingstarted/#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": "Query.jl supports two different front-end syntax options: 1) standalone query operators that are combined via the pipe operator and 2) LINQ style queries."
},

{
    "location": "gettingstarted/#Standalone-query-operators-1",
    "page": "Getting Started",
    "title": "Standalone query operators",
    "category": "section",
    "text": "The standalone query operators are typically combined into more complicated queries via the pipe operator. The example from the previous section can also be written like this, using the @filter and @map standalone query operators:using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = df |>\n  @filter(_.age>50) |>\n  @map({_.name, _.children}) |>\n  DataFrame\n\nprintln(x)\n\n# output\n\n1×2 DataFrames.DataFrame\n│ Row │ name   │ children │\n│     │ String │ Int64    │\n├─────┼────────┼──────────┤\n│ 1   │ Kirk   │ 2        │"
},

{
    "location": "gettingstarted/#LINQ-style-queries-1",
    "page": "Getting Started",
    "title": "LINQ style queries",
    "category": "section",
    "text": "The basic structure of a LINQ style query statement isq = @from <range variable> in <source> begin\n    <query statements>\nendMultiple <query statements> are separated by line breaks. Probably the most simple example is a query that filters a DataFrame and returns a subset of its columns:using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age>50\n    @select {i.name, i.children}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×2 DataFrames.DataFrame\n│ Row │ name   │ children │\n│     │ String │ Int64    │\n├─────┼────────┼──────────┤\n│ 1   │ Kirk   │ 2        │"
},

{
    "location": "gettingstarted/#Result-types-1",
    "page": "Getting Started",
    "title": "Result types",
    "category": "section",
    "text": "The results of a query can optionally be materialized into a data structure. For LINQ style queries this is done with a @collect statement at the end of the query. For the standalone query option, one can simply pipe things into a data structure type. The Data Sinks section describes all the available formats for query materialization.A query that is not materialized will return an iterator that can be used to iterate over the individual elements of the result set."
},

{
    "location": "gettingstarted/#Tables-1",
    "page": "Getting Started",
    "title": "Tables",
    "category": "section",
    "text": "The Query package does not require data sources or sinks to have a table like structure (i.e. rows and columns). When a table like structure is queried, it is treated as a set of NamedTuples, where the set elements correspond to the rows of the source, and the fields of the NamedTuple correspond to the columns. Data sinks that have a table like structure typically require the results of the query to be projected into a NamedTuple. The {} syntax in the Query package provides a simplified way to construct NamedTuples in query statements."
},

{
    "location": "gettingstarted/#Missing-values-1",
    "page": "Getting Started",
    "title": "Missing values",
    "category": "section",
    "text": "Missing values are represented as DataValue types from the DataValues.jl package. Here are some usage tips.All arithmetic operators work automatically with missing values. If any of the arguments to an arithmetic operation is a missing value, the result will also be a missing value.All comparison operators, like == or < etc. also work with missing values. These operators always return either true or false.If you want to use a function that does not support missing values out of the box, you can lift that function using the . operator. This lifted function will propagate any missing values, i.e. if any of the arguments to such a lifted function is missing, the result will also be a missing value. For example, to apply the log function on a column that is of type DataValue{Float64}, i.e. a column that can have missing values, one would write log.(i.a), assuming the column is named a. The return type of this call will be DataValue{Float64}."
},

{
    "location": "gettingstarted/#Piping-data-through-a-LINQ-style-query-1",
    "page": "Getting Started",
    "title": "Piping data through a LINQ style query",
    "category": "section",
    "text": "LINQ style queries can also be intgrated into data pipelines that are constructed via the |> operator. Such queries are started with the @query macro instead of the @from macro. The main difference between those two macros is that the @query macro does not take an argument for the data source, instead the data source needs to be piped into the query. In practice the syntax for the @query macro looks like this:using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = df |> @query(i, begin\n            @where i.age>50\n            @select {i.name, i.children}\n          end) |> DataFrame\n\nprintln(x)\n\n# output\n\n1×2 DataFrames.DataFrame\n│ Row │ name   │ children │\n├─────┼────────┼──────────┤\n│ 1   │ \"Kirk\" │ 2        │Note how the range variable i is the first argument to the @query macro, and then the second argument is a begin...end block that contains the query operators for the query. Note also that it is recommended to use parenthesis () to call the @query macro, otherwise any continuing pipe operator will not work."
},

{
    "location": "standalonequerycommands/#",
    "page": "Standalone Query Commands",
    "title": "Standalone Query Commands",
    "category": "page",
    "text": ""
},

{
    "location": "standalonequerycommands/#Standalone-query-operators-1",
    "page": "Standalone Query Commands",
    "title": "Standalone query operators",
    "category": "section",
    "text": "The standalone query operators are typically combined via the pipe operator. Here is an example that demonstrates their use:using Query, DataFrames, Statistics\n\ndf = DataFrame(a=[1,1,2,3], b=[4,5,6,8])\n\ndf2 = df |>\n    @groupby(_.a) |>\n    @map({a=key(_), b=mean(_.b)}) |>\n    @filter(_.b > 5) |>\n    @orderby_descending(_.b) |>\n    DataFrame"
},

{
    "location": "standalonequerycommands/#Standalone-query-operators-2",
    "page": "Standalone Query Commands",
    "title": "Standalone query operators",
    "category": "section",
    "text": "All standalone query commands can either take a source as their first argument, or one can pipe the source into the command, as in the above example. For example, one can either writedf = df |> @groupby(_.a)ordf = @groupby(df, _.a)both forms are equivalent.The remaining arguments of each query demand are command specific.The following discussion will present each command in the version where a source is piped into the command."
},

{
    "location": "standalonequerycommands/#The-@map-command-1",
    "page": "Standalone Query Commands",
    "title": "The @map command",
    "category": "section",
    "text": "The @map command has the form source |> @map(element_selector). source can be any source that can be queried. element_selector must be an anonymous function that accepts one element of the element type of the source and applies some transformation to this single element."
},

{
    "location": "standalonequerycommands/#Example-1",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query\n\ndata = [1,2,3]\n\nx = data |> @map(_^2) |> collect\n\nprintln(x)\n\n# output\n\n[1, 4, 9]\n"
},

{
    "location": "standalonequerycommands/#The-@filter-command-1",
    "page": "Standalone Query Commands",
    "title": "The @filter command",
    "category": "section",
    "text": "The @filter command has the form source |> @filter(filter_condition). source can be any source that can be queried. filter_condition must be an anonymous function that accepts one element of the element type of the source and returns true if that element should be retained, and false if that element should be filtered out."
},

{
    "location": "standalonequerycommands/#Example-2",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = df |> @filter(_.age > 30 && _.children > 2) |> DataFrame\n\nprintln(x)\n\n# output\n\n1×3 DataFrames.DataFrame\n│ Row │ name   │ age     │ children │\n│     │ String │ Float64 │ Int64    │\n├─────┼────────┼─────────┼──────────┤\n│ 1   │ Sally  │ 42.0    │ 5        │"
},

{
    "location": "standalonequerycommands/#The-@groupby-command-1",
    "page": "Standalone Query Commands",
    "title": "The @groupby command",
    "category": "section",
    "text": "There are two versions of the @groupby command. The simple version has the form source |> @groupby(key_selector). source can be any source that can be queried. key_selector must be an anonymous function that returns a value for each element of source by which the source elements should be grouped.The second variant has the form source |> @groupby(source, key_selector, element_selector). The definition of source and key_selector is the same as in the simple variant. element_selector must be an anonymous function that is applied to each element of the source before that element is placed into a group, i.e. this is a projection function.The return value of @groupby is an iterable of groups. Each group is itself a collection of data rows, and has a key field that is equal to the value the rows were grouped by. Often the next step in the pipeline will be to use @map with a function that acts on each group, summarizing it in a new data row."
},

{
    "location": "standalonequerycommands/#Example-3",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = df |>\n    @groupby(_.children) |>\n    @map({Key=key(_), Count=length(_)}) |>\n    DataFrame\n\nprintln(x)\n\n# output\n\n2×2 DataFrames.DataFrame\n│ Row │ Key   │ Count │\n│     │ Int64 │ Int64 │\n├─────┼───────┼───────┤\n│ 1   │ 3     │ 1     │\n│ 2   │ 2     │ 2     │"
},

{
    "location": "standalonequerycommands/#The-@orderby,-@orderby_descending,-@thenby-and-@thenby_descending-command-1",
    "page": "Standalone Query Commands",
    "title": "The @orderby, @orderby_descending, @thenby and @thenby_descending command",
    "category": "section",
    "text": "There are four commands that are used to sort data. Any sorting has to start with either a @orderby or @orderby_descending command. @thenby and @thenby_descending commands can only directly follow a previous sorting command. They specify how ties in the previous sorting condition are to be resolved.The general sorting command form is source |> @orderby(key_selector). source can be any source than can be queried. key_selector must be an anonymous function that returns a value for each element of source. The elements of the source are then sorted is ascending order by the value returned from the key_selector function. The @orderby_descending command works in the same way, but sorts things in descending order. The @thenby and @thenby_descending command only accept the return value of any of the four sorting commands as their source, otherwise they have the same syntax as the @orderby and @orderby_descending commands."
},

{
    "location": "standalonequerycommands/#Example-4",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(a=[2,1,1,2,1,3],b=[2,2,1,1,3,2])\n\nx = df |> @orderby_descending(_.a) |> @thenby(_.b) |> DataFrame\n\nprintln(x)\n\n# output\n\n6×2 DataFrames.DataFrame\n│ Row │ a     │ b     │\n│     │ Int64 │ Int64 │\n├─────┼───────┼───────┤\n│ 1   │ 3     │ 2     │\n│ 2   │ 2     │ 1     │\n│ 3   │ 2     │ 2     │\n│ 4   │ 1     │ 1     │\n│ 5   │ 1     │ 2     │\n│ 6   │ 1     │ 3     │"
},

{
    "location": "standalonequerycommands/#The-@groupjoin-command-1",
    "page": "Standalone Query Commands",
    "title": "The @groupjoin command",
    "category": "section",
    "text": "The @groupjoin command has the form outer |> @groupjoin(inner, outer_selector, inner_selector, result_selector). outer and inner can be any source that can be queried. outer_selector and inner_selector must be an anonymous function that extracts the value from the outer and inner source respectively on which the join should be run. The result_selector must be an anonymous function that takes two arguments, first the element from the outer source, and second an array of those elements from the second source that are grouped together."
},

{
    "location": "standalonequerycommands/#Example-5",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = DataFrame(c=[2,4,2], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = df1 |> @groupjoin(df2, _.a, _.c, {t1=_.a, t2=length(__)}) |> DataFrame\n\nprintln(x)\n\n# output\n\n3×2 DataFrames.DataFrame\n│ Row │ t1    │ t2    │\n│     │ Int64 │ Int64 │\n├─────┼───────┼───────┤\n│ 1   │ 1     │ 0     │\n│ 2   │ 2     │ 2     │\n│ 3   │ 3     │ 0     │"
},

{
    "location": "standalonequerycommands/#The-@join-command-1",
    "page": "Standalone Query Commands",
    "title": "The @join command",
    "category": "section",
    "text": "The @join command has the form outer |> @join(inner, outer_selector, inner_selector, result_selector). outer and inner can be any source that can be queried. outer_selector and inner_selector must be an anonymous function that extracts the value from the outer and inner source respectively on which the join should be run. The result_selector must be an anonymous function that takes two arguments. It will be called for each element in the result set, and the first argument will hold the element from the outer source and the second argument will hold the element from the inner source."
},

{
    "location": "standalonequerycommands/#Example-6",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = DataFrame(c=[2,4,2], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = df1 |> @join(df2, _.a, _.c, {_.a, _.b, __.c, __.d}) |> DataFrame\n\nprintln(x)\n\n# output\n\n2×4 DataFrames.DataFrame\n│ Row │ a     │ b       │ c     │ d      │\n│     │ Int64 │ Float64 │ Int64 │ String │\n├─────┼───────┼─────────┼───────┼────────┤\n│ 1   │ 2     │ 2.0     │ 2     │ John   │\n│ 2   │ 2     │ 2.0     │ 2     │ Sally  │"
},

{
    "location": "standalonequerycommands/#The-@mapmany-command-1",
    "page": "Standalone Query Commands",
    "title": "The @mapmany command",
    "category": "section",
    "text": "The @mapmany command has the form source |> @mapmany(collection_selector, result_selector). source can be any source that can be queried. collection_selector must be an anonymous function that takes one argument and returns a collection. result_selector must be an anonymous function that takes two arguments. It will be applied to each element of the intermediate collection."
},

{
    "location": "standalonequerycommands/#Example-7",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query\n\nsource = Dict(:a=>[1,2,3], :b=>[4,5])\n\nq = source |> @mapmany(_.second, {Key=_.first, Value=__}) |> DataFrame\n\nprintln(q)\n\n# output\n\n5×2 DataFrames.DataFrame\n│ Row │ Key    │ Value │\n│     │ Symbol │ Int64 │\n├─────┼────────┼───────┤\n│ 1   │ a      │ 1     │\n│ 2   │ a      │ 2     │\n│ 3   │ a      │ 3     │\n│ 4   │ b      │ 4     │\n│ 5   │ b      │ 5     │"
},

{
    "location": "standalonequerycommands/#The-@take-command-1",
    "page": "Standalone Query Commands",
    "title": "The @take command",
    "category": "section",
    "text": "The @take command has the form source |> @take(n). source can be any source that can be queried. n must be an integer, and it specifies how many elements from the beginning of the source should be kept."
},

{
    "location": "standalonequerycommands/#Example-8",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query\n\nsource = [1,2,3,4,5]\n\nq = source |> @take(3) |> collect\n\nprintln(q)\n\n# output\n\n[1, 2, 3]"
},

{
    "location": "standalonequerycommands/#The-@drop-command-1",
    "page": "Standalone Query Commands",
    "title": "The @drop command",
    "category": "section",
    "text": "The @drop command has the form source |> @drop(n). source can be any source that can be queried. n must be an integer, and it specifies how many elements from the beginning of the source should be dropped from the results."
},

{
    "location": "standalonequerycommands/#Example-9",
    "page": "Standalone Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query\n\nsource = [1,2,3,4,5]\n\nq = source |> @drop(3) |> collect\n\nprintln(q)\n\n# output\n\n[4, 5]"
},

{
    "location": "standalonequerycommands/#The-@unique-command-1",
    "page": "Standalone Query Commands",
    "title": "The @unique command",
    "category": "section",
    "text": "The @unique command has the formsource |> @unique().source` can be any source that can be queried. The command will filter out any duplicates from the input source. Note that there is also an experimental version of this command that accepts a key selector, see the experimental section in the documentation."
},

{
    "location": "standalonequerycommands/#Exmample-1",
    "page": "Standalone Query Commands",
    "title": "Exmample",
    "category": "section",
    "text": "using Query\n\nsource = [1,1,2,2,3]\n\nq = source |> @unique() |> collect\n\nprintln(q)\n\n# output\n\n[1, 2, 3]"
},

{
    "location": "standalonequerycommands/#The-@select-command-1",
    "page": "Standalone Query Commands",
    "title": "The @select command",
    "category": "section",
    "text": "The @select command has the form source |> @select(selectors...). source can be any source that can be queried. Each selector of selectors... can either select elements from source and add them to the result set, or select elements from the result set and remove them. A selector may select or remove an element by name, by position, or using a predicate function. All selectors... are executed in order and may not commute.using Query, DataFrames\n\ndf = DataFrame(fruit=[\"Apple\",\"Banana\",\"Cherry\"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])\n\nq1 = df |> @select(2:3, occursin(\"ui\"), -:amount) |> DataFrame\n\nprintln(q1)\n\n# output\n\n3×2 DataFrame\n│ Row │ price   │ fruit  │\n│     │ Float64 │ String │\n├─────┼─────────┼────────┤\n│ 1   │ 1.2     │ Apple  │\n│ 2   │ 2.0     │ Banana │\n│ 3   │ 0.4     │ Cherry │q2 = df |> @select(!endswith(\"t\"), 1) |> DataFrame\n\nprintln(q2)\n\n# output\n\n3×3 DataFrame\n│ Row │ price   │ isyellow │ fruit  │\n│     │ Float64 │ Bool     │ String │\n├─────┼─────────┼──────────┼────────┤\n│ 1   │ 1.2     │ false    │ Apple  │\n│ 2   │ 2.0     │ true     │ Banana │\n│ 3   │ 0.4     │ false    │ Cherry │"
},

{
    "location": "standalonequerycommands/#The-@rename-command-1",
    "page": "Standalone Query Commands",
    "title": "The @rename command",
    "category": "section",
    "text": "The @rename command has the form source |> @rename(args...). source can be any source that can be queried. Each argument from args... must specify the name or index of the element, as well as the new name for the element. All args... are executed in order, and the result set of the previous renaming is the source of each current operation.using Query, DataFrames\n\ndf = DataFrame(fruit=[\"Apple\",\"Banana\",\"Cherry\"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])\n\nq = df |> @rename(:fruit => :food, :price => :cost, :food => :name) |> DataFrame\n\nprintln(q)\n\n# output\n\n3×4 DataFrame\n│ Row │ name   │ amount │ cost    │ isyellow │\n│     │ String │ Int64  │ Float64 │ Bool     │\n├─────┼────────┼────────┼─────────┼──────────┤\n│ 1   │ Apple  │ 2      │ 1.2     │ false    │\n│ 2   │ Banana │ 6      │ 2.0     │ true     │\n│ 3   │ Cherry │ 1000   │ 0.4     │ false    │"
},

{
    "location": "standalonequerycommands/#The-@mutate-command-1",
    "page": "Standalone Query Commands",
    "title": "The @mutate command",
    "category": "section",
    "text": "The @mutate command has the form source |> @mutate(args...). source can be any source that can be queried. Each argument from args... must specify the name of the element and the formula to which its values are transformed. The formula can contain elements of source. All args... are executed in order, and the result set of the previous mutation is the source of each current mutation.using Query, DataFrames\n\ndf = DataFrame(fruit=[\"Apple\",\"Banana\",\"Cherry\"],amount=[2,6,1000],price=[1.2,2.0,0.4],isyellow=[false,true,false])\n\nq = df |> @mutate(price = 2 * _.price + _.amount, isyellow = fruit == \"Apple\") |> DataFrame\n\nprintln(q)\n\n# output\n\n3×4 DataFrame\n│ Row │ fruit  │ amount │ price   │ isyellow │\n│     │ String │ Int64  │ Float64 │ Bool     │\n├─────┼────────┼────────┼─────────┼──────────┤\n│ 1   │ Apple  │ 2      │ 4.4     │ true     │\n│ 2   │ Banana │ 6      │ 10.0    │ false    │\n│ 3   │ Cherry │ 1000   │ 1000.8  │ false    │"
},

{
    "location": "linqquerycommands/#",
    "page": "LINQ Style Query Commands",
    "title": "LINQ Style Query Commands",
    "category": "page",
    "text": ""
},

{
    "location": "linqquerycommands/#LINQ-Style-Query-Commands-1",
    "page": "LINQ Style Query Commands",
    "title": "LINQ Style Query Commands",
    "category": "section",
    "text": ""
},

{
    "location": "linqquerycommands/#Sorting-1",
    "page": "LINQ Style Query Commands",
    "title": "Sorting",
    "category": "section",
    "text": "The @orderby statement sorts the elements from a source by one or more element attributes. The syntax for the @orderby statement is @orderby <attribute>[, <attribute>]. <attribute> can be any julia expression that returns an attribute by which the source elements should be sorted. The default sort order is ascending. By wrapping an <attribute> in a call to descending(<attribute) one can reverse the sort order. The @orderby statement accepts multiple <attribute>s separated by ,s. With multiple sorting attributes, the elements are first sorted by the first attribute. Elements that can\'t be ranked by the first attribute are then sorted by the second attribute etc."
},

{
    "location": "linqquerycommands/#Example-1",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(a=[2,1,1,2,1,3],b=[2,2,1,1,3,2])\n\nx = @from i in df begin\n    @orderby descending(i.a), i.b\n    @select i\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n6×2 DataFrames.DataFrame\n│ Row │ a     │ b     │\n│     │ Int64 │ Int64 │\n├─────┼───────┼───────┤\n│ 1   │ 3     │ 2     │\n│ 2   │ 2     │ 1     │\n│ 3   │ 2     │ 2     │\n│ 4   │ 1     │ 1     │\n│ 5   │ 1     │ 2     │\n│ 6   │ 1     │ 3     │"
},

{
    "location": "linqquerycommands/#Filtering-1",
    "page": "LINQ Style Query Commands",
    "title": "Filtering",
    "category": "section",
    "text": "The @where statement filters a source so that only those elements are returned that satisfy a filter condition. The syntax for the @where statement is @where <condition>. <condition> can be any arbitrary julia expression that evaluates to true or false."
},

{
    "location": "linqquerycommands/#Example-2",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @where i.age > 30. && i.children > 2\n    @select i\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×3 DataFrames.DataFrame\n│ Row │ name   │ age     │ children │\n│     │ String │ Float64 │ Int64    │\n├─────┼────────┼─────────┼──────────┤\n│ 1   │ Sally  │ 42.0    │ 5        │"
},

{
    "location": "linqquerycommands/#Projecting-1",
    "page": "LINQ Style Query Commands",
    "title": "Projecting",
    "category": "section",
    "text": "The @select statement applies a transformation to each element of the source. The syntax for the @select statement is @select <condition>. <condition> can be any arbitrary julia expression that transforms an element from the source into the desired target format."
},

{
    "location": "linqquerycommands/#Example-3",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "The following example transforms each element from the source by squaring it.using Query\n\ndata = [1,2,3]\n\nx = @from i in data begin\n    @select i^2\n    @collect\nend\n\nprintln(x)\n\n# output\n\n[1, 4, 9]One of the most common patterns in Query is to transform elements into named tuples with a @select statement. There are two ways to create a named tuples in Query: a) using the standard syntax from julia for named tuples, or b) a special syntax that only works inside Query.jl macros. This special syntax is based on curly brackets {}. An example that highlights all options of this syntax is this:using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select {i.name, Age=i.age}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×2 DataFrames.DataFrame\n│ Row │ name   │ Age     │\n│     │ String │ Float64 │\n├─────┼────────┼─────────┤\n│ 1   │ John   │ 23.0    │\n│ 2   │ Sally  │ 42.0    │\n│ 3   │ Kirk   │ 59.0    │The elements of the new named tuple are separated by commas ,. One can specify an explicit name for an individual element of a named tuple using the = syntax, where the name of the element is specified as the left argument and the value as the right argument. If the name of the element should be the same as the variable that is passed for the value, one doesn\'t have to specify a name explicitly, instead the {} syntax automatically infers the name."
},

{
    "location": "linqquerycommands/#Flattening-1",
    "page": "LINQ Style Query Commands",
    "title": "Flattening",
    "category": "section",
    "text": "One can project child elements from the elements of a source by using multiple @from statements. The nested child elements are flattened into one stream of results when multiple @from statements are used. The syntax for any additional @from statement (apart from the initial one that starts a query) is @from <range variable> in <selector>. <range variable> is the name of the range variable to be used for the child elements, and <selector> is a julia expression that returns the child elements."
},

{
    "location": "linqquerycommands/#Example-4",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query\n\nsource = Dict(:a=>[1,2,3], :b=>[4,5])\n\nq = @from i in source begin\n    @from j in i.second\n    @select {Key=i.first,Value=j}\n    @collect DataFrame\nend\n\nprintln(q)\n\n# output\n\n5×2 DataFrames.DataFrame\n│ Row │ Key    │ Value │\n│     │ Symbol │ Int64 │\n├─────┼────────┼───────┤\n│ 1   │ a      │ 1     │\n│ 2   │ a      │ 2     │\n│ 3   │ a      │ 3     │\n│ 4   │ b      │ 4     │\n│ 5   │ b      │ 5     │"
},

{
    "location": "linqquerycommands/#Joining-1",
    "page": "LINQ Style Query Commands",
    "title": "Joining",
    "category": "section",
    "text": "The @join statement combines data from two different sources. There are two variants of the statement: an inner join and a group join. The @left_outer_join statement provides a traditional left outer join option."
},

{
    "location": "linqquerycommands/#Inner-join-1",
    "page": "LINQ Style Query Commands",
    "title": "Inner join",
    "category": "section",
    "text": "The syntax for an inner join is @join <range variable> in <source> on <left key> equals <right key>. <range variable> is the name of the variable that should reference elements from the right source in the join. <source> is the name of the right source in the join operation. <left key> and <right key> are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values."
},

{
    "location": "linqquerycommands/#Example-5",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = DataFrame(c=[2,4,2], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = @from i in df1 begin\n    @join j in df2 on i.a equals j.c\n    @select {i.a,i.b,j.c,j.d}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×4 DataFrames.DataFrame\n│ Row │ a     │ b       │ c     │ d      │\n│     │ Int64 │ Float64 │ Int64 │ String │\n├─────┼───────┼─────────┼───────┼────────┤\n│ 1   │ 2     │ 2.0     │ 2     │ John   │\n│ 2   │ 2     │ 2.0     │ 2     │ Sally  │"
},

{
    "location": "linqquerycommands/#Group-join-1",
    "page": "LINQ Style Query Commands",
    "title": "Group join",
    "category": "section",
    "text": "The syntax for a group join is @join <range variable> in <source> on <left key> equals <right key> into <group variable>. <range variable> is the name of the variable that should reference elements from the right source in the join. <source> is the name of the right source in the join operation. <left key> and <right key> are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values. <group variable> is the name of the variable that will hold all the elements from the right source that are joined to a given element from the left source."
},

{
    "location": "linqquerycommands/#Example-6",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query\n\ndf1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\ndf2 = DataFrame(c=[2,4,2], d=[\"John\", \"Jim\",\"Sally\"])\n\nx = @from i in df1 begin\n    @join j in df2 on i.a equals j.c into k\n    @select {t1=i.a,t2=length(k)}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×2 DataFrames.DataFrame\n│ Row │ t1    │ t2    │\n│     │ Int64 │ Int64 │\n├─────┼───────┼───────┤\n│ 1   │ 1     │ 0     │\n│ 2   │ 2     │ 2     │\n│ 3   │ 3     │ 0     │"
},

{
    "location": "linqquerycommands/#Left-outer-join-1",
    "page": "LINQ Style Query Commands",
    "title": "Left outer join",
    "category": "section",
    "text": "They syntax for a left outer join is @left_outer_join <range variable> in <source> on <left key> equals <right key>. <range variable> is the name of the variable that should reference elements from the right source in the join. <source> is the name of the right source in the join operation. <left key> and <right key> are julia expressions that extract a value from the elements of the left and right source; the statement will then join on equality of these extracted values. For elements in the left source that don\'t have any corresponding element in the right source, <range variable> is assigned the default value returned by the default_if_empty function based on the element types of <source>. If the right source has elements of type NamedTuple, and the fields of that named tuple are all of type DataValue, then an instance of that named tuple with all fields having NA values will be used."
},

{
    "location": "linqquerycommands/#Example-7",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\nsource_df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])\nsource_df2 = DataFrame(c=[2,4,2], d=[\"John\", \"Jim\",\"Sally\"])\n\nq = @from i in source_df1 begin\n    @left_outer_join j in source_df2 on i.a equals j.c\n    @select {i.a,i.b,j.c,j.d}\n    @collect DataFrame\nend\n\nprintln(q)\n\n# output\n\n4×4 DataFrames.DataFrame\n│ Row │ a     │ b       │ c       │ d       │\n│     │ Int64 │ Float64 │ Int64⍰  │ String⍰ │\n├─────┼───────┼─────────┼─────────┼─────────┤\n│ 1   │ 1     │ 1.0     │ missing │ missing │\n│ 2   │ 2     │ 2.0     │ 2       │ John    │\n│ 3   │ 2     │ 2.0     │ 2       │ Sally   │\n│ 4   │ 3     │ 3.0     │ missing │ missing │"
},

{
    "location": "linqquerycommands/#Grouping-1",
    "page": "LINQ Style Query Commands",
    "title": "Grouping",
    "category": "section",
    "text": "The @group statement groups elements from the source by some attribute. The syntax for the group statement is @group <element selector> by <key selector> [into <range variable>]. <element selector> is an arbitrary julia expression that determines the content of the group elements. <key selector> is an arbitrary julia expression that returns the values by which the elements are grouped. A @group statement without an into clause ends a query statement, i.e. no further @select statement is needed. When a @group statement has an into clause, the <range variable> sets the name of the range variable for the groups, and further query statements can operate on these groups by referencing that range variable."
},

{
    "location": "linqquerycommands/#Example-8",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "This is an example of a @group statement without a into clause:using DataFrames, Query\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @group i.name by i.children\n    @collect\nend\n\nprintln(x)\n\n# output\n\nGrouping{Int64,String}[[\"John\"], [\"Sally\", \"Kirk\"]]This is an example of a @group statement with an into clause:using DataFrames, Query\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @group i by i.children into g\n    @select {Key=key(g),Count=length(g)}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×2 DataFrames.DataFrame\n│ Row │ Key   │ Count │\n│     │ Int64 │ Int64 │\n├─────┼───────┼───────┤\n│ 1   │ 3     │ 1     │\n│ 2   │ 2     │ 2     │"
},

{
    "location": "linqquerycommands/#Split-Apply-Combine-(a.k.a.-dplyr)-1",
    "page": "LINQ Style Query Commands",
    "title": "Split-Apply-Combine (a.k.a. dplyr)",
    "category": "section",
    "text": "Query.jl provides special syntax to summarize data in a Query.Grouping as above. Summarizing here is synonymous to aggregating or collapsing the dataset over a certain grouping variable. Summarizing thus requires an aggregating function like mean, maximum, or any other function that takes a vector and returns a scalar. The special syntax is @select new_var = agg_fun(g.var), where agg_fun is your aggregation function (e.g. mean), g is your grouping, and var is the relevant column that you want to summarize."
},

{
    "location": "linqquerycommands/#Example-9",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames, Statistics\n\ndf = DataFrame(name=repeat([\"John\", \"Sally\", \"Kirk\"],inner=[1],outer=[2]), \n     age=vcat([10., 20., 30.],[10., 20., 30.].+3), \n     children=repeat([3,2,2],inner=[1],outer=[2]),state=[:a,:a,:a,:b,:b,:b])\n\nx = @from i in df begin\n    @group i by i.state into g\n    @select {group=key(g),mage=mean(g.age), oldest=maximum(g.age), youngest=minimum(g.age)}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n2×4 DataFrames.DataFrame\n│ Row │ group  │ mage    │ oldest  │ youngest │\n│     │ Symbol │ Float64 │ Float64 │ Float64  │\n├─────┼────────┼─────────┼─────────┼──────────┤\n│ 1   │ a      │ 20.0    │ 30.0    │ 10.0     │\n│ 2   │ b      │ 23.0    │ 33.0    │ 13.0     │"
},

{
    "location": "linqquerycommands/#Range-variables-1",
    "page": "LINQ Style Query Commands",
    "title": "Range variables",
    "category": "section",
    "text": "The @let statement introduces new range variables in a query expression. The syntax for the range statement is @let <range variable> = <value selector>. <range variable> specifies the name of the new range variable and <value selector> is any julia expression that returns the value that should be assigned to the new range variable."
},

{
    "location": "linqquerycommands/#Example-10",
    "page": "LINQ Style Query Commands",
    "title": "Example",
    "category": "section",
    "text": "using DataFrames, Query\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,2,2])\n\nx = @from i in df begin\n    @let count = length(i.name)\n    @let kids_per_year = i.children / i.age\n    @where count > 4\n    @select {Name=i.name, Count=count, KidsPerYear=kids_per_year}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n1×3 DataFrames.DataFrame\n│ Row │ Name   │ Count │ KidsPerYear │\n│     │ String │ Int64 │ Float64     │\n├─────┼────────┼───────┼─────────────┤\n│ 1   │ Sally  │ 5     │ 0.047619    │"
},

{
    "location": "sources/#",
    "page": "Data Sources",
    "title": "Data Sources",
    "category": "page",
    "text": ""
},

{
    "location": "sources/#Data-Sources-1",
    "page": "Data Sources",
    "title": "Data Sources",
    "category": "section",
    "text": "Query supports many different types of data sources, and you can often mix and match different source types in one query. This section describes all the currently supported data source types."
},

{
    "location": "sources/#DataFrame-1",
    "page": "Data Sources",
    "title": "DataFrame",
    "category": "section",
    "text": "DataFrames are probably the most common data source in Query. They are implemented as an Enumerable data source type, and can therefore be combined with any other Enumerable data source type within one query. The range variable in a query that has a DataFrame as its source is a NamedTuple that has fields for each column of the DataFrame. The implementation of DataFrame sources gets around all problems of type stability that are sometimes associated with the DataFrames package."
},

{
    "location": "sources/#Example-1",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select i\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×3 DataFrames.DataFrame\n│ Row │ name   │ age     │ children │\n│     │ String │ Float64 │ Int64    │\n├─────┼────────┼─────────┼──────────┤\n│ 1   │ John   │ 23.0    │ 3        │\n│ 2   │ Sally  │ 42.0    │ 5        │\n│ 3   │ Kirk   │ 59.0    │ 2        │"
},

{
    "location": "sources/#TypedTable-1",
    "page": "Data Sources",
    "title": "TypedTable",
    "category": "section",
    "text": "The TypedTables package provides an alternative implementation of a DataFrame-like data structure. Support for TypedTable data sources works in the same way as normal DataFrame sources, i.e. columns are represented as fields of NamedTuples. TypedTable sources are implemented as  Enumerable data source and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources/#Example-2",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames, TypedTables\n\ntt = Table(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in tt begin\n    @select i\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×3 DataFrames.DataFrame\n│ Row │ name   │ age     │ children │\n│     │ String │ Float64 │ Int64    │\n├─────┼────────┼─────────┼──────────┤\n│ 1   │ John   │ 23.0    │ 3        │\n│ 2   │ Sally  │ 42.0    │ 5        │\n│ 3   │ Kirk   │ 59.0    │ 2        │"
},

{
    "location": "sources/#Arrays-1",
    "page": "Data Sources",
    "title": "Arrays",
    "category": "section",
    "text": "Any array can be a data source for a query. The range variables are of the element type of the array and the elements are iterated in the order of the standard iterator of the array. Array sources are implemented as Enumerable data sources and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources/#Example-3",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\nstruct Person\n    Name::String\n    Friends::Vector{String}\nend\n\nsource = [\n    Person(\"John\", [\"Sally\", \"Miles\", \"Frank\"]),\n    Person(\"Sally\", [\"Don\", \"Martin\"])]\n\nresult = @from i in source begin\n         @where length(i.Friends) > 2\n         @select {i.Name, Friendcount=length(i.Friends)}\n         @collect\nend\n\nprintln(result)\n\n# output\n\nNamedTuple{(:Name, :Friendcount),Tuple{String,Int64}}[(Name = \"John\", Friendcount = 3)]"
},

{
    "location": "sources/#IndexedTables-1",
    "page": "Data Sources",
    "title": "IndexedTables",
    "category": "section",
    "text": "IndexedTable data sources can be a source in a query. Individual rows are represented as a NamedTuple with two fields. The index field holds the index data for this row. If the source has named columns, the type of the index field is a NamedTuple, where the fieldnames correspond to the names of the index columns. If the source doesn\'t use named columns, the type of the index field is a regular tuple. The second field is named value and holds the value of the row in the original source. IndexedTable sources are implemented as Enumerable data sources and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources/#Example-4",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "using Query, IndexedTables, Dates\n\nsource_indexedtable = table((city=[fill(\"New York\",3); fill(\"Boston\",3)], date=repeat(Date(2016,7,6):Day(1):Date(2016,7,8), 2), value=[91,89,91,95,83,76]))\nq = @from i in source_indexedtable begin\n    @where i.city==\"New York\"\n    @select i.value\n    @collect\nend\n\nprintln(q)\n\n# output\n\n[91, 89, 91]"
},

{
    "location": "sources/#Any-iterable-type-1",
    "page": "Data Sources",
    "title": "Any iterable type",
    "category": "section",
    "text": "Any data source type that implements the standard julia iterator protocoll (i.e. a start, next and done method) can be a query data source. Iterable data sources are implemented as Enumerable data sources and can therefore be combined with any other Enumerable data source in a single query."
},

{
    "location": "sources/#Example-5",
    "page": "Data Sources",
    "title": "Example",
    "category": "section",
    "text": "[TODO]"
},

{
    "location": "sinks/#",
    "page": "Data Sinks",
    "title": "Data Sinks",
    "category": "page",
    "text": ""
},

{
    "location": "sinks/#Data-Sinks-1",
    "page": "Data Sinks",
    "title": "Data Sinks",
    "category": "section",
    "text": "Query supports a number of different data sink types. One can materialize the results of a query into a specific sink by using the @collect statement. Queries that don\'t end with a @collect statement return an iterator that can be used to iterate over the results of the query."
},

{
    "location": "sinks/#Array-1",
    "page": "Data Sinks",
    "title": "Array",
    "category": "section",
    "text": "Using the @collect statement without any further argument will materialize the query results into an array. The array will be a vector, and the element type of the array is the type of the elements returned by the last projection statement."
},

{
    "location": "sinks/#Example-1",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select i.name\n    @collect\nend\n\nprintln(x)\n\n# output\n\n[\"John\", \"Sally\", \"Kirk\"]"
},

{
    "location": "sinks/#DataFrame,-DataTable-and-TypedTable-1",
    "page": "Data Sinks",
    "title": "DataFrame, DataTable and TypedTable",
    "category": "section",
    "text": "The statement @collect TableType (with TableType being one of DatFrame, DataTable or TypedTable) will materialize the query results into a new instance of that type. This statement only works if the last projection statement transformed the results into a NamedTuple, for example by using the {} syntax."
},

{
    "location": "sinks/#Example-2",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select {i.name, i.age, Children=i.children}\n    @collect DataFrame\nend\n\nprintln(x)\n\n# output\n\n3×3 DataFrames.DataFrame\n│ Row │ name   │ age     │ Children │\n│     │ String │ Float64 │ Int64    │\n├─────┼────────┼─────────┼──────────┤\n│ 1   │ John   │ 23.0    │ 3        │\n│ 2   │ Sally  │ 42.0    │ 5        │\n│ 3   │ Kirk   │ 59.0    │ 2        │"
},

{
    "location": "sinks/#Dict-1",
    "page": "Data Sinks",
    "title": "Dict",
    "category": "section",
    "text": "The statement @collect Dict will materialize the query results into a new Dict instance. This statement only works if the last projection statement transformed the results into a Pair, for example by using the => syntax."
},

{
    "location": "sinks/#Example-3",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "using Query, DataFrames\n\ndf = DataFrame(name=[\"John\", \"Sally\", \"Kirk\"], age=[23., 42., 59.], children=[3,5,2])\n\nx = @from i in df begin\n    @select i.name=>i.children\n    @collect Dict\nend\n\nprintln(x)\n\n# output\n\nDict(\"Sally\"=>5,\"John\"=>3,\"Kirk\"=>2)"
},

{
    "location": "sinks/#TimeArray-1",
    "page": "Data Sinks",
    "title": "TimeArray",
    "category": "section",
    "text": "The statement @collect TimeArray will materialize the query results into a new TimeSeries.TimeArray instance. This statement only works if the last projection statement transformed the results into a NamedTuple, for example by using the {} syntax, and this NamedTuple has one field named timestamp that is of a type that can be used as a time index in the TimeArray type."
},

{
    "location": "sinks/#Example-4",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "[TODO]"
},

{
    "location": "sinks/#Temporal-1",
    "page": "Data Sinks",
    "title": "Temporal",
    "category": "section",
    "text": "The statement @collect TS will materialize the query results into a new Temporal.TS instance. This statement only works if the last projection statement transformed the results into a NamedTuple, for example by using the {} syntax, and this NamedTuple has one field named Index that is of a type that can be used as a time index in the TS type."
},

{
    "location": "sinks/#Example-5",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "[TODO]"
},

{
    "location": "sinks/#IndexedTable-1",
    "page": "Data Sinks",
    "title": "IndexedTable",
    "category": "section",
    "text": "The statement @collect IndexedTable will materialize the query results into a new IndexedTables.IndexedTable instance. This statement only works if the last projection statement transformed the results into a NamedTuple, for example by using the {} syntax. The last column of the result table will be the data column, all other columns will be index columns."
},

{
    "location": "sinks/#Example-6",
    "page": "Data Sinks",
    "title": "Example",
    "category": "section",
    "text": "[TODO]"
},

{
    "location": "experimental/#",
    "page": "Experimental Features",
    "title": "Experimental Features",
    "category": "page",
    "text": ""
},

{
    "location": "experimental/#Experimental-features-1",
    "page": "Experimental Features",
    "title": "Experimental features",
    "category": "section",
    "text": "The following features are experimental, i.e. they might change significantly in the future. You are advised to only use them if you are prepared to deal with significant changes to these features in future versions of Query.jl. At the same time any feedback on these features would be especially welcome."
},

{
    "location": "experimental/#The-_-and-__-syntax-1",
    "page": "Experimental Features",
    "title": "The _ and __ syntax",
    "category": "section",
    "text": "This syntax only works in the standalone query commands. Instead of writing a full anonymous function, for example @map(i->i.a), one can write @map(_.a), where _ stands for the current element, i.e. has the same role as the argument of the anonymous function.If one uses both _ and __, Query will automatically create an anonymous function with two arguments. For example, the result selector in the @join command requires an anonymous function that takes two arguments. This can be written succinctly like this:using DataFrames, Query\n\ndf_parents = DataFrame(Name=[\"John\", \"Sally\"])\ndf_children = DataFrame(Name=[\"Bill\", \"Joe\", \"Mary\"], Parent=[\"John\", \"John\", \"Sally\"])\n\ndf_parents |> @join(df_children, _.Name, _.Parent, {Parent=_.Name, Child=__.Name}) |> DataFrame"
},

{
    "location": "experimental/#Key-selector-in-the-@unique-standalone-command-1",
    "page": "Experimental Features",
    "title": "Key selector in the @unique standalone command",
    "category": "section",
    "text": "As an experimental feature, one can specify a key selector for the @unique command. In that case uniqueness is tested based on that key.using Query\n\nsource = [1,-1,2,2,3]\n\nq = source |> @unique(abs(_)) |> collect\n\nprintln(q)\n\n# output\n\n[1, 2, 3]"
},

{
    "location": "internals/#",
    "page": "Internals",
    "title": "Internals",
    "category": "page",
    "text": ""
},

{
    "location": "internals/#Internals-1",
    "page": "Internals",
    "title": "Internals",
    "category": "section",
    "text": ""
},

{
    "location": "internals/#Overview-1",
    "page": "Internals",
    "title": "Overview",
    "category": "section",
    "text": "This package is modeled closely after LINQ. If you are not familiar with LINQ, this is a great overview. It is especially recommended if you associate LINQ mainly with a query syntax in a language and don\'t know about the underlying language features and architecture, for example how anonymous types, lambdas and lots of other language features all play together. The query syntax is really just the tip of the iceberg.The core idea of this package right now is to iterate over NamedTuples for table like data structures. Starting with a DataFrame, query will create an iterator that produces a NamedTuple that has a field for each column, and the collect method can turn a stream of NamedTuples back into a DataFrame.If one starts with a queryable data source (like SQLite), the query will automatically be translated into SQL and executed in the database.The wording of methods and types currently follows LINQ, not julia conventions. This is mainly to prevent clashes while Query.jl is in development."
},

{
    "location": "internals/#Readings-1",
    "page": "Internals",
    "title": "Readings",
    "category": "section",
    "text": "The original LINQ document is still a good read.The The Wayward WebLog has some excellent posts about writing query providers:LINQ: Building an IQueryable Provider – Part I\nLINQ: Building an IQueryable Provider – Part II\nLINQ: Building an IQueryable Provider – Part III\nLINQ: Building an IQueryable Provider – Part IV\nLINQ: Building an IQueryable Provider – Part V\nLINQ: Building an IQueryable Provider – Part VI\nLINQ: Building an IQueryable provider – Part VII\nLINQ: Building an IQueryable Provider – Part VIII\nLINQ: Building an IQueryable Provider – Part IX\nLINQ: Building an IQueryable Provider – Part X\nLINQ: Building an IQueryable Provider – Part XI\nBuilding a LINQ IQueryable Provider – Part XII\nBuilding a LINQ IQueryable Provider – Part XIII\nBuilding a LINQ IQueryable provider – Part XIV\nBuilding a LINQ IQueryable provider – Part XV (IQToolkit v0.15)\nBuilding a LINQ IQueryable Provider – Part XVI (IQToolkit 0.16)\nBuilding a LINQ IQueryable Provider – Part XVII (IQToolkit 0.17)Joe Duffy wrote an interesting article about iterator protocolls:Joe Duffy on enumerating in .NetOn NULL values and 3VL in .Net."
},

]}
