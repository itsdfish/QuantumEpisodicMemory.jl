# Introduction 

# Task

## Law of Total Probability

## Subadditivity

# Model 

```@example model
using LaTeXStrings
using QuantumEpisodicMemory
using Plots
```

## Bases 

1. Gist basis: ``\boldsymbol{\chi}_G = \{ \ket{G}, \ket{G}^{\perp} \}``
2. Verbatim basis: ``\boldsymbol{\chi}_V = \{ \ket{V}, \ket{V}^{\perp} \}``
3. New Related basis: ``\boldsymbol{\chi}_N = \{ \ket{N}, \ket{N}^{\perp} \}``

## State Vectors


1. Old state vector: ``\ket{\psi_O}``
2. New related state vector: ``\ket{\psi_R}``
3. New unrelated state vector: ``\ket{\psi_U}``

## Parameters

1. ``\theta_G``:
2. ``\theta_U``:
3. ``\theta_{\psi_O}``:
4. ``\theta_{\psi_R}``:
5. ``\theta_{\psi_U}``:

```@example model 
θG = -.5
θU = 2
θψO = .90
θψR = .15
θψU = -1.5
```

```@example model
dist = GQEM(; θG, θU, θψO, θψR, θψU)
```

```@example model
plot(dist, θψR, θG; state_label = L"\psi_R")
```