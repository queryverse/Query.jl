immutable QueryableWhere{T,Provider} <: Queryable{T,Provider}
	source
	filter::Expr
end

function where{T,Provider}(source::Queryable{T,Provider}, filter::Function, filter_expr::Expr)
    return QueryableWhere{T,Provider}(source, filter_expr)
end
