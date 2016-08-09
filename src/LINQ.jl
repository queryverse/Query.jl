module LINQ

using DataFrames
using TypedTables
using NamedTuples
import FunctionWrappers: FunctionWrapper

import Base.start
import Base.next
import Base.done
import Base.collect
import Base.length
import Base.eltype

export @from, query

include("enumerable.jl")
include("queryable.jl")

include("sources/source_array.jl")
include("sources/source_iterable.jl")
include("sources/source_dataframe.jl")
include("sources/source_sqlite.jl")
include("sources/source_typedtable.jl")

include("collect.jl")

macro from(range::Expr, body::Expr, final_call=nothing)
	if range.head!=:call || range.args[1]!=:in
		error()
	end
	range_var = range.args[2]
	source = range.args[3]

	if body.head!=:block
		error()
	end

	local result_expression::Expr

	if isa(source, Expr) && source.head==:call && source.args[1]==:query
		result_expression = :($(esc(source)))
	else
		result_expression = :(LINQ.query($(esc(source))))
	end

	for clause in body.args
		if clause.head==:line
		elseif clause.head==:macrocall
			if clause.args[1]==Symbol("@select")
				func_call = Expr(:->, range_var, clause.args[2])
				result_expression = :(LINQ.@select($result_expression, $(esc(func_call))))
			elseif clause.args[1]==Symbol("@where")
				func_call = Expr(:->, range_var, clause.args[2])
				result_expression = :(LINQ.@where($result_expression, $(esc(func_call))))
			else
				error()
			end
		else
			error()
		end
	end

	if final_call!=nothing
		insert!(final_call.args, 2, result_expression)
		result_expression = final_call
	end

	return result_expression
end

macro where(source, f)
	q = Expr(:quote, f)
    quote
        where($(esc(source)), $(esc(q)))
    end
end

macro select(source, f)
	q = Expr(:quote, f)
    quote
        select($(esc(source)), $(esc(q)))
    end
end

end # module
