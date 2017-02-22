using Query
using DataFrames
using DataArrays
using TypedTables
using NamedTuples
using DataStreams
using CSV
using SQLite
using JSON
using Feather
using NullableArrays
using Base.Test

immutable Person
    Name::String
    Friends::Vector{String}
end

@testset "Queries" begin

source_df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

q = @from i in source_df begin
    @where i.age>30. && i.children > 2
    @select {Name=lowercase(i.name)}
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,1)
@test q[1,:Name]=="sally"

source_dict = Dict("John"=>34., "Sally"=>56.)

q = @from i in source_dict begin
    @where i.second>36.
    @select {Name=lowercase(i.first)}
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
    @select {i.Name, Friendcount=length(i.Friends)}
    @collect
end

@test isa(q,Array{NamedTuples._NT_NameFriendcount{String,Int},1})
@test length(q)==1
@test q[1].Name=="John"
@test q[1].Friendcount==3

q = @from i in source_array begin
    @where length(i.Friends) > 2
    @select {i.Name, Friendcount=length(i.Friends)}
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,2)
@test q[1,:Name]=="John"
@test q[1,:Friendcount]==3

source_typedtable = @Table(name=Nullable{String}["John", "Sally", "Kirk"], age=Nullable{Float64}[23., 42., 59.], children=Nullable{Int}[3,5,2])

q = @from i in source_typedtable begin
    @where i.age>30 && i.children>2
    @select {Name=lowercase(get(i.name))}
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,1)
@test q[1,:Name]=="sally"

source_df2 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
source_typedtable2 = @Table(c=[2.,4.,2.], d=["John", "Jim","Sally"])

q = @from i in source_df2 begin
    @join j in source_typedtable2 on get(i.a) equals convert(Int,j.c)
    @select {i.a,i.b,j.c,j.d,e="Name: $(j.d)"}
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

q = @from i in source_df2 begin
    @join j in (@from i in source_typedtable2 begin
                    @where i.c<3.
                    @select i
                end) on get(i.a) equals convert(Int,j.c)
    @select {i.a,i.b,j.c,j.d,e="Name: $(j.d)"}
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
    @select {Name=i.name, Count=count, KidsPerYear=kids_per_year}
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

@test isa(q, Array{DataValue{String},1})
@test length(q)==3
@test q==["john", "sally", "kirk"]

q = @from i in source_df begin
    @orderby descending(i.age)
    @select lowercase(i.name)
    @collect
end

@test isa(q, Array{DataValue{String},1})
@test length(q)==3
@test q==["kirk", "sally", "john"]

q = @from i in source_df begin
    @orderby ascending(i.age)
    @select lowercase(i.name)
    @collect
end

@test isa(q, Array{DataValue{String},1})
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

@test isa(q, Array{DataValue{Int},1})
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
    @where i.Children > 2
    @select get(i.Name)
    @collect
end

@test isa(q,Array{String,1})
@test length(q)==2
@test q[1]=="John"
@test q[2]=="Kirk"

q = @from i in source_df begin
    @from j in source_df2
    @select {Name=i.name,Age=i.age,Children=i.children,A=j.a,B=j.b}
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
    @select {Key=i.first,Value=j}
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
    @select {Name=i.name,Age=i.age,Children=i.children,A=j.a,B=j.b}
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
    @select {Key=i.first,Value=j}
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

@test isa(x, Array{Grouping{DataValue{Int},DataValue{String}}})
@test length(x)==2
@test x[1].key==3
@test x[1][:]==["John"]
@test x[2].key==2
@test x[2][:]==["Sally", "Kirk"]

x = @from i in source_df_groupby begin
    @group i by i.children
    @collect
end

@test isa(x, Array{Grouping{DataValue{Int},NamedTuples._NT_namechildren{DataValue{String},DataValue{Int}}},1})
@test length(x)==2
@test x[1].key==3
@test x[1][1].name=="John";
@test x[2].key==2
@test x[2][1].name=="Sally";
@test x[2][2].name=="Kirk";

q = @from i in source_df_groupby begin
    @group i by i.children into g
    @select {Children=g.key,Number_of_parents=length(g)}
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(2,2)
@test q[:Children]==[3,2]
@test q[:Number_of_parents]==[1,2]


q = @from i in source_df begin
    @where i.age>30. && i.children > 2
    @select i into j
    @select {Name=lowercase(j.name)}
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(1,1)
@test q[1,:Name]=="sally"

q = @from i in source_df2 begin
    @join j in source_typedtable2 on get(i.a) equals convert(Int,j.c) into k
    @select {i.a,i.b,c=k}
    @collect
end

@test isa(q,Array{NamedTuples._NT_abc{DataValue{Int},DataValue{Float64},Array{NamedTuples._NT_cd{Float64,String},1}},1})
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
    @join j in source_typedtable2 on get(i.a) equals convert(Int,j.c) into k
    @where length(k)>0
    @select {i.a,i.b,c=k}
    @collect
end

@test isa(q,Array{NamedTuples._NT_abc{DataValue{Int},DataValue{Float64},Array{NamedTuples._NT_cd{Float64,String},1}},1})
@test length(q)==1
@test q[1].a==2
@test q[1].b==2.
@test isa(q[1].c, Array{NamedTuples._NT_cd{Float64,String},1})
@test length(q[1].c)==2
@test q[1].c[1].c==2.
@test q[1].c[1].d== "John"
@test q[1].c[2].c==2.
@test q[1].c[2].d== "Sally"

sqlite_db = SQLite.DB(joinpath(Pkg.dir("SQLite"), "test", "Chinook_Sqlite.sqlite"))

q = @from i in SQLite.Source(sqlite_db,"SELECT * FROM Employee") begin
    @where i.ReportsTo==2
    @select {Name=i.LastName, Adr=i.Address}
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(3,2)
@test q[:Name]==["Peacock","Park","Johnson"]
@test q[:Adr]==["1111 6 Ave SW", "683 10 Street SW", "7727B 41 Ave"]

source_json_string = """
{
    "Students": [
        {
            "Name": "John",
            "Parents": [ {"name": "Paul"}, {"name": "Mary"}]
        },
        {
            "Name": "Steward",
            "Parents": [ {"name": "George"} ]
        },
        {
            "Name": "Felix",
            "Parents": [ {"name": "Greg"}, {"name": "Susan"}]
        },
        {
            "Name": "Sara",
            "Parents": [ {"name": "Susan"}]
        }
    ]
}
"""

q = @from student in JSON.parse(source_json_string)["Students"] begin
    @from parent in student["Parents"]
    @select {Student=student["Name"], Parent=parent["name"]}
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(6,2)
@test q[:Student] == Any["John", "John", "Steward", "Felix", "Felix", "Sara"]
@test q[:Parent] == Any["Paul", "Mary", "George", "Greg", "Susan", "Susan"]


q = @from i in Feather.Source(joinpath(Pkg.dir("Feather"),"test", "data", "airquality.feather")) begin
    @where i.Day==2
    @select i.Month
    @collect
end

@test isa(q, Array{Query.DataValue{Int32},1})
@test q==[5,6,7,8,9]

source_df_nulls = DataFrame(name=@data(["John", "Sally", NA, "Kirk"]), age=[23., 42., 54., 59.], children=@data([3,NA,8,2]))
q = @from i in source_df_nulls begin
    @select i
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(4,3)
@test q[1,:name]=="John"
@test q[2,:name]=="Sally"
@test isna(q[3,:name])
@test q[4,:name]=="Kirk"
@test q[:age]==@data([23., 42., 54., 59.])
@test q[1,:children]==3
@test isna(q[2,:children])
@test q[3,:children]==8
@test q[4,:children]==2

q = @from i in source_df begin
    @select i
    @collect CSV.Sink("test-output.csv")
end
Data.close!(q)
df_loaded_from_csv = CSV.read("test-output.csv")
@test size(source_df) == size(df_loaded_from_csv)
@test source_df[1,:name] == get(df_loaded_from_csv[1,:name])
@test source_df[2,:name] == get(df_loaded_from_csv[2,:name])
@test source_df[3,:name] == get(df_loaded_from_csv[3,:name])
@test source_df[1,:age] == get(df_loaded_from_csv[1,:age])
@test source_df[2,:age] == get(df_loaded_from_csv[2,:age])
@test source_df[3,:age] == get(df_loaded_from_csv[3,:age])
@test source_df[1,:children] == get(df_loaded_from_csv[1,:children])
@test source_df[2,:children] == get(df_loaded_from_csv[2,:children])
@test source_df[3,:children] == get(df_loaded_from_csv[3,:children])

q = @from i in source_df begin
    @select i
    @collect Feather.Sink("test-output.feather")
end
Data.close!(q)
df_loaded_from_feather = Feather.read("test-output.feather")
@test size(source_df) == size(df_loaded_from_feather)
@test source_df[1,:name] == get(df_loaded_from_feather[1,:name])
@test source_df[2,:name] == get(df_loaded_from_feather[2,:name])
@test source_df[3,:name] == get(df_loaded_from_feather[3,:name])
@test source_df[1,:age] == get(df_loaded_from_feather[1,:age])
@test source_df[2,:age] == get(df_loaded_from_feather[2,:age])
@test source_df[3,:age] == get(df_loaded_from_feather[3,:age])
@test source_df[1,:children] == get(df_loaded_from_feather[1,:children])
@test source_df[2,:children] == get(df_loaded_from_feather[2,:children])
@test source_df[3,:children] == get(df_loaded_from_feather[3,:children])

q = Query.collect(Query.default_if_empty(DataValue{String}[]))
@test length(q)==1
@test isna(q[1])

q = Query.collect(Query.default_if_empty(DataValue{String}["John", "Sally"]))
@test length(q)==2
@test q==DataValue{String}["John", "Sally"]


source_df3 = DataFrame(c=[2,4,2], d=["John", "Jim","Sally"])
q = @from i in source_df2 begin
    @left_outer_join j in source_df3 on i.a equals j.c
    @select {i.a,i.b,j.c,j.d}
    @collect DataFrame
end

@test isa(q, DataFrame)
@test size(q)==(4,4)
@test q[:a]==[1,2,2,3]
@test q[:b]==[1.,2.,2.,3.]
@test isna(q[1,:c])
@test q[2,:c]==2
@test q[3,:c]==2
@test isna(q[4,:c])
@test isna(q[1,:d])
@test q[2,:d]=="John"
@test q[3,:d]=="Sally"
@test isna(q[4,:d])

q = @from i in source_df begin
    @select get(i.name)=>get(i.children)
    @collect Dict
end

@test isa(q, Dict{String,Int})
@test length(q)==3
@test q["John"]==3
@test q["Sally"]==5
@test q["Kirk"]==2

@test @count(source_df)==3
@test @count(source_df, i->i.children>3)==1

q = collect(@where(source_df, i->i.age>30. && i.children > 2), DataFrame)

@test isa(q, DataFrame)
@test size(q)==(1,3)
@test q[1,:name]=="Sally"
@test q[1,:age]==42.
@test q[1,:children]==5

q = collect(Query.@select(source_df, i->get(i.children)))

@test isa(q, Array{Int,1})
@test q==[3,5,2]

include("test_indexedtables.jl")

end

@testset "Operators" begin
include("test_operators.jl")
end

@testset "Examples" begin
    example_files = ["../example/01-DataFrame.jl",
        "../example/02-Dict.jl",
        "../example/03-Array.jl",
        "../example/04-SQLite.jl",
        "../example/05-Nullable.jl",
        "../example/06-Generator.jl",
        "../example/07-typedtables.jl",
        "../example/08-join.jl",
        "../example/09-let.jl",
        "../example/10-orderby.jl",
        "../example/11-Datastream.jl",
        "../example/13-selectmany.jl",
        "../example/14-groupby.jl",
        "../example/15-groupinto.jl",
        "../example/16-selectinto.jl",
        "../example/17-groupjoin.jl",
        "../example/18-orderby-nested.jl",
        "../example/19-feather.jl",
        "../example/20-json.jl",
        "../example/21-nulls.jl",
        "../example/22-datastreams-sink.jl",
        "../example/23-dict-sink.jl"]

    is_installed("IndexedTables") && push!(example_files, "../example/12-IndexedTables.jl")

    color = Base.have_color ? "--color=yes" : "--color=no"
    compilecache = "--compilecache=" * (Bool(Base.JLOptions().use_compilecache) ? "yes" : "no")
    julia_exe = Base.julia_cmd()

    for file in example_files
        if success(`$julia_exe --check-bounds=yes $color $compilecache $file`)
            @test true
        else
            @test false
        end
    end
end
