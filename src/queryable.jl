abstract Queryable{T,Provider}
abstract QueryProvider

immutable QueryableWhere{T,Provider} <: Queryable{T,Provider}
	source
	filter::Expr
end

function where{T,Provider}(source::Queryable{T,Provider}, filter::Function, filter_expr::Expr)
    return QueryableWhere{T,Provider}(source, filter_expr)
end

immutable QueryableSelect{T,Provider} <: Queryable{T,Provider}
    source
    f::Expr
end

function select{TS,Provider}(source::Queryable{TS,Provider}, f::Function, f_expr::Expr)
    T = Base.return_types(f, (TS,))[1]
    return QueryableSelect{T,Provider}(source, f_expr)
end
