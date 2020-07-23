using Documenter, DensityScatter

makedocs(
    modules = [DensityScatter],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Fredrik Pettersson",
    sitename = "DensityScatter.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/Fredrikp-ume/DensityScatter.jl.git",
    push_preview = true
)
