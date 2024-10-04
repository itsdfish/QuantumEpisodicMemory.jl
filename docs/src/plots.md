# Visualizing The Model Predictions

This tutorial demonstrates how to visualize the predictions of the GQEM. When `Plots` is loaded into your session along with `QuantumEpisodicMemory`, a method for the function `plot` is loaded, allowing one to visualize the model predictions as projections within a unit circle.

## Load Packages

The first step is to load the required packages. You will need to install each package in your local
environment in order to run the code locally. We will also set a random number generator so that the results are reproducible.

```@example plot
using QuantumEpisodicMemory
using Plots
```

## Initialize Model 
In the code block below, we define a GQEM model. 
```@example plot
model = GQEM(; 
    θG = -.5,
    θU = 2,
    θψO = .90,
    θψR = .10,
    θψU = -1.5,
)
```

## Generate Plot

Next, we pass the model object to the `plot` function to visualize the predictions. Each unit circle consists of the same three bases, but each row has a different state vector, and in each column, the state vector is projected onto a different basis vector. The bases are defined below:  

### Bases

1. Gist basis: ``\boldsymbol{\chi}_G = \{ \ket{G}, \ket{G}^{\perp} \}``
2. Verbatim basis: ``\boldsymbol{\chi}_V = \{ \ket{V}, \ket{V}^{\perp} \}``
3. New Related basis: ``\boldsymbol{\chi}_N = \{ \ket{N}, \ket{N}^{\perp} \}``

Unit circles in each row include the same state vector, shown in red to distinguish them from the basis vectors. Each instruction condition is associated with a unique state vector, defined as:

### State Vectors

1. Old state vector: ``\ket{\psi_O}``
2. New related state vector: ``\ket{\psi_R}``
3. New unrelated state vector: ``\ket{\psi_U}``

### Projectors and Projections

The projectors are denoted by a dashed black line. By contrast, the projections are denoted by a green, thick arrow. 

```@example plot
plot(model)
```


# References 

Trueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model.
Cognitive Science, 41(8), 2089-2125.