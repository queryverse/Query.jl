import Base.get
import Base.convert

immutable DataValue{T}
    hasvalue::Bool
    value::T

    DataValue() = new(false)
    DataValue(value::T, hasvalue::Bool=true) = new(hasvalue, value)
end

DataValue{T}(value::T, hasvalue::Bool=true) = DataValue{T}(value, hasvalue)
DataValue{T}(value::Nullable{T}) = isnull(value) ? DataValue{T}() : DataValue{T}(get(value))
DataValue() = DataValue{Union{}}()

eltype{T}(::Type{DataValue{T}}) = T

convert{T}(::Type{DataValue{T}}, x::DataValue{T}) = x
convert(::Type{DataValue}, x::DataValue) = x

convert{T}(t::Type{DataValue{T}}, x::Any) = convert(t, convert(T, x))

function convert{T}(::Type{DataValue{T}}, x::DataValue)
    return isnull(x) ? DataValue{T}() : DataValue{T}(convert(T, get(x)))
end

convert{T}(::Type{DataValue{T}}, x::T) = DataValue{T}(x)
convert{T}(::Type{DataValue}, x::T) = DataValue{T}(x)

convert{T}(::Type{DataValue{T}}, ::Void) = DataValue{T}()
convert(::Type{DataValue}, ::Void) = DataValue{Union{}}()

promote_rule{S,T}(::Type{DataValue{S}}, ::Type{T}) = DataValue{promote_type(S, T)}
promote_rule{S,T}(::Type{DataValue{S}}, ::Type{DataValue{T}}) = DataValue{promote_type(S, T)}
promote_op{S,T}(op::Any, ::Type{DataValue{S}}, ::Type{DataValue{T}}) = DataValue{promote_op(op, S, T)}

function Base.show{T}(io::IO, x::DataValue{T})
    if get(io, :compact, false)
        if isnull(x)
            print(io, "#NA")
        else
            show(io, x.value)
        end
    else
        print(io, "DataValue{")
        showcompact(io, eltype(x))
        print(io, "}(")
        if !isnull(x)
            showcompact(io, x.value)
        end
        print(io, ')')
    end
end

@inline function get{S,T}(x::DataValue{S}, y::T)
    if isbits(S)
        ifelse(isnull(x), y, x.value)
    else
        isnull(x) ? y : x.value
    end
end

get(x::DataValue) = isnull(x) ? throw(DataValueException()) : x.value

unsafe_get(x::DataValue) = x.value
unsafe_get(x) = x

Base.isnull(x::DataValue) = !x.hasvalue

const DataValuehash_seed = UInt === UInt64 ? 0x932e0143e51d0171 : 0xe51d0171

function hash(x::DataValue, h::UInt)
    if isnull(x)
        return h + DataValuehash_seed
    else
        return hash(x.value, h + DataValuehash_seed)
    end
end

import Base.==
import Base.!=

# C# spec section 7.10.9

=={T}(a::DataValue{T},b::DataValue{Union{}}) = isnull(a)
=={T}(a::DataValue{Union{}},b::DataValue{T}) = isnull(b)
!={T}(a::DataValue{T},b::DataValue{Union{}}) = !isnull(a)
!={T}(a::DataValue{Union{}},b::DataValue{T}) = !isnull(b)

# Strings

for op in (:lowercase,:uppercase,:reverse,:ucfirst,:lcfirst,:chop,:chomp)
    @eval begin
        import Base.$(op)
        function $op{T<:AbstractString}(x::DataValue{T})
            if isnull(x)
                return DataValue{T}()
            else
                return DataValue($op(get(x)))
            end
        end
    end
end

import Base.getindex
function getindex{T<:AbstractString}(s::DataValue{T},i)
    if isnull(s)
        return DataValue{T}()
    else
        return DataValue(get(s)[i])
    end
end

import Base.endof
function endof{T<:AbstractString}(s::DataValue{T})
    if isnull(s)
        # TODO Decide whether this makes sense?
        return 0
    else
        return endof(get(s))
    end
end

import Base.length
function length{T<:AbstractString}(s::DataValue{T})
    if isnull(s)
        return DataValue{Int}()
    else
        return DataValue{Int}(length(get(s)))
    end
end

# C# spec section 7.3.7

for op in (:+, :-, :!, :~)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(x::DataValue{T}) = isnull(x) ? DataValue{T}() : DataValue($op(get(x)))
    end
end


for op in (:+, :-, :*, :/, :%, :&, :|, :^, :<<, :>>)
    @eval begin
        import Base.$(op)
        $op{T1<:Number,T2<:Number}(a::DataValue{T1},b::DataValue{T2}) = isnull(a) || isnull(b) ? DataValue{promote_type(T1,T2)}() : DataValue{promote_type(T1,T2)}($op(get(a), get(b)))
        $op{T1<:Number,T2<:Number}(x::DataValue{T1},y::T2) = isnull(x) ? DataValue{promote_type(T1,T2)}() : DataValue{promote_type(T1,T2)}($op(get(x), y))
        $op{T1<:Number,T2<:Number}(x::T1,y::DataValue{T2}) = isnull(y) ? DataValue{promote_type(T1,T2)}() : DataValue{promote_type(T1,T2)}($op(x, get(y)))
    end
end

^{T<:Number}(x::DataValue{T},p::Integer) = isnull(x) ? DataValue{T}() : DataValue(get(x)^p)

=={T1,T2}(a::DataValue{T1},b::DataValue{T2}) = isnull(a) && isnull(b) ? true : !isnull(a) && !isnull(b) ? get(a)==get(b) : false
=={T1,T2}(a::DataValue{T1},b::T2) = isnull(a) ? false : get(a)==b
=={T1,T2}(a::T1,b::DataValue{T2}) = isnull(b) ? false : a==get(b)

!={T1,T2}(a::DataValue{T1},b::DataValue{T2}) = isnull(a) && isnull(b) ? false : !isnull(a) && !isnull(b) ? get(a)!=get(b) : true
!={T1,T2}(a::DataValue{T1},b::T2) = isnull(a) ? true : get(a)!=b
!={T1,T2}(a::T1,b::DataValue{T2}) = isnull(b) ? true : a!=get(b)

for op in (:<,:>,:<=,:>=)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(a::DataValue{T},b::DataValue{T}) = isnull(a) || isnull(b) ? false : $op(get(a), get(b))
        $op{T1<:Number,T2<:Number}(x::DataValue{T1},y::T2) = isnull(x) ? false : $op(get(x), y)
        $op{T1<:Number,T2<:Number}(x::T1,y::DataValue{T2}) = isnull(y) ? false : $op(x, get(y))
    end
end

# C# spec 7.11.4
function (&)(x::DataValue{Bool},y::DataValue{Bool})
    if isnull(x)
        if isnull(y) || get(y)==true
            return DataValue{Bool}()
        else
            return DataValue(false)
        end
    elseif get(x)==true
        return y
    else
        return DataValue(false)
    end
end

(&)(x::Bool,y::DataValue{Bool}) = x ? y : DataValue(false)
(&)(x::DataValue{Bool},y::Bool) = y ? x : DataValue(false)

function (|)(x::DataValue{Bool},y::DataValue{Bool})
    if isnull(x)
        if isnull(y) || !get(y)
            return DataValue{Bool}()
        else
            return DataValue(true)
        end
    elseif get(x)
        return DataValue(true)
    else
        return y
    end
end

(|)(x::Bool,y::DataValue{Bool}) = x ? DataValue(true) : y
(|)(x::DataValue{Bool},y::Bool) = y ? DataValue(true) : x

import Base.isless
function isless{S,T}(x::DataValue{S}, y::DataValue{T})
    if isnull(x)
        return false
    elseif isnull(y)
        return true
    else
        return isless(x.value, y.value)
    end
end
