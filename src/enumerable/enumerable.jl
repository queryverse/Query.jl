abstract type Enumerable end

Base.iteratorsize{T<:Enumerable}(::Type{T}) = Base.SizeUnknown()
