# Welcome to Query

## Overview

Query allows you to execute queries against almost any julia data structure. The package currently supports queries against [DataFrames](https://github.com/JuliaStats/DataFrames.jl), [TypedTables](https://github.com/FugroRoames/TypedTables.jl), [DataStreams](https://github.com/JuliaData/DataStreams.jl) (e.g. [CSV](https://github.com/JuliaData/CSV.jl)) and any other iterable (arrays, dictionaries etc.).

## Installation

This package only works on julia 0.5- and newer. It is currently not registered, so you need to clone it:
```julia
Pkg.clone("https://github.com/davidanthoff/Query.jl.git")
```
