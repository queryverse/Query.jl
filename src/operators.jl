import Base.get
import Base.convert

immutable NAable{T}
    hasvalue::Bool
    value::T

    NAable() = new(false)
    NAable(value::T, hasvalue::Bool=true) = new(hasvalue, value)
end

NAable{T}(value::T, hasvalue::Bool=true) = NAable{T}(value, hasvalue)
NAable{T}(value::Nullable{T}) = isnull(value) ? NAable{T}() : NAable{T}(get(value))
NAable() = NAable{Union{}}()

eltype{T}(::Type{NAable{T}}) = T

convert{T}(::Type{NAable{T}}, x::NAable{T}) = x
convert(::Type{NAable}, x::NAable) = x

convert{T}(t::Type{NAable{T}}, x::Any) = convert(t, convert(T, x))

function convert{T}(::Type{NAable{T}}, x::NAable)
    return isna(x) ? NAable{T}() : NAable{T}(convert(T, get(x)))
end

convert{T}(::Type{NAable{T}}, x::T) = NAable{T}(x)
convert{T}(::Type{NAable}, x::T) = NAable{T}(x)

convert{T}(::Type{NAable{T}}, ::Void) = NAable{T}()
convert(::Type{NAable}, ::Void) = NAable{Union{}}()

promote_rule{S,T}(::Type{NAable{S}}, ::Type{T}) = NAable{promote_type(S, T)}
promote_rule{S,T}(::Type{NAable{S}}, ::Type{NAable{T}}) = NAable{promote_type(S, T)}
promote_op{S,T}(op::Any, ::Type{NAable{S}}, ::Type{NAable{T}}) = NAable{promote_op(op, S, T)}

function show{T}(io::IO, x::NAable{T})
    if get(io, :compact, false)
        if isna(x)
            print(io, "#NA")
        else
            show(io, x.value)
        end
    else
        print(io, "NAable{")
        showcompact(io, eltype(x))
        print(io, "}(")
        if !isna(x)
            showcompact(io, x.value)
        end
        print(io, ')')
    end
end

@inline function get{S,T}(x::NAable{S}, y::T)
    if isbits(S)
        ifelse(isna(x), y, x.value)
    else
        isna(x) ? y : x.value
    end
end

get(x::NAable) = isna(x) ? throw(NAableException()) : x.value

unsafe_get(x::NAable) = x.value
unsafe_get(x) = x

import DataArrays.isna
isna(x::NAable) = !x.hasvalue
# isna(x) = false

const NAablehash_seed = UInt === UInt64 ? 0x932e0143e51d0171 : 0xe51d0171

function hash(x::NAable, h::UInt)
    if isna(x)
        return h + NAablehash_seed
    else
        return hash(x.value, h + NAablehash_seed)
    end
end

import Base.==
import Base.!=

# C# spec section 7.10.9

=={T}(a::NAable{T},b::NAable{Union{}}) = isna(a)
=={T}(a::NAable{Union{}},b::NAable{T}) = isna(b)
!={T}(a::NAable{T},b::NAable{Union{}}) = !isna(a)
!={T}(a::NAable{Union{}},b::NAable{T}) = !isna(b)

# Strings

for op in (:lowercase,:uppercase,:reverse,:ucfirst,:lcfirst,:chop,:chomp)
    @eval begin
        import Base.$(op)
        function $op{T<:AbstractString}(x::NAable{T})
            if isna(x)
                return NAable{T}()
            else
                return NAable($op(get(x)))
            end
        end
    end
end

import Base.getindex
function getindex{T<:AbstractString}(s::NAable{T},i)
    if isna(s)
        return NAable{T}()
    else
        return NAable(get(s)[i])
    end
end

import Base.endof
function endof{T<:AbstractString}(s::NAable{T})
    if isna(s)
        # TODO Decide whether this makes sense?
        return 0
    else
        return endof(get(s))
    end
end

import Base.length
function length{T<:AbstractString}(s::NAable{T})
    if isna(s)
        return NAable{Int}()
    else
        return NAable{Int}(length(get(s)))
    end
end

# C# spec section 7.3.7

for op in (:+, :-, :!, :~)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(x::NAable{T}) = isna(x) ? NAable{T}() : NAable($op(get(x)))
    end
end


for op in (:+, :-, :*, :/, :%, :&, :|, :^, :<<, :>>)
    @eval begin
        import Base.$(op)
        $op{T1<:Number,T2<:Number}(a::NAable{T1},b::NAable{T2}) = isna(a) || isna(b) ? NAable{promote_type(T1,T2)}() : NAable{promote_type(T1,T2)}($op(get(a), get(b)))
        $op{T1<:Number,T2<:Number}(x::NAable{T1},y::T2) = isna(x) ? NAable{promote_type(T1,T2)}() : NAable{promote_type(T1,T2)}($op(get(x), y))
        $op{T1<:Number,T2<:Number}(x::T1,y::NAable{T2}) = isna(y) ? NAable{promote_type(T1,T2)}() : NAable{promote_type(T1,T2)}($op(x, get(y)))
    end
end

^{T<:Number}(x::NAable{T},p::Integer) = isna(x) ? NAable{T}() : NAable(get(x)^p)

=={T1,T2}(a::NAable{T1},b::NAable{T2}) = isna(a) && isna(b) ? true : !isna(a) && !isna(b) ? get(a)==get(b) : false
=={T1,T2}(a::NAable{T1},b::T2) = isna(a) ? false : get(a)==b
=={T1,T2}(a::T1,b::NAable{T2}) = isna(b) ? false : a==get(b)

!={T1,T2}(a::NAable{T1},b::NAable{T2}) = isna(a) && isna(b) ? false : !isna(a) && !isna(b) ? get(a)!=get(b) : true
!={T1,T2}(a::NAable{T1},b::T2) = isna(a) ? true : get(a)!=b
!={T1,T2}(a::T1,b::NAable{T2}) = isna(b) ? true : a!=get(b)

for op in (:<,:>,:<=,:>=)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(a::NAable{T},b::NAable{T}) = isna(a) || isna(b) ? false : $op(get(a), get(b))
        $op{T1<:Number,T2<:Number}(x::NAable{T1},y::T2) = isna(x) ? false : $op(get(x), y)
        $op{T1<:Number,T2<:Number}(x::T1,y::NAable{T2}) = isna(y) ? false : $op(x, get(y))
    end
end

# C# spec 7.11.4
function (&)(x::NAable{Bool},y::NAable{Bool})
    if isna(x)
        if isna(y) || get(y)==true
            return NAable{Bool}()
        else
            return NAable(false)
        end
    elseif get(x)==true
        return y
    else
        return NAable(false)
    end
end

(&)(x::Bool,y::NAable{Bool}) = x ? y : NAable(false)
(&)(x::NAable{Bool},y::Bool) = y ? x : NAable(false)

function (|)(x::NAable{Bool},y::NAable{Bool})
    if isna(x)
        if isna(y) || !get(y)
            return NAable{Bool}()
        else
            return NAable(true)
        end
    elseif get(x)
        return NAable(true)
    else
        return y
    end
end

(|)(x::Bool,y::NAable{Bool}) = x ? NAable(true) : y
(|)(x::NAable{Bool},y::Bool) = y ? NAable(true) : x

import Base.isless
function isless{S,T}(x::NAable{S}, y::NAable{T})
    if isna(x)
        return false
    elseif isna(y)
        return true
    else
        return isless(x.value, y.value)
    end
end
