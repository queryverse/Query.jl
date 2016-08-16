using Query
using DataFrames
using TypedTables
using NamedTuples
using Base.Test

immutable Person
    Name::String
    Friends::Vector{String}
end

@testset begin

source_df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

q = @from i in source_df begin
    @where i.age>30. && i.children > 2
    @select @NT(Name=>lowercase(i.name))
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,1)
@test q[1,:Name]=="sally"

source_dict = Dict("John"=>34., "Sally"=>56.)

q = @from i in source_dict begin
    @where i.second>36.
    @select @NT(Name=>lowercase(i.first))
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,1)
@test q[1,:Name]=="sally"

q = @from i in source_dict begin
    @where i.second>36.
    @select lowercase(i.first)
    @collect
end

@test isa(q, Array{String,1})
@test length(q)==1
@test q[1]=="sally"

source_array = Array(Person,0)
push!(source_array, Person("John", ["Sally", "Miles", "Frank"]))
push!(source_array, Person("Sally", ["Don", "Martin"]))

q = @from i in source_array begin
    @where length(i.Friends) > 2
    @select @NT( Name=>i.Name, Friendcount=>length(i.Friends))
    @collect
end

@test isa(q,Array{NamedTuples._NT_NameFriendcount{String,Int64},1})
@test length(q)==1
@test q[1].Name=="John"
@test q[1].Friendcount==3

q = @from i in source_array begin
    @where length(i.Friends) > 2
    @select @NT( Name=>i.Name, Friendcount=>length(i.Friends))
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,2)
@test q[1,:Name]=="John"
@test q[1,:Friendcount]==3

source_typedtable = @Table(name=Nullable{String}["John", "Sally", "Kirk"], age=Nullable{Float64}[23., 42., 59.], children=Nullable{Int64}[3,5,2])

q = @from i in source_typedtable begin
    @where get(i.age)>30. && get(i.children) >2
    @select @NT(Name=>lowercase(get(i.name)))
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,1)
@test q[1,:Name]=="sally"

source_df2 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
source_typedtable2 = @Table(c=[2.,4.,2.], d=["John", "Jim","Sally"])

q = @from i in source_df2 begin
    @join j in source_typedtable2 on i.a equals convert(Int,j.c)
    @select @NT(a=>i.a,b=>i.b,c=>j.c,d=>j.d,e=>"Name: $(j.d)")
    @collect DataFrame
end

@test isa(q,DataFrame)
@test size(q)==(2,5)
@test q[1,:a]==2
@test q[1,:b]==2.
@test q[1,:c]==2.
@test q[1,:d]=="John"
@test q[1,:e]=="Name: John"
@test q[2,:a]==2
@test q[2,:b]==2.
@test q[2,:c]==2.
@test q[2,:d]=="Sally"
@test q[2,:e]=="Name: Sally"

q = @from i in source_df begin
    @let count = length(i.name)
    @let kids_per_year = i.children / i.age
    @where count > 4
    @select @NT(Name=>i.name, Count=>count, KidsPerYear=>kids_per_year)
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,3)
@test q[1,:Name]=="Sally"
@test q[1,:Count]==5
@test q[1,:KidsPerYear]≈0.119047619047

q = @from i in source_df begin
    @orderby i.age
    @select lowercase(i.name)
    @collect
end

@test isa(q, Array{String,1})
@test length(q)==3
@test q==["john", "sally", "kirk"]

q = @from i in source_df begin
    @orderby descending(i.age)
    @select lowercase(i.name)
    @collect
end

@test isa(q, Array{String,1})
@test length(q)==3
@test q==["kirk", "sally", "john"]

q = @from i in source_df begin
    @orderby ascending(i.age)
    @select lowercase(i.name)
    @collect
end

@test isa(q, Array{String,1})
@test length(q)==3
@test q==["john", "sally", "kirk"]

end

@testset "Examples" begin
    include("../example/01-DataFrame.jl")
    include("../example/02-Dict.jl")
    include("../example/03-Array.jl")
    #include("../example/04-SQLite.jl")
    include("../example/05-Nullable.jl")
    include("../example/06-Generator.jl")
    include("../example/07-typedtables.jl")
    include("../example/08-join.jl")
    include("../example/09-let.jl")
    include("../example/10-orderby.jl")
end

@testset "Doctests" begin
    include("../docs/make.jl")
end
