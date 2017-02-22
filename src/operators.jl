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
    return isna(x) ? DataValue{T}() : DataValue{T}(convert(T, get(x)))
end

convert{T}(::Type{DataValue{T}}, x::T) = DataValue{T}(x)
convert{T}(::Type{DataValue}, x::T) = DataValue{T}(x)

convert{T}(::Type{DataValue{T}}, ::Void) = DataValue{T}()
convert(::Type{DataValue}, ::Void) = DataValue{Union{}}()

promote_rule{S,T}(::Type{DataValue{S}}, ::Type{T}) = DataValue{promote_type(S, T)}
promote_rule{S,T}(::Type{DataValue{S}}, ::Type{DataValue{T}}) = DataValue{promote_type(S, T)}
promote_op{S,T}(op::Any, ::Type{DataValue{S}}, ::Type{DataValue{T}}) = DataValue{promote_op(op, S, T)}

function show{T}(io::IO, x::DataValue{T})
    if get(io, :compact, false)
        if isna(x)
            print(io, "#NA")
        else
            show(io, x.value)
        end
    else
        print(io, "DataValue{")
        showcompact(io, eltype(x))
        print(io, "}(")
        if !isna(x)
            showcompact(io, x.value)
        end
        print(io, ')')
    end
end

@inline function get{S,T}(x::DataValue{S}, y::T)
    if isbits(S)
        ifelse(isna(x), y, x.value)
    else
        isna(x) ? y : x.value
    end
end

get(x::DataValue) = isna(x) ? throw(DataValueException()) : x.value

unsafe_get(x::DataValue) = x.value
unsafe_get(x) = x

import DataArrays.isna
isna(x::DataValue) = !x.hasvalue
# isna(x) = false

const DataValuehash_seed = UInt === UInt64 ? 0x932e0143e51d0171 : 0xe51d0171

function hash(x::DataValue, h::UInt)
    if isna(x)
        return h + DataValuehash_seed
    else
        return hash(x.value, h + DataValuehash_seed)
    end
end

import Base.==
import Base.!=

# C# spec section 7.10.9

=={T}(a::DataValue{T},b::DataValue{Union{}}) = isna(a)
=={T}(a::DataValue{Union{}},b::DataValue{T}) = isna(b)
!={T}(a::DataValue{T},b::DataValue{Union{}}) = !isna(a)
!={T}(a::DataValue{Union{}},b::DataValue{T}) = !isna(b)

# Strings

for op in (:lowercase,:uppercase,:reverse,:ucfirst,:lcfirst,:chop,:chomp)
    @eval begin
        import Base.$(op)
        function $op{T<:AbstractString}(x::DataValue{T})
            if isna(x)
                return DataValue{T}()
            else
                return DataValue($op(get(x)))
            end
        end
    end
end

import Base.getindex
function getindex{T<:AbstractString}(s::DataValue{T},i)
    if isna(s)
        return DataValue{T}()
    else
        return DataValue(get(s)[i])
    end
end

import Base.endof
function endof{T<:AbstractString}(s::DataValue{T})
    if isna(s)
        # TODO Decide whether this makes sense?
        return 0
    else
        return endof(get(s))
    end
end

import Base.length
function length{T<:AbstractString}(s::DataValue{T})
    if isna(s)
        return DataValue{Int}()
    else
        return DataValue{Int}(length(get(s)))
    end
end

# C# spec section 7.3.7

for op in (:+, :-, :!, :~)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(x::DataValue{T}) = isna(x) ? DataValue{T}() : DataValue($op(get(x)))
    end
end


for op in (:+, :-, :*, :/, :%, :&, :|, :^, :<<, :>>)
    @eval begin
        import Base.$(op)
        $op{T1<:Number,T2<:Number}(a::DataValue{T1},b::DataValue{T2}) = isna(a) || isna(b) ? DataValue{promote_type(T1,T2)}() : DataValue{promote_type(T1,T2)}($op(get(a), get(b)))
        $op{T1<:Number,T2<:Number}(x::DataValue{T1},y::T2) = isna(x) ? DataValue{promote_type(T1,T2)}() : DataValue{promote_type(T1,T2)}($op(get(x), y))
        $op{T1<:Number,T2<:Number}(x::T1,y::DataValue{T2}) = isna(y) ? DataValue{promote_type(T1,T2)}() : DataValue{promote_type(T1,T2)}($op(x, get(y)))
    end
end

^{T<:Number}(x::DataValue{T},p::Integer) = isna(x) ? DataValue{T}() : DataValue(get(x)^p)

=={T1,T2}(a::DataValue{T1},b::DataValue{T2}) = isna(a) && isna(b) ? true : !isna(a) && !isna(b) ? get(a)==get(b) : false
=={T1,T2}(a::DataValue{T1},b::T2) = isna(a) ? false : get(a)==b
=={T1,T2}(a::T1,b::DataValue{T2}) = isna(b) ? false : a==get(b)

!={T1,T2}(a::DataValue{T1},b::DataValue{T2}) = isna(a) && isna(b) ? false : !isna(a) && !isna(b) ? get(a)!=get(b) : true
!={T1,T2}(a::DataValue{T1},b::T2) = isna(a) ? true : get(a)!=b
!={T1,T2}(a::T1,b::DataValue{T2}) = isna(b) ? true : a!=get(b)

for op in (:<,:>,:<=,:>=)
    @eval begin
        import Base.$(op)
        $op{T<:Number}(a::DataValue{T},b::DataValue{T}) = isna(a) || isna(b) ? false : $op(get(a), get(b))
        $op{T1<:Number,T2<:Number}(x::DataValue{T1},y::T2) = isna(x) ? false : $op(get(x), y)
        $op{T1<:Number,T2<:Number}(x::T1,y::DataValue{T2}) = isna(y) ? false : $op(x, get(y))
    end
end

# C# spec 7.11.4
function (&)(x::DataValue{Bool},y::DataValue{Bool})
    if isna(x)
        if isna(y) || get(y)==true
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
    if isna(x)
        if isna(y) || !get(y)
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
    if isna(x)
        return false
    elseif isna(y)
        return true
    else
        return isless(x.value, y.value)
    end
end
