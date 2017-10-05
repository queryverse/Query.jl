module Query

using Requires
using NamedTuples
using TableTraits
using IterableTables
using Nulls
using MacroTools: postwalk
using QueryOperators

import Base.start
import Base.next
import Base.done
import Base.collect
import Base.length
import Base.eltype
import Base.join
import Base.count

import QueryOperators: Enumerable
import QueryOperators: Queryable
import QueryOperators: QueryProvider
import QueryOperators: @count_internal
import QueryOperators: @group_by_internal
import QueryOperators: @group_by_internal_simple
import QueryOperators: @group_join_internal
import QueryOperators: @join_internal
import QueryOperators: @orderby_internal
import QueryOperators: @orderby_descending_internal
import QueryOperators: @thenby_internal
import QueryOperators: @thenby_descending_internal
import QueryOperators: @select_internal
import QueryOperators: @select_many_internal
import QueryOperators: @where_internal

export @from, @query, @count, Grouping, @NT

export @select, @where, @groupby, @orderby, @orderby_descending,
	@thenby, @thenby_descending

include("query_utils.jl")
include("query_translation.jl")
include("standalone_query_macros.jl")

include("sources/source_sqlite.jl")

include("sinks/sink_type.jl")
include("sinks/sink_dict.jl")
include("sinks/sink_datastream_source.jl")

macro from(range::Expr, body::Expr)
	if range.head!=:call || range.args[1]!=:in
		error()
	end

	if body.head!=:block
		error()
	end

	body.args = filter(i->i.head!=:line,body.args)

	insert!(body.args,1,:( @from $(range.args[2]) in $(range.args[3]) ))

	translate_query(body)

	return body.args[1]
end

macro query(range::Symbol, body::Expr)
	if body.head!=:block
		error()
	end

	f_arg = gensym()
	x = Expr(:->,f_arg,Expr(:macrocall,Symbol("@from"), Expr(:call, esc(:in), esc(range), f_arg), esc(body)))
	return x
end

end # module
