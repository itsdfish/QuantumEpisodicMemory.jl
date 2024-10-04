abstract type AbstractGQEM{T <: Real} <: DiscreteUnivariateDistribution end
"""
    GQEM{T<:Real} <: AbstractGQEM{T}

A model object for the Generalized Quantum Episodic Memory (GQEM) model of item recognition. In the recognition memory task, subjects study a list of words. In the test phase, three types of words are presented: old words from the study list, new but semantically related words, and new but unrelated words. Subjects are given four sets of instructions

1. gist: respond "yes" to semantically related words (G)
2. verbatim: respond "yes" to old (i.e. studied) words (V)
3. gist + verbatim: respond "yes" to semantically related and old words (G ∪ V)
4. unrelated: respond "yes" to unrelated words (U)

The law of total probability is violated in experiments, such that Pr(G) + Pr(V) > P(G ∪ V). Similarly, the judgments are subadditive: Pr(G) + Pr(V) + Pr(U) > 1. These effects emerge in the GQEM because the memory representations are incompatible, meaning they are represented with different, non-orthogonal bases and evaluated sequentially. As a result, LOTP and additivity do not necessarily hold. 

# Fields

- `θG::T`: angle in radians between the verbatim and gist bases 
- `θU::T`: angle in radians between the verbatim and new unrelated bases 
- `θψO::T`: angle in radians between verbatim basis and the initial state for old words
- `θψR::T`: angle in radians between verbatim basis and the initial state for related new words 
- `θψU::T`: angle in radians between verbatim basis and the initial state for new unrelated words

# Example

```julia
using QuantumEpisodicMemory

θG = -.12
θU = -1.54
θψO = -.71
θψR = -.86
θψU = 1.26

dist = GQEM(; θG, θU, θψO, θψR, θψU)
preds = compute_preds(dist)
table = to_table(preds)

# violation of LOPT
sum(table[["gist","verbatim"],:], dims=1) - table["gist+verbatim", :]'
```
# References 

Trueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model.
Cognitive Science, 41(8), 2089-2125.
"""
mutable struct GQEM{T <: Real} <: AbstractGQEM{T}
    θG::T
    θU::T
    θψO::T
    θψR::T
    θψU::T
end

function GQEM(θG, θU, θψO, θψR, θψU)
    return GQEM(promote(θG, θU, θψO, θψR, θψU)...)
end

function GQEM(; θG, θU, θψO, θψR, θψU)
    return GQEM(θG, θU, θψO, θψR, θψU)
end
