using DataFrames, Query, NamedTuples, NullableArrays

source_df_nulls = DataFrame(name=NullableArray(["John", "Sally", "NA", "Kirk"],[false,false,true,false]), age=[23., 42., 54., 59.], children=NullableArray([3,0,8,2],[false,true,false,false]))
q = @from i in source_df_nulls begin
    @select i
    @collect DataFrame
end

println(q)
