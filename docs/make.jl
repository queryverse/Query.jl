using Documenter, Query

# Install dependencies and precompile everything
Pkg.add("DataFrames")
using DataFrames

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
		"Experimental Features" => "experimental.md",
		"Internals" => "internals.md"]
)

deploydocs(
    deps = nothing,
    make = nothing,
    target = "build",
    repo = "github.com/queryverse/Query.jl.git",
    julia = "1.0"
)
