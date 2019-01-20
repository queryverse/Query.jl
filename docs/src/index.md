# Introduction

## Overview

Query is a package for querying julia data sources. It can filter, project, join, sort and group data from any iterable data source, including all the sources that support the [TableTraits.jl](https://github.com/queryverse/TableTraits.jl) interface (this includes everything listed in [IterableTables.jl](https://github.com/queryverse/IterableTables.jl)).

Query is heavily inspired by [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx) and [dplyr](https://dplyr.tidyverse.org/).

## Installation

You can install the package at the Pkg REPL-mode with:
````julia
(v1.0) pkg> add Query
````

## Highlights

- Query contains an almost complete implementation of the query expression section of the C# specification, with some additional julia specific features added in.
- The package supports a large number of data sources: DataFrames.jl, Pandas.jl, IndexedTables.jl, JuliaDB.jl, TimeSeries.jl, Temporal.jl, CSVFiles.jl, ExcelFiles.jl, FeatherFiles.jl, ParquetFiles.jl, BedgraphFiles.jl, StatFiles.jl, DifferentialEquations (any DESolution), arrays and any type that can be iterated.
- The results of a query can be materialized into a range of different data structures: iterators, DataFrames.jl, IndexedTables.jl, JuliaDB.jl, TimeSeries.jl, Temporal.jl, Pandas.jl, StatsModels.jl, CSVFiles.jl, FeatherFiles.jl, ExcelFiles.jl, StatPlots.jl, VegaLite.jl, TableView.jl, DataVoyager.jl, arrays, dictionaries or any array.
- One can mix and match almost all sources and sinks within one query. For example, one can easily perform a join of a DataFrame with a CSV file and write the results into a Feather file, all within one query.
- The type instability problems that one can run into with DataFrames do not affect Query, i.e. queries against DataFrames are completely type stable.
- There are three different APIs that package authors can use to make their data sources queryable with this package. The most simple API only requires a data source to provide an iterator. Another API provides a data source with a complete graph representation of the query and the data source can e.g. rewrite that query graph as a SQL statement to execute the query. The final API allows a data source to provide its own data structures that can represent a query graph.
- The package is completely documented.
