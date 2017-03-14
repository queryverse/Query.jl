ChainRecursive.@chain begin

# useful to avoid adding extra line number info
anon(a, b) = Expr(:->, a, b)

separate_left_outer_join(e) =
	# odd syntax because macrotools has trouble with internal _s
	if (MacroTools.@capture e @verb_ iterator_ in source_ args__) && verb == Symbol("@left_outer_join")
		gensym()
		[ :(@join $iterator in $source $(args...) into $it),
		  :(@from $iterator in $default_if_empty($it) ) ]
	else
		e
	end

query_sources_and_named_tuple_select(e, i) =
    if i == 1 && MacroTools.@capture e :(@from iterator_ in (Query.@verb_ inner_args__) )
        e
    else
        MacroTools.@match e begin
            (@from iterator_ in source_) =>
                :(@from $iterator in $query($source) )
            (@join iterator_ in source_ args__) =>
                :(@join $iterator in $query($source) $(args...) )
            (@select {args__} ) => begin
				map(args) do arg
					MacroTools.@match arg begin
					    (a_ => b_) => :($a => $b)
					    (a_ = b_) => :($a => $b)
					    a_.b_ => :($b => $a.$b)
					    s_Symbol => :($s => $s)
					    a_ => error("Select arguments must be either symbols, pairs, dots, or assignments")
				   end
			   end
				:(@select $NamedTuples.@NT $(it...) )
			end
            a_ => a
        end
    end

recurrable(es, i) = begin
    length(es)
    i <= it && it >= 2 && MacroTools.@capture es[1] @from args__
end

recur_subquery(es, i, e, into) = begin
	es[1:i-1]
	vcat(it, e)
	translate_query(it)
	:(@from $into in $it)
	vcat(it, es[i+1:end])
	translate_subqueries(it)
end

translate_subqueries(es, i = 1) = if recurrable(es, i)
	MacroTools.@match es[i] begin
		(@group element_ by key_ into iterator_) =>
			recur_subquery(es, i, :(@group $element by $key), iterator)
		(@select selection_ into iterator_) =>
			recur_subquery(es, i, :(@select $selection), iterator)
		a_ => translate_subqueries(es, i + 1)
	end
else
	es
end

merge_common_from_select(es) =
	if ( MacroTools.@capture es[1] (@from iterator_ in source_) ) &&
		    ( MacroTools.@capture es[2] (@select selection_) ) &&
			iterator == selection
		anon(:x, :x)
		:(Query.@select_internal $source $it)
		[it, es[3:end]...]
	    merge_common_from_select(it)
	else
		es
	end

two_iterators(source, outerIterator, innerIterator) = begin
	gensym(:t)
	Expr(:transparentidentifier, it, outerIterator, innerIterator)
	:(@from $it in $source)
end

macro_call(symbol, args...) = begin
	GlobalRef(Query, symbol)
	Expr(:macrocall, it, args...)
end

order_recur(source, iterator, clauses, match_results) = begin
	order_macro, attribute = match_results
	anon(iterator, attribute)
	macro_call(order_macro, source, it)
	recur_sort_clause(it, iterator, clauses...)
end

sort_clause(source, iterator, clause, clauses...) = begin
	 MacroTools.@match clause begin
		descending(attribute_) => Symbol("@orderby_descending_internal"), attribute
		ascending(attribute_) => Symbol("@orderby_internal"), attribute
		attribute_ => Symbol("@orderby_internal"), attribute
	end
	order_recur(source, iterator, clauses, it)
end

recur_sort_clause(source, iterator) = source
recur_sort_clause(source, iterator, clause, clauses...) = begin
	order_macro, attribute = MacroTools.@match clause begin
		descending(attribute_) => Symbol("@thenby_descending_internal"), attribute
		ascending(attribute_) => Symbol("@thenby_internal"), attribute
		attribute_ => Symbol("@thenby_internal"), attribute
	end
	order_recur(source, iterator, clauses, it)
end

with_user_selection(f, es, outerIterator, innerIterator) = begin
	user_selection = MacroTools.@capture es[3] (@select selection_)
	if selection == nothing
		selection = :( $NamedTuples.@NT $outerIterator => $outerIterator $innerIterator => $innerIterator)
	end
	inner_query = begin
		Expr(:tuple, outerIterator, innerIterator)
		anon(it, selection)
		f(it)
	end
	if user_selection
		3, inner_query
	else
		2, two_iterators(inner_query, outerIterator, innerIterator)
	end
end

multiline_transformations(es) = if length(es) >= 3 && MacroTools.@capture es[1] @from outerIterator_ in outerSource_
	number_of_lines_used, compaction = MacroTools.@match es[2] begin
		(@from innerIterator_ in innerSource_) =>
			with_user_selection(es, outerIterator, innerIterator) do result
				anon(outerIterator, innerSource)
				:(Query.@select_many_internal $outerSource $it $result)
			end
		(@let innerIterator_ = innerSource_) => begin
			:( $NamedTuples.@NT $outerIterator => $outerIterator $innerIterator => $innerSource)
			anon(outerIterator, it)
			:(Query.@select_internal $outerSource $it)
			two_iterators(it, outerIterator, innerIterator)
			2, it
		end
		(@where condition_) => begin
			anon(outerIterator, condition)
			:(Query.@where_internal $outerSource $it)
			:(@from $outerIterator in $it)
			2, it
		end
		(@join innerIterator_ in innerSource_ on outerKey_ equals innerKey_ into group_) => begin
			with_user_selection(es, outerIterator, group) do selection
				:(Query.@group_join_internal $outerSource $innerSource $(anon(outerIterator, outerKey)) $(anon(innerIterator, innerKey)) $selection)
			end
		end
		(@join innerIterator_ in innerSource_ on outerKey_ equals innerKey_) => begin
			with_user_selection(es, outerIterator, innerIterator) do selection
				:(Query.@join_internal $outerSource $innerSource $(anon(outerIterator, outerKey)) $(anon(innerIterator, innerKey)) $selection)
			end
		end
		(@orderby (attributes__,) ) => begin
			sort_clause(outerSource, outerIterator, attributes...)
			:(@from $outerIterator in $it)
			2, it
		end
		(@orderby attribute_) => begin
			sort_clause(outerSource, outerIterator, attribute)
			:(@from $outerIterator in $it)
			2, it
		end
		a_ => (0, nothing)
	end
	if number_of_lines_used > 0
		[compaction, es[number_of_lines_used + 1 : end]...] |> multiline_transformations
	else
		es
	end
else
	es
end

handle_remaining_selects(es, i = 2) =
	if i <= length(es) && MacroTools.@capture es[i] @select selection_
		if MacroTools.@capture es[i - 1] @from iterator_ in source_
			if iterator == selection
				source
			else
				anon(iterator, selection)
				:(Query.@select_internal $source $it)
			end
			handle_remaining_selects( [es[1:i-2]..., it, es[i+1:end]...], i)
		else
			error("error in handle_remaining_selects")
		end
	else
		es
	end

handle_groups(es) =
	if length(es) >= 2 && (MacroTools.@capture es[1] @from iterator_ in source_) && MacroTools.@capture es[2] @group element_ by key_
		if iterator == element
			anon(iterator, key)
			:(Query.@group_by_internal_simple $source $it)
		else
			:(Query.@group_by_internal $source $(anon(iterator, key)) $(anon(iterator, element)) )
		end
		[it, es[3:end]...]
	else
		es
	end

map_expression(f, e::Expr) = begin
	map(f, e.args)
	Expr(e.head, it...)
end
map_expression(f, e) = e

find_names_to_put_in_scope!(a, name_dict) = a
find_names_to_put_in_scope!(e::Expr, name_dict) = begin
	if e.head == :transparentidentifier
		first_arg = e.args[1]
		foreach(e.args[2:end]) do arg
			if MacroTools.isexpr(arg, :transparentidentifier)
				for (key, value) in find_names_to_put_in_scope!(arg, Dict())
					name_dict[key] = :($first_arg.$value)
				end
			else MacroTools.@match arg begin
				a_.b_ => name_dict[b] = first_arg
				s_Symbol => name_dict[s] = first_arg
				a_ => error("Arguments to a transparent identifier must be dots, symbols, or transparent identifiers")
			end end
		end
	end
	name_dict
end

let_transparent_identifier(e, name_dict) =
	if length(name_dict) > 0
		( :($key = $value.$key) for (key, value) in name_dict )
		Expr(:let, e, it...)
	else
		e
	end

handle_transparent_identifiers(a) = a
handle_transparent_identifiers(e::Expr) =
	if e.head == :transparentidentifier
		e.args[1]
	else
		name_dict = Dict()
	    MacroTools.@match e begin
	        ( (inputs__,) -> output_) => begin
				foreach(inputs) do input
					find_names_to_put_in_scope!(input, name_dict)
				end
				let_transparent_identifier(output, name_dict)
				anon(Expr(:tuple, inputs...), it)
	        end
	        (input_ -> output_) => begin
				find_names_to_put_in_scope!(input, name_dict)
				let_transparent_identifier(output, name_dict)
				anon(input, it)
	        end
			a_ => a
	    end
		map_expression(handle_transparent_identifiers, it)
	end

collect_query(es, i = 2) =
	if i <= length(es)
		if MacroTools.@capture es[i] (@collect args__)
			:( $collect($(es[i-1]), $(args...) ) )
			[es[1:i-2]..., it, es[i+1:end]...]
			collect_query(it, i)
		else
			collect_query(es, i + 1)
		end
	else
		es
	end

debug_print(es, debug, message) = begin
	if debug
		println(message)
		Expr(:block, es...)
		println(it)
	end
	es
end

translate_query(es, debug = false) = begin
	debug_print(es, debug, "at start")
	separate_left_outer_join.(it)
	vcat(it...)
	debug_print(it, debug, "after separate_left_outer_join")
	query_sources_and_named_tuple_select.(it, 1:length(it))
	debug_print(it, debug, "after query_sources_and_named_tuple_select")
	translate_subqueries(it)
	debug_print(it, debug, "after translate_subqueries")
	merge_common_from_select(it)
	debug_print(it, debug, "after merge_common_from_select")
	multiline_transformations(it)
	debug_print(it, debug, "after multiline_transformations")
	handle_remaining_selects(it)
	debug_print(it, debug, "after handle_remaining_selects")
	handle_groups(it)
	debug_print(it, debug, "after handle_groups")
	handle_transparent_identifiers.(it)
	debug_print(it, debug, "after handle_transparent_identifiers")
	collect_query(it)
	results = debug_print(it, debug, "after collect query")
	@assert length(results) == 1
	results[1]
end

end
