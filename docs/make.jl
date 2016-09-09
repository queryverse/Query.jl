using Documenter, Query

# Install dependencies and precompile everything
Pkg.add("DataFrames")
Pkg.add("TypedTables")
using DataFrames
using NamedTuples
using TypedTables

makedocs(
	modules = [Query],
	format = Documenter.Formats.HTML,
	sitename = "Query.jl",
	pages = [
		"Introduction" => "index.md",
		"Query Commands" => "querycommands.md",
		"Examples" => "examples.md",
		"Internals" => "internals.md"]
)

deploydocs(
    deps = nothing,
    make = nothing,
    target = "build",
    repo = "github.com/davidanthoff/Query.jl.git",
    julia = "0.5"
)
