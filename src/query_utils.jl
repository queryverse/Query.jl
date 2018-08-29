ismacro(ex, name::Symbol, nargs::Integer=-1) =
    isa(ex, Expr) && ex.head==:macrocall && ex.args[1]==name &&
    (nargs == -1 || length(ex.args) == nargs+1)
ismacro(ex, name::String, nargs::Integer=-1) = ismacro(ex, Symbol(name), nargs)

iscall(ex, name::Symbol, nargs::Integer=-1) =
    isa(ex, Expr) && ex.head==:call && ex.args[1]==name &&
    (nargs == -1 || length(ex.args) == nargs+1)

anon(amacro, arguments, body) = Expr(:->, arguments, Expr(:block, amacro.args[2], body))
