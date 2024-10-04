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
    # probability of retrieving gist + prob not retrieving gist and verbatim
    return proj_G' * proj_G + proj_VG' * proj_VG
end

"""
    prob_verbatim(θψ)

Probability of accepting a word in the verbatim instruction condition. 

# Arguments

- `θψ`: angle in radians between verbatim basis and a superposition
"""
function prob_verbatim(θψ)
    # basis vector for verbatim
    V = [1, 0]
    # initial state relative to V
    ψ = 𝕦(θψ) * V
    # projector matrix for verbatim trace
    MV = V * V'
    # projection onto verbatim trace
    proj_V = MV * ψ
    # probability of retrieving verbatim
    return proj_V' * proj_V
end

"""
    prob_gist(θG, θψ)

Probability of accepting a word in the gist instruction condition. 

# Arguments

- `θG`: angle in radians between verbatim and gist bases 
- `θψ`: angle in radians between verbatim basis and a superposition
"""
function prob_gist(θG, θψ)
    # basis vectors for verbatim
    V = [1, 0]
    # basis vector for gist 
    G = 𝕦(θG) * V

    ψ = 𝕦(θψ) * V
    # projector matrix for gist trace
    MG = G * G'

    # projection onto gist trace
    proj_G = MG * ψ
    # probability of retrieving gist
    return proj_G' * proj_G
end

"""
    prob_unrelated(θU, θψ)

Probability of accepting a word in the new unrelated instruction condition. 

# Arguments

- `θU`: angle in radians between verbatim and new unrelated bases 
- `θψ`: angle in radians between verbatim basis and a superposition
"""
function prob_unrelated(θU, θψ)
    # basis vectors for verbatim
    V = [1, 0]
    # basis vector for unrelated new 
    N = 𝕦(θU) * V

    # initial state relative to V
    ψ = 𝕦(θψ) * V
    # projector matrix for unrelated trace
    MN = N * N'

    # projection onto unrelated trace
    proj_N = MN * ψ
    # probability of responding unrelated new
    return proj_N' * proj_N
end

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
"""
function compute_preds(dist::AbstractGQEM{T}) where {T}
    (; θG, θU, θψO, θψR, θψU) = dist
    Ψ = enumerate((θψO, θψR, θψU))
    preds = zeros(T, 4, 3)
    for (i, θψ) in Ψ
        preds[1, i] = prob_gist(θG, θψ)
        preds[2, i] = prob_verbatim(θψ)
        preds[3, i] = prob_gist_verbatim(θG, θψ)
        preds[4, i] = prob_unrelated(θU, θψ)
    end
    preds .= min.(preds, 1.0)
    return preds
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
"""
function logpdf(
    dist::AbstractGQEM,
    n::Union{Int, Array{Int, N}},
    data::Array{Int, N}
) where {N}
    preds = compute_preds(dist)
    return sum(@. logpdf(Binomial(n, preds), data))
end

loglikelihood(dist::AbstractGQEM, data::Tuple) = logpdf(dist, data...)

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
"""
function pdf(
    dist::AbstractGQEM,
    n::Union{Int, Array{Int, N}},
    data::Array{Int, N}
) where {N}
    return logpdf(dist, n, data) |> exp
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
4×3 Named Matrix{Float64}
condition ╲ word type │       old    related  unrelated
──────────────────────┼────────────────────────────────
gist                  │  0.690462   0.545336  0.0359636
verbatim              │  0.575113   0.425675   0.093524
gist + verbatim       │  0.694898   0.551852  0.0497793
unrelated new         │  0.455457   0.604619   0.887783
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
