```@raw html
<img src="https://raw.githubusercontent.com/itsdfish/QuantumEpisodicMemory.jl/refs/heads/main/docs/logo/logo_readme.png" alt="drawing" width="900"/>
```

# Bayesian Model Comparison

In this tutorial, we demonstrate how to perform Bayesian model comparison of two variants of the GQEM using [Pigeons.jl](https://github.com/Julia-Tempering/Pigeons.jl) with the [Turing.jl](https://turinglang.org/) interface. 
For a description of the decision making task, please see the description in the [model overview](https://itsdfish.github.io/TrueAndErrorModels.jl/dev/overview/). 

### Bayes Factor 

Before proceeding to the code, we provide a brief overview of the Bayes factor. Readers who are familiar with Bayes factors can skip this section. In Bayesian model comparison, the Bayes factor allows one to compare the probability of the data under two different models while taking into account model flexibility stemming all sources, including the number of parameters, functional form, and prior distribution. Thus, it provides a way to balance model fit and model flexibility into a single index. One important fact to keep in mind is that Bayes factors can be sensitive to the choice prior distributions over parameters. Sensitivity to prior distributions over parameters might be desireable depending on one's goals and knowledge of the models under consideration. 

The Bayes factor is the likelihood of the data $\mathbf{Y} = \left[y_1,y_2, \dots, y_n\right]$ under model $\mathcal{M}_i$ vs. model $\mathcal{M}_j$. The relationship between the Bayes Factor and the posterior of odds of $\mathcal{M}_i$ vs. $\mathcal{M}_j$ can be stated as:

``\frac{\pi(\mathcal{M}_i \mid \mathbf{Y})}{\pi(\mathcal{M}_j \mid \mathbf{Y})} = \frac{\pi(\mathcal{M}_i)}{\pi(\mathcal{M}_j)} \mathrm{BF}_{i,j}.``

The term on the left hand side is the posterior odds of $\mathcal{M}_i$ vs. $\mathcal{M}_j$, $\pi$ is the posterior probability, the first term on the right hand side is the prior odds of $\mathcal{M}_i$ vs. $\mathcal{M}_j$, and ``\mathrm{BF}_{i,j}`` is the Bayes factor for $\mathcal{M}_i$ vs. $\mathcal{M}_j$.  In the equation above, ``\mathrm{BF}_{i,j}`` functions as a conversion factor between prior odds and posterior odds. Thus,  the Bayes factor is as the factor by which prior odds must be updated in light of the data. This interpretation is important because demonstrates that the prior odds should be updated by the same factor even if there is disagreement over the prior odds. The Bayes factor can also be written as the ratio of marginal likelihoods as follows: 

``\mathrm{BF}_{i,j} = \frac{f(\mathbf{Y} \mid \mathcal{M}_i)}{f(\mathbf{Y} \mid \mathcal{M}_j)}``,

where $f$ is the likelihood function of $\mathcal{M}_i$, and the marginal likelihood of $\mathcal{M}_i$ is given by:

``f(\mathbf{Y} \mid \mathcal{M}_i) = \int_{\boldsymbol{\theta}\in \boldsymbol{\Theta}_i} f(\mathbf{Y} \mid \boldsymbol{\theta}, \mathcal{M}_i) \pi(\boldsymbol{\theta} \mid \mathcal{M}_i) d \boldsymbol{\theta}``.

In the equation above, $\boldsymbol{\Theta}_i$ is the parameter space for $\mathcal{M}_i$ and $\boldsymbol{\theta} \in \boldsymbol{\Theta}$ is a vector of parameters. Under this interpretation, the marginal likelihood represents its average prior predictive ability of of $\mathcal{M}_i$. One benefit of the Bayes factor is that the marginal likelihood accounts for model flexibility because the density of the prior distribution must be "rationed" across the parameter space (i.e., must integrate to 1). Consequentially, the predictions of a model with a diffuse distribution in a high dimensional parameter space will be penalized due to its low prior density. 

## Load Packages

The first step is to load the required packages. You will need to install each package in your local
environment in order to run the code locally. We will also set a random number generator so that the results are reproducible.

```julia
using Pigeons
using QuantumEpisodicMemory
using Random
using Turing
Random.seed!(65)
```

## Models

We will compare two versions of the GQEM model: full model with no contraints on the parameters, and a restricted model with constraints on the basis angles.

### Full Model 

The full model places no constraints on the angle parameters. Each angle parameter has the following prior distribution:

$\theta_i \sim \mathrm{VonMises(0, .10)}$

THe Von Mises distribution roughly corresponds to a normal distribution on the circumference of a circle (i.e., the support is $[-\pi, \pi]$). For each parameter the mean is set to zero, and the concentration parameter, which is inversely related to the variance, is set to a small number of $.10$. In the code block below, the Bayesian model is defined using the `@model` macro in Turing. 

```julia
@model function full_model(data)
    θG ~ VonMises(0, .1)
    θU ~ VonMises(0, .1)
    θψO ~ VonMises(0, .1)
    θψR ~ VonMises(0, .1)
    θψU ~ VonMises(0, .1)
    data ~ GQEM(; θG, θU, θψO, θψR, θψU)
end
```
### Restricted Model 

The restricted model is identical to the full model with exception of the following constraint: the superposition state vectors must be equal. Thus,

$\theta \sim \mathrm{VonMises}(0, .1)$

``\theta_{\psi_O} = \theta_{\psi_R} = \theta_{\psi_U} = \theta``

The model in the code block below imposes this constraint:
```julia
@model function restricted_model(data)
    θG ~ VonMises(0, .1)
    θU ~ VonMises(0, .1)
    θ ~ VonMises(0, .1)
    data ~ GQEM(; θG, θU, θψO = θ, θψR = θ, θψU = θ)
end
```

## Generate Data

In the code block below, we generate simulated data for parameter estimation. The first portion of the code block generates a `NamedTuple` of the parameters. Next, the parameters are passed to the `GQEM` model constructor. Finally, we generate responses from 100 trials per condition and combine the data inputs into a `Tuple` named data. 

```julia
parms = (
    θG = -.50,
    θU = 1.54,
    θψO = .15,
    θψR = -.10,
    θψU = .05,
)
dist = GQEM(; parms...)
n_trials = 100
responses = rand(dist, n_trials)
data = (n_trials, responses)
```

To make the responses easier to interpret, we can use `to_table` to add labels to the rows and columns. The rows correspond to experimental conditions and columns correspond to word types.

```julia 
table = to_table(responses)
```

## Compute Marginal Log Likelihoods 

Now that the data have been generated and the models have been specified, we can compare the models. The first step in computing the Bayes factor is to estimate the marginal log likelihood for each model. To achieve this end, we will pass data and each model to the function `pigeons`. The code blocks for each model and their traces are shown below.

### Full Model

```julia
pt_full = pigeons(target=TuringLogPotential(
    full_model(data)), 
    record = [traces], 
    multithreaded = true, 
    n_chains = 20,
)
```

```julia
────────────────────────────────────────────────────────────────────────────
  scans        Λ      log(Z₁/Z₀)   min(α)     mean(α)    min(αₑ)   mean(αₑ) 
────────── ────────── ────────── ────────── ────────── ────────── ──────────
        2       6.07       -151   9.64e-15       0.68      0.937      0.993 
        4          5      -64.4    0.00402      0.737      0.984      0.999 
        8       4.77      -45.2      0.313      0.749      0.992      0.999 
       16       5.02      -42.5      0.472      0.736      0.988      0.999 
       32       5.63      -45.5      0.417      0.704      0.996      0.999 
       64       5.62      -44.1      0.561      0.704      0.998      0.999 
      128       5.77        -44      0.572      0.696      0.997          1 
      256        5.4      -44.2      0.638      0.716      0.997      0.999 
      512        5.5      -44.1      0.664       0.71      0.998      0.999 
 1.02e+03       5.45      -44.1      0.674      0.713      0.999          1 
────────────────────────────────────────────────────────────────────────────
```

### Restricted Model

```julia
pt_restricted = pigeons(target=TuringLogPotential(
    restricted_model(data)), 
    record = [traces], 
    multithreaded = true, 
    n_chains = 20,
)
```

```julia
────────────────────────────────────────────────────────────────────────────
  scans        Λ      log(Z₁/Z₀)   min(α)     mean(α)    min(αₑ)   mean(αₑ) 
────────── ────────── ────────── ────────── ────────── ────────── ──────────
        2          5       -140   3.58e-14      0.737        0.9      0.995 
        4        3.5      -64.8    0.00747      0.816          1          1 
        8       4.64      -55.2      0.327      0.756          1          1 
       16       3.85      -53.3      0.588      0.797      0.993          1 
       32       3.92      -54.8      0.546      0.793          1          1 
       64       4.38      -54.9      0.602       0.77      0.998          1 
      128       4.08      -54.9       0.67      0.785      0.999          1 
      256       4.24        -55      0.663      0.777          1          1 
      512       4.21      -54.5      0.743      0.778      0.999          1 
 1.02e+03       4.16      -54.7      0.747      0.781      0.999          1 
────────────────────────────────────────────────────────────────────────────
```

## Compute Bayes Factor

We can compute the Bayes factor by calling `stepping_stone` on the `Pigeons` objects for each model, and exponentiating the difference. For ease of intepretation, the Bayes factor is converted to ``\log_{10}`` units. The output below shows that the data are more than 4 orders of magnitude more likely under the full model compared to the restricted model. 

```julia
ml_full = stepping_stone(pt_full)
ml_restricted = stepping_stone(pt_restricted)
BF = log10(exp(ml_full - ml_restricted))
```
```julia
4.577669561628219
```