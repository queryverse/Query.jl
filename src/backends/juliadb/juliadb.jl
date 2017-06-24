@require JuliaDB begin

function select(source::JuliaDB.DTable, f, f_expr)
    map(f, source)
end

function where(source::JuliaDB.DTable, filter::Function, filter_expr::Expr)
    JuliaDB.filter(filter, source)
end

query(source::JuliaDB.DTable) = source

end
