module QuantumEpisodicMemory

    using Distributions, ConcreteStructs, NamedArrays
    import Distributions: logpdf, pdf, rand 

    export GQEM, pdf, logpdf, rand, compute_preds
    export to_table

    include("structs.jl")
    include("functions.jl")
end
