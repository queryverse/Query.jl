using Documenter, Query

makedocs(
	modules = [Query]
)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo = "github.com/davidanthoff/Query.jl.git",
    julia = "0.5"
)
