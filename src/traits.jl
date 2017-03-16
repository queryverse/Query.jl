@traitfn function get_typed_iterator{X; SimpleTraits.BaseTraits.IsIterable{X}}(x::X)
    return x
end

@traitdef IsTypedIterable{X}
@traitdef HasCustomTypedIterator{X}

@generated function SimpleTraits.trait{X}(::Type{IsTypedIterable{X}})
    method_exists(start, Tuple{X}) || istrait(HasCustomTypedIterator{X}) ? :(IsTypedIterable{X}) : :(Not{IsTypedIterable{X}})
end
