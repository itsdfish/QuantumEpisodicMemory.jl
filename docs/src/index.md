```@raw html
<img src="https://raw.githubusercontent.com/itsdfish/QuantumEpisodicMemory.jl/refs/heads/main/docs/logo/logo_readme.png" alt="drawing" width="900"/>
```
# Overview

This package is a Julia implementation of the Generalized Quantum Episodic Memory model. For more details, use the menu on the left panel to navigate the documentation. 

# Installation

There are two ways to install `QuantumEpisodicMemory`. The first method is to enter package mode via `]` and run the following in package mode:

```julia
add https://github.com/itsdfish/QuantumEpisodicMemory.jl
```

The second method involves to add the package to your local environment via this [private registry](https://github.com/itsdfish/Registry.jl). Follow the instructions in the README to add the registry. Next, activate your local environment and paste the following command:

```julia
add QuantumEpisodicMemory
```
One benefit of the second approach is that it allows you to specify compatibility boundries on the version.  

# Quick Example 

The following example illustrates how to generate predicted response probabilities from the GQEM model. 

```@example readme
using QuantumEpisodicMemory

dist = GQEM(; 
  θG = -.12,
  θU = -1.54,
  θψO = -.71,
  θψR = -.86,
  θψU = 1.26,
)
preds = compute_preds(dist)
table = to_table(preds)
```

# References 

Trueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model.
Cognitive Science, 41(8), 2089-2125.