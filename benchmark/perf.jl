using DataTables, Query

N = 100_000_000;
A = rand(N);
B = rand(1:100, N);
dt = DataTable([A, B], [:A, :B]);
dt = DataTable(A = NullableArray(A), B = NullableArray(B));

@time by(dt, :B, d -> mean(d[:A]));

@time x = @from i in dt begin
    @group i.A by i.B into g
    @select {m = mean(g)}
    @collect DataTable
end;

function foo1(dt)
    by(dt, :B, d -> mean(d[:A]))
end

function foo2(dt)
    x = @from i in dt begin
        @group i.A by i.B into g
        @select {m = mean(g)}
        @collect DataTable
    end
end

@time foo1(dt);
@time foo2(dt);

@profile foo2(dt);
