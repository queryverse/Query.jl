# Query

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://davidanthoff.github.io/Query.jl/latest)
[![Build Status](https://travis-ci.org/davidanthoff/Query.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/Query.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/9xdm60oa50uw5eru/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/query-jl/branch/master)
[![codecov](https://codecov.io/gh/davidanthoff/Query.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidanthoff/Query.jl)

## Overview

Query is a package for querying julia data sources. It can filter, project, join and group data from any iterable data source. It has enhanced support for querying arrays, [DataFrames](https://github.com/JuliaStats/DataFrames.jl), [TypedTables](https://github.com/FugroRoames/TypedTables.jl), [NDSparseData](https://github.com/JuliaComputing/NDSparseData.jl) and any [DataStream](https://github.com/JuliaData/DataStreams.jl) source (e.g. [CSV](https://github.com/JuliaData/CSV.jl), [Feather](https://github.com/JuliaStats/Feather.jl), [SQLite](https://github.com/JuliaDB/SQLite.jl) etc.).

The package currenlty provides working implementations for in-memory data sources, but will eventually be able to translate queries into e.g. SQL. There is a prototype implementation of such a "query provider" for [SQLite](https://github.com/JuliaDB/SQLite.jl) in the package, but it is experimental at this point and only works for a *very* small subset of queries.

Query is heavily inspired by [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx), in fact right now the package is largely an implementation of the [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx) part of the [C# specification](https://msdn.microsoft.com/en-us/library/ms228593.aspx). Future versions of Query will most likely add features that are not found in the original [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx) design.

## Alternatives
[Query.jl](https://github.com/davidanthoff/Query.jl) is not the only julia initiative for querying data, there are many other packages that have similar goals. Take a look at [DataFramesMeta.jl](https://github.com/JuliaStats/DataFramesMeta.jl), [jplyr.jl](https://github.com/davidagold/jplyr.jl) and [PanQuery.jl](https://github.com/bramtayl/PanQuery.jl). *If I missed other initiatives, please let me know and I'll add them to this list!*

## Installation

This package only works on julia 0.5- and newer. You can add it with:
````julia
Pkg.add("Query")
````

## Getting started
To get started, work through the Tutorial in the [documentation](http://www.david-anthoff.com/Query.jl/latest/).
