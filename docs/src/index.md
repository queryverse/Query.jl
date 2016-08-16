# Welcome to Query

## Overview

Query allows you to execute queries against almost any julia data structure.

## Installation

This package only works on julia 0.5- and newer. First, clone the package:
```julia
Pkg.clone("https://github.com/davidanthoff/Query.jl.git")
```

If you want to use the following packages with Query, you need to check out their ``master`` branch first:
```julia
Pkg.checkout("TypedTables")
Pkg.checkout("SQLite")
```
