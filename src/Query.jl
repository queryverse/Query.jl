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
	done = false
	while !done
		if length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@from") && qe[3].head==:macrocall && qe[3].args[1]==Symbol("@select")
			x1 = qe[1].args[2].args[2]
			x2 = qe[2].args[2].args[2]
			e1 = qe[1].args[2].args[3]
			e2 = qe[2].args[2].args[3]
			v = qe[3].args[2]

			f_collection_selector = Expr(:->, x1, e2)
			f_result_selector = Expr(:->, Expr(:tuple,x1,x2), v)

			qe[1] = :( Query.@select_many_internal($e1, $(esc(f_collection_selector)), $(esc(f_result_selector))) )
			deleteat!(qe,3)
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@let")
			x = qe[1].args[2].args[2]
			e = qe[1].args[2].args[3]
			y = qe[2].args[2].args[1]
			f = qe[2].args[2].args[2]

			f_selector = Expr(:->, x, :(@NT($x=>$x,$y=>$f)))

			qe[1].args[2].args[2] = Expr(:transparentidentifier, x, y)
			qe[1].args[2].args[3] = :( Query.@select_internal($e,$(esc(f_selector))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@where")
			x = qe[1].args[2].args[2]
			e = qe[1].args[2].args[3]
			f = qe[2].args[2]

			f_condition = Expr(:->, x, f)

			qe[1].args[2].args[3] = :( Query.@where_internal($e,$(esc(f_condition))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@join") && qe[3].head==:macrocall && qe[3].args[1]==Symbol("@select")
			outer = qe[1].args[2].args[3]
			inner = qe[2].args[2].args[3]
			outer_range_var = qe[1].args[2].args[2]
			inner_range_var = qe[2].args[2].args[2]
			f_outer_key = Expr(:->, outer_range_var, qe[2].args[4])
			f_inner_key = Expr(:->, inner_range_var, qe[2].args[6])
			f_result = Expr(:->, Expr(:tuple,outer_range_var,inner_range_var), qe[3].args[2])
			qe[1] = :(
				Query.@join_internal($outer, $inner, $(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result)))
				)

			deleteat!(qe,3)
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@join")
			e1 = qe[1].args[2].args[3]
			e2 = qe[2].args[2].args[3]
			x1 = qe[1].args[2].args[2]
			x2 = qe[2].args[2].args[2]
			k1 = qe[2].args[4]
			k2 = qe[2].args[6]
			f_outer_key = Expr(:->, x1, k1)
			f_inner_key = Expr(:->, x2, k2)
			f_result = Expr(:->, Expr(:tuple,x1,x2), :(@NT($x1=>$x1,$x2=>$x2)) )

			qe[1].args[2].args[2] = Expr(:transparentidentifier, x1, x2)
			qe[1].args[2].args[3] = :( Query.@join_internal($e1,$e2,$(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result))) )
			deleteat!(qe,2)
		else
			done = true
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

# Phase 7

function replace_transparent_identifier_in_anonym_func(ex::Expr, identifier, children)
	for (i,child_ex) in enumerate(ex.args)
		if isa(child_ex, Expr)
			replace_transparent_identifier_in_anonym_func(child_ex, identifier, children)
		elseif isa(child_ex, Symbol) && in(child_ex, children)
			if !(ex.head==Symbol("=>") && i==1)
				ex.args[i] = Expr(:., identifier, QuoteNode(child_ex))
			end
		end
	end
end

function find_and_translate_transparent_identifier(ex::Expr)
	if ex.head==:-> && isa(ex.args[1], Expr) && ex.args[1].head==:transparentidentifier
		names_to_put_in_scope = ex.args[1].args
		ex.args[1] = :x
		replace_transparent_identifier_in_anonym_func(ex, :x, names_to_put_in_scope)
	end

	for child_ex in ex.args
		if isa(child_ex, Expr)
			find_and_translate_transparent_identifier(child_ex)
		end
	end
end

function query_expression_translation_phase_7(qe)
	for clause in qe
		if isa(clause, Expr)
			find_and_translate_transparent_identifier(clause)
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
	debug_output = false
	if range.head!=:call || range.args[1]!=:in
		error()
	end

	if body.head!=:block
		error()
	end

	body.args = filter(i->i.head!=:line,body.args)

	insert!(body.args,1,:( @from $(range.args[2]) in $(range.args[3]) ))

	debug_output && println("AT START")
	debug_output && println(body)

	query_expression_translation_phase_A(body.args)
	debug_output && println("AFTER A")
	debug_output && println(body)

	query_expression_translation_phase_4(body.args)
	debug_output && println("AFTER 4")
	debug_output && println(body)

	query_expression_translation_phase_5(body.args)
	debug_output && println("AFTER 5")
	debug_output && println(body)

	query_expression_translation_phase_7(body.args)
	debug_output && println("AFTER 7")
	debug_output && println(body)

	query_expression_translation_phase_B(body.args)
	debug_output && println("AFTER B")
	debug_output && println(body)

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
