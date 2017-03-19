using DataFrames, Query

include("prep_data.jl")

function foo_a(df)
    return collect(@select(@where(df,i->i.age>5.), i->@NT(Friends=>i.friends, Children=>i.children)), DataFrame)
end

function foo_b(df)
    return collect(@select(@where(df,i->i.age>5.), i->@NT(Friends=>i.friends, Children=>i.children)))
end

immutable Mydata
    friends::Int64
    age::Float64
    children::Int64
end

function foo2(friends, age, children)
    ret = Array{Mydata}(0)
    for i in 1:length(friends)
        if age[i]>5.
            push!(ret, Mydata(friends[i], age[i], children[i]))
        end
    end
    return ret
end

function foo3(friends, age, children)
    ret = Array{Tuple{Int64, Float64, Int64}}(0)
    for i in 1:length(friends)
        if age[i]>5.
            push!(ret, (friends[i], age[i], children[i]))
        end
    end
    return ret
end

function foo4(friends, age, children)
    ret = Array{@NT( friends::Int64, age::Float64, children::Int64 )}(0)
    for i in 1:length(friends)
        if age[i]>5.
            push!(ret, @NT(friends=>friends[i], age=>age[i], children=>children[i]))
        end
    end
    return ret
end

function foo5(friends, age, children)
    ret = DataFrame([Int64, Float64, Int64], [:friends, :age, :children], 0)
    for i in 1:length(friends)
        if age[i]>5.
            push!(ret, (friends[i], age[i], children[i]))
        end
    end
    return ret
end

function foo6(df)
    ret = df[bitbroadcast(
        (friends, age, children) -> age>5.,
        df[:friends], df[:age], df[:children]),
        :]
    return ret
end

foo_a(df)
foo_b(df)
foo2(data_friends, data_age, data_children)
foo3(data_friends, data_age, data_children)
foo4(data_friends, data_age, data_children)
foo5(data_friends, data_age, data_children)
foo6(df)

gc()
@time foo_a(df)
gc()
@time foo_b(df)
gc()
@time foo2(data_friends, data_age, data_children)
gc()
@time foo3(data_friends, data_age, data_children)
gc()
@time foo4(data_friends, data_age, data_children)
gc()
@time foo5(data_friends, data_age, data_children)
gc()
@time foo6(df)
