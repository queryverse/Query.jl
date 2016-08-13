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

function query_expression_translation_phase_A(qe)
	i = 1
	while i<=length(qe)
		clause = qe[i]
		if clause.head==:macrocall && clause.args[1]==Symbol("@from")
			clause.args[2].args[3] = :(Query.query($(esc(clause.args[2].args[3]))))
		elseif clause.head==:macrocall && clause.args[1]==Symbol("@join")
			clause.args[2].args[3] = :(Query.query($(esc(clause.args[2].args[3]))))
		end
		i+=1
	end
end

function query_expression_translation_phase_4(qe)
	i = 1
	while i<=length(qe)
		clause = qe[i]
		if clause.head==:macrocall && clause.args[1]==Symbol("@where")
			from_clause = qe[i-1]
			if from_clause.head!=:macrocall || from_clause.args[1]!=Symbol("@from")
				error("Error in phase 4")
			end
			range_var = from_clause.args[2].args[2]
			func_call = Expr(:->, range_var, clause.args[2])
			from_clause.args[2].args[3] = :( Query.@where_internal($(from_clause.args[2].args[3]), $(esc(func_call))) )
			deleteat!(qe,i)
		elseif clause.head==:macrocall && clause.args[1]==Symbol("@join") && qe[i+1].head==:macrocall && qe[i+1].args[1]==Symbol("@select") && qe[i-1].head==:macrocall && qe[i-1].args[1]==Symbol("@from")
			outer = qe[i-1].args[2].args[3]
			inner = clause.args[2].args[3]
			outer_range_var = qe[i-1].args[2].args[2]
			inner_range_var = clause.args[2].args[2]
			f_outer_key = Expr(:->, outer_range_var, clause.args[4])
			f_inner_key = Expr(:->, inner_range_var, clause.args[6])
			f_result = Expr(:->, Expr(:tuple,outer_range_var,inner_range_var), qe[i+1].args[2])
			qe[i-1] = :(
				Query.@join_internal($outer, $inner, $(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result)))
				)
			deleteat!(qe,i+1)
			deleteat!(qe,i)
		else
			i+=1
		end
	end
end

function query_expression_translation_phase_5(qe)
	i = 1
	while i<=length(qe)
		clause = qe[i]
		if clause.head==:macrocall && clause.args[1]==Symbol("@select")
			from_clause = qe[i-1]
			if from_clause.head!=:macrocall || from_clause.args[1]!=Symbol("@from")
				error("Error in phase 5")
			end
			range_var = from_clause.args[2].args[2]
			source = from_clause.args[2].args[3]
			if clause.args[2]==range_var
				qe[i-1] = source
			else
				func_call = Expr(:->, range_var, clause.args[2])
				qe[i-1] = :( Query.@select_internal($source, $(esc(func_call))) )
			end
			deleteat!(qe,i)
		else
			i+=1
		end
	end
end

function query_expression_translation_phase_B(qe)
	i = 1
	while i<=length(qe)
		clause = qe[i]
		if clause.head==:macrocall && clause.args[1]==Symbol("@collect")
			previous_clause = qe[i-1]
			if length(clause.args)==1
				qe[i-1] = :( collect($previous_clause) )
			else
				qe[i-1] = :( collect($previous_clause, $(esc(clause.args[2]))) )
			end
			deleteat!(qe,i)
		else
			i+=1
		end
	end
end

macro from(range::Expr, body::Expr)
	if range.head!=:call || range.args[1]!=:in
		error()
	end

	if body.head!=:block
		error()
	end

	body.args = filter(i->i.head!=:line,body.args)

	insert!(body.args,1,:( @from $(range.args[2]) in $(range.args[3]) ))

	query_expression_translation_phase_A(body.args)
	query_expression_translation_phase_4(body.args)
	query_expression_translation_phase_5(body.args)
	query_expression_translation_phase_B(body.args)

	return body.args[1]
end

macro where_internal(source, f)
	q = Expr(:quote, f)
    :(where($(esc(source)), $(esc(q))))
end

macro select_internal(source, f)
	q = Expr(:quote, f)
    :(select($(esc(source)), $(esc(q))))
end

macro join_internal(outer, inner, outerKeySelector, innerKeySelector, resultSelector)
	q_outerKeySelector = Expr(:quote, outerKeySelector)
	q_innerKeySelector = Expr(:quote, innerKeySelector)
	q_resultSelector = Expr(:quote, resultSelector)

	:(join($(esc(outer)), $(esc(inner)), $(esc(q_outerKeySelector)),$(esc(q_innerKeySelector)),$(esc(q_resultSelector))))
end

end # module
