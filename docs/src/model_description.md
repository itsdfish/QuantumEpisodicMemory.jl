```@raw html
<img src="https://raw.githubusercontent.com/itsdfish/QuantumEpisodicMemory.jl/refs/heads/main/docs/logo/logo_readme.png" alt="drawing" width="900"/>
```

# Introduction 

This page provides an overview of the Generalized Quantum Episodic Memory (GQEM) model and its implementation in the Julia package `QuantumEpisodicMemoryModels`. The GQEM is a quantum model of recognition memory which accounts for phenomena that pose challenges to many alternative models. These phenomena include subadditivity (a.k.a. overdispersion) and violations of the law of total probability (LOTP). In what follows, we will introduce a recognition memory task used to study subaddivity and violations of the LOTP, the mechanics of the GQEM model, and illustrate some basic functionality provided by this package.

# Task

In the recognition memory task, participants study a list of items (e.g., pictures or words) during the learning phase. Subsequently, in the test phase, participants distinguish between previously studied items and two types of new items. The three item types are:

1.  $O$: an old item defined as an item in the study list
2.  $R$: a new item defined as an item that is related an item in the study list
3.  $U$: a new item that is not related to any items in the study list 

Particpants complete the test phase under one of three between-subject conditions:

1.  $V$: respond *yes* to old items (verbatim)
2.  $G$: respond *yes* to new, related items (gist)
3.  $V \cup G$: respond *yes* to old items or new, related items (verbatim + gist)
4.  $U$: respond *yes* to new, unrelated items (unrelated)


## Subadditivity

Classical probability theory requires mutually exclusive and exhaustive events to sum to 1. In the recognition memory task above, subjects are instructed to respond *yes* to items in three mutually exclusive and exhaustive categories: gist (G), verbatim (V), and new unrelated (U). Thus, for a given item type $i \in \{O,R,U \}$, the judgments summed across the three conditions should be: 

$\Pr(Y_G = 1 \mid i) + \Pr(Y_V = 1 \mid i) + \Pr(Y_U = 1 \mid i) = 1$

Subadditivity, which occurs when the sum exceeds 1, is frequently observed in recognition memory decisions.

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

The GQEM consists of 5 parameters which describe the angle between the standard basis ``\boldsymbol{\chi}_V = \{ \ket{V} = [1,0]^{\top}, \ket{V}^{\perp} = [0,1]^{\top} \}`` and other two bases and the three state vectors. The parameters are defined as follows:

1. ``\theta_G``: angle between basis ``\boldsymbol{\chi}_V`` and ``\boldsymbol{\chi}_G`` in radians
2. ``\theta_U``: angle between basis ``\boldsymbol{\chi}_V`` and ``\boldsymbol{\chi}_U`` in radians
3. ``\theta_{\psi_O}``: angle between basis ``\boldsymbol{\chi}_V`` and state vector ``\ket{\psi_O}`` in radians
4. ``\theta_{\psi_R}``: angle between basis ``\boldsymbol{\chi}_V`` and state vector ``\ket{\psi_R}`` in radians
5. ``\theta_{\psi_U}``: angle between basis ``\boldsymbol{\chi}_V`` and state vector ``\ket{\psi_U}`` in radians

## Response Probabilities

The purpose of this section is to provide a geometric illustration of computing response probabilities with the GQEM model. In the code block below, we will begin by setting the value for each parameter, and creating a model object.
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

The figure below illustrates geometrically how response probabilities are generated from the GQEM model. In this example, we assume that a person was placed in the gist condition, and is in a superposition state for related new items, $\ket{\psi_R}$. The probability of responding *yes* is found by projecting $\ket{\psi_R}$ onto the basis vector $\ket{G}$. In the figure below, the red vector represents the superposition state $\ket{\psi_R}$, the green vector represents the projection of $\ket{\psi_R}$ onto $\ket{G}$ and the dashed black line is perpendicular to the projection. 

```@example model
plot(dist, θψR, θG; state_label = L"\psi_R")
```

```@raw html
<details>
<summary><b>Show Details </b></summary>
```
The superposition state for related items is obtained by rotating the verbatim basis vector.

$\ket{\psi_R} = \mathbb{U}(\theta_{\psi_R}) \ket{V}$

Similarly, the basis state for gist instructions is obtained by rotating the verbatim basis vector.

$\ket{G} = \mathbb{U}(\theta_{G}) \ket{V}$

The projector matrix for basis vector $\ket{G}$ is defined as:

$\mathbf{P} = \ket{G} \bra{G}$

The probability of responding *yes* given a related word is defined as the squared magnitude of the projection of $\ket{\psi_R}$ onto $\ket{G}$:

$\Pr(X = 1 \mid R) = \lVert \mathbf{P} \ket{\psi_R} \rVert^2$

```@raw html
</details>
```

# Model Usage


## Predictions

### Response Probabilities

The predicted response probabilities are computed via the function `compute_pred` as shown below. The predictions can be piped to the function `to_table` to provide row and column names. 

```@example model 
preds = compute_preds(dist) |> to_table
```
### Subadditivity 

Below, the model predicts subadditivity for verbatim and unrelated new items, but not old items. 

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