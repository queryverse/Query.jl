using Query
using Base.Test

# 3VL

@test DataValue(true) & DataValue(true) == DataValue(true)
@test DataValue(true) & DataValue(false) == DataValue(false)
@test DataValue(true) & DataValue{Bool}() == DataValue{Bool}()
@test DataValue(false) & DataValue(true) == DataValue(false)
@test DataValue(false) & DataValue(false) == DataValue(false)
@test DataValue(false) & DataValue{Bool}() == DataValue(false)
@test DataValue{Bool}() & DataValue(true) == DataValue{Bool}()
@test DataValue{Bool}() & DataValue(false) == DataValue(false)
@test DataValue{Bool}() & DataValue{Bool}() == DataValue{Bool}()

@test true & DataValue(true) == DataValue(true)
@test true & DataValue(false) == DataValue(false)
@test true & DataValue{Bool}() == DataValue{Bool}()
@test false & DataValue(true) == DataValue(false)
@test false & DataValue(false) == DataValue(false)
@test false & DataValue{Bool}() == DataValue(false)

@test DataValue(true) & true == DataValue(true)
@test DataValue(true) & false == DataValue(false)
@test DataValue(false) & true == DataValue(false)
@test DataValue(false) & false == DataValue(false)
@test DataValue{Bool}() & true == DataValue{Bool}()
@test DataValue{Bool}() & false == DataValue(false)

@test DataValue(true) | DataValue(true) == DataValue(true)
@test DataValue(true) | DataValue(false) == DataValue(true)
@test DataValue(true) | DataValue{Bool}() == DataValue(true)
@test DataValue(false) | DataValue(true) == DataValue(true)
@test DataValue(false) | DataValue(false) == DataValue(false)
@test DataValue(false) | DataValue{Bool}() == DataValue{Bool}()
@test DataValue{Bool}() | DataValue(true) == DataValue(true)
@test DataValue{Bool}() | DataValue(false) == DataValue{Bool}()
@test DataValue{Bool}() | DataValue{Bool}() == DataValue{Bool}()

@test true | DataValue(true) == DataValue(true)
@test true | DataValue(false) == DataValue(true)
@test true | DataValue{Bool}() == DataValue(true)
@test false | DataValue(true) == DataValue(true)
@test false | DataValue(false) == DataValue(false)
@test false | DataValue{Bool}() == DataValue{Bool}()

@test DataValue(true) | true == DataValue(true)
@test DataValue(true) | false == DataValue(true)
@test DataValue(false) | true == DataValue(true)
@test DataValue(false) | false == DataValue(false)
@test DataValue{Bool}() | true == DataValue(true)
@test DataValue{Bool}() | false == DataValue{Bool}()

@test !DataValue(true) == DataValue(false)
@test !DataValue(false) == DataValue(true)
@test !DataValue{Bool}() == DataValue{Bool}()

# :+, :-, :!, :~
@test +DataValue(1) == DataValue(+1)
@test +DataValue{Int}() == DataValue{Int}()
@test -DataValue(1) == DataValue(-1)
@test -DataValue{Int}() == DataValue{Int}()
@test ~DataValue(1) == DataValue(~1)
@test ~DataValue{Int}() == DataValue{Int}()

#abs
@test DataValue(1) == abs(DataValue(1))
@test DataValue(1) == abs(DataValue(-1))
@test DataValue{Int}() == abs(DataValue{Int}())

# TODO add ^, / back
for op in (:+, :-, :*, :%, :&, :|, :<<, :>>)
    @eval begin
        @test $op(DataValue(3), DataValue(5)) == DataValue($op(3, 5))
        @test $op(DataValue{Int}(), DataValue(5)) == DataValue{Int}()
        @test $op(DataValue(3), DataValue{Int}()) == DataValue{Int}()
        @test $op(DataValue{Int}(), DataValue{Int}()) == DataValue{Int}()

        @test $op(DataValue{Int}(3), 5) == DataValue($op(3, 5))
        @test $op(3, DataValue{Int}(5)) == DataValue($op(3, 5))
        @test $op(DataValue{Int}(), 5) == DataValue{Int}()
        @test $op(3, DataValue{Int}()) == DataValue{Int}()
    end
end

@test DataValue(3)^2 == DataValue(9)
@test DataValue{Int}()^2 == DataValue{Int}()

@test DataValue(3) == DataValue(3)
@test !(DataValue(3) == DataValue(4))
@test !(DataValue{Int}() == DataValue(3))
@test !(DataValue{Float64}() == DataValue(3))
@test !(DataValue(3) == DataValue{Int}())
@test !(DataValue(3) == DataValue{Float64}())
@test DataValue{Int}() == DataValue{Int}()
@test DataValue{Int}() == DataValue{Float64}()

@test DataValue(3) == 3
@test 3 == DataValue(3)
@test !(DataValue(3) == 4)
@test !(4 == DataValue(3))
@test !(DataValue{Int}() == 3)
@test !(3 == DataValue{Int}())

@test !(DataValue(3) != DataValue(3))
@test DataValue(3) != DataValue(4)
@test DataValue{Int}() != DataValue(3)
@test DataValue{Float64}() != DataValue(3)
@test DataValue(3) != DataValue{Int}()
@test DataValue(3) != DataValue{Float64}()
@test !(DataValue{Int}() != DataValue{Int}())
@test !(DataValue{Int}() != DataValue{Float64}())

@test !(DataValue(3) != 3)
@test !(3 != DataValue(3))
@test DataValue(3) != 4
@test 4 != DataValue(3)
@test DataValue{Int}() != 3
@test 3 != DataValue{Int}()

@test DataValue(4) > DataValue(3)
@test !(DataValue(3) > DataValue(4))
@test !(DataValue(4) > DataValue{Int}())
@test !(DataValue{Int}() > DataValue(3))
@test !(DataValue{Int}() > DataValue{Int}())

@test DataValue(4) > 3
@test !(DataValue(3) > 4)
@test !(DataValue{Int}() > 3)

@test 4 > DataValue(3)
@test !(3 > DataValue(4))
@test !(4 > DataValue{Int}())

@test lowercase(DataValue("TEST"))==DataValue("test")
@test lowercase(DataValue{String}())==DataValue{String}()

@test DataValue("TEST")[2:end]==DataValue("EST")
@test DataValue{String}()[2:end]==DataValue{String}()

@test length(DataValue("TEST"))==DataValue(4)
@test length(DataValue{String}())==DataValue{Int}()
