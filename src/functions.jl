"""
    compute_preds(dist::AbstractGQEM)

Returns a matrix of predictions for the GQEM model. 

The output is organized in a matrix where rows correspond to instructions and 
columns correspond to word type:

|                 | word type |         |           |
|-----------------|-----------|---------|-----------|
| condition       | old       | related | unrelated |
| gist            | 0.65      | 0.65    | 0.9       |
| verbatim        | 0.35      | 0.35    | 0.65      |
| Gist + verbatim | 0.69      | 0.69    | 0.91      |
| unrelated new   | 0.9       | 0.9     | 1         |

# Arguments

- `dist::AbstractGQEM`: a GQEM distribution object

# Example

```julia 
using QuantumEpisodicMemory

# basis rotation parameters relative to the standard verbatim basis, V
θG = -.12
θU = -1.54
θψO = -.71
θψR = -.86
θψU = 1.26

dist = GQEM(; θG, θU, θψO, θψR, θψU)
preds = compute_preds(dist)
preds = to_table(preds)
```
"""
function compute_preds(dist::AbstractGQEM{T}) where {T}
    (; θG, θU, θψO, θψR, θψU) = dist
    Ψ = enumerate((θψO, θψR, θψU))
    preds = zeros(T, 4, 3)
    for (i, θψ) in Ψ
        preds[1, i] = compute_prob(θG, θψ)
        preds[2, i] = compute_prob(0.0, θψ)
        preds[3, i] = prob_gist_verbatim(θG, θψ)
        preds[4, i] = compute_prob(θU, θψ)
    end
    preds .= min.(preds, 1.0)
    return preds
end

"""
    prob_verbatim(θψ)

Probability of accepting a word in the verbatim + gist instruction condition. 

# Arguments

- `θψ`: angle in radians between verbatim basis and a superposition
"""
function prob_gist_verbatim(θG, θψ)
    # basis vectors for verbatim
    V = [1, 0]
    V̅ = [0, 1]
    # basis vectors for gist 
    G = 𝕦(θG) * V
    G̅ = 𝕦(θG) * V̅
    # initial state relative to V
    ψ = 𝕦(θψ) * V
    # projector matrix for gist trace
    MG = G * G'
    # projector matrix for compliment of gist trace 
    MG̅ = G̅ * G̅'
    # projector matrix for verbatim trace
    MV = V * V'
    # projection onto gist trace
    proj_G = MG * ψ
    # projection onto compliment of gist trace then verbatim trace 
    proj_VG = MV * MG̅ * ψ
    # probability of retrieving gist + prob not retrieving gist and retrieving verbatim
    return proj_G' * proj_G + proj_VG' * proj_VG
end

"""
    compute_prob(θ, θψ)

Probability of accepting a word. 

# Arguments

- `θ`: angle in radians between verbatim and other bases 
- `θψ`: angle in radians between verbatim basis and a superposition
"""
function compute_prob(θ, θψ)
    # basis vectors for verbatim
    V = [1, 0]
    # rotated basis vectors 
    G = 𝕦(θ) * V

    ψ = 𝕦(θψ) * V
    # projector matrix for gist trace
    MG = G * G'

    # projection onto gist trace
    proj_G = MG * ψ
    # probability of retrieving gist
    return proj_G' * proj_G
end

"""
    rand(dist::AbstractGQEM, n::Union{Int,Array{Int,N}})

Generates data from the GQEM model 

The output is organized in a matrix where rows correspond to instructions and 
columns correspond to word type:

|                 | word type |         |           |
|-----------------|-----------|---------|-----------|
| condition       | old       | related | unrelated |
| gist            | 3         | 5       | 9         |
| verbatim        | 0         | 1       | 2         |
| gist + verbatim | 4         | 1       | 10        |
| unrelated new   | 5         | 8       | 2         |

# Arguments

- `dist::AbstractGQEM`: a GQEM distribution object

# Example 

```julia 
using QuantumEpisodicMemory

# basis rotation parameters relative to the standard verbatim basis, V
θG = -.12
θU = -1.54
θψO = -.71
θψR = -.86
θψU = 1.26

dist = GQEM(; θG, θU, θψO, θψR, θψU)
data = rand(dist, 100)
table = to_table(data)
```
"""
function rand(dist::AbstractGQEM, n::Array{Int, N}) where {N}
    preds = compute_preds(dist)
    return @. rand(Binomial(n, preds))
end

function rand(dist::AbstractGQEM, n::Int)
    preds = compute_preds(dist)
    return @. rand(Binomial(n, preds))
end

"""
    logpdf(dist::AbstractGQEM, n::Union{Int,Array{Int,N}}, data::Array{Int,N})

Returns the log likelihood of the data for the GQEM model.

The data are  organized in a matrix where rows correspond to instructions and 
columns correspond to word type:

|                 | word type |         |           |
|-----------------|-----------|---------|-----------|
| condition       | old       | related | unrelated |
| gist            | 3         | 5       | 9         |
| verbatim        | 0         | 1       | 2         |
| gist + verbatim | 4         | 1       | 10        |
| unrelated new   | 5         | 8       | 2         |

# Arguments

- `dist::AbstractGQEM`: a GQEM distribution object
- `n::Union{Int, Array{Int, N}}`: the number of trials 
- `data::Array{Int, N}`: number of "yes" responses 

# Example 

```julia 
using QuantumEpisodicMemory

# basis rotation parameters relative to the standard verbatim basis, V
θG = -.12
θU = -1.54
θψO = -.71
θψR = -.86
θψU = 1.26

dist = GQEM(; θG, θU, θψO, θψR, θψU)
data = rand(dist, 100)
logpdf(dist, 100, data)
```
"""
function logpdf(
    dist::AbstractGQEM,
    n::Union{Int, Array{Int, N}},
    data::Array{Int, N}
) where {N}
    preds = compute_preds(dist)
    return @. logpdf(Binomial(n, preds), data)
end

loglikelihood(dist::AbstractGQEM, data::Tuple) = sum(logpdf(dist, data...))

"""
    pdf(dist::AbstractGQEM, n::Union{Int,Array{Int,N}}, data::Array{Int,N})

Returns the likelihood of the data for the GQEM model.

The data are  organized in a matrix where rows correspond to instructions and 
columns correspond to word type:

|                 | word type |         |           |
|-----------------|-----------|---------|-----------|
| condition       | old       | related | unrelated |
| gist            | 3         | 5       | 9         |
| verbatim        | 0         | 1       | 2         |
| gist + verbatim | 4         | 1       | 10        |
| unrelated new   | 5         | 8       | 2         |

# Arguments

- `dist::AbstractGQEM`: a GQEM distribution object
- `n::Union{Int, Array{Int, N}}`: the number of trials 
- `data::Array{Int, N}`: number of "yes" responses 

# Example 

```julia 
using QuantumEpisodicMemory

# basis rotation parameters relative to the standard verbatim basis, V
θG = -.12
θU = -1.54
θψO = -.71
θψR = -.86
θψU = 1.26

dist = GQEM(; θG, θU, θψO, θψR, θψU)
data = rand(dist, 100)
pdf(dist, 100, data)
```
"""
function pdf(
    dist::AbstractGQEM,
    n::Union{Int, Array{Int, N}},
    data::Array{Int, N}
) where {N}
    return exp.(logpdf(dist, n, data))
end

"""
    𝕦(θ)

Unitary transformation matrix.

# Arguments

- `θ`: angle in radians
"""
function 𝕦(θ)
    return [cos(θ) -sin(θ)
        sin(θ) cos(θ)]
end

"""
    to_table(x)

Converts matrix to table with labeled dimensions and indices. 

# Example

```julia 
using QuantumEpisodicMemory

# basis rotation parameters relative to the standard verbatim basis, V
θG = -.12
θU = -1.54
θψO = -.71
θψR = -.86
θψU = 1.26

dist = GQEM(; θG, θU, θψO, θψR, θψU)
data = rand(dist, 100)
to_table(data)
```

```julia
4×3 Named Matrix{Int64}
condition ╲ word type │       old    related  unrelated
──────────────────────┼────────────────────────────────
gist                  │        65         51          2
verbatim              │        66         41          9
gist+verbatim         │        58         52          5
unrelated new         │        50         57         91
```
"""
function to_table(x)
    return NamedArray(
        x,
        (["gist", "verbatim", "gist+verbatim", "unrelated new"],
            ["old", "related", "unrelated"]),
        ("condition", "word type")
    )
end
