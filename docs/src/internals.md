# Internals

## Overview

This package is modeled closely after LINQ. If you are not familiar with LINQ, [this](https://msdn.microsoft.com/en-us/library/bb308959.aspx) is a great overview. It is especially recommended if you associate LINQ mainly with a query syntax in a language and don't know about the underlying language features and architecture, for example how anonymous types, lambdas and lots of other language features all play together. The query syntax is really just the tip of the iceberg.

The core idea of this package right now is to iterate over ``NamedTuple``s for table like data structures. Starting with a ``DataFrame``, ``query`` will create an iterator that produces a ``NamedTuple`` that has a field for each column, and the ``collect`` method can turn a stream of ``NamedTuple``s back into a ``DataFrame``.

If one starts with a queryable data source (like SQLite), the query will automatically be translated into SQL and executed in the database.

The wording of methods and types currently follows LINQ, not julia conventions. This is mainly to prevent clashes while Query.jl is in development.

## Readings

The original [LINQ](https://msdn.microsoft.com/en-us/library/bb308959.aspx) document is still a good read.

The [The Wayward WebLog](https://blogs.msdn.microsoft.com/mattwar/) has some excellent posts about writing query providers:

- [LINQ: Building an IQueryable Provider – Part I](https://blogs.msdn.microsoft.com/mattwar/2007/07/30/linq-building-an-iqueryable-provider-part-i/)
- [LINQ: Building an IQueryable Provider – Part II](https://blogs.msdn.microsoft.com/mattwar/2007/07/31/linq-building-an-iqueryable-provider-part-ii/)
- [LINQ: Building an IQueryable Provider – Part III](https://blogs.msdn.microsoft.com/mattwar/2007/08/01/linq-building-an-iqueryable-provider-part-iii/)
- [LINQ: Building an IQueryable Provider – Part IV](https://blogs.msdn.microsoft.com/mattwar/2007/08/02/linq-building-an-iqueryable-provider-part-iv/)
- [LINQ: Building an IQueryable Provider – Part V](https://blogs.msdn.microsoft.com/mattwar/2007/08/03/linq-building-an-iqueryable-provider-part-v/)
- [LINQ: Building an IQueryable Provider – Part VI](https://blogs.msdn.microsoft.com/mattwar/2007/08/09/linq-building-an-iqueryable-provider-part-vi/)
- [LINQ: Building an IQueryable provider – Part VII](https://blogs.msdn.microsoft.com/mattwar/2007/09/04/linq-building-an-iqueryable-provider-part-vii/)
- [LINQ: Building an IQueryable Provider – Part VIII](https://blogs.msdn.microsoft.com/mattwar/2007/10/09/linq-building-an-iqueryable-provider-part-viii/)
- [LINQ: Building an IQueryable Provider – Part IX](https://blogs.msdn.microsoft.com/mattwar/2008/01/16/linq-building-an-iqueryable-provider-part-ix/)
- [LINQ: Building an IQueryable Provider – Part X](https://blogs.msdn.microsoft.com/mattwar/2008/07/08/linq-building-an-iqueryable-provider-part-x/)
- [LINQ: Building an IQueryable Provider – Part XI](https://blogs.msdn.microsoft.com/mattwar/2008/07/14/linq-building-an-iqueryable-provider-part-xi/)
- [Building a LINQ IQueryable Provider – Part XII](https://blogs.msdn.microsoft.com/mattwar/2008/11/17/building-a-linq-iqueryable-provider-part-xii/)
- [Building a LINQ IQueryable Provider – Part XIII](https://blogs.msdn.microsoft.com/mattwar/2009/01/22/building-a-linq-iqueryable-provider-part-xiii/)
- [Building a LINQ IQueryable provider – Part XIV](https://blogs.msdn.microsoft.com/mattwar/2009/04/08/building-a-linq-iqueryable-provider-part-xiv/)
- [Building a LINQ IQueryable provider – Part XV (IQToolkit v0.15)](https://blogs.msdn.microsoft.com/mattwar/2009/06/16/building-a-linq-iqueryable-provider-part-xv-iqtoolkit-v0-15/)
- [Building a LINQ IQueryable Provider – Part XVI (IQToolkit 0.16)](https://blogs.msdn.microsoft.com/mattwar/2009/09/15/building-a-linq-iqueryable-provider-part-xvi-iqtoolkit-0-16/)
- [Building a LINQ IQueryable Provider – Part XVII (IQToolkit 0.17)](https://blogs.msdn.microsoft.com/mattwar/2010/02/09/building-a-linq-iqueryable-provider-part-xvii-iqtoolkit-0-17/)

[Joe Duffy](http://joeduffyblog.com/) wrote an interesting article about iterator protocolls:

- [Joe Duffy on enumerating in .Net](http://joeduffyblog.com/2008/09/21/the-cost-of-enumerating-in-net/)
