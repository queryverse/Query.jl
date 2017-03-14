ChainRecursive.@chain begin

add_quote(e) = [e, Meta.quot(e) ]

quoted_arguments(f, sources::Tuple, arguments...) = begin
	add_quote.(arguments)
	vcat(it...)
	:( $f( $(sources...), $(it...) ) )
end

quoted_arguments(f, source, arguments...) = begin
	add_quote.(arguments)
	vcat(it...)
	:( $f( $source, $(it...) ) )
end

macro orderby_internal(source, f)
	quoted_arguments(orderby, source, f)
	esc(it)
end

macro orderby_descending_internal(source, f)
	quoted_arguments(orderby_descending, source, f)
	esc(it)
end

macro thenby_internal(source, f)
	quoted_arguments(thenby, source, f)
	esc(it)
end

macro thenby_descending_internal(source, f)
	quoted_arguments(thenby_descending, source, f)
	esc(it)
end

macro join_internal(outerSource, innerSource, outerKey, innerKey, result)
	quoted_arguments(join, (outerSource, innerSource), outerKey, innerKey, result)
	esc(it)
end

macro group_join_internal(outerSource, innerSource, outerKey, innerKey, result)
	quoted_arguments(group_join, (outerSource, innerSource), outerKey, innerKey, result)
	esc(it)
end

macro select_many_internal(source, collection, result)
	quoted_arguments(select_many, source, collection, result)
	esc(it)
end

macro group_by_internal(source, element, result)
	quoted_arguments(group_by, source, element, result)
	esc(it)
end

macro group_by_internal_simple(source, element)
	quoted_arguments(group_by, source, element)
	esc(it)
end

macro where_internal(source, f)
    quoted_arguments(where, source, f)
	esc(it)
end

macro where(source, f)
	:(Query.query($source))
    quoted_arguments(where, it, f)
	esc(it)
end

macro select_internal(source, f)
    quoted_arguments(select, source, f)
	esc(it)
end

macro select(source, f)
	:(Query.query($source))
    quoted_arguments(select, it, f)
	esc(it)
end

macro from(range::Expr, body::Expr)
	@assert body.head == :block
	@assert MacroTools.@capture range iterator_ in source_
	filter(body.args) do arg
		arg.head != :line
	end
	[:( @from $range), it...]
	translate_query(it)
	esc(it)
end

end
