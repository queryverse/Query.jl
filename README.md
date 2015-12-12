# LINQ

[![Build Status](https://travis-ci.org/davidanthoff/LINQ.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/LINQ.jl)

Currently all development is happening on the ``dev`` branch. The code is at best a sketch of an idea, certainly not ready to be used for anything. The main purpose is to try out various things and see whether it is worth pursuing them.

You need to checkout the ``nl/nullable`` branch in the DataFrames.jl package, ``JeffBezanson-master`` in NamedTuples.jl and ``master`` in DataStreams.jl, WeakRefStrings.jl, TypedTables.jl and SQLite.jl. You also need to clone ``https://github.com/yuyichao/FunctionWrappers.jl``.

To get started, look at the code in the ``example`` folder.

This is modeled closely after LINQ. If you are not familiar with LINQ, [this](https://msdn.microsoft.com/en-us/library/bb308959.aspx) is a great overview. It is especially recommended if you associate LINQ mainly with a query syntax in a language and don't know about the underlying language features and architecture, for example how anonymous types, lambdas and lots of other language features all play together. The query syntax is really just the tip of the iceberg.

The core idea of this package right now is to iterate over ``NamedTuple``s. Starting with a ``DataFrame``, ``enumerable`` will create an iterator that produces a ``NamedTuple`` that has a field for each column, and the ``collect`` method can turn a stream of ``NamedTuple``s back into a ``DataFrame``.

If one starts with a queryable data source (like SQLite), the query will automatically be translated into SQL and executed in the database.

The wording of methods and types currently follows LINQ, not julia conventions. This is mainly to prevent clashes while LINQ.jl is in development.
