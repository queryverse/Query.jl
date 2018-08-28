struct QueryException <: Exception
	msg::String
	context::Any
	QueryException(msg::AbstractString, context=nothing) = new(msg, context)
end

function Base.showerror(io::IO, ex::QueryException)
	print(io, "QueryException: $(ex.msg)")
	if ex.context !== nothing
		print(io, " at $(ex.context)")
	end
end

function helper_namedtuples_replacement(ex)
	return postwalk(ex) do x
		if x isa Expr && x.head==:braces
			new_ex = Expr(:tuple, x.args...)

			for (j,field_in_NT) in enumerate(new_ex.args)
				if isa(field_in_NT, Expr) && field_in_NT.head==:.
					name_to_use = field_in_NT.args[2].value
					new_ex.args[j] = Expr(:(=), name_to_use, field_in_NT)
				elseif isa(field_in_NT, Symbol)
					new_ex.args[j] = Expr(:(=), field_in_NT, field_in_NT)
				end
			end

			return new_ex
		else
			return x
		end
	end
end

function helper_replace_anon_func_syntax(ex)
	if !(isa(ex, Expr) && ex.head==:->)
		new_symb = gensym()
		new_symb2 = gensym()
		two_args = false
		new_ex = postwalk(ex) do x
			if isa(x, Symbol)
				if x==:_
					return new_symb
				elseif x==:__
					two_args = true
					return new_symb2
				else
					return x
				end
			else
				return x
			end
		end

		if two_args
			return :(($new_symb, $new_symb2) -> $(new_ex) )
		else
			return :($new_symb -> $(new_ex) )
		end
	else
		return ex
	end
end

function helper_replace_field_extraction_syntax(ex)
	postwalk(ex) do x
		iscall(x, :(..)) ? :(map(i->i.$(x.args[3]), $(x.args[2]))) : x
	end
end

function query_expression_translation_phase_A(qe)
	i = 1
	while i<=length(qe)
		clause = qe[i]
		if ismacro(clause, "@left_outer_join")
			clause.args[1] = Symbol("@join")
			temp_name = gensym()
			x1 = clause.args[3].args[2]
			push!(clause.args, :into)
			push!(clause.args, temp_name)
			nested_from = :(@from $x1 in QueryOperators.default_if_empty($temp_name))
			insert!(qe,i+1,nested_from)
		end
		i+=1
	end

	for i in eachindex(qe)
		qe[i] = helper_replace_field_extraction_syntax(qe[i])
	end
end

function query_expression_translation_phase_B(qe)
	i = 1
	while i<=length(qe)
		qe[i] = helper_namedtuples_replacement(qe[i])
		clause = qe[i]

		# for l=length(clause.args):-1:1
		# 	if clause.args[l] isa LineNumberNode
		# 		deleteat!(clause.args,l)
		# 	end
		# end

		if i==1 && ismacro(clause, "@from")
			# Handle the case of a nested query. We are essentially detecting
			# here that the subquery starts with convert2nullable
			# and then we don't escape things.
			subq = clause.args[3].args[3]
			if isa(subq, Expr) && subq.head==:call && isa(subq.args[1],Expr) && subq.args[1].head==:. && subq.args[1].args[1]==:QueryOperators
				clause.args[3].args[3] = :(QueryOperators.query($(subq)))
			elseif !(isa(subq, Expr) && subq.head==:macrocall && isa(subq.args[1],Expr) && subq.args[1].head==:. && subq.args[1].args[1]==:QueryOperators)
				clause.args[3].args[3] = :(QueryOperators.query($(esc(subq))))
			end
		elseif ismacro(clause, "@from")
			clause.args[3].args[3] = :(QueryOperators.query($(clause.args[3].args[3])))
		elseif ismacro(clause, "@join")
			clause.args[3].args[3] = :(QueryOperators.query($(esc(clause.args[3].args[3]))))
		end
		i+=1
	end
end

function query_expression_translation_phase_1(qe)
	done = false
	while !done
		group_into_index = findfirst(i->ismacro(i, "@group", 6) && i.args[6]==:into, qe)
		select_into_index = findfirst(i->ismacro(i, "@select", 4) && i.args[4]==:into, qe)
		if length(qe)>=2 && ismacro(qe[1], "@from") && group_into_index!==nothing
			x = qe[group_into_index].args[7]

			sub_query = Expr(:block, qe[1:group_into_index]...)

			deleteat!(sub_query.args[end].args,7)
			deleteat!(sub_query.args[end].args,6)

			translate_query(sub_query)

			length(sub_query.args)==1 || throw(QueryException("@group ... into subquery too long", sub_query))

			qe[1] = :( @from $x in $(sub_query.args[1]) )
			deleteat!(qe, 2:group_into_index)
		elseif length(qe)>=2 && ismacro(qe[1], "@from") && select_into_index!==nothing
			x = qe[select_into_index].args[5]

			sub_query = Expr(:block, qe[1:select_into_index]...)
			deleteat!(sub_query.args[end].args,5)
			deleteat!(sub_query.args[end].args,4)

			translate_query(sub_query)

			length(sub_query.args)==1 || throw(QueryException("@select ... into subquery too long", sub_query))

			qe[1] = :( @from $x in $(sub_query.args[1]) )
			deleteat!(qe, 2:select_into_index)
		else
			done = true
		end
	end
end

function query_expression_translation_phase_3(qe)
	done = false
	while !done
		if length(qe)>=2 && ismacro(qe[1], "@from") && ismacro(qe[2], "@select") && qe[1].args[3].args[2]==qe[2].args[3]
			x = qe[1].args[3].args[2]
			e = qe[1].args[3].args[3]

			qe[1] = :( QueryOperators.@map($e,x->x) )
			deleteat!(qe,2)
		else
			done = true
		end
	end
end

function query_expression_translation_phase_4(qe)
	done = false
	while !done
		if length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@from") && ismacro(qe[3], "@select")
			x1 = qe[1].args[3].args[2]
			x2 = qe[2].args[3].args[2]
			e1 = qe[1].args[3].args[3]
			e2 = qe[2].args[3].args[3]
			v = qe[3].args[3]

			f_collection_selector = Expr(:->, x1, e2)
			f_result_selector = Expr(:->, Expr(:tuple,x1,x2), v)

			qe[1] = :( QueryOperators.@mapmany($e1, $(esc(f_collection_selector)), $(esc(f_result_selector))) )
			deleteat!(qe,3)
			deleteat!(qe,2)
		elseif length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@from")
			x1 = qe[1].args[3].args[2]
			x2 = qe[2].args[3].args[2]
			e1 = qe[1].args[3].args[3]
			e2 = qe[2].args[3].args[3]

			f_collection_selector = Expr(:->, x1, e2)
			f_result_selector = Expr(:->, Expr(:tuple,x1,x2), :(($x1=$x1,$x2=$x2)))

			qe[1].args[3].args[2] = Expr(:transparentidentifier, gensym(:t), x1, x2)
			qe[1].args[3].args[3] = :( QueryOperators.@mapmany($e1, $(esc(f_collection_selector)), $(esc(f_result_selector))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@let")
			x = qe[1].args[3].args[2]
			e = qe[1].args[3].args[3]
			y = qe[2].args[3].args[1]
			f = qe[2].args[3].args[2]

			f_selector = Expr(:->, x, :(($x=$x,$y=$f)))

			qe[1].args[3].args[2] = Expr(:transparentidentifier, gensym(:t), x, y)
			qe[1].args[3].args[3] = :( QueryOperators.@map($e,$(esc(f_selector))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@where")
			x = qe[1].args[3].args[2]
			e = qe[1].args[3].args[3]
			f = qe[2].args[3]

			f_condition = Expr(:->, x, f)

			qe[1].args[3].args[3] = :( QueryOperators.@filter($e,$(esc(f_condition))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@join", 6) && ismacro(qe[3], "@select")
			outer = qe[1].args[3].args[3]
			inner = qe[2].args[3].args[3]
			outer_range_var = qe[1].args[3].args[2]
			inner_range_var = qe[2].args[3].args[2]
			f_outer_key = Expr(:->, outer_range_var, qe[2].args[5])
			f_inner_key = Expr(:->, inner_range_var, qe[2].args[7])
			f_result = Expr(:->, Expr(:tuple,outer_range_var,inner_range_var), qe[3].args[3])
			qe[1] = :(
				QueryOperators.@join($outer, $inner, $(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result)))
				)

			deleteat!(qe,3)
			deleteat!(qe,2)
		elseif length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@join", 6)
			e1 = qe[1].args[3].args[3]
			e2 = qe[2].args[3].args[3]
			x1 = qe[1].args[3].args[2]
			x2 = qe[2].args[3].args[2]
			k1 = qe[2].args[5]
			k2 = qe[2].args[7]
			f_outer_key = Expr(:->, x1, k1)
			f_inner_key = Expr(:->, x2, k2)
			f_result = Expr(:->, Expr(:tuple,x1,x2), :(($x1=$x1,$x2=$x2)) )

			qe[1].args[3].args[2] = Expr(:transparentidentifier, gensym(:t), x1, x2)
			qe[1].args[3].args[3] = :( QueryOperators.@join($e1,$e2,$(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@join", 8) && ismacro(qe[3], "@select")
			e1 = qe[1].args[3].args[3]
			e2 = qe[2].args[3].args[3]
			x1 = qe[1].args[3].args[2]
			x2 = qe[2].args[3].args[2]
			k1 = qe[2].args[5]
			k2 = qe[2].args[7]
			g = qe[2].args[9]
			v = qe[3].args[3]
			f_outer_key = Expr(:->, x1, k1)
			f_inner_key = Expr(:->, x2, k2)
			f_result = Expr(:->, Expr(:tuple,x1,g), v)
			qe[1] = :( QueryOperators.@groupjoin($e1, $e2, $(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result))) )

			deleteat!(qe,3)
			deleteat!(qe,2)
		elseif length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@join", 8)
			e1 = qe[1].args[3].args[3]
			e2 = qe[2].args[3].args[3]
			x1 = qe[1].args[3].args[2]
			x2 = qe[2].args[3].args[2]
			k1 = qe[2].args[5]
			k2 = qe[2].args[7]
			g = qe[2].args[9]
			f_outer_key = Expr(:->, x1, k1)
			f_inner_key = Expr(:->, x2, k2)
			f_result = Expr(:->, Expr(:tuple,x1,g), :(($x1=$x1,$g=$g)) )

			qe[1].args[3].args[2] = Expr(:transparentidentifier, gensym(:t), x1, g)
			qe[1].args[3].args[3] = :( QueryOperators.@groupjoin($e1,$e2,$(esc(f_outer_key)), $(esc(f_inner_key)), $(esc(f_result))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && ismacro(qe[1], "@from") && ismacro(qe[2], "@orderby")
			e = qe[1].args[3].args[3]
			x = qe[1].args[3].args[2]
			ks = []
			if isa(qe[2].args[3], Expr) && qe[2].args[3].head==:tuple
				for sort_clause in qe[2].args[3].args
					if isa(sort_clause, Expr) && iscall(sort_clause, :descending)
						k = sort_clause.args[2]
						direction = :descending
					elseif isa(sort_clause, Expr) && iscall(sort_clause, :ascending)
						k = sort_clause.args[2]
						direction = :ascending
					else
						k = sort_clause
						direction = :ascending
					end
					push!(ks, (k, direction))
				end
			else
				if isa(qe[2].args[3], Expr) && iscall(qe[2].args[3], :descending)
					k = qe[2].args[3].args[2]
					direction = :descending
				elseif isa(qe[2].args[3], Expr) && iscall(qe[2].args[3], :ascending)
					k = qe[2].args[3].args[2]
					direction = :ascending
				else
					k = qe[2].args[3]
					direction = :ascending
				end
				push!(ks, (k, direction))
			end

			for (i,sort_clause) in enumerate(ks)
				f_condition = Expr(:->, x, sort_clause[1])

				if sort_clause[2]==:ascending
					if i==1
						qe[1].args[3].args[3] = :( QueryOperators.@orderby($e,$(esc(f_condition))) )
					else
						qe[1].args[3].args[3] = :( QueryOperators.@thenby($(qe[1].args[3].args[3]),$(esc(f_condition))) )
					end
				elseif sort_clause[2]==:descending
					if i==1
						qe[1].args[3].args[3] = :( QueryOperators.@orderby_descending($e,$(esc(f_condition))) )
					else
						qe[1].args[3].args[3] = :( QueryOperators.@thenby_descending($(qe[1].args[3].args[3]),$(esc(f_condition))) )
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
		if ismacro(clause, "@select")
			from_clause = qe[i-1]
			ismacro(from_clause, "@from") || throw(QueryException("Phase 5: expected @from before @select", from_clause))
			range_var = from_clause.args[3].args[2]
			source = from_clause.args[3].args[3]
			if clause.args[3]==range_var
				qe[i-1] = source
			else
				func_call = Expr(:->, range_var, clause.args[3])
				qe[i-1] = :( QueryOperators.@map($source, $(esc(func_call))) )
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
		if (@capture qe[1] @from rangevariable_ in source_) && (@capture qe[2] @group elementselector_ by keyselector_ args__)
			f_elementSelector = Expr(:->, rangevariable, keyselector)
			f_resultSelector = Expr(:->, rangevariable, elementselector)

			if elementselector == rangevariable
				qe[1] = :( QueryOperators.@groupby_simple($source, $(esc(f_elementSelector))) )
			else
				qe[1] = :( QueryOperators.@groupby($source, $(esc(f_elementSelector)), $(esc(f_resultSelector))) )
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
			if index_of_name!==nothing && !(ex.head==Symbol("=>") && i==1)
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
			throw(QueryException("identifier expected", child_ex))
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
		isa(clause, Expr) && find_and_translate_transparent_identifier(clause)
	end
end

function query_expression_translation_phase_D(qe)
	i = 1
	while i<=length(qe)
		clause = qe[i]
		if ismacro(clause, "@collect")
			previous_clause = qe[i-1]
			if length(clause.args)==2
				qe[i-1] = :( collect($previous_clause) )
			else
				qe[i-1] = :( collect($previous_clause, $(esc(clause.args[3]))) )
			end
			deleteat!(qe,i)
		else
			i+=1
		end
	end
end

function translate_query(body)
	debug_output = true

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
