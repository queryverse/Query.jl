module Query

using TableTraits
import IterableTables
using DataValues
using MacroTools: postwalk
using QueryOperators

import Base.length
import Base.eltype
import Base.join
import Base.count

import QueryOperators: Enumerable

export @from, @query, @count, Grouping, key

export @map, @filter, @groupby, @orderby, @orderby_descending,
	@thenby, @thenby_descending, @groupjoin, @join, @mapmany, @take, @drop

include("query_utils.jl")
include("query_translation.jl")
include("standalone_query_macros.jl")

include("sinks/sink_type.jl")

macro from(range::Expr, body::Expr)
	if range.head!=:call || (range.args[1]!=:in && range.args[1]!=in)
		error()
	end

	if body.head!=:block
		error()
	end

	body.args = filter(i->!isa(i, LineNumberNode),body.args)

	insert!(body.args,1,:( @from $(range.args[2]) in $(range.args[3]) ))

	translate_query(body)

	return body.args[1]
end

macro query(range::Symbol, body::Expr)
	if body.head!=:block
		error()
	end

	f_arg = gensym()
	x = x = esc(:($f_arg -> $Query.@from $in($range, $f_arg) $body))
	return x
end

end # module
