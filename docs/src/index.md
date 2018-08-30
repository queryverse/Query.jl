# Introduction

## Overview

Query is a package for querying julia data sources. It can filter, project, join and group data from any iterable data source, including all the sources supported in [IterableTables.jl](https://github.com/queryverse/IterableTables.jl).

Query is heavily inspired by [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx), in fact right now the package is largely an implementation of the [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx) part of the [C# specification](https://msdn.microsoft.com/en-us/library/ms228593.aspx). Future versions of Query will most likely add features that are not found in the original [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx) design.

## Installation

You can add the package it with:
````julia
Pkg.add("Query")
````

## Highlights

- Query is an almost complete implementation of the query expression section of the C# specification, with some additional julia specific features added in.
- The package supports a large number of data sources: DataFrames, DataStreams (including CSV, Feather, SQLite, ODBC), DataTables, IndexedTables, TimeSeries, Temporal, TypedTables, DifferentialEquations (any DESolution), arrays any type that can be iterated.
- The results of a query can be materialized into a range of different data structures: iterators, DataFrames, DataTables, IndexedTables, TimeSeries, Temporal, TypedTables, arrays, dictionaries or any DataStream sink (this includes CSV and Feather files).
- One can mix and match almost all sources and sinks within one query. For example, one can easily perform a join of a DataFrame with a CSV file and write the results into a Feather file, all within one query.
- The type instability problems that one can run into with DataFrames do not affect Query, i.e. queries against DataFrames are completely type stable.
- There are three different APIs that package authors can use to make their data sources queryable with this package. The most simple API only requires a data source to provide an iterator. Another API provides a data source with a complete graph representation of the query and the data source can e.g. rewrite that query graph as a SQL statement to execute the query. The final API allows a data source to provide its own data structures that can represent a query graph.
- The package is completely documented.
