using AdvancedLayoutCalculator
using Documenter

DocMeta.setdocmeta!(AdvancedLayoutCalculator, :DocTestSetup, :(using AdvancedLayoutCalculator); recursive=true)

makedocs(;
    modules=[AdvancedLayoutCalculator],
    authors="Sh",
    repo="https://github.com/Sandsquare-Tinkerbrain/AdvancedLayoutCalculator.jl/blob/{commit}{path}#{line}",
    sitename="AdvancedLayoutCalculator.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Sandsquare-Tinkerbrain.github.io/AdvancedLayoutCalculator.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Sandsquare-Tinkerbrain/AdvancedLayoutCalculator.jl",
)
