var documenterSearchIndex = {"docs":
[{"location":"api/#Constructors","page":"API","title":"Constructors","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"GQEM","category":"page"},{"location":"api/#QuantumEpisodicMemory.GQEM","page":"API","title":"QuantumEpisodicMemory.GQEM","text":"GQEM{T<:Real} <: AbstractGQEM{T}\n\nA model object for the Generalized Quantum Episodic Memory (GQEM) model of item recognition. In the recognition memory task, subjects study a list of words. In the test phase, three types of words are presented: old words from the study list, new but semantically related words, and new but unrelated words. Subjects are given four sets of instructions\n\ngist: respond \"yes\" to semantically related words (G)\nverbatim: respond \"yes\" to old (i.e. studied) words (V)\ngist + verbatim: respond \"yes\" to semantically related and old words (G ∪ V)\nunrelated: respond \"yes\" to unrelated words (U)\n\nThe law of total probability is violated in experiments, such that Pr(G) + Pr(V) > P(G ∪ V). Similarly, the judgments are subadditive: Pr(G) + Pr(V) + Pr(U) > 1. These effects emerge in the GQEM because the memory representations are incompatible, meaning they are represented with different, non-orthogonal bases and evaluated sequentially. As a result, LOTP and additivity do not necessarily hold. \n\nFields\n\nθG::T: angle in radians between the verbatim and gist bases \nθU::T: angle in radians between the verbatim and new unrelated bases \nθψO::T: angle in radians between verbatim basis and the initial state for old words\nθψR::T: angle in radians between verbatim basis and the initial state for related new words \nθψU::T: angle in radians between verbatim basis and the initial state for new unrelated words\n\nExample\n\nusing QuantumEpisodicMemory\n\nθG = -.12\nθU = -1.54\nθψO = -.71\nθψR = -.86\nθψU = 1.26\n\ndist = GQEM(; θG, θU, θψO, θψR, θψU)\npreds = compute_preds(dist)\ntable = to_table(preds)\n\n# violation of LOPT\nsum(table[[\"gist\",\"verbatim\"],:], dims=1) - table[\"gist+verbatim\", :]'\n\nReferences\n\nTrueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model. Cognitive Science, 41(8), 2089-2125.\n\n\n\n\n\n","category":"type"},{"location":"api/#Core-Functions","page":"API","title":"Core Functions","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"compute_preds\nlogpdf\nrand","category":"page"},{"location":"api/#QuantumEpisodicMemory.compute_preds","page":"API","title":"QuantumEpisodicMemory.compute_preds","text":"compute_preds(dist::AbstractGQEM)\n\nReturns a matrix of predictions for the GQEM model. \n\nThe output is organized in a matrix where rows correspond to instructions and  columns correspond to word type:\n\n word type  \ncondition old related unrelated\ngist 0.65 0.65 0.9\nverbatim 0.35 0.35 0.65\nGist + verbatim 0.69 0.69 0.91\nunrelated new 0.9 0.9 1\n\nArguments\n\ndist::AbstractGQEM: a GQEM distribution object\n\n\n\n\n\n","category":"function"},{"location":"api/#Distributions.logpdf","page":"API","title":"Distributions.logpdf","text":"logpdf(dist::AbstractGQEM, n::Union{Int,Array{Int,N}}, data::Array{Int,N})\n\nReturns the log likelihood of the data for the GQEM model.\n\nThe data are  organized in a matrix where rows correspond to instructions and  columns correspond to word type:\n\n word type  \ncondition old related unrelated\ngist 3 5 9\nverbatim 0 1 2\ngist + verbatim 4 1 10\nunrelated new 5 8 2\n\nArguments\n\ndist::AbstractGQEM: a GQEM distribution object\nn::Union{Int, Array{Int, N}}: the number of trials \ndata::Array{Int, N}: number of \"yes\" responses \n\n\n\n\n\n","category":"function"},{"location":"api/#Base.rand","page":"API","title":"Base.rand","text":"rand(dist::AbstractGQEM, n::Union{Int,Array{Int,N}})\n\nGenerates data from the GQEM model \n\nThe output is organized in a matrix where rows correspond to instructions and  columns correspond to word type:\n\n word type  \ncondition old related unrelated\ngist 3 5 9\nverbatim 0 1 2\ngist + verbatim 4 1 10\nunrelated new 5 8 2\n\nArguments\n\ndist::AbstractGQEM: a GQEM distribution object\n\n\n\n\n\n","category":"function"},{"location":"api/#Utilities","page":"API","title":"Utilities","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"to_table","category":"page"},{"location":"api/#QuantumEpisodicMemory.to_table","page":"API","title":"QuantumEpisodicMemory.to_table","text":"to_table(x)\n\nConverts matrix to table with labeled dimensions and indices. \n\nExample\n\n4×3 Named Matrix{Float64}\ncondition ╲ word type │       old    related  unrelated\n──────────────────────┼────────────────────────────────\ngist                  │  0.690462   0.545336  0.0359636\nverbatim              │  0.575113   0.425675   0.093524\ngist + verbatim       │  0.694898   0.551852  0.0497793\nunrelated new         │  0.455457   0.604619   0.887783\n\n\n\n\n\n","category":"function"},{"location":"api/#Plots","page":"API","title":"Plots","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"plot","category":"page"},{"location":"api/#RecipesBase.plot","page":"API","title":"RecipesBase.plot","text":"plot(dist::AbstractGQEM; font_size = 10, kwargs...)\n\nPlots the projection of an AbstractGQEM model as a 3 x 3 set of unit circles. Across all unit circles,  the bases are the same. However, the state vector varies by row and the basis vector onto which the state vector is projected varies by column. \n\nArguments\n\ndist::AbstractGQEM: a GQEM distribution object\n\nKeywords\n\nfont_size = 10: font size of the vector labels \nkwargs...: optional keyword arguments passed to the plot functions \n\nExample\n\ndist = GQEM(; \n    θG = -.5,\n    θU = 2,\n    θψO = .90,\n    θψR = .15,\n    θψU = -1.5,\n)\n       \nplot(dist)\n\n\n\n\n\nplot(\n    dist::AbstractGQEM,\n    θψ,\n    θ_basis;\n    state_label = L\"psi\",\n    font_size = 10,\n    kwargs...\n)\n\nPlots the projection from a given state vector onto a given basis vector within a unit circle. \n\nArguments\n\ndist::AbstractGQEM: a GQEM distribution object\nθψ: the angle of the state vector with respect to the verbatim basis \nθ_basis: the angle of the basis onto which the state vector is projected. The angle   is with respect to the verbatim basis.\n\nKeywords\n\nstate_label = \"L\"psi\": the label of the state vector ket\nfont_size = 10: font size of the vector labels \nkwargs...: optional keyword arguments passed to the plot functions \n\nExample\n\ndist = GQEM(; \n    θG = -.5,\n    θU = 2,\n    θψO = .90,\n    θψR = .15,\n    θψU = -1.5,\n)\n       \nplot(dist, .1, -.5)\n\n\n\n\n\n","category":"function"},{"location":"parameter_estimation/#Bayesian-Parameter-Estimation","page":"Parameter Estimation","title":"Bayesian Parameter Estimation","text":"","category":"section"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"The purpose of this tutorial is to demonstrate how to perform Bayesian parameter estimation of the True and Error model (TET; Birnbaum & Quispe-Torreblanca, 2018) using the Turing.jl package. ","category":"page"},{"location":"parameter_estimation/#Load-Packages","page":"Parameter Estimation","title":"Load Packages","text":"","category":"section"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"The first step is to load the required packages. You will need to install each package in your local environment in order to run the code locally. We will also set a random number generator so that the results are reproducible.","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"using Pigeons\nusing QuantumEpisodicMemory\nusing Random\nusing Turing\nusing StatsPlots\nRandom.seed!(6522)","category":"page"},{"location":"parameter_estimation/#Generate-Data","page":"Parameter Estimation","title":"Generate Data","text":"","category":"section"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"For a description of the decision making task, please see the description in the model overview. In the code block below, we will create a model object and generate 2 simulated responses from 100 simulated subjects for a total of 200 responses. For this model, we assume that the probability of a true preference state RR is relatively high, and the probability of other preference states decreases as they become more difference from RR:","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"p_mathrmR_1R_2 = 65\np_mathrmR_1S_2 = 15\np_mathrmS_1R_2 = 15\np_mathrmS_1S_2 = 05","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"In addition, our model assumes the error probabilities are constrained to be equal:","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"epsilon_mathrmS_1 = epsilon_mathrmS_S = epsilon_mathrmR_1 =epsilon_mathrmR_2 = 10","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"dist = GQEM(; \n    θG = -.12,\n    θN = -1.54,\n    θψO = -.71,\n    θψR = -.86,\n    θψU = 1.26,\n)\nn_trials = 1000\nresponses = rand(dist, n_trials)\ndata = (n_trials, responses)","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"table = to_table(data)","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"4×3 Named Matrix{Int64}\ncondition ╲ word type │       old    related  unrelated\n──────────────────────┼────────────────────────────────\ngist                  │        70         63          6\nverbatim              │        49         48         10\ngist+verbatim         │        64         49          5\nunrelated new         │        46         63         91","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"In the output above, we see the response vector has 16 elements, which correspond to response frequencies for the 16 response patterns:","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"(mathcalR_1mathcalR_2mathcalR_1mathcalR_2)(mathcalR_1mathcalR_2mathcalR_1mathcalS_2) dots (mathcalS_1mathcalS_2mathcalS_1mathcalS_2)","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"where mathcalR and mathcalS correspond to risky and safe options, respectively, and the subscript indexes the choice set.  ","category":"page"},{"location":"parameter_estimation/#The-Turing-Model","page":"Parameter Estimation","title":"The Turing Model","text":"","category":"section"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"@model function model(data)\n    θG ~ VonMises(0, π / 2)\n    θN ~ VonMises(0, π / 2)\n    θψO ~ VonMises(0, π / 2)\n    θψR ~ VonMises(0, π / 2)\n    θψU ~ VonMises(0, π / 2)\n    data ~ GQEM(; θG, θN, θψO, θψR, θψU)\nend","category":"page"},{"location":"parameter_estimation/#Estimate-the-Parameters","page":"Parameter Estimation","title":"Estimate the Parameters","text":"","category":"section"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Now that the Turing model has been specified, we can perform Bayesian parameter estimation with the function sample. We will use the No U-Turn Sampler (NUTS) to sample from the posterior distribution. The inputs into the sample function below are summarized as follows:","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"model(data): the Turing model with data passed\nNUTS(1000, .65): a sampler object for the No U-Turn Sampler for 1000 warmup samples.\nMCMCThreads(): instructs Turing to run each chain on a separate thread\nn_iterations: the number of iterations performed after warmup\nn_chains: the number of chains","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"# Estimate parameters\nchains = sample(model(data), NUTS(1000, .65), MCMCThreads(), 1000, 4)","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"For ease of intepretation, we will convert the numerical indices of preference vector mathbfp to more informative labeled indices. ","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"name_map = Dict(\n    \"p[1]\" => \"pᵣᵣ\",\n    \"p[2]\" => \"pᵣₛ\",\n    \"p[3]\" => \"pₛᵣ\",\n    \"p[4]\" => \"pₛₛ\",\n)\nchains = replacenames(chains, name_map)","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"The output below shows the mean, standard deviation, effective sample size, and rhat for each of the five parameters. The pannel below shows the quantiles of the marginal distributions. ","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Chains MCMC chain (1000×20×4 Array{Float64, 3}):\n\nIterations        = 1001:1:2000\nNumber of chains  = 4\nSamples per chain = 1000\nWall duration     = 2.11 seconds\nCompute duration  = 6.21 seconds\nparameters        = pᵣᵣ, pᵣₛ, pₛᵣ, pₛₛ, ϵ\ninternals         = lp, n_steps, is_accept, acceptance_rate, log_density, hamiltonian_energy, hamiltonian_energy_error, max_hamiltonian_energy_error, tree_depth, numerical_error, step_size, nom_step_size\n\nSummary Statistics\n  parameters      mean       std      mcse    ess_bulk    ess_tail      rhat   ess_per_sec \n      Symbol   Float64   Float64   Float64     Float64     Float64   Float64       Float64 \n\n         pᵣᵣ    0.6580    0.0373    0.0005   6647.4436   3364.7026    1.0008      231.3522\n         pᵣₛ    0.1378    0.0293    0.0004   6554.7555   3621.5757    1.0000      228.1264\n         pₛᵣ    0.1180    0.0271    0.0004   5902.0436   2996.5486    1.0013      205.4099\n         pₛₛ    0.0862    0.0230    0.0003   6936.9475   3246.1778    1.0003      241.4279\n           ϵ    0.1018    0.0122    0.0002   6510.9497   3234.6554    1.0008      226.6018\n\nQuantiles\n  parameters      2.5%     25.0%     50.0%     75.0%     97.5% \n      Symbol   Float64   Float64   Float64   Float64   Float64 \n\n         pᵣᵣ    0.5858    0.6331    0.6580    0.6833    0.7300\n         pᵣₛ    0.0843    0.1172    0.1365    0.1574    0.1980\n         pₛᵣ    0.0694    0.0991    0.1164    0.1362    0.1742\n         pₛₛ    0.0448    0.0699    0.0847    0.1012    0.1362\n           ϵ    0.0797    0.0937    0.1015    0.1095    0.1266","category":"page"},{"location":"parameter_estimation/#Evaluation","page":"Parameter Estimation","title":"Evaluation","text":"","category":"section"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"It is important to verify that the chains converged. We see that the chains converged according to hatr leq 105, and the trace plots below show that the chains look like \"hairy caterpillars\", which indicates the chains did not get stuck. ","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"post_plot = plot(chains, grid = false)\nvline!(post_plot, [missing .65 missing .15 missing .15 missing .05 missing .10], color = :black, linestyle = :dash)","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"The data-generating parameters are represented as black vertical lines in the density plots. As expected, the posterior distributions are centered near the data-generating parameters. Given that the data-generating and estimated model are the same, we would expect the posterior distributions to be near the data-generating parameters. ","category":"page"},{"location":"parameter_estimation/#References","page":"Parameter Estimation","title":"References","text":"","category":"section"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Birnbaum, M. H., & Quispe-Torreblanca, E. G. (2018). TEMAP2. R: True and error model analysis program in R. Judgment and Decision Making, 13(5), 428-440.","category":"page"},{"location":"parameter_estimation/","page":"Parameter Estimation","title":"Parameter Estimation","text":"Lee, M. D. (2018). Bayesian methods for analyzing true-and-error models. Judgment and Decision Making, 13(6), 622-635.","category":"page"},{"location":"plots/#Visualizing-The-Model-Predictions","page":"Plots","title":"Visualizing The Model Predictions","text":"","category":"section"},{"location":"plots/","page":"Plots","title":"Plots","text":"This tutorial demonstrates how to visualize the predictions of the GQEM. When Plots is loaded into your session along with QuantumEpisodicMemory, a method for the function plot is loaded, allowing one to visualize the model predictions as projections within a unit circle.","category":"page"},{"location":"plots/#Load-Packages","page":"Plots","title":"Load Packages","text":"","category":"section"},{"location":"plots/","page":"Plots","title":"Plots","text":"The first step is to load the required packages. You will need to install each package in your local environment in order to run the code locally. We will also set a random number generator so that the results are reproducible.","category":"page"},{"location":"plots/","page":"Plots","title":"Plots","text":"using QuantumEpisodicMemory\nusing Plots","category":"page"},{"location":"plots/#Initialize-Model","page":"Plots","title":"Initialize Model","text":"","category":"section"},{"location":"plots/","page":"Plots","title":"Plots","text":"In the code block below, we define a GQEM model. ","category":"page"},{"location":"plots/","page":"Plots","title":"Plots","text":"model = GQEM(; \n    θG = -.5,\n    θU = 2,\n    θψO = .90,\n    θψR = .10,\n    θψU = -1.5,\n)","category":"page"},{"location":"plots/#Generate-Plot","page":"Plots","title":"Generate Plot","text":"","category":"section"},{"location":"plots/","page":"Plots","title":"Plots","text":"Next, we pass the model object to the plot function to visualize the predictions. Each unit circle consists of the same three bases, but each row has a different state vector, and in each column, the state vector is projected onto a different basis vector. The bases are defined below:  ","category":"page"},{"location":"plots/#Bases","page":"Plots","title":"Bases","text":"","category":"section"},{"location":"plots/","page":"Plots","title":"Plots","text":"Gist basis: boldsymbolchi_G =  ketG ketG^perp \nVerbatim basis: boldsymbolchi_V =  ketV ketV^perp \nNew Related basis: boldsymbolchi_N =  ketN ketN^perp ","category":"page"},{"location":"plots/","page":"Plots","title":"Plots","text":"Unit circles in each row include the same state vector, shown in red to distinguish them from the basis vectors. Each instruction condition is associated with a unique state vector, defined as:","category":"page"},{"location":"plots/#State-Vectors","page":"Plots","title":"State Vectors","text":"","category":"section"},{"location":"plots/","page":"Plots","title":"Plots","text":"Old state vector: ketpsi_O\nNew related state vector: ketpsi_R\nNew unrelated state vector: ketpsi_U","category":"page"},{"location":"plots/#Projectors-and-Projections","page":"Plots","title":"Projectors and Projections","text":"","category":"section"},{"location":"plots/","page":"Plots","title":"Plots","text":"The projectors are denoted by a dashed black line. By contrast, the projections are denoted by a green, thick arrow. ","category":"page"},{"location":"plots/","page":"Plots","title":"Plots","text":"plot(model)","category":"page"},{"location":"plots/#References","page":"Plots","title":"References","text":"","category":"section"},{"location":"plots/","page":"Plots","title":"Plots","text":"Trueblood, J. S., & Hemmer, P. (2017). The generalized quantum episodic memory model. Cognitive Science, 41(8), 2089-2125.","category":"page"},{"location":"model_description/#Introduction","page":"Model Description","title":"Introduction","text":"","category":"section"},{"location":"model_description/#Task","page":"Model Description","title":"Task","text":"","category":"section"},{"location":"model_description/#Law-of-Total-Probability","page":"Model Description","title":"Law of Total Probability","text":"","category":"section"},{"location":"model_description/#Subadditivity","page":"Model Description","title":"Subadditivity","text":"","category":"section"},{"location":"model_description/#Model","page":"Model Description","title":"Model","text":"","category":"section"},{"location":"model_description/","page":"Model Description","title":"Model Description","text":"using LaTeXStrings\nusing QuantumEpisodicMemory\nusing Plots","category":"page"},{"location":"model_description/#Bases","page":"Model Description","title":"Bases","text":"","category":"section"},{"location":"model_description/","page":"Model Description","title":"Model Description","text":"Gist basis: boldsymbolchi_G =  ketG ketG^perp \nVerbatim basis: boldsymbolchi_V =  ketV ketV^perp \nNew Related basis: boldsymbolchi_N =  ketN ketN^perp ","category":"page"},{"location":"model_description/#State-Vectors","page":"Model Description","title":"State Vectors","text":"","category":"section"},{"location":"model_description/","page":"Model Description","title":"Model Description","text":"Old state vector: ketpsi_O\nNew related state vector: ketpsi_R\nNew unrelated state vector: ketpsi_U","category":"page"},{"location":"model_description/#Parameters","page":"Model Description","title":"Parameters","text":"","category":"section"},{"location":"model_description/","page":"Model Description","title":"Model Description","text":"theta_G:\ntheta_U:\ntheta_psi_O:\ntheta_psi_R:\ntheta_psi_U:","category":"page"},{"location":"model_description/","page":"Model Description","title":"Model Description","text":"θG = -.5\nθU = 2\nθψO = .90\nθψR = .15\nθψU = -1.5","category":"page"},{"location":"model_description/","page":"Model Description","title":"Model Description","text":"dist = GQEM(; θG, θU, θψO, θψR, θψU)","category":"page"},{"location":"model_description/","page":"Model Description","title":"Model Description","text":"plot(dist, θψR, θG; state_label = L\"\\psi_R\")","category":"page"},{"location":"#QuantumEpisodicMemory.jl","page":"Home","title":"QuantumEpisodicMemory.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for QuantumEpisodicMemory.jl","category":"page"}]
}
