using SQLite

immutable QueryableSQLite{T,Provider} <: Queryable{T,Provider}
    db::SQLite.DB
    tablename::AbstractString
end

type QueryProviderSQLite <: QueryProvider
end

function query(db::SQLite.DB, tablename::AbstractString)
	columns = SQLite.columns(db, tablename)

    col_expressions = Array{Expr,1}()
    for i in 1:size(columns,1)
    	type_string = get(columns[i,:type])
    	eltype = type_string=="INTEGER" ? Int64 :
    	         type_string[1:8]=="NVARCHAR" ? String :
    	         type_string=="DATETIME" ? DateTime : error("Unsupported column type")
    	if get(columns[i,:notnull])==0
    		eltype=Nullable{eltype}
    	end
        push!(col_expressions, Expr(:(::), get(columns[i,:name]), Type(eltype)))
    end
    t_expr = NamedTuples.make_tuple(col_expressions)
    #t_expr.args[1] = t_expr.args[1].args[1]

    t2 = :(Query.QueryableSQLite{Float64,Query.QueryProviderSQLite})
    t2.args[2] = t_expr

    eval(NamedTuples, :(import Query))
    t = eval(NamedTuples, t2)

    q = t(db, tablename)

    return q
end

# This must be a contender for most hacky, unstable function ever...
function collect(::Type{QueryProviderSQLite}, source)
    query_elements = []
    current_source = source
    while !isa(current_source, QueryableSQLite)
        push!(query_elements, current_source)
        current_source = current_source.source
    end

    where_count = count(i->isa(i,QueryableWhere),query_elements)
    where_clause = ""
    if where_count==1
    	where_o = filter(i->isa(i,QueryableWhere),query_elements)[1]
    	filter_el = where_o.filter
    	if filter_el.head!=:(->)
    		error()
    	end
    	name_of_index_var = filter_el.args[1]
    	operator = where_o.filter.args[2].args[1]
    	if operator!=:(==)
    		error()
    	end
    	if where_o.filter.args[2].args[2].head!=:(.) || where_o.filter.args[2].args[2].args[1]!=name_of_index_var
    		error()
    	end
    	left_hand_name = string(where_o.filter.args[2].args[2].args[2].value)
    	right_hand_value = where_o.filter.args[2].args[3]
    	where_clause = "WHERE $left_hand_name=\"$right_hand_value\""
    elseif where_count>1
    	error("At most one where clause is supported.")
    end

    select_count = count(i->isa(i,QueryableSelect),query_elements)
    select_clause = "*"
    if select_count==1
		select_o = filter(i->isa(i,QueryableSelect),query_elements)[1]
		f_el = select_o.f
		# Get columns we need
		col_names = Array(String,0)
		for i in 2:length(f_el.args[2].args)
			col_name = string(f_el.args[2].args[i].args[2].args[2].value)
			desired_name = string(f_el.args[2].args[i].args[1])
			push!(col_names, "$col_name AS $desired_name")
		end
		select_clause = join(col_names, ", ")
    elseif select_count>1
    	error("At most one select clause is supported.")
    end


    root = current_source
    sql_query = "SELECT $select_clause FROM $(root.tablename) $where_clause"
    println(sql_query)
    df = SQLite.query(root.db, sql_query)

    collect(query(df))
end
