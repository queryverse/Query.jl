# Query.jl v0.9.0 Release Notes
* Add @take and @drop standalone macros
* Fix some test bugs

# Query.jl v0.8.0 Release Notes
* Add @groupjoin, @join and @mapmany standalone macros
* Move backend code to QueryOperators.jl

# Query.jl v0.7.2 Release Notes
* Fix bug in group implementation

# Query.jl v0.7.1 Release Notes
* Enable a..b syntax in @select, @where and @groupby standalone macros
* Add single argument @groupby standalone version
* Add @orderby, @orderby_descending, @thenby and @thenby_descending standalone macros
* Add "Experimental" documentation section

# Query.jl v0.7.0 Release Notes
* Add a..b syntax
* Fix some performance problems
* Fixed eltype detection
* Enable use of {} syntax everywhere
* Add experimental @select, @where and @groupby standalone macros
* Migrate to TableTraits.jl

# Query.jl v0.6.0 Release Notes
* Add @query macro for pipe syntax

# Query.jl v0.5.0 Release Notes
* Fix remaining julia 0.6 compat problems
* Drop julia 0.5 support
* Use DataValues.jl package

# Query.jl v0.4.1 Release Notes
* Fix bug in hash method for DataValue

# Query.jl v0.4.0 Release Notes
* Use DataValue instead of Nullable
* Move much of the integration code into IterableTables.jl
* Drop use of FunctionWrappers.jl

# Query.jl v0.3.2 Release Notes
* Fix bug with nested lists of lists in DataFrame sources

# Query.jl v0.3.1 Release Notes
* Add DataTable source and sink support
* Track DataStreams breaking changes

# Query.jl v0.3.0 Release Notes
* Add Dict sink support
* Reexport @NT, so one doesn't have to load NamedTuples manually

# Query.jl v0.2.1 Release Notes
* Throw an error if a DataStreams source doesn't support field-based streaming
* Track rename of NDSparseData to IndexedTables
* Track DataStreams breaking changes

# Query.jl v0.2.0 Release Notes
* Add @left_outer_join statement
* Fix bug in transparent identifier phase
* Add default_if_empty query operator

# Query.jl v0.1.0 Release Notes
* Add DataStreams sink support
* Documentation updates

# Query.jl v0.0.4 Release Notes
* Add {} syntax
* Bug fixes
* Add JSON example
* Add CSV sink support

# Query.jl v0.0.3 Release Notes
* Bug fixes

# Query.jl v0.0.2 Release Notes
* Documentation updates
* Test fixes

# Query.jl v0.0.1 Release Notes
* Initial release
