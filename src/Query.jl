module Query

using Requires
using NamedTuples
using DataStructures
using TableTraits
using IterableTables
using DataValues
using MacroTools: postwalk

import Base.start
import Base.next
import Base.done
import Base.collect
import Base.length
import Base.eltype
import Base.join
import Base.count

export @from, @query, @count, Grouping, @NT

export @select, @where, @groupby, @orderby, @orderby_descending,
	@thenby, @thenby_descending

include("enumerable/enumerable.jl")
include("enumerable/enumerable_groupby.jl")
include("enumerable/enumerable_join.jl")
include("enumerable/enumerable_groupjoin.jl")
include("enumerable/enumerable_orderby.jl")
include("enumerable/enumerable_select.jl")
include("enumerable/enumerable_where.jl")
include("enumerable/enumerable_selectmany.jl")
include("enumerable/enumerable_defaultifempty.jl")
include("enumerable/enumerable_count.jl")

include("queryable/queryable.jl")
include("queryable/queryable_select.jl")
include("queryable/queryable_where.jl")

include("query_translation.jl")

include("sources/source_iterable.jl")
include("sources/source_sqlite.jl")

include("sinks/sink_type.jl")
include("sinks/sink_array.jl")
include("sinks/sink_dict.jl")
include("sinks/sink_csvfile.jl")
include("sinks/sink_datastream_source.jl")

macro from(range::Expr, body::Expr)
	if range.head!=:call || range.args[1]!=:in
		error()
	end

	if body.head!=:block
		error()
	end

	body.args = filter(i->i.head!=:line,body.args)

	insert!(body.args, 1, Expr(:macrocall, Symbol("@from"), range))

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
