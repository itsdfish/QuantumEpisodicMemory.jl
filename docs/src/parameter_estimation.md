```@raw html
<img src="https://raw.githubusercontent.com/itsdfish/QuantumEpisodicMemory.jl/refs/heads/main/docs/logo/logo_readme.png" alt="drawing" width="900"/>
```

# Bayesian Parameter Estimation

In this tutorial, we demonstrate how to perform Bayesian parameter estimation of the GQEM using [Pigeons.jl](https://github.com/Julia-Tempering/Pigeons.jl) with the [Turing.jl](https://turinglang.org/) interface. 
For a description of the decision making task, please see the description in the [model overview](https://itsdfish.github.io/TrueAndErrorModels.jl/dev/overview/). 

## Load Packages

The first step is to load the required packages. You will need to install each package in your local
environment in order to run the code locally. We will also set a random number generator so that the results are reproducible.

```julia
using Pigeons
using QuantumEpisodicMemory
using Random
using Turing
using StatsPlots
Random.seed!(3320)
```

## Generate Data

In the code block below, we will create a model object and generate 2 simulated responses from 100 simulated subjects for a total of 200 responses. For this model, we assume that the probability of a true preference state RR is relatively high, and the probability of other preference states decreases as they become more difference from RR:

```julia
parms = (
    θG = -.12,
    θU = -1.54,
    θψO = -.71,
    θψR = -.86,
    θψU = 1.26,
)
dist = GQEM(; parms...)
n_trials = 1000
responses = rand(dist, n_trials)
data = (n_trials, responses)
```

```julia 
table = to_table(responses)
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

## The Turing Model

```julia
@model function model(data)
    θG ~ VonMises(0, .1)
    θU ~ VonMises(0, .1)
    θψO ~ VonMises(0, .1)
    θψR ~ VonMises(0, .1)
    θψU ~ VonMises(0, .1)
    data ~ GQEM(; θG, θU, θψO, θψR, θψU)
end
```

## Estimate the Parameters


```julia
# Estimate parameters
pt = pigeons(target=TuringLogPotential(
    model(data)), 
    record = [traces], 
    multithreaded = true, 
    n_chains = 20,
)
```

For ease of intepretation, we will convert the numerical indices of preference vector $\mathbf{p}$ to more informative labeled indices. 

```julia
chains = Chains(pt)
```
The output below shows the mean, standard deviation, effective sample size, and rhat for each of the five parameters. The pannel below shows the quantiles of the marginal distributions. 
```julia
Summary Statistics
  parameters      mean       std      mcse   ess_bulk   ess_tail      rhat   ess_per_sec 
      Symbol   Float64   Float64   Float64    Float64    Float64   Float64       Missing 

          θG   -0.0883    1.9003    0.1310   209.2796   495.0300    1.0026       missing
          θU   -0.0527    1.5713    0.0858   404.8390   543.2327    0.9994       missing
         θψO    0.1158    1.6601    0.1256   188.7431   617.9621    1.0053       missing
         θψR   -0.0568    1.6559    0.1124   230.9679   527.2334    1.0123       missing
         θψU   -0.2296    1.5712    0.1082   171.3612   587.1192    1.0227       missing

Quantiles
  parameters      2.5%     25.0%     50.0%     75.0%     97.5% 
      Symbol   Float64   Float64   Float64   Float64   Float64 

          θG   -3.0715   -0.1495   -0.0539    0.1420    3.0691
          θU   -1.6493   -1.5724   -1.4849    1.5704    1.6413
         θψO   -2.4354   -0.7697    0.7051    0.7974    2.4393
         θψR   -2.3437   -0.8994   -0.7815    0.8831    2.3380
         θψU   -1.9365   -1.8452   -1.2235    1.2722    1.9279
```

## Evaluation

It is important to verify that the chains converged. We see that the chains converged according to $\hat{r} \leq 1.05$, and the trace plots below show that the chains look like "hairy caterpillars", which indicates the chains did not get stuck. 

```julia
plot(chains, grid = false)
```
![](assets/posterior_distributions.png)

```julia
pairplot(chains, PairPlots.Truth(parms))
```

![](assets/pairplots.png)
# References

Birnbaum, M. H., & Quispe-Torreblanca, E. G. (2018). TEMAP2. R: True and error model analysis program in R. Judgment and Decision Making, 13(5), 428-440.

Lee, M. D. (2018). Bayesian methods for analyzing true-and-error models. Judgment and Decision Making, 13(6), 622-635.