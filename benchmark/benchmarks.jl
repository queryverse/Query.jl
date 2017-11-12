using PkgBenchmark
using Query
using QueryOperators
using DataTables

@benchgroup "Variable group columns" begin
    N = 100_000;
    A = rand(N);
    B = rand(1:100, N);
    C = rand(1:100, N);
    dt = DataTable([A, B, C], [:A, :B, :C]);

    @bench "one column" @from i in $dt begin
        @group i.A by i.B into g
        @select {m = mean(g)}
        @collect 
    end
    
    @bench "two columns" @from i in $dt begin
        @group {i.A, i.B} by i.B into g
        @select {m = mean(g..A)}
        @collect 
    end

    @bench "three columns" @from i in $dt begin
        @group {i.A, i.B, i.C} by i.B into g
        @select {m = mean(g..A)}
        @collect 
    end
end


@benchgroup "Variable group by columns" begin
    N = 100_000;
    A = rand(N);
    B = rand(1:100, N);
    C = rand(1:100, N);
    dt = DataTable([A, B, C], [:A, :B, :C]);

    @bench "one column" @from i in $dt begin
        @group i.A by i.A into g
        @select {m = mean(g)}
        @collect DataTable
    end

    @bench "two columns" @from i in $dt begin
        @group i.A by {i.A, i.B} into g
        @select {m = mean(g)}
        @collect DataTable
    end

    @bench "three columns" @from i in $dt begin
        @group i.A by {i.A, i.B, i.C} into g
        @select {m = mean(g)}
        @collect DataTable
    end
end


@benchgroup "Variable datatypes" begin
    @benchgroup "Integer" begin
        N = 10_000;
        A = rand(1:10_000, N);
        B = rand(1:10_000, N);
        C = rand(1:10_000, N);
        dt = DataTable([A, B, C], [:A, :B, :C]);

        @bench "IntegerTest" @from i in $dt begin
            @group i.A by i.A into g
            @select g
            @collect 
        end
    end

    @benchgroup "Float64" begin
        N = 10_000;
        A = rand(N);
        B = rand(N);
        C = rand(N);
        dt = DataTable([A, B, C], [:A, :B, :C]);

        @bench "Float64Test" @from i in $dt begin
            @group i.A by i.A into g
            @select g
            @collect
        end
    end

    @benchgroup "String" begin
        N = 10_000;
        A = [randstring(20) for i in 1:N];
        B = [randstring(20) for i in 1:N];
        C = [randstring(20) for i in 1:N];
        dt = DataTable([A, B, C], [:A, :B, :C]);

        @bench "StringTest" @from i in $dt begin
            @group i.A by i.A into g
            @select g
            @collect
        end
    end

    @benchgroup "Date" begin
        N = 10_000;
        A = [Dates.unix2datetime(time() - i) for i in rand(-1_000_000_000:1_000_000_000, N)];
        B = [Dates.unix2datetime(time() - i) for i in rand(-1_000_000_000:1_000_000_000, N)];
        C = [Dates.unix2datetime(time() - i) for i in rand(-1_000_000_000:1_000_000_000, N)];
        dt = DataTable([A, B, C], [:A, :B, :C]);

        @bench "DateTest" @from i in $dt begin
            @group i.A by i.A into g
            @select g
            @collect
        end
    end
end