# Query

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://queryverse.github.io/Query.jl/stable)
[![Build Status](https://travis-ci.org/queryverse/Query.jl.svg?branch=master)](https://travis-ci.org/queryverse/Query.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/wuo030ogcyrchkde/branch/master?svg=true)](https://ci.appveyor.com/project/queryverse/query-jl/branch/master)
[![codecov](https://codecov.io/gh/queryverse/Query.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/queryverse/Query.jl)

## Overview

Query is a package for querying julia data sources. It can filter, project, join and group data from any iterable data source, including all the sources supported in [IterableTables.jl](https://github.com/queryverse/IterableTables.jl). One can for example query any of the following data sources:
any array,
[DataFrames](https://github.com/JuliaStats/DataFrames.jl),
[DataStreams](https://github.com/JuliaData/DataStreams.jl)
(including [CSV](https://github.com/JuliaData/CSV.jl),
[Feather](https://github.com/JuliaStats/Feather.jl),
[SQLite](https://github.com/JuliaDB/SQLite.jl),
[ODBC](https://github.com/JuliaDB/ODBC.jl)),
[DataTables](https://github.com/JuliaData/DataTables.jl),
[IndexedTables](https://github.com/JuliaComputing/IndexedTables.jl),
[TimeSeries](https://github.com/JuliaStats/TimeSeries.jl),
[Temporal](https://github.com/dysonance/Temporal.jl),
[TypedTables](https://github.com/FugroRoames/TypedTables.jl) and
[DifferentialEquations](https://github.com/JuliaDiffEq/DifferentialEquations.jl) (any ``DESolution``).

The package currently provides working implementations for in-memory data sources, but will eventually be able to translate queries into e.g. SQL. There is a prototype implementation of such a "query provider" for [SQLite](https://github.com/JuliaDB/SQLite.jl) in the package, but it is experimental at this point and only works for a *very* small subset of queries.

Query is heavily inspired by [LINQ](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/linq/index), in fact right now the package is largely an implementation of the [LINQ](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/linq/indexq) part of the [C# specification](https://msdn.microsoft.com/en-us/library/ms228593.aspx). Future versions of Query will most likely add features that are not found in the original [LINQ](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/linq/index) design.

## Alternatives
[Query.jl](https://github.com/queryverse/Query.jl) is not the only julia initiative for querying data, there are many other packages that have similar goals. Take a look at [DataFramesMeta.jl](https://github.com/JuliaStats/DataFramesMeta.jl), and [SplitApplyCombine.jl](https://github.com/JuliaData/SplitApplyCombine.jl). *If I missed other initiatives, please let me know and I'll add them to this list!*

## Installation

You can add the package with:
````julia
Pkg.add("Query")
````

## Getting started
To get started, take a look at the [documentation](http://www.queryverse.org/Query.jl/stable/).

## Getting help

Please ask any usage question in the [Data Domain](https://discourse.julialang.org/c/domain/data) on the [julia Discourse forum](https://discourse.julialang.org/). If you find a bug or have an improvement suggestion for this package, please open an issue in this github repository.

## Highlights

- Query is an almost complete implementation of the query expression section of the C# specification, with some additional julia specific features added in.
- The package supports a large number of data sources: DataFrames, DataStreams (including CSV, Feather, SQLite, ODBC), DataTables, IndexedTables, TimeSeries, Temporal, TypedTables, DifferentialEquations (any DESolution), arrays any type that can be iterated.
- The results of a query can be materialized into a range of different data structures: iterators, DataFrames, DataTables, IndexedTables, TimeSeries, Temporal, TypedTables, arrays, dictionaries or any DataStream sink (this includes CSV and Feather files).
- One can mix and match almost all sources and sinks within one query. For example, one can easily perform a join of a DataFrame with a CSV file and write the results into a Feather file, all within one query.
- The type instability problems that one can run into with DataFrames do not affect Query, i.e. queries against DataFrames are completely type stable.
- There are three different APIs that package authors can use to make their data sources queryable with this package. The most simple API only requires a data source to provide an iterator. Another API provides a data source with a complete graph representation of the query and the data source can e.g. rewrite that query graph as a SQL statement to execute the query. The final API allows a data source to provide its own data structures that can represent a query graph.
- The package is completely documented.
