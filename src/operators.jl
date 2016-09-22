import Base.==
import Base.!=

const null = Nullable{Union{}}()

# C# spec section 7.10.9

=={T}(a::Nullable{T},b::Nullable{Union{}}) = isnull(a)
=={T}(a::Nullable{Union{}},b::Nullable{T}) = isnull(b)
!={T}(a::Nullable{T},b::Nullable{Union{}}) = !isnull(a)
!={T}(a::Nullable{Union{}},b::Nullable{T}) = !isnull(b)

# Strings

for op in (:lowercase,:uppercase,:reverse,:ucfirst,:lcfirst,:chop,:chomp)
    @eval begin
        import Base.$(op)
        function $op{T<:AbstractString}(x::Nullable{T})
            if isnull(x)
                return Nullable{T}()
            else
                return Nullable($op(get(x)))
            end
        end
    end
end

import Base.getindex
function getindex{T<:AbstractString}(s::Nullable{T},i)
    if isnull(s)
        return Nullable{T}()
    else
        return Nullable(get(s)[i])
    end
end

import Base.endof
function endof{T<:AbstractString}(s::Nullable{T})
    if isnull(s)
        # TODO Decide whether this makes sense?
        return 0
    else
        return endof(get(s))
    end
end

import Base.length
function length{T<:AbstractString}(s::Nullable{T})
    if isnull(s)
        return Nullable{Int}()
    else
        return Nullable{Int}(length(get(s)))
    end
end

# C# spec section 7.3.7

for op in (:+, :-, :!, :~)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(x::Nullable{T}) = isnull(x) ? Nullable{T}() : Nullable($op(get(x)))
    end
end


for op in (:+, :-, :*, :/, :%, :&, :|, :^, :<<, :>>)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(a::Nullable{T},b::Nullable{T}) = isnull(a) || isnull(b) ? Nullable{T}() : Nullable($op(get(a), get(b)))
        $op{T1<:Number,T2<:Number}(x::Nullable{T1},y::T2) = isnull(x) ? Nullable{promote_type(T1,T2)}() : Nullable{promote_type(T1,T2)}($op(get(x), y))
        $op{T1<:Number,T2<:Number}(x::T1,y::Nullable{T2}) = isnull(y) ? Nullable{promote_type(T1,T2)}() : Nullable{promote_type(T1,T2)}($op(x, get(y)))
    end
end

=={T1,T2}(a::Nullable{T1},b::Nullable{T2}) = isnull(a) && isnull(b) ? true : !isnull(a) && !isnull(b) ? get(a)==get(b) : false
=={T1,T2}(a::Nullable{T1},b::T2) = isnull(a) ? false : get(a)==b
=={T1,T2}(a::T1,b::Nullable{T2}) = isnull(b) ? false : a==get(b)

!={T1,T2}(a::Nullable{T1},b::Nullable{T2}) = isnull(a) && isnull(b) ? false : !isnull(a) && !isnull(b) ? get(a)!=get(b) : true
!={T1,T2}(a::Nullable{T1},b::T2) = isnull(a) ? true : get(a)!=b
!={T1,T2}(a::T1,b::Nullable{T2}) = isnull(b) ? true : a!=get(b)

for op in (:<,:>,:<=,:>=)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(a::Nullable{T},b::Nullable{T}) = isnull(a) || isnull(b) ? false : $op(get(a), get(b))
        $op{T1<:Number,T2<:Number}(x::Nullable{T1},y::T2) = isnull(x) ? false : $op(get(x), y)
        $op{T1<:Number,T2<:Number}(x::T1,y::Nullable{T2}) = isnull(y) ? false : $op(x, get(y))
    end
end

# C# spec 7.11.4
function (&)(x::Nullable{Bool},y::Nullable{Bool})
    if isnull(x)
        if isnull(y) || get(y)==true
            return Nullable{Bool}()
        else
            return Nullable(false)
        end
    elseif get(x)==true
        return y
    else
        return Nullable(false)
    end
end

(&)(x::Bool,y::Nullable{Bool}) = x ? y : Nullable(false)
(&)(x::Nullable{Bool},y::Bool) = y ? x : Nullable(false)

function (|)(x::Nullable{Bool},y::Nullable{Bool})
    if isnull(x)
        if isnull(y) || !get(y)
            return Nullable{Bool}()
        else
            return Nullable(true)
        end
    elseif get(x)
        return Nullable(true)
    else
        return y
    end
end

(|)(x::Bool,y::Nullable{Bool}) = x ? Nullable(true) : y
(|)(x::Nullable{Bool},y::Bool) = y ? Nullable(true) : x
