# Query

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.org/davidanthoff/Query.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/Query.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/0jys47jov7m7hb8j/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/Query-jl/branch/master)
[![codecov](https://codecov.io/gh/davidanthoff/Query.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidanthoff/Query.jl)
[![Coverage Status](https://coveralls.io/repos/github/davidanthoff/Query.jl/badge.svg?branch=master)](https://coveralls.io/github/davidanthoff/Query.jl?branch=master)

The code is at best a sketch of an idea, certainly not ready to be used for anything. The main purpose is to try out various things and see whether it is worth pursuing them.

## Installation

This package only works on julia 0.5- and newer. First, clone these packages:
````julia
Pkg.clone("https://github.com/davidanthoff/Query.jl.git")
Pkg.clone("https://github.com/yuyichao/FunctionWrappers.jl.git")
````
You then need to be on master for these packages:
````julia
Pkg.checkout("TypedTables")
Pkg.checkout("SQLite")
````

## Getting started
To get started, look at the code in the ``example`` folder.

## Background
This package is modeled closely after LINQ. If you are not familiar with LINQ, [this](https://msdn.microsoft.com/en-us/library/bb308959.aspx) is a great overview. It is especially recommended if you associate LINQ mainly with a query syntax in a language and don't know about the underlying language features and architecture, for example how anonymous types, lambdas and lots of other language features all play together. The query syntax is really just the tip of the iceberg.

The core idea of this package right now is to iterate over ``NamedTuple``s. Starting with a ``DataFrame``, ``query`` will create an iterator that produces a ``NamedTuple`` that has a field for each column, and the ``collect`` method can turn a stream of ``NamedTuple``s back into a ``DataFrame``.

If one starts with a queryable data source (like SQLite), the query will automatically be translated into SQL and executed in the database.

The wording of methods and types currently follows LINQ, not julia conventions. This is mainly to prevent clashes while Query.jl is in development.
