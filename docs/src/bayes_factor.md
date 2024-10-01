# Bayesian Model Comparison

## Overview

In this tutorial, we will compare two True and Error model variants using the Bayes factor. One model variant imposes no restrictions on the error probability parameters, whereas the other model constrains the error probabilities to be equal. Computing the Bayes factor is challenging because it requires integrating over a potentially high dimensional parameter space. To compute Bayes factors, we will use a robust method called non-reversible parallel tempering (Bouchard-Côté et al., 2022) using the Julia package
[Pigeons.jl](https://julia-tempering.github.io/Pigeons.jl/dev/). 

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

Before proceeding, we will load the required packages.

```julia
using MCMCChains
using Pigeons
using Random
using QuantumEpisodicMemory
using Turing
```

## Define Models 

The following code blocks define the models along with their prior distributions using [Turing.jl](https://turinglang.org/stable/). Notice that the models are identical except constraints imposed on the error probabilities $\epsilon_i$.

### TET4 Model

The TET4 model is described in detail on the page called [model overview](https://itsdfish.github.io/TrueAndErrorModels.jl/dev/overview/). The *4* in TET4 refers to the number of error probability parameters, which are described below. The TET4 model has four true preference state parameters which collectively form the joint probability distribution over preference states $R_1,R_2$, $R_1,S_2, $S_1,R_2$, $S_1S_2$, where R represents a true preference for the risky option, S represents a true preference for the safe option, and the subscript corresponds to choice set. The joint preference states are:

- ``p_{\mathrm{R_1R_2}}``: the probability of prefering the risky option in both choice sets
- ``p_{\mathrm{R_1S_2}}``: the probability of prefering the risky option in the first choice set and prefering the safe option in the second choice set
- ``p_{\mathrm{S_1R_2}}``: the probability of prefering the safe option in the first choice set and prefering the risky option in the second choice set
- ``p_{\mathrm{S_1S_2}}``: the probability of prefering the safe option in both choice sets

subject to the constraint that ``p_{\mathrm{R_1R_2}} + p_{\mathrm{R_1S_2}} + p_{\mathrm{S_1R_2}} + p_{\mathrm{S_1S_2}} = 1``, and $p_i \geq 0, \forall i$. As its namesake implies, the TET4 model also has four error probability parameters:

- ``\epsilon_{\mathrm{S}_1}``: the error probability of selecting $\mathcal{S}_1$ given that $\mathcal{R}_1$ is prefered.
- ``\epsilon_{\mathrm{S}_2}``: the error probability of selecting $\mathcal{S}_2$ given that $\mathcal{R}_2$ is prefered.
- ``\epsilon_{\mathrm{R}_1}``: the error probability of selecting $\mathcal{R}_1$ given that $\mathcal{S}_1$ is prefered.
- ``\epsilon_{\mathrm{R}_2}``: the error probability of selecting $\mathcal{R}_2$ given that $\mathcal{S}_2$ is prefered.

The only constraint is that $\epsilon_i \in [0, .50],\forall i$. The TET4 model is automatically loaded when Turing is loaded into your Julia session. The `tet4_model` function accepts a vector of response frequencies. The prior distributions are as follows:

``
\mathbf{p} \sim \mathrm{Dirichlet}([1,1,1,1])
``

``
\boldsymbol{\epsilon} \sim \mathrm{Uniform}(0, .5)
``

where $\mathbf{p}$ is a vector of four preference state parameters, and $\boldsymbol{\epsilon}$ is a vector of error probabilities. 

## TET1 Model 

As the name implies, the TET1 model constrains all error probability parameters to be equal:

``\epsilon = \epsilon_{\mathrm{S}_1} = \epsilon_{\mathrm{S}_2} = \epsilon_{\mathrm{R}_1} =\epsilon_{\mathrm{R}_2}``

Otherwise, TET1 and TET4 are identical. The TET1 model is also automatically loaded when Turing is loaded into your Julia session. The `tet1_model` function accepts a vector of response frequencies, and using the following prior distributions over the parameters:

``
\mathbf{p} \sim \mathrm{Dirichlet}([1,1,1,1])
``

``
\epsilon \sim \mathrm{Uniform}(0, .5),
``

where $\mathbf{p}$ is a vector of four preference state parameters, and error probability $\epsilon$ is a scalar. 


## Data-Generating Model

 In our demonstration, we will use the TET1 as the data-generating model. In the code block below, we will create a model object and generate 2 simulated responses from all 100 simulated subjects for a total of 200 responses. In this model, we assume that the probability of a true preference state RR is relatively high, and the probability of other preference states decreases as they become more difference from RR:

- ``p_{\mathrm{R_1R_2}} = .65``
- ``p_{\mathrm{R_1S_2}} = .15``
- ``p_{\mathrm{S_1R_2}} = .15``
- ``p_{\mathrm{S_1S_2}} = .05``

In addition, our model assumes the error probabilities are constrained to be equal:

``\epsilon_{\mathrm{S}_1} = \epsilon_{\mathrm{S}_S} = \epsilon_{\mathrm{R}_1} =\epsilon_{\mathrm{R}_2} = .10``

```julia
Random.seed!(258)
dist = TrueErrorModel(; p = [0.65, .15, .15, .05], ϵ = fill(.10, 4))
data = rand(dist, 200)
```

## Estimate Marginal Log Likelihood

The next step is to run the `pigeons` function to estimate the marginal log likelihood for each model. 

### TET4

The code block below estimates the marginal log likelihood of the the TET4 model. This involves passing the `tet4_model` to the function `pigeons` along with the vector of response frequencies `data`.

```julia
pt_tet4 = pigeons(target=TuringLogPotential(tet4_model(data)), record=[traces])
```
```julia
────────────────────────────────────────────────────────────────────────────
  scans        Λ      log(Z₁/Z₀)   min(α)     mean(α)    min(αₑ)   mean(αₑ) 
────────── ────────── ────────── ────────── ────────── ────────── ──────────
        2       3.22      -47.6   0.000923      0.643          1          1 
        4       1.86      -39.9      0.265      0.793          1          1 
        8        3.6      -38.2      0.255        0.6          1          1 
       16        3.2      -39.2      0.403      0.645          1          1 
       32       3.51      -38.8       0.36       0.61          1          1 
       64       3.56      -39.6      0.441      0.605          1          1 
      128       3.78      -40.1      0.488       0.58          1          1 
      256       3.63      -39.4      0.482      0.596          1          1 
      512       3.61      -39.5      0.556      0.599          1          1 
 1.02e+03       3.56      -39.2      0.577      0.604          1          1 
────────────────────────────────────────────────────────────────────────────
```

Below, we will change the numerical indices to more descriptive indices for ease of interpretation. The next line of code converts the output to an `Chain` object.

```julia
name_map = Dict(
    "p[1]" => "pᵣᵣ",
    "p[2]" => "pᵣₛ",
    "p[3]" => "pₛᵣ",
    "p[4]" => "pₛₛ",
    "ϵ[1]" => "ϵₛ₁",
    "ϵ[2]" => "ϵₛ₂",
    "ϵ[3]" => "ϵᵣ₁",
    "ϵ[4]" => "ϵᵣ₂",
)
chain_te4 = Chains(pt_tet4)
chain_te4 = replacenames(chain_te4, name_map)
```
A summary of the MCMCChain is provided below.

```julia 
Chains MCMC chain (1024×9×1 Array{Float64, 3}):

Iterations        = 1:1:1024
Number of chains  = 1
Samples per chain = 1024
parameters        = pᵣᵣ, pᵣₛ, pₛᵣ, pₛₛ, ϵₛ₁, ϵₛ₂, ϵᵣ₁, ϵᵣ₂
internals         = log_density

Summary Statistics
  parameters      mean       std      mcse   ess_bulk   ess_tail      rhat   ess_per_sec 
      Symbol   Float64   Float64   Float64    Float64    Float64   Float64       Missing 

         pᵣᵣ    0.5768    0.0824    0.0039   449.2267   570.8385    1.0027       missing
         pᵣₛ    0.1820    0.0662    0.0033   391.3331   750.0271    1.0000       missing
         pₛᵣ    0.1787    0.0579    0.0026   523.1174   740.9073    1.0002       missing
         pₛₛ    0.0625    0.0297    0.0012   618.7097   755.8075    0.9995       missing
         ϵₛ₁    0.0517    0.0314    0.0014   529.0317   866.9172    0.9995       missing
         ϵₛ₂    0.0571    0.0342    0.0017   418.1905   657.3602    1.0010       missing
         ϵᵣ₁    0.1995    0.1077    0.0048   514.3591   868.8844    1.0006       missing
         ϵᵣ₂    0.2706    0.1235    0.0065   372.7194   763.7186    1.0005       missing

Quantiles
  parameters      2.5%     25.0%     50.0%     75.0%     97.5% 
      Symbol   Float64   Float64   Float64   Float64   Float64 

         pᵣᵣ    0.4293    0.5165    0.5762    0.6383    0.7335
         pᵣₛ    0.0712    0.1317    0.1765    0.2275    0.3180
         pₛᵣ    0.0820    0.1335    0.1760    0.2202    0.2987
         pₛₛ    0.0179    0.0411    0.0576    0.0808    0.1294
         ϵₛ₁    0.0033    0.0245    0.0511    0.0754    0.1104
         ϵₛ₂    0.0033    0.0282    0.0566    0.0840    0.1238
         ϵᵣ₁    0.0162    0.1078    0.2056    0.2830    0.3887
         ϵᵣ₂    0.0232    0.1705    0.2894    0.3699    0.4639
```

### TE1

As we did above, we will estimate the marginal log likelihood by passing `tet1_model` to the function`pigeons`. 

```julia
pt_tet1 = pigeons(target=TuringLogPotential(te1_model(data)), record=[traces])
```

```julia
────────────────────────────────────────────────────────────────────────────
  scans        Λ      log(Z₁/Z₀)   min(α)     mean(α)    min(αₑ)   mean(αₑ) 
────────── ────────── ────────── ────────── ────────── ────────── ──────────
        2       3.18      -69.3   1.04e-16      0.647          1          1 
        4       2.11      -41.9    0.00298      0.766          1          1 
        8       3.41      -39.2      0.226      0.621          1          1 
       16       2.96      -38.6      0.364      0.671          1          1 
       32       3.71      -37.6      0.459      0.588          1          1 
       64       3.55      -38.3      0.505      0.605          1          1 
      128       3.42        -38      0.487       0.62          1          1 
      256       3.48      -38.1      0.556      0.613          1          1 
      512       3.28      -37.7      0.593      0.635          1          1 
 1.02e+03       3.41        -38      0.578      0.621          1          1 
────────────────────────────────────────────────────────────────────────────
```
In the code block below, we will rename the parameters, and convert the output to an `Chain` object
```julia
name_map = Dict(
    "p[1]" => "pᵣᵣ",
    "p[2]" => "pᵣₛ",
    "p[3]" => "pₛᵣ",
    "p[4]" => "pₛₛ",
)
chain_te1 = Chains(pt_tet1)
chain_te1 = replacenames(chain_te1, name_map)
```
The output below provides a summary of the chain.
```julia 
Chains MCMC chain (1024×6×1 Array{Float64, 3}):

Iterations        = 1:1:1024
Number of chains  = 1
Samples per chain = 1024
parameters        = pᵣᵣ, pᵣₛ, pₛᵣ, pₛₛ, ϵ
internals         = log_density

Summary Statistics
  parameters      mean       std      mcse    ess_bulk    ess_tail      rhat   ess_per_sec 
      Symbol   Float64   Float64   Float64     Float64     Float64   Float64       Missing 

         pᵣᵣ    0.7077    0.0351    0.0011   1106.2442   1055.5828    1.0000       missing
         pᵣₛ    0.1178    0.0261    0.0009    908.2753    965.3276    1.0009       missing
         pₛᵣ    0.1408    0.0268    0.0008   1036.7903    867.0191    0.9992       missing
         pₛₛ    0.0338    0.0140    0.0005    891.6153   1059.1575    1.0031       missing
           ϵ    0.0874    0.0115    0.0004    952.5670    803.6060    0.9995       missing

Quantiles
  parameters      2.5%     25.0%     50.0%     75.0%     97.5% 
      Symbol   Float64   Float64   Float64   Float64   Float64 

         pᵣᵣ    0.6364    0.6843    0.7065    0.7329    0.7712
         pᵣₛ    0.0717    0.0993    0.1165    0.1344    0.1746
         pₛᵣ    0.0923    0.1213    0.1402    0.1589    0.1964
         pₛₛ    0.0120    0.0235    0.0318    0.0422    0.0662
           ϵ    0.0668    0.0795    0.0867    0.0947    0.1114
```

## Extract marginal log likelihood

In the following code block, the function `stepping_stone` extracts that marginal log likelihood for each model:

```julia
mll_tet1 = stepping_stone(pt_tet1)
mll_tet4 = stepping_stone(pt_tet4)
```

## Compute the Bayes Factor

The bayes factor is obtained by exponentiating the difference between marginal log likelihoods. Recall that TET1 was the data-generating model.  As expected, the value of `3.39` indicates that the data are `3.39` times more likely under the data-generating model, TET1, than TET4.

```julia
bf = exp(mll_tet1 - mll_tet4)
```
```julia 
3.3948019100884617
```
# References

Birnbaum, M. H., & Quispe-Torreblanca, E. G. (2018). TEMAP2. R: True and error model analysis program in R. Judgment and Decision Making, 13(5), 428-440.

Lee, M. D. (2018). Bayesian methods for analyzing true-and-error models. Judgment and Decision making, 13(6), 622-635.

Syed, S., Bouchard-Côté, A., Deligiannidis, G., & Doucet, A. (2022). Non-reversible parallel tempering: a scalable highly parallel MCMC scheme. Journal of the Royal Statistical Society Series B: Statistical Methodology, 84(2), 321-350.