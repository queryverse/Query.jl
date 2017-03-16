using DataFrames, Query

source_df_nulls = DataFrame(name=@data(["John", "Sally", NA, "Kirk"]), age=[23., 42., 54., 59.], children=@data([3,NA,8,2]))
q = @from i in source_df_nulls begin
    @select i
    @collect DataFrame
end

println(q)
