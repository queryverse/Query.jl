immutable QueryableSelect{T,Provider} <: Queryable{T,Provider}
    source
    f::Expr
end

function select{TS,Provider}(source::Queryable{TS,Provider}, f::Function, f_expr::Expr)
    T = Base.return_types(f, (TS,))[1]
    return QueryableSelect{T,Provider}(source, f_expr)
end
