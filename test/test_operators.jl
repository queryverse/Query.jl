using Query
using Base.Test

# 3VL

@test Nullable(true) & Nullable(true) == Nullable(true)
@test Nullable(true) & Nullable(false) == Nullable(false)
@test Nullable(true) & Nullable{Bool}() == Nullable{Bool}()
@test Nullable(false) & Nullable(true) == Nullable(false)
@test Nullable(false) & Nullable(false) == Nullable(false)
@test Nullable(false) & Nullable{Bool}() == Nullable(false)
@test Nullable{Bool}() & Nullable(true) == Nullable{Bool}()
@test Nullable{Bool}() & Nullable(false) == Nullable(false)
@test Nullable{Bool}() & Nullable{Bool}() == Nullable{Bool}()

@test true & Nullable(true) == Nullable(true)
@test true & Nullable(false) == Nullable(false)
@test true & Nullable{Bool}() == Nullable{Bool}()
@test false & Nullable(true) == Nullable(false)
@test false & Nullable(false) == Nullable(false)
@test false & Nullable{Bool}() == Nullable(false)

@test Nullable(true) & true == Nullable(true)
@test Nullable(true) & false == Nullable(false)
@test Nullable(false) & true == Nullable(false)
@test Nullable(false) & false == Nullable(false)
@test Nullable{Bool}() & true == Nullable{Bool}()
@test Nullable{Bool}() & false == Nullable(false)

@test Nullable(true) | Nullable(true) == Nullable(true)
@test Nullable(true) | Nullable(false) == Nullable(true)
@test Nullable(true) | Nullable{Bool}() == Nullable(true)
@test Nullable(false) | Nullable(true) == Nullable(true)
@test Nullable(false) | Nullable(false) == Nullable(false)
@test Nullable(false) | Nullable{Bool}() == Nullable{Bool}()
@test Nullable{Bool}() | Nullable(true) == Nullable(true)
@test Nullable{Bool}() | Nullable(false) == Nullable{Bool}()
@test Nullable{Bool}() | Nullable{Bool}() == Nullable{Bool}()

@test true | Nullable(true) == Nullable(true)
@test true | Nullable(false) == Nullable(true)
@test true | Nullable{Bool}() == Nullable(true)
@test false | Nullable(true) == Nullable(true)
@test false | Nullable(false) == Nullable(false)
@test false | Nullable{Bool}() == Nullable{Bool}()

@test Nullable(true) | true == Nullable(true)
@test Nullable(true) | false == Nullable(true)
@test Nullable(false) | true == Nullable(true)
@test Nullable(false) | false == Nullable(false)
@test Nullable{Bool}() | true == Nullable(true)
@test Nullable{Bool}() | false == Nullable{Bool}()

@test !Nullable(true) == Nullable(false)
@test !Nullable(false) == Nullable(true)
@test !Nullable{Bool}() == Nullable{Bool}()

# null comparisons
@test (Nullable(5)==null) == false
@test (Nullable{Int}()==null) == true
@test (null==Nullable(5)) == false
@test (null==Nullable{Int}()) == true

@test (Nullable(5)!=null) == true
@test (Nullable{Int}()!=null) == false
@test (null!=Nullable(5)) == true
@test (null!=Nullable{Int}()) == false

:+, :-, :!, :~
@test +Nullable(1) == Nullable(+1)
@test +Nullable{Int}() == Nullable{Int}()
@test -Nullable(1) == Nullable(-1)
@test -Nullable{Int}() == Nullable{Int}()
@test ~Nullable(1) == Nullable(~1)
@test ~Nullable{Int}() == Nullable{Int}()

# TODO add ^, / back
for op in (:+, :-, :*, :%, :&, :|, :<<, :>>)
    @eval begin
        @test $op(Nullable(3), Nullable(5)) == Nullable($op(3, 5))
        @test $op(Nullable{Int}(), Nullable(5)) == Nullable{Int}()
        @test $op(Nullable(3), Nullable{Int}()) == Nullable{Int}()
        @test $op(Nullable{Int}(), Nullable{Int}()) == Nullable{Int}()

        @test $op(Nullable{Int}(3), 5) == Nullable($op(3, 5))
        @test $op(3, Nullable{Int}(5)) == Nullable($op(3, 5))
        @test $op(Nullable{Int}(), 5) == Nullable{Int}()
        @test $op(3, Nullable{Int}()) == Nullable{Int}()
    end
end

@test Nullable(3) == Nullable(3)
@test !(Nullable(3) == Nullable(4))
@test !(Nullable{Int}() == Nullable(3))
@test !(Nullable{Float64}() == Nullable(3))
@test !(Nullable(3) == Nullable{Int}())
@test !(Nullable(3) == Nullable{Float64}())
@test Nullable{Int}() == Nullable{Int}()
@test Nullable{Int}() == Nullable{Float64}()

@test Nullable(3) == 3
@test 3 == Nullable(3)
@test !(Nullable(3) == 4)
@test !(4 == Nullable(3))
@test !(Nullable{Int}() == 3)
@test !(3 == Nullable{Int}())

@test !(Nullable(3) != Nullable(3))
@test Nullable(3) != Nullable(4)
@test Nullable{Int}() != Nullable(3)
@test Nullable{Float64}() != Nullable(3)
@test Nullable(3) != Nullable{Int}()
@test Nullable(3) != Nullable{Float64}()
@test !(Nullable{Int}() != Nullable{Int}())
@test !(Nullable{Int}() != Nullable{Float64}())

@test !(Nullable(3) != 3)
@test !(3 != Nullable(3))
@test Nullable(3) != 4
@test 4 != Nullable(3)
@test Nullable{Int}() != 3
@test 3 != Nullable{Int}()

@test Nullable(4) > Nullable(3)
@test !(Nullable(3) > Nullable(4))
@test !(Nullable(4) > Nullable{Int}())
@test !(Nullable{Int}() > Nullable(3))
@test !(Nullable{Int}() > Nullable{Int}())

@test Nullable(4) > 3
@test !(Nullable(3) > 4)
@test !(Nullable{Int}() > 3)

@test 4 > Nullable(3)
@test !(3 > Nullable(4))
@test !(4 > Nullable{Int}())

@test lowercase(Nullable("TEST"))==Nullable("test")
@test lowercase(Nullable{String}())==Nullable{String}()

@test Nullable("TEST")[2:end]==Nullable("EST")
@test Nullable{String}()[2:end]==Nullable{String}()

@test length(Nullable("TEST"))==Nullable(4)
@test length(Nullable{String}())==Nullable{Int}()
