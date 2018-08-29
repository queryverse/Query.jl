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
		# macrotools doesn't like underscores
		if ismacro(clause, Symbol("@left_outer_join")) && @capture clause @amacro_ argument1_ in body1_ args__
			clause.args[1] = Symbol("@join")
			temp_name = gensym()
			push!(clause.args, :into)
			push!(clause.args, temp_name)
			nested_from = :(@from $argument1 in QueryOperators.default_if_empty($temp_name))
			insert!(qe,i+1,nested_from)
		end
		i+=1
	end

	for i in eachindex(qe)
		qe[i] = helper_replace_field_extraction_syntax(qe[i])
	end
end

function query_bodies!(qe)
	i = 1
	while i<=length(qe)
		qe[i] = helper_namedtuples_replacement(qe[i])
		clause = qe[i]

		# for l=length(clause.args):-1:1
		# 	if clause.args[l] isa LineNumberNode
		# 		deleteat!(clause.args,l)
		# 	end
		# end

		if i==1 && @capture clause @from argument1_ in body1_
			# Handle the case of a nested query. We are essentially detecting
			# here that the subquery starts with convert2nullable
			# and then we don't escape things.
			if @capture body1 Query.something_(args__)
				clause.args[3].args[3] = :(QueryOperators.query($(body1)))
			elseif !(@capture body1 @QueryOperators.something_ args__)
				clause.args[3].args[3] = :(QueryOperators.query($(esc(body1))))
			end
		elseif @capture clause @from argument1_ in body1_
			clause.args[3].args[3] = :(QueryOperators.query($body1))
		elseif @capture clause @join argument1_ in body1_ args__
			clause.args[3].args[3] = :(QueryOperators.query($(esc(body1))))
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

function remove_trivial_selects!(qe)
	done = false
	while !done
		if length(qe)>=2 &&
		    (@capture qe[1] @from argument1_ in body1_) &&
		    (@capture qe[2] @select body2_) &&
		    body2 == body1

		    qe[1] = :( QueryOperators.@map($body1,identity) )
			deleteat!(qe,2)
		else
			done = true
		end
	end
end

function attribute_and_direction(sort_clause)
	if @capture sort_clause descending(attribute_)
		attribute, :descending
	elseif @capture sort_clause ascending(attribute_)
		attribute, :ascending
	else
		sort_clause, :ascending
	end
end

function from_let_where_join_orderby!(qe)
	done = false
	while !done
		if length(qe)>=3 && (@capture qe[1] @from argument1_ in body1_) && (@capture qe[2] @from argument2_ in body2_)
			function1 = anon(qe[2], argument1, body2)
			function3_arguments = Expr(:tuple,argument1,argument2)
			if (@capture qe[3] @select body3_)
				function3 = anon(qe[3], function3_arguments, body3)

				qe[1] = :( QueryOperators.@mapmany($body1, $(esc(function1)), $(esc(function3))) )
				deleteat!(qe,3)
			else
				function3 = anon(qe[3], function3_arguments, :(($argument1=$argument1,$argument2=$argument2)))

				qe[1].args[3].args[2] = Expr(:transparentidentifier, gensym(:t), argument1, argument2)
				qe[1].args[3].args[3] = :( QueryOperators.@mapmany($body1, $(esc(function1)), $(esc(function3))) )
			end
			deleteat!(qe,2)
		elseif length(qe)>=3 && (@capture qe[1] @from argument1_ in body1_) && (@capture qe[2] @let argument2_ = valueselector_)
			function1 = anon(qe[2], argument1, :(($argument1=$argument1,$argument2=$valueselector)))

			qe[1].args[3].args[2] = Expr(:transparentidentifier, gensym(:t), argument1, argument2)
			qe[1].args[3].args[3] = :( QueryOperators.@map($body1,$(esc(function1))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && (@capture qe[1] @from argument1_ in body1_) && (@capture qe[2] @where body2_)
			function1 = anon(qe[2], argument1, body2)

			qe[1].args[3].args[3] = :( QueryOperators.@filter($body1,$(esc(function1))) )
			deleteat!(qe,2)
		elseif length(qe)>=3 && (@capture qe[1] @from argument1_ in body1_) && (@capture qe[2] @join argument2_ in body2_ on leftkey_ equals rightkey_)
			function1 = anon(qe[2], argument1, leftkey)
			function2 = anon(qe[2], argument2, rightkey)
			function3_arguments = Expr(:tuple,argument1,argument2)
			if (@capture qe[3] @select body3_)
				function3 = anon(qe[3], function3_arguments, body3)
				qe[1] = :(
					QueryOperators.@join($body1, $body2, $(esc(function1)), $(esc(function2)), $(esc(function3)))
					)

				deleteat!(qe,3)
			else
				function3 = anon(qe[2], function3_arguments, :(($argument1=$argument1,$argument2=$argument2)) )

				qe[1].args[3].args[2] = Expr(:transparentidentifier, gensym(:t), argument1, argument2)
				qe[1].args[3].args[3] = :( QueryOperators.@join($body1,$body2,$(esc(function1)), $(esc(function2)), $(esc(function3))) )

			end
			deleteat!(qe,2)
		elseif length(qe)>=3 && (@capture qe[1] @from argument1_ in body1_) && (@capture qe[2] @join argument2_ in body2_ on leftkey_ equals rightkey_ into groupvariable_)
			function1 = anon(qe[2], argument1, leftkey)
			function2 = anon(qe[2], argument2, rightkey)
			function3_arguments = Expr(:tuple,argument1,groupvariable)
			if (@capture qe[3] @select body3_)
				function3 = anon(qe[3], function3_arguments, body3)
				qe[1] = :( QueryOperators.@groupjoin($body1, $body2, $(esc(function1)), $(esc(function2)), $(esc(function3))) )

				deleteat!(qe,3)
			else
				function3 = anon(qe[2], function3_arguments, :(($argument1=$argument1,$groupvariable=$groupvariable)) )

				qe[1].args[3].args[2] = Expr(:transparentidentifier, gensym(:t), argument1, groupvariable)
				qe[1].args[3].args[3] = :( QueryOperators.@groupjoin($body1,$body2,$(esc(function1)), $(esc(function2)), $(esc(function3))) )
			end
			deleteat!(qe,2)
		elseif length(qe)>=3 && (@capture qe[1] @from argument1_ in body1_) && (@capture qe[2] @orderby sortclause_)
			ks = []
			if @capture sortclause (sortclauses__,)
				for sort_clause in sortclauses
					push!(ks, attribute_and_direction(sort_clause))
				end
			else
				push!(ks, attribute_and_direction(sortclause))
			end

			for (i,sort_clause) in enumerate(ks)
				function1 = anon(qe[2], argument1, sort_clause[1])

				if sort_clause[2]==:ascending
					if i==1
						qe[1].args[3].args[3] = :( QueryOperators.@orderby($body1,$(esc(function1))) )
					else
						qe[1].args[3].args[3] = :( QueryOperators.@thenby($body1,$(esc(function1))) )
					end
				elseif sort_clause[2]==:descending
					if i==1
						qe[1].args[3].args[3] = :( QueryOperators.@orderby_descending($body1,$(esc(function1))) )
					else
						qe[1].args[3].args[3] = :( QueryOperators.@thenby_descending($(qe[1].args[3].args[3]),$(esc(function1))) )
					end
				end
			end
			deleteat!(qe,2)
		else
			done = true
		end
	end
end

function selects!(qe)
	i = 1
	while i<=length(qe)
		if @capture qe[i] @select body2_
			from_clause = qe[i-1]
			if @capture from_clause @from argument1_ in body1_
				if body2==argument1
					qe[i-1] = body1
				else
					func_call = Expr(:->, argument1, body2)
					qe[i-1] = :( QueryOperators.@map($body1, $(esc(func_call))) )
				end
				deleteat!(qe,i)
		    else
				throw(QueryException("Phase 5: expected @from before @select", from_clause))
			end
		else
			i+=1
		end
	end
end

function groups!(qe)
	done = false
	while !done
		if (@capture qe[1] @from argument1_ in body1_) && (@capture qe[2] @group elementselector_ by keyselector_ args__)
			f_elementSelector = Expr(:->, argument1, keyselector)
			f_resultSelector = Expr(:->, argument1, elementselector)

			if elementselector == argument1
				qe[1] = :( QueryOperators.@groupby_simple($body1, $(esc(f_elementSelector))) )
			else
				qe[1] = :( QueryOperators.@groupby($body1, $(esc(f_elementSelector)), $(esc(f_resultSelector))) )
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

function transparents!(qe)
	for clause in qe
		isa(clause, Expr) && find_and_translate_transparent_identifier(clause)
	end
end

function sinks!(qe)
	i = 1
	while i<=length(qe)
		clause = qe[i]
		if @capture clause @collect args__
			previous_clause = qe[i-1]
			if @capture clause @collect sink_
			    qe[i-1] = :( collect($previous_clause, $(esc(sink))) )
			elseif @capture clause @collect
			    qe[i-1] = :( collect($previous_clause) )
			end
			deleteat!(qe,i)
		else
			i+=1
		end
	end
end

function translate_query(body1)
	debug_output = true

	debug_output && println("AT START")
	debug_output && println(body1)

	query_expression_translation_phase_1(body1.args)
	debug_output && println("AFTER 1")
	debug_output && println(body1)

	query_expression_translation_phase_A(body1.args)
	debug_output && println("AFTER A")
	debug_output && println(body1)

	query_bodies!(body1.args)
	debug_output && println("AFTER B")
	debug_output && println(body1)

	remove_trivial_selects!(body1.args)
	debug_output && println("AFTER 3")
	debug_output && println(body1)

	from_let_where_join_orderby!(body1.args)
	debug_output && println("AFTER 4")
	debug_output && println(body1)

	selects!(body1.args)
	debug_output && println("AFTER 5")
	debug_output && println(body1)

	groups!(body1.args)
	debug_output && println("AFTER 6")
	debug_output && println(body1)

	transparents!(body1.args)
	debug_output && println("AFTER 7")
	debug_output && println(body1)

	sinks!(body1.args)
	debug_output && println("AFTER D")
	debug_output && println(body1)
end
