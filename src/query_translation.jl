function helper_namedtuples_replacement(ex)
	return MacroTools.postwalk(ex) do x
		if x isa Expr && x.head==:cell1d
			new_ex = Expr(:macrocall, Symbol("@NT"), x.args...)

			for (j,field_in_NT) in enumerate(new_ex.args[2:end])
				if isa(field_in_NT, Expr) && field_in_NT.head==:(=)
					new_ex.args[j+1] = Expr(:kw, field_in_NT.args...)
				elseif isa(field_in_NT, Expr) && field_in_NT.head==:.
					name_to_use = field_in_NT.args[2].args[1]
					new_ex.args[j+1] = Expr(:kw, name_to_use, field_in_NT)
				elseif isa(field_in_NT, Symbol)
					new_ex.args[j+1] = Expr(:kw, field_in_NT, field_in_NT)
				end
			end

			return new_ex
		else
			return x
		end
	end
end

function query_expression_translation_phase_A(qe)
	i = 1
	while i<=length(qe)
		clause = qe[i]
		if clause.head==:macrocall && clause.args[1]==Symbol("@left_outer_join")
			clause.args[1] = Symbol("@join")
			temp_name = gensym()
			x1 = clause.args[2].args[2]
			push!(clause.args, :into)
			push!(clause.args, temp_name)
			nested_from = :(@from $x1 in Query.default_if_empty($temp_name))
			insert!(qe,i+1,nested_from)
		end
		i+=1
	end
end

function query_expression_translation_phase_B(qe)
	i = 1
	while i<=length(qe)
		qe[i] = helper_namedtuples_replacement(qe[i])
		clause = qe[i]
		if i==1 && clause.head==:macrocall && clause.args[1]==Symbol("@from")
			# Handle the case of a nested query. We are essentially detecting 
			# here that the subquery starts with convert2nullable
			# and then we don't escape things.
			if isa(clause.args[2].args[3], Expr) && clause.args[2].args[3].head==:call && isa(clause.args[2].args[3].args[1],Expr) && clause.args[2].args[3].args[1].head==:. && clause.args[2].args[3].args[1].args[1]==:Query
				clause.args[2].args[3] = :(Query.query($(clause.args[2].args[3])))
			elseif !(isa(clause.args[2].args[3], Expr) && clause.args[2].args[3].head==:macrocall && isa(clause.args[2].args[3].args[1],Expr) && clause.args[2].args[3].args[1].head==:. && clause.args[2].args[3].args[1].args[1]==:Query)
				clause.args[2].args[3] = :(Query.query($(esc(clause.args[2].args[3]))))
			end
		elseif clause.head==:macrocall && clause.args[1]==Symbol("@from")
			clause.args[2].args[3] = :(Query.query($(clause.args[2].args[3])))
		elseif clause.head==:macrocall && clause.args[1]==Symbol("@join")
			clause.args[2].args[3] = :(Query.query($(esc(clause.args[2].args[3]))))
		end
		i+=1
	end
end

function query_expression_translation_phase_1(qe)
	done = false
	while !done
		group_into_index = findfirst(i->i.head==:macrocall && i.args[1]==Symbol("@group") && length(i.args)==6 && i.args[5]==:into,qe)
		select_into_index = findfirst(i->i.head==:macrocall && i.args[1]==Symbol("@select") && length(i.args)==4 && i.args[3]==:into,qe)
		if length(qe)>=2 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && group_into_index>0
			x = qe[group_into_index].args[6]

			sub_query = Expr(:block, qe[1:group_into_index]...)
			deleteat!(sub_query.args[end].args,6)
			deleteat!(sub_query.args[end].args,5)

			translate_query(sub_query)

			if length(sub_query.args)>1
				error("Subquery too long")
			end

			qe[1] = :( @from $x in $(sub_query.args[1]) )
			for i=group_into_index:-1:2
				deleteat!(qe,i)
			end
		elseif length(qe)>=2 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && select_into_index>0
			x = qe[select_into_index].args[4]

			sub_query = Expr(:block, qe[1:select_into_index]...)
			deleteat!(sub_query.args[end].args,4)
			deleteat!(sub_query.args[end].args,3)

			translate_query(sub_query)

			if length(sub_query.args)>1
				error("Subquery too long")
			end

			qe[1] = :( @from $x in $(sub_query.args[1]) )
			for i=select_into_index:-1:2
				deleteat!(qe,i)
			end
		else
			done = true
		end
	end
end

function query_expression_translation_phase_3(qe)
	done = false
	while !done
		if length(qe)>=2 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@select") && qe[1].args[2].args[2]==qe[2].args[2]
			x = qe[1].args[2].args[2]
			e = qe[1].args[2].args[3]

			qe[1] = :( Query.@select_internal($e,x->x) )
			deleteat!(qe,2)
		else
			done = true
		end
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
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@from")
			x1 = qe[1].args[2].args[2]
			x2 = qe[2].args[2].args[2]
			e1 = qe[1].args[2].args[3]
			e2 = qe[2].args[2].args[3]

			f_collection_selector = Expr(:->, x1, e2)
			f_result_selector = Expr(:->, Expr(:tuple,x1,x2), :(@NT($x1=$x1,$x2=$x2)))

			qe[1].args[2].args[2] = Expr(:transparentidentifier, gensym(:t), x1, x2)
			qe[1].args[2].args[3] = :( Query.@select_many_internal($e1, $(esc(f_collection_selector)), $(esc(f_result_selector))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@let")
			x = qe[1].args[2].args[2]
			e = qe[1].args[2].args[3]
			y = qe[2].args[2].args[1]
			f = qe[2].args[2].args[2]

			f_selector = Expr(:->, x, :(@NT($x=$x,$y=$f)))

			qe[1].args[2].args[2] = Expr(:transparentidentifier, gensym(:t), x, y)
			qe[1].args[2].args[3] = :( Query.@select_internal($e,$(esc(f_selector))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@where")
			x = qe[1].args[2].args[2]
			e = qe[1].args[2].args[3]
			f = qe[2].args[2]

			f_condition = Expr(:->, x, f)

			qe[1].args[2].args[3] = :( Query.@where_internal($e,$(esc(f_condition))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@join") && length(qe[2].args)==6 && qe[3].head==:macrocall && qe[3].args[1]==Symbol("@select")
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
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@join") && length(qe[2].args)==6
			e1 = qe[1].args[2].args[3]
			e2 = qe[2].args[2].args[3]
			x1 = qe[1].args[2].args[2]
			x2 = qe[2].args[2].args[2]
			k1 = qe[2].args[4]
			k2 = qe[2].args[6]
			f_outer_key = Expr(:->, x1, k1)
			f_inner_key = Expr(:->, x2, k2)
			f_result = Expr(:->, Expr(:tuple,x1,x2), :(@NT($x1=$x1,$x2=$x2)) )

			qe[1].args[2].args[2] = Expr(:transparentidentifier, gensym(:t), x1, x2)
			qe[1].args[2].args[3] = :( Query.@join_internal($e1,$e2,$(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@join") && length(qe[2].args)==8 && qe[3].head==:macrocall && qe[3].args[1]==Symbol("@select")
			e1 = qe[1].args[2].args[3]
			e2 = qe[2].args[2].args[3]
			x1 = qe[1].args[2].args[2]
			x2 = qe[2].args[2].args[2]
			k1 = qe[2].args[4]
			k2 = qe[2].args[6]
			g = qe[2].args[8]
			v = qe[3].args[2]
			f_outer_key = Expr(:->, x1, k1)
			f_inner_key = Expr(:->, x2, k2)
			f_result = Expr(:->, Expr(:tuple,x1,g), v)
			qe[1] = :( Query.@group_join_internal($e1, $e2, $(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result))) )

			deleteat!(qe,3)
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@join") && length(qe[2].args)==8
			e1 = qe[1].args[2].args[3]
			e2 = qe[2].args[2].args[3]
			x1 = qe[1].args[2].args[2]
			x2 = qe[2].args[2].args[2]
			k1 = qe[2].args[4]
			k2 = qe[2].args[6]
			g = qe[2].args[8]
			f_outer_key = Expr(:->, x1, k1)
			f_inner_key = Expr(:->, x2, k2)
			f_result = Expr(:->, Expr(:tuple,x1,g), :(@NT($x1=$x1,$g=$g)) )

			qe[1].args[2].args[2] = Expr(:transparentidentifier, gensym(:t), x1, g)
			qe[1].args[2].args[3] = :( Query.@group_join_internal($e1,$e2,$(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@orderby")
			e = qe[1].args[2].args[3]
			x = qe[1].args[2].args[2]
			ks = []
			if isa(qe[2].args[2], Expr) && qe[2].args[2].head==:tuple
				for sort_clause in qe[2].args[2].args
					if isa(sort_clause, Expr) && sort_clause.head==:call && sort_clause.args[1]==:descending
						k = sort_clause.args[2]
						direction = :descending
					elseif isa(sort_clause, Expr) && sort_clause.head==:call && sort_clause.args[1]==:ascending
						k = sort_clause.args[2]
						direction = :ascending
					else
						k = sort_clause
						direction = :ascending
					end
					push!(ks, (k, direction))
				end
			else
				if isa(qe[2].args[2], Expr) && qe[2].args[2].head==:call && qe[2].args[2].args[1]==:descending
					k = qe[2].args[2].args[2]
					direction = :descending
				elseif isa(qe[2].args[2], Expr) && qe[2].args[2].head==:call && qe[2].args[2].args[1]==:ascending
					k = qe[2].args[2].args[2]
					direction = :ascending
				else
					k = qe[2].args[2]
					direction = :ascending
				end
				push!(ks, (k, direction))
			end

			for (i,sort_clause) in enumerate(ks)
				f_condition = Expr(:->, x, sort_clause[1])

				if sort_clause[2]==:ascending
					if i==1
						qe[1].args[2].args[3] = :( Query.@orderby_internal($e,$(esc(f_condition))) )
					else
						qe[1].args[2].args[3] = :( Query.@thenby_internal($(qe[1].args[2].args[3]),$(esc(f_condition))) )
					end
				elseif sort_clause[2]==:descending
					if i==1
						qe[1].args[2].args[3] = :( Query.@orderby_descending_internal($e,$(esc(f_condition))) )
					else
						qe[1].args[2].args[3] = :( Query.@thenby_descending_internal($(qe[1].args[2].args[3]),$(esc(f_condition))) )
					end
				end
			end
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

function query_expression_translation_phase_6(qe)
	done = false
	while !done
		if length(qe)>=2 && qe[1].head==:macrocall && qe[1].args[1]==Symbol("@from") && qe[2].head==:macrocall && qe[2].args[1]==Symbol("@group")
			e = qe[1].args[2].args[3]
			x = qe[1].args[2].args[2]
			v = qe[2].args[2]
			k = qe[2].args[4]

			f_elementSelector = Expr(:->, x, k)
			f_resultSelector = Expr(:->, x, v)

			if v==x
				qe[1] = :( Query.@group_by_internal_simple($e, $(esc(f_elementSelector))) )
			else
				qe[1] = :( Query.@group_by_internal($e, $(esc(f_elementSelector)), $(esc(f_resultSelector))) )
			end
			deleteat!(qe,2)
		else
			done = true
		end
	end
end

# Phase 7

function replace_transparent_identifier_in_anonym_func(ex::Expr, names_to_put_in_scope)
	for (i,child_ex) in enumerate(ex.args)
		if isa(child_ex, Expr)
			replace_transparent_identifier_in_anonym_func(child_ex, names_to_put_in_scope)
		elseif isa(child_ex, Symbol)
			index_of_name = findfirst(j->child_ex==j[2], names_to_put_in_scope)
			if index_of_name>0 && !(ex.head==Symbol("=>") && i==1)
				ex.args[i] = Expr(:., names_to_put_in_scope[index_of_name][1], QuoteNode(child_ex))
			end
		end
	end
end

function find_names_to_put_in_scope(ex::Expr)
	names = []
	for child_ex in ex.args[2:end]
		if isa(child_ex,Expr) && child_ex.head==:transparentidentifier
			child_names = find_names_to_put_in_scope(child_ex)
			for child_name in child_names
				push!(names, (Expr(:., ex.args[1], QuoteNode(child_name[1])), child_name[2]))
			end
		elseif isa(child_ex, Symbol)
			push!(names,(ex.args[1],child_ex))
		elseif isa(child_ex, Expr) && child_ex.head==:.
			push!(names,(ex.args[1],child_ex.args[2].value))
		else
			error()
		end
	end
	return names
end

function find_and_translate_transparent_identifier(ex::Expr)
	# First expand any transparent identifiers in lambdas
	if ex.head==:-> && isa(ex.args[1], Expr) && ex.args[1].head==:transparentidentifier
		names_to_put_in_scope = find_names_to_put_in_scope(ex.args[1])
		ex.args[1] = ex.args[1].args[1]
		replace_transparent_identifier_in_anonym_func(ex, names_to_put_in_scope)
	elseif ex.head==:-> && isa(ex.args[1], Expr) && ex.args[1].head==:tuple
		names_to_put_in_scope = []
		for (i, child_ex) in enumerate(ex.args[1].args)
			if isa(child_ex, Expr) && child_ex.head==:transparentidentifier
				append!(names_to_put_in_scope, find_names_to_put_in_scope(child_ex))
				ex.args[1].args[i] = child_ex.args[1]
			end
		end
		replace_transparent_identifier_in_anonym_func(ex, names_to_put_in_scope)
	end


	for (i,child_ex) in enumerate(ex.args)
		if isa(child_ex, Expr) && child_ex.head==:transparentidentifier
			ex.args[i] = child_ex.args[1]
		elseif isa(child_ex, Expr)
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

function query_expression_translation_phase_D(qe)
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

function translate_query(body)
	debug_output = false

	debug_output && println("AT START")
	debug_output && println(body)

	query_expression_translation_phase_1(body.args)
	debug_output && println("AFTER 1")
	debug_output && println(body)

	query_expression_translation_phase_A(body.args)
	debug_output && println("AFTER A")
	debug_output && println(body)

	query_expression_translation_phase_B(body.args)
	debug_output && println("AFTER B")
	debug_output && println(body)

	query_expression_translation_phase_3(body.args)
	debug_output && println("AFTER 3")
	debug_output && println(body)

	query_expression_translation_phase_4(body.args)
	debug_output && println("AFTER 4")
	debug_output && println(body)

	query_expression_translation_phase_5(body.args)
	debug_output && println("AFTER 5")
	debug_output && println(body)

	query_expression_translation_phase_6(body.args)
	debug_output && println("AFTER 6")
	debug_output && println(body)

	query_expression_translation_phase_7(body.args)
	debug_output && println("AFTER 7")
	debug_output && println(body)

	query_expression_translation_phase_D(body.args)
	debug_output && println("AFTER D")
	debug_output && println(body)
end
