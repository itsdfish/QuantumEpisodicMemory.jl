using ConcreteStructs 
using Distributions

import Distributions: logpdf, pdf, rand

"""
    GQEM

# Fields

- `θG`: angle in radians between the verbatim and gist bases 
- `θN`: angle in radians between the verbatim and new unrelated bases 
- `θψO`: angle in radians between verbatim basis and the initial state for old words
- `θψR`: angle in radians between verbatim basis and the initial state for related new words 
- `θψN`: angle in radians between verbatim basis and the initial state for new unrelated words

# Reference 

Trueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model.
Cognitive Science, 41(8), 2089-2125.

"""
@concrete mutable struct GQEM <: ContinuousUnivariateDistribution
	θG
	θN 
	θψO
	θψR
	θψU
end

function GQEM(;θG, θN, θψO, θψR, θψU)
    return GQEM(θG, θN, θψO, θψR, θψU)
end
