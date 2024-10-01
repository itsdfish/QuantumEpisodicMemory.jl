using SafeTestsets

@safetestset "logpdf" begin
    using QuantumEpisodicMemory
    using Random
    using Test

    Random.seed!(155)

    θG = π / 2
    θN = π / 3
    θψO = π / 1
    θψR = π / 4
    θψU = π / 2

    n_trials = 10_000
    dist = GQEM(; θG, θN, θψO, θψR, θψU)

    data = rand(dist, n_trials)

    θGs = range(θG * 0.8, θG * 1.2, length = 100)
    LLs = map(x -> logpdf(GQEM(; θG = x, θN, θψO, θψR, θψU), n_trials, data), θGs)
    mv, mi = findmax(LLs)
    @test θGs[mi] ≈ θG atol = 1e-2

    θNs = range(θN * 0.8, θN * 1.2, length = 100)
    LLs = map(x -> logpdf(GQEM(; θG, θN = x, θψO, θψR, θψU), n_trials, data), θNs)
    mv, mi = findmax(LLs)
    @test θNs[mi] ≈ θN atol = 1e-2

    θψOs = range(θψO * 0.8, θψO * 1.2, length = 100)
    LLs = map(x -> logpdf(GQEM(; θG, θN, θψO = x, θψR, θψU), n_trials, data), θψOs)
    mv, mi = findmax(LLs)
    @test θψOs[mi] ≈ θψO atol = 1e-2

    θψRs = range(θψR * 0.8, θψR * 1.2, length = 100)
    LLs = map(x -> logpdf(GQEM(; θG, θN, θψO, θψR = x, θψU), n_trials, data), θψRs)
    mv, mi = findmax(LLs)
    @test θψRs[mi] ≈ θψR atol = 1e-2

    θψUs = range(θψU * 0.8, θψU * 1.2, length = 100)
    LLs = map(x -> logpdf(GQEM(; θG, θN, θψO, θψR, θψU = x), n_trials, data), θψUs)
    mv, mi = findmax(LLs)
    @test θψUs[mi] ≈ θψU atol = 1e-2
end
