



module QueryPerf

using Query, DataFrames, StatsBase, RCall

    function R_bench(N,K)

        R"""
        library(data.table)
        N <- $N
        K <- $K
        # copied from https://github.com/Rdatatable/data.table/wiki/Benchmarks-%3A-Grouping
        set.seed(1)
        DT <- data.table(
          id1 = sample(sprintf("id%03d",1:K), N, TRUE),      # large groups (char)
          id2 = sample(sprintf("id%03d",1:K), N, TRUE),      # large groups (char)
          id3 = sample(sprintf("id%010d",1:(N/K)), N, TRUE), # small groups (char)
          id4 = sample(K, N, TRUE),                          # large groups (int)
          id5 = sample(K, N, TRUE),                          # large groups (int)
          id6 = sample(N/K, N, TRUE),                        # small groups (int)
          v1 =  sample(5, N, TRUE),                          # int in range [1,5]
          v2 =  sample(5, N, TRUE),                          # int in range [1,5]
          v3 =  sample(round(runif(100,max=100),4), N, TRUE) # numeric e.g. 23.5749
        )

        timings <- list()

        timings$sum1 <- system.time( DT[, sum(v1), keyby=id1] )[3]
        timings$sum2 <- system.time( DT[, sum(v1), keyby=id1] )[3]
        timings$sum3 <- system.time( DT[, sum(v1), keyby="id1,id2"] )[3]
        timings$sum4 <- system.time( DT[, sum(v1), keyby="id1,id2"] )[3]
        timings$sum_mean1 <- system.time( DT[, list(sum(v1),mean(v3)), keyby=id3] )[3]
        timings$sum_mean2 <- system.time( DT[, list(sum(v1),mean(v3)), keyby=id3] )[3]
        timings$mean7_9_by_id4_1 <- system.time( DT[, lapply(.SD, mean), keyby=id4, .SDcols=7:9] )[3]
        timings$mean7_9_by_id4_2 <- system.time( DT[, lapply(.SD, mean), keyby=id4, .SDcols=7:9] )[3]
        timings$sum7_9_by_id6_2 <- system.time( DT[, lapply(.SD, sum), keyby=id6, .SDcols=7:9] )[3]
        timings$sum7_9_by_id6_2 <- system.time( DT[, lapply(.SD, sum), keyby=id6, .SDcols=7:9] )[3]
        """
        @rget timings
        return timings
    end

    function createData(N::Int,K::Int)

        df = DataFrame(id1 = sample(["id$x" for x in 1:K],N),
                       id2 = sample(["id$x" for x in 1:K],N),
                       id3 = sample(["id$x" for x in 1:(N/K)],N),
                       id4 = sample(1:K,N),
                       id5 = sample(1:K,N),
                       id6 = sample(1:(N/K),N),
                       v1 = sample(1:5,N),
                       v2 = sample(1:5,N),
                       v3 = sample(round.(rand(100),4),N))

        return df
    end

    function bench1(df::DataFrame)

        t1 = @from i in df begin
                 @group i by i.id1 into g
                 @select {r=sum(g..v1)}
                 @collect DataFrame 
            end
        return nothing
    end

    function run_benches(N=1_000,K=100)
        # get small data for JIT warmup
        d_ = createData(10,3)
        # warm up
        bench1(d_)

        # timings
        ti = Dict()

        # get real data
        d = createData(N,K)
        # measure
        ti[:sum1] = @elapsed bench1(d)
        return ti
    end


end # module








