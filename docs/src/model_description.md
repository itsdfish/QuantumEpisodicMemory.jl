#
<img src="https://raw.githubusercontent.com/itsdfish/QuantumEpisodicMemory.jl/gh-pages/dev/assets/logo_readme.png" alt="drawing" width="900"/>

# Introduction 

This documentation provides an overview of the Generalized Quantum Episodic Memory (GQEM) model and its implementation in the Julia package `QuantumEpisodicMemoryModels`. The GQEM is a quantum model of item recognition memory which accounts for subadditivity (a.k.a. overdispersion) and violations of the law of total probability. In what follows, we will introduce the task, the mechanics of the model, and illustrate some basic functionality using `QuantumEpisodicMemoryModels`.

# Task

In the recognition memory task, participants study a list of items (e.g., pictures or words) during the learning phase. Subsequently, in the test phase, participants distinguish between previously studied items and two types of new items. The three item types are:

1.  $O$: old items defined as items in the study list
2.  $R$: new items that are related any item in the study list
3.  $U$: new items that are not related to any items in the study list 

Particpants complete the test phase under one of three between-subject conditions:

1.  $V$: respond *yes* to old items (verbatim)
2.  $G$: respond *yes* to new, related items (gist)
3.  $V \cup G$: respond *yes* to old items or new, related items (verbatim + gist)


## Law of Total Probability

## Subadditivity

# Model Description

The goal of this section is to introduce the mechanics and concepts underlying the QGEM. Before introducing the GQEM, we will load the `QuantumEpisodicMemory` package along with packages for plotting and LaTeX support for mathematical support. 

```@example model
using LaTeXStrings
using QuantumEpisodicMemory
using Plots
using Random
Random.seed!(407)
```

Quantum cognition distinguishes between two types of representations: compatible and incompatible. Compatible representations can be evaluated simultaneously within the same basis. For example, if you can simultaneously think and reason about your political beliefs and those of your friend, you are using a compatible representation. The joint probability distribution is represented with a common basis. However, if you cannot represent the beliefs simultenously, the beliefs are incompatible. As a consequence, they must be evaluated sequentially using a different basis for each. The bases are defined in the same representational space, but are related to each other through a rotation. Conceptually, this is analogous to shifting one's perceptive to reason about another's political beliefs. 

## Bases 

The GQEM model assumes that the features of an item — gist $(G)$, verbatim $(V)$, and unrelated $(U)$ – are incompatible. For this reason, the features are represented in $\mathbb{R}^2$ with respect to their own bases:

1. Verbatim basis: ``\boldsymbol{\chi}_V = \{ \ket{V} = [1,0]^{\top}, \ket{V}^{\perp} = [0,1]^{\top} \}``
2. Gist basis: ``\boldsymbol{\chi}_G = \{ \ket{G}, \ket{G}^{\perp} \}``
3. New Unrelated basis: ``\boldsymbol{\chi}_U = \{ \ket{U}, \ket{U}^{\perp} \}``

Note that all quantities discussed below are defined relative to this ``\boldsymbol{\chi}_V ``, which is arbitarily anchored to the standard position.

## State Vectors

Upon viewing an old, new related, or new unrelated items a person enters a superposition defined by the corresponding state vectors:

1. Old state vector: ``\ket{\psi_O}``
2. New related state vector: ``\ket{\psi_R}``
3. New unrelated state vector: ``\ket{\psi_U}``

## Parameters

The GQEM consists of 5 angle parameters which describe the relationship between the standard basis ``\boldsymbol{\chi}_V = \{ \ket{V} = [1,0]^{\top}, \ket{V}^{\perp} = [0,1]^{\top} \}`` and other two bases and the three state vectors. The parameters are defined as follows:

1. ``\theta_G``: angle between basis ``\boldsymbol{\chi}_V`` and ``\boldsymbol{\chi}_G`` in radians
2. ``\theta_U``: angle between basis ``\boldsymbol{\chi}_V`` and ``\boldsymbol{\chi}_U`` in radians
3. ``\theta_{\psi_O}``: angle between basis ``\boldsymbol{\chi}_V`` and state vector ``\ket{\psi_O}`` in radians
4. ``\theta_{\psi_R}``: angle between basis ``\boldsymbol{\chi}_V`` and state vector ``\ket{\psi_R}`` in radians
5. ``\theta_{\psi_U}``: angle between basis ``\boldsymbol{\chi}_V`` and state vector ``\ket{\psi_U}`` in radians

## Response Probabilities

The purpose of this section is to provide a geometric illustration of computing response probabilities with the GQEM model. In the code block below, we will begin by setting the value for each parameter.
```@example model 
θG = -.5
θU = 2
θψO = .90
θψR = .20
θψU = -1.5
```
Next, we pass the parameters to the GQEM constructor as keyword arguments (order does not matter).
```@example model
dist = GQEM(; θG, θU, θψO, θψR, θψU)
```

The figure below illustrates how response probabilities are generated from the GQEM model. 

```@example model
plot(dist, θψR, θG; state_label = L"\psi_R")
```

# Model Usage


## Predictions

### Response Probabilities

The predicted response probabilities are computed via the function `compute_pred` as shown below. The predictions can be piped to the function `to_table` to provide row and column names. 

```@example model 
preds = compute_preds(dist) |> to_table
```
### Subadditivity 

The predictions for subadditivity can be computed by summing across the item times for each instruction condition. Below, the model predicts subadditivity for verbatim and unrelated new items, but not old items. 

```@example model 
sum(preds[["gist", "verbatim", "unrelated new"],:], dims = 1)
```

## Generate Data

The code block below demonstrates how to generate 100 trials for each condition.

```@example model 
n_trials = 100
data = rand(dist, n_trials)
```
As before, we can display names for rows and columns to aid in the interpretation of the data. 
```@example model 
to_table(data)
```

## Log Likelihood

Finally, the code block below shows how to compute the log likelihood of the data using the function `logpdf`.

```@example model 
logpdf(dist, n_trials, data)
```

# References 

Trueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model.
Cognitive Science, 41(8), 2089-2125.