using SQLite
using Query
using DataFrames

db = SQLite.DB(joinpath(Pkg.dir("SQLite"), "test", "Chinook_Sqlite.sqlite"))

result = @from i in table(db, "Employee") begin
         @where i.ReportsTo==2
         @select {Name=i.LastName, Adr=i.Address}
         @collect DataFrame
end

println(result)


result = @from i in table(db, "Employee") begin
         @where i.ReportsTo==2
         @select {Name=i.LastName, Adr=i.Address}
         @collect
end

println(result)

# This is an exmaple where the first part gets executed in the DB
# And the second part uses the Enumerable iterator part of Query.jl

result = @from i in result begin
         @select {Mangled=i.Name .* i.Adr}
         @collect DataFrame
end

println(result)

# This examples uses SQLite just like any other DataStreams source.

results = @from i in SQLite.Source(db,"SELECT * FROM Employee") begin
    @where i.ReportsTo==2
    @select {Name=i.LastName, Adr=i.Address}
    @collect DataFrame
end

println(result)
