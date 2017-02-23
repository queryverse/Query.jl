using PkgBenchmark
using Query

@benchgroup "enumerable-select" begin
    q = @from i in collect(1:100_000_000) begin
        @select log(i^2)
    end
    @bench "select" collect($q)
end
