using Documenter, FastBroadcast

makedocs(
    sitename = "FastBroadcast.jl",
    authors = "Yingbo Ma, Chris Elrod, and contributors",
    modules = [FastBroadcast],
    clean = true,
    doctest = false,
    linkcheck = false,
    checkdocs = :exports,
    format = Documenter.HTML(
        assets = String[],
        canonical = "https://docs.sciml.ai/FastBroadcast/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ]
)

deploydocs(
    repo = "github.com/SciML/FastBroadcast.jl.git";
    push_preview = true
)
