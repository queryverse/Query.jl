@traitfn function getiterator{X; SimpleTraits.BaseTraits.IsIterator{X}}(x::X)
    return x
end

@traitdef IsIterable{X}

@generated function SimpleTraits.trait{X}(::Type{IsIterable{X}})
    istrait(SimpleTraits.BaseTraits.IsIterator{X}) ? :(IsIterable{X}) : :(Not{IsIterable{X}})
end

@traitdef IsIterableTable{X}

if VERSION >= v"0.6.0-"
    @generated function SimpleTraits.trait{X}(::Type{IsIterableTable{X}})
        if istrait(IsIterable{X})
            if Base.iteratoreltype(X)==Base.HasEltype()
                if Base.eltype(X)<: NamedTuple
                    return :(IsIterableTable{X})
                elseif Base.eltype(X) == Any
                    return :(Base.eltype(X) <: NamedTuples.NamedTuple ? IsIterableTable{X} : Not{IsIterableTable{X}})
                end
            end
        end
        return :(Not{IsIterableTable{X}})
    end
else
    @generated function SimpleTraits.trait{X}(::Type{IsIterableTable{X}})
        istrait(IsIterable{X}) && ( Base.iteratoreltype(X)==Base.HasEltype() && eltype(X)<: NamedTuple ) ? :(IsIterableTable{X}) : :(Not{IsIterableTable{X}})
    end
end
