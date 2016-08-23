using Query
using DataFrames
using TypedTables
using NamedTuples
using DataStreams
using CSV
using NDSparseData
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

@test isa(q,Array{NamedTuples._NT_NameFriendcount{String,Int},1})
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

source_typedtable = @Table(name=Nullable{String}["John", "Sally", "Kirk"], age=Nullable{Float64}[23., 42., 59.], children=Nullable{Int}[3,5,2])

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

source_nestedsort = [(4,3),(4,3),(1,2),(1,1)]
q = @from i in source_nestedsort begin
    @orderby i[1], descending(i[2])
    @select i
    @collect
end

@test isa(q, Array{Tuple{Int,Int},1})
@test length(q)==4
@test q==[(1,2),(1,1),(4,3),(4,3)]


# We need to use a typed const here, otherwise type inference stands no chance
const closure_var_1::Int = 1

q = @from i in source_df begin
    @let k = i.children + closure_var_1
    @join j in source_df2 on i.children*closure_var_1 equals j.a*closure_var_1
    @where i.age>closure_var_1
    @orderby i.age*closure_var_1
    @select i.children + closure_var_1
    @collect
end

@test isa(q, Array{Int,1})
@test length(q)==2
@test q[1]==4
@test q[2]==3

q = @from i in [5,4,4,6,1] begin
    @orderby i
    @select i
    @collect
end

@test isa(q,Array{Int,1})
@test length(q)==5
@test q==[1,4,4,5,6]

q = @from i in [5,4,4,6,1] begin
    @orderby descending(i)
    @select i
    @collect
end

@test isa(q,Array{Int,1})
@test length(q)==5
@test q==[6,5,4,4,1]

# Test phase 3 query translation

q = @from i in source_array begin
    @select i
    @collect
end

@test isa(q,Array{Person,1})
@test length(q)==2
@test q[1].Name=="John"
@test q[1].Friends==["Sally", "Miles", "Frank"]
@test q[2].Name=="Sally"
@test q[2].Friends==["Don", "Martin"]

q = @from i in CSV.Source("data.csv") begin
    @where get(i.Children) > 2
    @select get(i.Name)
    @collect
end

@test isa(q,Array{String,1})
@test length(q)==2
@test q[1]=="John"
@test q[2]=="Kirk"

source_ndsparsearray1 = NDSparse([fill("New York",3); fill("Boston",3)],
                            repmat(Date(2016,7,6):Date(2016,7,8), 2),
                            [91,89,91,95,83,76])

q = @from i in source_ndsparsearray1 begin
    @where i.index[1]=="Boston"
    @select i.value
    @collect
end

@test isa(q, Array{Int,1})
@test length(q)==3
@test q==[95,83,76]

source_ndsparsearray2 = NDSparse(Columns(city = [fill("New York",3); fill("Boston",3)],
                            date = repmat(Date(2016,7,6):Date(2016,7,8), 2)),
                            [91,89,91,95,83,76])

q = @from i in source_ndsparsearray2 begin
    @where i.index.city=="New York"
    @select i.value
    @collect
end

@test isa(q, Array{Int,1})
@test length(q)==3
@test q==[91,89,91]

q = @from i in source_df begin
    @from j in source_df2
    @select @NT(Name=>i.name,Age=>i.age,Children=>i.children,A=>j.a,B=>j.b)
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(9,5)
@test q[:Name]==["John","John","John","Sally","Sally","Sally","Kirk","Kirk","Kirk"]
@test q[:Age]==[23.,23.,23.,42.,42.,42.,59.,59.,59.]
@test q[:Children]==[3,3,3,5,5,5,2,2,2]
@test q[:A]==[1,2,3,1,2,3,1,2,3]
@test q[:B]==[1.,2.,3.,1.,2.,3.,1.,2.,3.]

source_nested_dict = Dict(:a=>[1,2,3], :b=>[4,5])

q = @from i in source_nested_dict begin
    @from j in i.second
    @select @NT(Key=>i.first,Value=>j)
    @collect
end

@test isa(q, Array{@NT(Key::Symbol,Value::Int),1})
@test length(q)==5
@test in(@NT(Key=>:a,Value=>1), q)
@test in(@NT(Key=>:a,Value=>2), q)
@test in(@NT(Key=>:a,Value=>3), q)
@test in(@NT(Key=>:b,Value=>4), q)
@test in(@NT(Key=>:b,Value=>5), q)

q = @from i in source_df begin
    @from j in source_df2
    @where j.a>1
    @select @NT(Name=>i.name,Age=>i.age,Children=>i.children,A=>j.a,B=>j.b)
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(6,5)
@test q[:Name]==["John","John","Sally","Sally","Kirk","Kirk"]
@test q[:Age]==[23.,23.,42.,42.,59.,59.]
@test q[:Children]==[3,3,5,5,2,2]
@test q[:A]==[2,3,2,3,2,3]
@test q[:B]==[2.,3.,2.,3.,2.,3.]

source_nested_dict = Dict(:a=>[1,2,3], :b=>[4,5])

q = @from i in source_nested_dict begin
    @from j in i.second
    @where j>2
    @select @NT(Key=>i.first,Value=>j)
    @collect
end

@test isa(q, Array{@NT(Key::Symbol,Value::Int),1})
@test length(q)==3
@test in(@NT(Key=>:a,Value=>3), q)
@test in(@NT(Key=>:b,Value=>4), q)
@test in(@NT(Key=>:b,Value=>5), q)

source_df_groupby = DataFrame(name=["John", "Sally", "Kirk"], children=[3,2,2])

x = @from i in source_df_groupby begin
    @group i.name by i.children
    @collect
end

@test isa(x, Array{Grouping{Int,String}})
@test length(x)==2
@test x[1].key==3
@test x[1][:]==["John"]
@test x[2].key==2
@test x[2][:]==["Sally", "Kirk"]

x = @from i in source_df_groupby begin
    @group i by i.children
    @collect
end

@test isa(x, Array{Grouping{Int,NamedTuples._NT_namechildren{String,Int}},1})
@test length(x)==2
@test x[1].key==3
@test x[1][1].name=="John";
@test x[2].key==2
@test x[2][1].name=="Sally";
@test x[2][2].name=="Kirk";

q = @from i in source_df_groupby begin
    @group i by i.children into g
    @select @NT(Children=>g.key,Number_of_parents=>length(g))
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(2,2)
@test q[:Children]==[3,2]
@test q[:Number_of_parents]==[1,2]


q = @from i in source_df begin
    @where i.age>30. && i.children > 2
    @select i into j
    @select @NT(Name=>lowercase(j.name))
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,1)
@test q[1,:Name]=="sally"

q = @from i in source_df2 begin
    @join j in source_typedtable2 on i.a equals convert(Int,j.c) into k
    @select @NT(a=>i.a,b=>i.b,c=>k)
    @collect
end

@test isa(q,Array{NamedTuples._NT_abc{Int,Float64,Array{NamedTuples._NT_cd{Float64,String},1}},1})
@test length(q)==3
@test q[1].a==1
@test q[1].b==1.
@test isa(q[1].c, Array{NamedTuples._NT_cd{Float64,String},1})
@test length(q[1].c)==0
@test q[2].a==2
@test q[2].b==2.
@test isa(q[2].c, Array{NamedTuples._NT_cd{Float64,String},1})
@test length(q[2].c)==2
@test q[2].c[1].c==2.
@test q[2].c[1].d== "John"
@test q[2].c[2].c==2.
@test q[2].c[2].d== "Sally"
@test q[3].a==3
@test q[3].b==3.
@test isa(q[3].c, Array{NamedTuples._NT_cd{Float64,String},1})
@test length(q[3].c)==0

q = @from i in source_df2 begin
    @join j in source_typedtable2 on i.a equals convert(Int,j.c) into k
    @where length(k)>0
    @select @NT(a=>i.a,b=>i.b,c=>k)
    @collect
end

@test isa(q,Array{NamedTuples._NT_abc{Int,Float64,Array{NamedTuples._NT_cd{Float64,String},1}},1})
@test length(q)==1
@test q[1].a==2
@test q[1].b==2.
@test isa(q[1].c, Array{NamedTuples._NT_cd{Float64,String},1})
@test length(q[1].c)==2
@test q[1].c[1].c==2.
@test q[1].c[1].d== "John"
@test q[1].c[2].c==2.
@test q[1].c[2].d== "Sally"

end

@testset "Examples" begin
    include("../example/01-DataFrame.jl")
    include("../example/02-Dict.jl")
    include("../example/03-Array.jl")
    include("../example/04-SQLite.jl")
    include("../example/05-Nullable.jl")
    include("../example/06-Generator.jl")
    include("../example/07-typedtables.jl")
    include("../example/08-join.jl")
    include("../example/09-let.jl")
    include("../example/10-orderby.jl")
    include("../example/11-Datastream.jl")
    include("../example/12-NDSparseData.jl")
    include("../example/13-selectmany.jl")
    include("../example/14-groupby.jl")
    include("../example/15-groupinto.jl")
    include("../example/16-selectinto.jl")
    include("../example/17-groupjoin.jl")
    include("../example/18-orderby-nested.jl")
end
