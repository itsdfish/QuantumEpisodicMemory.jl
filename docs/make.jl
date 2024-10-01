using Documenter
using QuantumEpisodicMemory

makedocs(
    warnonly = true,
    sitename = "QuantumEpisodicMemory",
    format = Documenter.HTML(),
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
        # Base.get_extension(QuantumEpisodicMemory, :PlotsExt)
    ]
)
