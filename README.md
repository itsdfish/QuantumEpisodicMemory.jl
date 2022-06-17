# QuantumEpisodicMemory

This repository constains Julia code for the Generalized Quantum Episodic Memory (GQEM) model of item recognition. In the recognition memory task, subjects study a list of words. In the test phase, three types of words are presented: old words from the study list, new but semantically related words, and new but unrelated words. Subjects are given four sets of instructions

1. gist: respond "yes" to semantically related words (G)
2. verbatim: respond "yes" to old (i.e. studied) words (V)
3. gist + verbatim: respond "yes" to semantically related and old words (GV)
4. unrelated: respond "yes" to unrelated words (U)

The law of total probability is violated in experiments, such that Pr(G) + Pr(V) > P(GV). Similarly, the judgments are subadditive: Pr(G) + Pr(V) + Pr(U) > 1. These effects emerge in the GQEM because the memory representations are incompatible, meaning they are represented with different, non-orthogonal bases and evaluated sequentially. As a result, LOTP and additivity do not necessarily hold. 

# Installation

To install from the REPL, use `]` to switch to the package mode and enter the following:

```julia
add https://github.com/itsdfish/QuantumEpisodicMemory.jl
```

# Documentation
Switch to help mode in the REPL with and type a function name, such as rand, pdf, logpdf, compute_preds, GQEM, to_table. For example,
```julia
help?> GQEM
search: GQEM

  GQEM

  Fields
  ≡≡≡≡≡≡≡≡

    •  θG: angle in radians between verbatim and gist bases

    •  θN: angle in radians between verbatim and new unrelated bases

    •  θψO: angle in radians between verbatim basis and superposition for old words

    •  θψR: angle in radians between verbatim basis and superposition for related new words

    •  θψN: angle in radians between verbatim basis and superposition for new unrelated words

  Reference
  ≡≡≡≡≡≡≡≡≡≡≡

  Trueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model. Cognitive Science, 41(8), 2089-2125.
```

# Example

```julia
using QuantumEpisodicMemory

# basis rotation parameters relative to the standard verbatim
# basis, V
θG = -.12
θN = -1.54
θψO = -.71
θψR = -.86
θψU = 1.26

dist = GQEM(;θG, θN, θψO, θψR, θψU)
preds = compute_preds(dist)

table = to_table(preds)

# violation of LOPT
sum(table[["gist","verbatim"],:], dims=1)

table["gist+verbatim", :]'
```
# References 

Trueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model.
Cognitive Science, 41(8), 2089-2125.