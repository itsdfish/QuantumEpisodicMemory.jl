```@raw html
<img src="https://raw.githubusercontent.com/itsdfish/TrueAndErrorModels.jl/gh-pages/dev/assets/logo_readme.png" alt="drawing" width="900"/>
```
# Bayesian Parameter Estimation

The purpose of this tutorial is to demonstrate how to perform Bayesian parameter estimation of the True and Error model (TET; Birnbaum & Quispe-Torreblanca, 2018) using the [Turing.jl](https://turinglang.org/) package. 

## Load Packages

The first step is to load the required packages. You will need to install each package in your local
environment in order to run the code locally. We will also set a random number generator so that the results are reproducible.

```julia
using Pigeons
using QuantumEpisodicMemory
using Random
using Turing
using StatsPlots
Random.seed!(6522)
```

## Generate Data

For a description of the decision making task, please see the description in the [model overview](https://itsdfish.github.io/TrueAndErrorModels.jl/dev/overview/). In the code block below, we will create a model object and generate 2 simulated responses from 100 simulated subjects for a total of 200 responses. For this model, we assume that the probability of a true preference state RR is relatively high, and the probability of other preference states decreases as they become more difference from RR:

- ``p_{\mathrm{R_1R_2}} = .65``
- ``p_{\mathrm{R_1S_2}} = .15``
- ``p_{\mathrm{S_1R_2}} = .15``
- ``p_{\mathrm{S_1S_2}} = .05``

In addition, our model assumes the error probabilities are constrained to be equal:

``\epsilon_{\mathrm{S}_1} = \epsilon_{\mathrm{S}_S} = \epsilon_{\mathrm{R}_1} =\epsilon_{\mathrm{R}_2} = .10``

```julia
dist = GQEM(; 
    θG = -.12,
    θN = -1.54,
    θψO = -.71,
    θψR = -.86,
    θψU = 1.26,
)
n_trials = 1000
responses = rand(dist, n_trials)
data = (n_trials, responses)
```

```julia 
table = to_table(data)
```

```julia
4×3 Named Matrix{Int64}
condition ╲ word type │       old    related  unrelated
──────────────────────┼────────────────────────────────
gist                  │        70         63          6
verbatim              │        49         48         10
gist+verbatim         │        64         49          5
unrelated new         │        46         63         91
```

In the output above, we see the response vector has 16 elements, which correspond to response frequencies for the 16 response patterns:

``\{(\mathcal{R}_1\mathcal{R}_2,\mathcal{R}_1\mathcal{R}_2),(\mathcal{R}_1\mathcal{R}_2,\mathcal{R}_1\mathcal{S}_2), \dots, (\mathcal{S}_1\mathcal{S}_2,\mathcal{S}_1\mathcal{S}_2)\},``

where $\mathcal{R}$ and $\mathcal{S}$ correspond to risky and safe options, respectively, and the subscript indexes the choice set.  

## The Turing Model

```julia
@model function model(data)
    θG ~ VonMises(0, π / 2)
    θN ~ VonMises(0, π / 2)
    θψO ~ VonMises(0, π / 2)
    θψR ~ VonMises(0, π / 2)
    θψU ~ VonMises(0, π / 2)
    data ~ GQEM(; θG, θN, θψO, θψR, θψU)
end
```

## Estimate the Parameters

Now that the Turing model has been specified, we can perform Bayesian parameter estimation with the function `sample`. We will use the No U-Turn Sampler (NUTS) to sample from the posterior distribution. The inputs into the `sample` function below are summarized as follows:

1. `model(data)`: the Turing model with data passed
2. `NUTS(1000, .65)`: a sampler object for the No U-Turn Sampler for 1000 warmup samples.
3. `MCMCThreads()`: instructs Turing to run each chain on a separate thread
4. `n_iterations`: the number of iterations performed after warmup
5. `n_chains`: the number of chains

```julia
# Estimate parameters
chains = sample(model(data), NUTS(1000, .65), MCMCThreads(), 1000, 4)
```

For ease of intepretation, we will convert the numerical indices of preference vector $\mathbf{p}$ to more informative labeled indices. 

```julia
name_map = Dict(
    "p[1]" => "pᵣᵣ",
    "p[2]" => "pᵣₛ",
    "p[3]" => "pₛᵣ",
    "p[4]" => "pₛₛ",
)
chains = replacenames(chains, name_map)
```
The output below shows the mean, standard deviation, effective sample size, and rhat for each of the five parameters. The pannel below shows the quantiles of the marginal distributions. 
```julia
Chains MCMC chain (1000×20×4 Array{Float64, 3}):

Iterations        = 1001:1:2000
Number of chains  = 4
Samples per chain = 1000
Wall duration     = 2.11 seconds
Compute duration  = 6.21 seconds
parameters        = pᵣᵣ, pᵣₛ, pₛᵣ, pₛₛ, ϵ
internals         = lp, n_steps, is_accept, acceptance_rate, log_density, hamiltonian_energy, hamiltonian_energy_error, max_hamiltonian_energy_error, tree_depth, numerical_error, step_size, nom_step_size

Summary Statistics
  parameters      mean       std      mcse    ess_bulk    ess_tail      rhat   ess_per_sec 
      Symbol   Float64   Float64   Float64     Float64     Float64   Float64       Float64 

         pᵣᵣ    0.6580    0.0373    0.0005   6647.4436   3364.7026    1.0008      231.3522
         pᵣₛ    0.1378    0.0293    0.0004   6554.7555   3621.5757    1.0000      228.1264
         pₛᵣ    0.1180    0.0271    0.0004   5902.0436   2996.5486    1.0013      205.4099
         pₛₛ    0.0862    0.0230    0.0003   6936.9475   3246.1778    1.0003      241.4279
           ϵ    0.1018    0.0122    0.0002   6510.9497   3234.6554    1.0008      226.6018

Quantiles
  parameters      2.5%     25.0%     50.0%     75.0%     97.5% 
      Symbol   Float64   Float64   Float64   Float64   Float64 

         pᵣᵣ    0.5858    0.6331    0.6580    0.6833    0.7300
         pᵣₛ    0.0843    0.1172    0.1365    0.1574    0.1980
         pₛᵣ    0.0694    0.0991    0.1164    0.1362    0.1742
         pₛₛ    0.0448    0.0699    0.0847    0.1012    0.1362
           ϵ    0.0797    0.0937    0.1015    0.1095    0.1266
```

## Evaluation

It is important to verify that the chains converged. We see that the chains converged according to $\hat{r} \leq 1.05$, and the trace plots below show that the chains look like "hairy caterpillars", which indicates the chains did not get stuck. 

```julia
post_plot = plot(chains, grid = false)
vline!(post_plot, [missing .65 missing .15 missing .15 missing .05 missing .10], color = :black, linestyle = :dash)
```

![](assets/posterior_distribution.png)

The data-generating parameters are represented as black vertical lines in the density plots. As expected, the posterior distributions are centered near the data-generating parameters. Given that the data-generating and estimated model are the same, we would expect the posterior distributions to be near the data-generating parameters. 

# References

Birnbaum, M. H., & Quispe-Torreblanca, E. G. (2018). TEMAP2. R: True and error model analysis program in R. Judgment and Decision Making, 13(5), 428-440.

Lee, M. D. (2018). Bayesian methods for analyzing true-and-error models. Judgment and Decision Making, 13(6), 622-635.