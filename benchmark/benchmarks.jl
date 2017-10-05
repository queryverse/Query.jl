using PkgBenchmark
using Query
using DataTables

@benchgroup "Query" begin
    @benchgroup "Query and group to DataTable"
        N = 100_000_000;
        A = rand(N);
        B = rand(1:100, N);
        dt = DataTable([A, B], [:A, :B]);

        @bench "group" @from i in $dt begin
            @group i.A by i.B into g
            @select {m = mean(g)}
            @collect DataTable
        end

        @bench "group2" @from i in $dt begin
            @group i.A by i.B into g
            @select {m = mean(g)}
            @collect DataTable
        end
    end   

    # @benchgroup "Query.jl vs R data.table" begin
    #     include(joinpath(dirname(@__FILE__),"Rdatatable.jl"))  
    #     N = 100_000_000
    #     K = 100
    #     Rtime = Rdatatable.R_bench(N,K)
    #     df = Rdatatable.createData(N,K)

        


        

    # end

    # @benchgroup "Query.jl vs DataFramesMeta.jl" begin
    #     info("Query.jl vs DataFramesMeta.jl is pending")
    # end

end
