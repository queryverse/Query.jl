# Introduction

## Overview

Query is a package for querying julia data sources. It can filter, project, join and group data from any iterable data source. It has enhanced support for querying arrays, [DataFrames](https://github.com/JuliaStats/DataFrames.jl), [TypedTables](https://github.com/FugroRoames/TypedTables.jl), [NDSparseData](https://github.com/JuliaComputing/NDSparseData.jl) and any [DataStream](https://github.com/JuliaData/DataStreams.jl) source (e.g. [CSV](https://github.com/JuliaData/CSV.jl), [Feather](https://github.com/JuliaStats/Feather.jl), [SQLite](https://github.com/JuliaDB/SQLite.jl) etc.).

The package currenlty provides working implementations for in-memory data sources, but will eventually be able to translate queries into e.g. SQL. There is a prototype implementation of such a "query provider" for [SQLite](https://github.com/JuliaDB/SQLite.jl) in the package, but it is experimental at this point and only works for a *very* small subset of queries.

Query is heavily inspired by [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx), in fact right now the package is largely an implementation of the [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx) part of the [C# specification](https://msdn.microsoft.com/en-us/library/ms228593.aspx). Future versions of Query will most likely add features that are not found in the original [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx) design.

## Installation

This package only works on julia 0.5 and newer. You can add it with:
````julia
Pkg.add("Query")
````
