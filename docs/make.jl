using Documenter, Query

# Install dependencies and precompile everything
Pkg.add("DataFrames")
Pkg.add("TypedTables")
using DataFrames
using NamedTuples
using TypedTables

makedocs(
	modules = [Query]
)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo = "github.com/davidanthoff/Query.jl.git",
    julia = "0.5"
)
