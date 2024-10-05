using Documenter
using QuantumEpisodicMemory
using Plots

makedocs(
    warnonly = true,
    sitename = "QuantumEpisodicMemory",
    format = Documenter.HTML(
        assets = [
            asset(
            "https://fonts.googleapis.com/css?family=Montserrat|Source+Code+Pro&display=swap",
            class = :css
        )
        ],
        collapselevel = 1
    ),
    modules = [
        QuantumEpisodicMemory
    # Base.get_extension(QuantumEpisodicMemory, :TuringExt),
        Base.get_extension(QuantumEpisodicMemory, :PlotsExt)
    ],
    pages = [
        "Home" => "index.md",
        "Model Description" => "model_description.md",
        "Parameter Estimation" => "parameter_estimation.md",
        "Plots" => "plots.md",
        "API" => "api.md",
    ]
)

deploydocs(repo = "github.com/itsdfish/QuantumEpisodicMemory.jl.git")
