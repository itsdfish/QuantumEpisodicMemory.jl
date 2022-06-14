module QuantumEpisodicMemory

    using Distributions, ConcreteStructs
    import Distributions: logpdf, pdf, rand 

    export GQEM, pdf, logpdf, rand, compute_preds

    include("structs.jl")
    include("functions.jl")
end
