function Query.select(source::JuliaDB.DTable, f, f_expr)
           map(f, source)
       end

        function Query.where(source::JuliaDB.DTable, f, f_exp)
           filter(f, source)
       end

       Query.query(source::JuliaDB.DTable) = source