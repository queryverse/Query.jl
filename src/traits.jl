@traitfn function get_typed_iterator{X; SimpleTraits.BaseTraits.IsIterable{X}}(x::X)
    return x
end

@traitdef IsTypedIterable{X}
@traitdef HasCustomTypedIterator{X}

@generated function SimpleTraits.trait{X}(::Type{IsTypedIterable{X}})
    method_exists(start, Tuple{X}) || istrait(HasCustomTypedIterator{X}) ? :(IsTypedIterable{X}) : :(Not{IsTypedIterable{X}})
end

@traitdef IsIterableTable{X}
@traitdef HasCustomTableIterator{X}

@generated function SimpleTraits.trait{X}(::Type{IsIterableTable{X}})
    istrait(IsTypedIterable{X}) && ( ( Base.iteratoreltype(X)==Base.HasEltype() && eltype(X)<: NamedTuple ) || istrait(HasCustomTableIterator{X}) ) ? :(IsIterableTable{X}) : :(Not{IsIterableTable{X}})
end
