using DataFrames, Query, Missings

source_df_nulls = DataFrame(name=["John", "Sally", missing, "Kirk"], age=[23., 42., 54., 59.], children=[3,missing,8,2])
q = @from i in source_df_nulls begin
    @select i
    @collect DataFrame
end

println(q)
