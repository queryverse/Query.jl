module Query

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
import Base.join

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
		result_expression = :(Query.query($(esc(source))))
	end

	body.args = filter(i->i.head!=:line,body.args)

	i = 1
	while i<=length(body.args)
		clause = body.args[i]
		if clause.head==:macrocall
			if clause.args[1]==Symbol("@select")
				func_call = Expr(:->, range_var, clause.args[2])
				result_expression = :(Query.@select($result_expression, $(esc(func_call))))
			elseif clause.args[1]==Symbol("@where")
				func_call = Expr(:->, range_var, clause.args[2])
				result_expression = :(Query.@where($result_expression, $(esc(func_call))))
			elseif clause.args[1]==Symbol("@join")
				inner_range_var = clause.args[2].args[2]
				inner_source = :(Query.query($(esc(clause.args[2].args[3]))))

				outerkey_func_call = Expr(:->, range_var, clause.args[4])
				innerkey_func_call = Expr(:->, inner_range_var, clause.args[6])

				if i<length(body.args) && body.args[i+1].head==:macrocall && body.args[i+1].args[1]==Symbol("@select")
					result_func_call = Expr(:->, Expr(:tuple,range_var,inner_range_var), body.args[i+1].args[2])
					i=i+1
				else
					error("Not yet supported")
				end
				result_expression = :(Query.@join($result_expression, $inner_source, $(esc(outerkey_func_call)), $(esc(innerkey_func_call)), $(esc(result_func_call))))
			else
				error()
			end
		else
			error()
		end
		i=i+1
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

macro join(outer, inner, outerKeySelector, innerKeySelector, resultSelector)
	q_outerKeySelector = Expr(:quote, outerKeySelector)
	q_innerKeySelector = Expr(:quote, innerKeySelector)
	q_resultSelector = Expr(:quote, resultSelector)

	quote
		join($(esc(outer)), $(esc(inner)), $(esc(q_outerKeySelector)),$(esc(q_innerKeySelector)),$(esc(q_resultSelector)))
	end
end

end # module
