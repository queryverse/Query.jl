using Documenter, Query

# Install dependencies and precompile everything
Pkg.add("DataFrames")
Pkg.add("TypedTables")
Pkg.add("DataStreams")
Pkg.add("CSV")
Pkg.add("Feather")
using DataFrames
using NamedTuples
using TypedTables
using DataStreams
using CSV
using Feather

makedocs(
	modules = [Query],
	format = :html,
	sitename = "Query.jl",
	pages = [
		"Introduction" => "index.md",
		"Getting Started" => "gettingstarted.md",
		"Query Commands" => "querycommands.md",
		"Data Sources" => "sources.md",
		"Data Sinks" => "sinks.md",
		"Internals" => "internals.md"]
)

deploydocs(
    deps = nothing,
    make = nothing,
    target = "build",
    repo = "github.com/davidanthoff/Query.jl.git",
    julia = "0.6"
)
