# LINQ

[![Build Status](https://travis-ci.org/davidanthoff/LINQ.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/LINQ.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/0jys47jov7m7hb8j/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/linq-jl/branch/master)
[![codecov](https://codecov.io/gh/davidanthoff/LINQ.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidanthoff/LINQ.jl)
[![Coverage Status](https://coveralls.io/repos/github/davidanthoff/LINQ.jl/badge.svg?branch=master)](https://coveralls.io/github/davidanthoff/LINQ.jl?branch=master)

The code is at best a sketch of an idea, certainly not ready to be used for anything. The main purpose is to try out various things and see whether it is worth pursuing them.

## Installation

This package only works on julia 0.5- and newer. First, clone this package:
````julia
Pkg.clone("https://github.com/davidanthoff/LINQ.jl.git")
````
You then need to be on master or other branches for various packages:
````julia
Pkg.checkout("DataFrames", "nl/nullable")
Pkg.checkout("DataStreams")
Pkg.checkout("WeakRefStrings")
Pkg.checkout("NamedTuples")
Pkg.checkout("TypedTables")
Pkg.checkout("SQLite")
````
Finally, you need to clone the [FunctionWrappers.jl](https://github.com/yuyichao/FunctionWrappers.jl) package:
````julia
Pkg.clone("https://github.com/yuyichao/FunctionWrappers.jl.git")
````

## Getting started
To get started, look at the code in the ``example`` folder.

## Background
This package is modeled closely after LINQ. If you are not familiar with LINQ, [this](https://msdn.microsoft.com/en-us/library/bb308959.aspx) is a great overview. It is especially recommended if you associate LINQ mainly with a query syntax in a language and don't know about the underlying language features and architecture, for example how anonymous types, lambdas and lots of other language features all play together. The query syntax is really just the tip of the iceberg.

The core idea of this package right now is to iterate over ``NamedTuple``s. Starting with a ``DataFrame``, ``query`` will create an iterator that produces a ``NamedTuple`` that has a field for each column, and the ``collect`` method can turn a stream of ``NamedTuple``s back into a ``DataFrame``.

If one starts with a queryable data source (like SQLite), the query will automatically be translated into SQL and executed in the database.

The wording of methods and types currently follows LINQ, not julia conventions. This is mainly to prevent clashes while LINQ.jl is in development.
