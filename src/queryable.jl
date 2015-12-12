abstract Queryable{T,Provider}
abstract QueryProvider

immutable QueryableWhere{T,Provider} <: Queryable{T,Provider}
	source
	filter::Expr
end

function where{T,Provider}(source::Queryable{T,Provider}, filter::Expr)
    return QueryableWhere{T,Provider}(source, filter)
end

immutable QueryableSelect{T,Provider} <: Queryable{T,Provider}
    source
    f::Expr
end

function select{TS,Provider}(source::Queryable{TS,Provider}, f_expr::Expr)
	f = eval(f_expr)
    T = Base.return_types(f, (TS,))[1]
    return QueryableSelect{T,Provider}(source, f_expr)
end
