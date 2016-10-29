immutable CsvFile
    filename::String
    delim_char::Char
    quote_char::Char
    escape_char::Char
    header::Bool

    function CsvFile(filename, delim_char=',', quote_char='"', escape_char='\\', header=true)
        new(filename, delim_char, quote_char, escape_char, header)
    end
end

function _writevalue(io::IO, value::String, file::CsvFile)
    print(io, file.quote_char)
    for c in value
        if c==file.quote_char
            print(io, file.escape_char)
        end
        print(io, c)
    end
    print(io, file.quote_char)
end

function _writevalue(io::IO, value, file::CsvFile)
    print(io, value)
end

@generated function _writecsv(io::IO, enumerable::Enumerable, csvfile::CsvFile, T::Type)
    col_names = fieldnames(T)
    n = length(col_names)
    push_exprs = Expr(:block)
    for i in 1:n
        push!(push_exprs.args, :( _writevalue(io, i.$(col_names[i]), csvfile) ))
        if i<n
            push!(push_exprs.args, :( print(io, csvfile.delim_char ) ))
        end
    end
    push!(push_exprs.args, :( println(io) ))

    quote
        for i in enumerable
            $push_exprs
        end
    end
end

function collect(enumerable::Enumerable, file::CsvFile)
    T = eltype(enumerable)
    if !(T<:NamedTuple)
        error("Can only collect a NamedTuple iterable to a CSV file.")
    end
    open(file.filename, "w") do io
        if file.header
            join(io,["$(file.quote_char)" *replace(string(colname), file.quote_char, "$(file.escape_char)$(file.quote_char)") * "$(file.quote_char)" for colname in fieldnames(T)],file.delim_char)
            println(io)
        end
        _writecsv(io, enumerable, file, T)
    end
    return nothing
end
