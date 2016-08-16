# Internals

This package is modeled closely after LINQ. If you are not familiar with LINQ, [this](https://msdn.microsoft.com/en-us/library/bb308959.aspx) is a great overview. It is especially recommended if you associate LINQ mainly with a query syntax in a language and don't know about the underlying language features and architecture, for example how anonymous types, lambdas and lots of other language features all play together. The query syntax is really just the tip of the iceberg.

The core idea of this package right now is to iterate over ``NamedTuple``s for table like data structures. Starting with a ``DataFrame``, ``query`` will create an iterator that produces a ``NamedTuple`` that has a field for each column, and the ``collect`` method can turn a stream of ``NamedTuple``s back into a ``DataFrame``.

If one starts with a queryable data source (like SQLite), the query will automatically be translated into SQL and executed in the database.

The wording of methods and types currently follows LINQ, not julia conventions. This is mainly to prevent clashes while Query.jl is in development.
