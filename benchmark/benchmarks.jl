using PkgBenchmark
using Query

@benchgroup "enumerable-select" begin
    q = @from i in collect(1:100_000_000) begin
        @select log(i^2)
    end
    @bench "select" collect($q)
end

function foo(n)
    res = 0
    for i=1:n
        res += i
    end
    return res
end

@benchgroup "stupid-test" begin
    @bench "basic" foo(1_000_000)
end
