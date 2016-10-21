using Query
using Base.Test

# 3VL

@test NAable(true) & NAable(true) == NAable(true)
@test NAable(true) & NAable(false) == NAable(false)
@test NAable(true) & NAable{Bool}() == NAable{Bool}()
@test NAable(false) & NAable(true) == NAable(false)
@test NAable(false) & NAable(false) == NAable(false)
@test NAable(false) & NAable{Bool}() == NAable(false)
@test NAable{Bool}() & NAable(true) == NAable{Bool}()
@test NAable{Bool}() & NAable(false) == NAable(false)
@test NAable{Bool}() & NAable{Bool}() == NAable{Bool}()

@test true & NAable(true) == NAable(true)
@test true & NAable(false) == NAable(false)
@test true & NAable{Bool}() == NAable{Bool}()
@test false & NAable(true) == NAable(false)
@test false & NAable(false) == NAable(false)
@test false & NAable{Bool}() == NAable(false)

@test NAable(true) & true == NAable(true)
@test NAable(true) & false == NAable(false)
@test NAable(false) & true == NAable(false)
@test NAable(false) & false == NAable(false)
@test NAable{Bool}() & true == NAable{Bool}()
@test NAable{Bool}() & false == NAable(false)

@test NAable(true) | NAable(true) == NAable(true)
@test NAable(true) | NAable(false) == NAable(true)
@test NAable(true) | NAable{Bool}() == NAable(true)
@test NAable(false) | NAable(true) == NAable(true)
@test NAable(false) | NAable(false) == NAable(false)
@test NAable(false) | NAable{Bool}() == NAable{Bool}()
@test NAable{Bool}() | NAable(true) == NAable(true)
@test NAable{Bool}() | NAable(false) == NAable{Bool}()
@test NAable{Bool}() | NAable{Bool}() == NAable{Bool}()

@test true | NAable(true) == NAable(true)
@test true | NAable(false) == NAable(true)
@test true | NAable{Bool}() == NAable(true)
@test false | NAable(true) == NAable(true)
@test false | NAable(false) == NAable(false)
@test false | NAable{Bool}() == NAable{Bool}()

@test NAable(true) | true == NAable(true)
@test NAable(true) | false == NAable(true)
@test NAable(false) | true == NAable(true)
@test NAable(false) | false == NAable(false)
@test NAable{Bool}() | true == NAable(true)
@test NAable{Bool}() | false == NAable{Bool}()

@test !NAable(true) == NAable(false)
@test !NAable(false) == NAable(true)
@test !NAable{Bool}() == NAable{Bool}()

# :+, :-, :!, :~
@test +NAable(1) == NAable(+1)
@test +NAable{Int}() == NAable{Int}()
@test -NAable(1) == NAable(-1)
@test -NAable{Int}() == NAable{Int}()
@test ~NAable(1) == NAable(~1)
@test ~NAable{Int}() == NAable{Int}()

# TODO add ^, / back
for op in (:+, :-, :*, :%, :&, :|, :<<, :>>)
    @eval begin
        @test $op(NAable(3), NAable(5)) == NAable($op(3, 5))
        @test $op(NAable{Int}(), NAable(5)) == NAable{Int}()
        @test $op(NAable(3), NAable{Int}()) == NAable{Int}()
        @test $op(NAable{Int}(), NAable{Int}()) == NAable{Int}()

        @test $op(NAable{Int}(3), 5) == NAable($op(3, 5))
        @test $op(3, NAable{Int}(5)) == NAable($op(3, 5))
        @test $op(NAable{Int}(), 5) == NAable{Int}()
        @test $op(3, NAable{Int}()) == NAable{Int}()
    end
end

@test NAable(3)^2 == NAable(9)
@test NAable{Int}()^2 == NAable{Int}()

@test NAable(3) == NAable(3)
@test !(NAable(3) == NAable(4))
@test !(NAable{Int}() == NAable(3))
@test !(NAable{Float64}() == NAable(3))
@test !(NAable(3) == NAable{Int}())
@test !(NAable(3) == NAable{Float64}())
@test NAable{Int}() == NAable{Int}()
@test NAable{Int}() == NAable{Float64}()

@test NAable(3) == 3
@test 3 == NAable(3)
@test !(NAable(3) == 4)
@test !(4 == NAable(3))
@test !(NAable{Int}() == 3)
@test !(3 == NAable{Int}())

@test !(NAable(3) != NAable(3))
@test NAable(3) != NAable(4)
@test NAable{Int}() != NAable(3)
@test NAable{Float64}() != NAable(3)
@test NAable(3) != NAable{Int}()
@test NAable(3) != NAable{Float64}()
@test !(NAable{Int}() != NAable{Int}())
@test !(NAable{Int}() != NAable{Float64}())

@test !(NAable(3) != 3)
@test !(3 != NAable(3))
@test NAable(3) != 4
@test 4 != NAable(3)
@test NAable{Int}() != 3
@test 3 != NAable{Int}()

@test NAable(4) > NAable(3)
@test !(NAable(3) > NAable(4))
@test !(NAable(4) > NAable{Int}())
@test !(NAable{Int}() > NAable(3))
@test !(NAable{Int}() > NAable{Int}())

@test NAable(4) > 3
@test !(NAable(3) > 4)
@test !(NAable{Int}() > 3)

@test 4 > NAable(3)
@test !(3 > NAable(4))
@test !(4 > NAable{Int}())

@test lowercase(NAable("TEST"))==NAable("test")
@test lowercase(NAable{String}())==NAable{String}()

@test NAable("TEST")[2:end]==NAable("EST")
@test NAable{String}()[2:end]==NAable{String}()

@test length(NAable("TEST"))==NAable(4)
@test length(NAable{String}())==NAable{Int}()
