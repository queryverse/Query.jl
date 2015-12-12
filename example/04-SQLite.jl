using SQLite
using LINQ
using DataFrames
using NamedTuples
using Lazy

db = SQLite.DB(joinpath(Pkg.dir("SQLite"), "test", "Chinook_Sqlite.sqlite"))

result = @from i in query(db, "Employee") begin
         @where i.ReportsTo==2
         @select @NT(Name=>i.LastName, Adr=>i.Address)
end collect(DataFrame)

println(result)


result = @from i in query(db, "Employee") begin
         @where i.ReportsTo==2
         @select @NT(Name=>i.LastName, Adr=>i.Address)
end collect()

println(result)

# This is an exmaple where the first part gets executed in the DB
# And the second part uses the Enumerable iterator part of LINQ

result = @from i in result begin
         @select @NT(Mangled=>i.Name * i.Adr)
end collect(DataFrame)

println(result)
