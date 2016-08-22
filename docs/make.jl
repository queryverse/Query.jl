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
		"Home" => "index.md",
		"Tutorial" => "tutorial.md",
		"Internals" => "internals.md"]
)

deploydocs(
    deps = nothing,
    make = nothing,
    repo = "github.com/davidanthoff/Query.jl.git",
    julia = "0.5"
)
