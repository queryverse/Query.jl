



module Rdatatable 

using StatsBase, RCall, Query, DataFrames, DataFramesMeta

    function R_bench(N,K)

        R"""
        library(data.table)
        N <- $N
        K <- $K
        # copied from 
        # https://github.com/Rdatatable/data.table/wiki/Benchmarks-%3A-Grouping
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
        timings$sum7_9_by_id6_1 <- system.time( DT[, lapply(.SD, sum), keyby=id6, .SDcols=7:9] )[3]
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

    function benches(df::DataFrame)

        # timings
        ti = Dict()

        ti[:sum1] = @elapsed @from i in df begin
                                 @group i by i.id1 into g
                                 @select {r=sum(g..v1)}
                                 @collect DataFrame 
                             end
        ti[:sum2] = @elapsed @from i in df begin
                                 @group i by i.id1 into g
                                 @select {r=sum(g..v1)}
                                 @collect DataFrame 
                             end
        ti[:sum3] = @elapsed @from i in df begin
                                 @group i by (i.id1,i.id2) into g
                                 @select {r=sum(g..v1)}
                                 @collect DataFrame 
                             end
        ti[:sum4] = @elapsed @from i in df begin
                                 @group i by (i.id1,i.id2) into g
                                 @select {r=sum(g..v1)}
                                 @collect DataFrame 
                             end
        ti[:sum_mean1] = @elapsed @from i in df begin
                                 @group i by i.id3 into g
                                 @select {s=sum(g..v1),m=mean(g..v3)}
                                 @collect DataFrame 
                             end
        ti[:sum_mean2] = @elapsed @from i in df begin
                                 @group i by i.id3 into g
                                 @select {s=sum(g..v1),m=mean(g..v3)}
                                 @collect DataFrame 
                             end
        ti[:mean7_9_by_id4_1] = @elapsed @from i in df begin
                                 @group i by i.id4 into g
                                 @select {m7=mean(g..v1),m8=mean(g..v2),m9=mean(g..v3)}
                                 @collect DataFrame 
                             end
        ti[:mean7_9_by_id4_2] = @elapsed @from i in df begin
                                 @group i by i.id4 into g
                                 @select {m7=mean(g..v1),m8=mean(g..v2),m9=mean(g..v3)}
                                 @collect DataFrame 
                             end
        ti[:sum7_9_by_id6_1] = @elapsed @from i in df begin
                                 @group i by i.id6 into g
                                 @select {m7=mean(g..v1),m8=mean(g..v2),m9=mean(g..v3)}
                                 @collect DataFrame 
                             end
        ti[:sum7_9_by_id6_2] = @elapsed @from i in df begin
                                 @group i by i.id6 into g
                                 @select {m7=mean(g..v1),m8=mean(g..v2),m9=mean(g..v3)}
                                 @collect DataFrame 
                             end
        return ti
    end

    function DfMeta_benches(df::DataFrame)

        # timings
        ti = Dict()

        ti[:sum1] = @elapsed @linq df |>
                        @by(:id1,r = sum(:v1))
       
        ti[:sum2] = @elapsed @linq df |>
                        @by(:id1,r = sum(:v1))

        ti[:sum3] = @elapsed @linq df |>
                        @by([:id1,:id2],r = sum(:v1))

        ti[:sum4] = @elapsed @linq df |>
                        @by([:id1,:id2],r = sum(:v1))

        ti[:sum_mean1] = @elapsed @linq df |>
                        @by(:id3,s = sum(:v1),m=mean(:v1))

        ti[:sum_mean2] = @elapsed @linq df |>
                        @by(:id3,s = sum(:v1),m=mean(:v1))

        ti[:mean7_9_by_id4_1] = @elapsed @linq df |>
                            @by(:id4,m7=mean(:v1),m8=mean(:v2),m9=mean(:v3))

        ti[:mean7_9_by_id4_2] = @elapsed @linq df |>
                            @by(:id4,m7=mean(:v1),m8=mean(:v2),m9=mean(:v3))

        ti[:sum7_9_by_id6_1] = @elapsed @linq df |>
                            @by(:id6,m7=mean(:v1),m8=mean(:v2),m9=mean(:v3))

        ti[:sum7_9_by_id6_2] = @elapsed @linq df |>
                            @by(:id6,m7=mean(:v1),m8=mean(:v2),m9=mean(:v3))

        return ti
    end

    function run_benches(N=1_000_000;K=100)
        # get small data for JIT warmup
        d_ = createData(10,3)

        # warm up julia benchmarks
        benches(d_);
        DfMeta_benches(d_);

        # get real data
        d = createData(N,K)
        # measure
        r = benches(d)
        r_meta = DfMeta_benches(d)

        # get R time
        rt = R_bench(N,K)

        # get
        out = DataFrame(bench = collect(keys(r)),Query = [r[k] for k in collect(keys(r))],DataFramesMeta=[r_meta[k] for k in collect(keys(r))], Rdatatable=[rt[k] for k in collect(keys(r))])
        sort!(out,cols=:bench)
        return out
    end

    function run_all()
        d=Dict()
        for n in [10_000, 100_000, 1_000_000]
            d[n] = run_benches(n)
            gc()
        end
        return d
    end
end # module








