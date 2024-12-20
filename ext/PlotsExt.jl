module PlotsExt

using LaTeXStrings
using Plots
using Plots.PlotMeasures
using QuantumEpisodicMemory

import Plots: plot
import Plots: plot!
import QuantumEpisodicMemory: plot_predictions

using QuantumEpisodicMemory: 𝕦

"""
    plot(dist::AbstractGQEM; font_size = 10, kwargs...)

Plots the projection of an `AbstractGQEM` model as a 3 x 3 set of unit circles. Across all unit circles, 
the bases are the same. However, the state vector varies by row and the basis vector onto which the state vector is projected varies by column. 

# Arguments

- `dist::AbstractGQEM`: a GQEM distribution object

# Keywords 

- `font_size = 10`: font size of the vector labels 
- `kwargs...`: optional keyword arguments passed to the `plot` functions 

# Example 

```julia 
dist = GQEM(; 
    θG = -.5,
    θU = 2,
    θψO = .90,
    θψR = .15,
    θψU = -1.5,
)
       
plot(dist)
```
"""
function plot(dist::AbstractGQEM; font_size = 10, kwargs...)
    plots = Plots.Plot[]
    (; θG, θU, θψO, θψR, θψU) = dist
    θV = 0.0
    Ψ = enumerate((θψO, θψR, θψU))
    θ_basis = (θV, θG, θU)
    state_labels = (L"\psi_O", L"\psi_R", L"\psi_U")
    _model_plot = setup_bases(dist; font_size, kwargs...)
    # iterate over the state vectors 
    for (i, θψ) ∈ Ψ
        # iterate over projections
        for j ∈ 1:3
            model_plot = deepcopy(_model_plot)

            model_plot = plot!(
                dist,
                model_plot,
                θψ,
                θ_basis[j];
                state_label = state_labels[i],
                font_size,
                kwargs...
            )
            push!(plots, model_plot)
        end
    end
    return plot(
        plots...;
        top_margin = 5mm,
        bottom_margin = 4mm,
        right_margin = -2mm,
        left_margin = -2mm,
        size = (1200, 800)
    )
end

function plot!(
    dist::AbstractGQEM,
    model_plot,
    θψ,
    θ_basis;
    state_label = L"\ket{\psi}",
    font_size = 10,
    kwargs...
)
    ψ = compute_state(θψ)
    plot_state!(model_plot, ψ; label = state_label, font_size, kwargs...)
    proj = compute_projection(θ_basis, ψ)
    plot_projection!(model_plot, proj; kwargs...)
    plot_projector!(model_plot, proj, ψ; kwargs...)
    return model_plot
end

"""
    plot(
        dist::AbstractGQEM,
        θψ,
        θ_basis;
        state_label = L"psi",
        font_size = 10,
        kwargs...
    )

Plots the projection from a given state vector onto a given basis vector within a unit circle. 

# Arguments

- `dist::AbstractGQEM`: a GQEM distribution object
- `θψ`: the angle of the state vector with respect to the verbatim basis 
- `θ_basis`: the angle of the basis onto which the state vector is projected. The angle
    is with respect to the verbatim basis.

# Keywords 

- `state_label = "L"psi"`: the label of the state vector ket
- `font_size = 10`: font size of the vector labels 
- `kwargs...`: optional keyword arguments passed to the `plot` functions 

# Example 

```julia 
dist = GQEM(; 
    θG = -.5,
    θU = 2,
    θψO = .90,
    θψR = .15,
    θψU = -1.5,
)
       
plot(dist, .1, -.5)
```
"""
function plot(
    dist::AbstractGQEM,
    θψ,
    θ_basis;
    state_label = L"\psi",
    font_size = 10,
    kwargs...
)
    model_plot = setup_bases(dist; font_size, kwargs...)
    return plot!(
        dist,
        model_plot,
        θψ,
        θ_basis;
        state_label,
        font_size = 10,
        kwargs...
    )
end

function setup_bases(dist; font_size, kwargs...)
    (; θG, θU) = dist
    my_cgrad = cgrad([:black, :grey], 3)
    _model_plot = plot_circle(1; margin = -2mm, kwargs...)
    plot_bases!(_model_plot, θG; label = "G", color = my_cgrad[1], font_size, kwargs...)
    plot_bases!(_model_plot, 0; label = "V", color = my_cgrad[2], font_size, kwargs...)
    plot_bases!(_model_plot, θU; label = "U", color = my_cgrad[3], font_size, kwargs...)
    return _model_plot
end

function plot_circle(r; kwargs...)
    return plot(
        make_circle(r),
        seriestype = [:shape],
        lw = 1,
        linecolor = :black,
        fillalpha = 0,
        leg = false,
        grid = false,
        aspect_ratio = 1,
        framestyle = :none;
        xaxis = nothing,
        yaxis = nothing,
        lims = (-1.05, 1.05),
        kwargs...
    )
end

function plot_basis!(model_plot, b; color, label, font_size, kwargs...)
    plot!(model_plot, [0, b[1]], [0, b[2]]; arrow = arrow(:closed, 0.50), color)
    annotate!(
        model_plot,
        (b[1] * 1.2, b[2] * 1.2, text(label, font_size, :left, :center, :black))
    )
    return nothing
end

function plot_bases!(model_plot, θ; label, font_size, kwargs...)
    b = make_basis(θ)
    plot_basis!(model_plot, b; label = L"""| %$label \rangle""", font_size, kwargs...)
    b = make_basis(mod(θ + π / 2, π * 1))
    plot_basis!(
        model_plot,
        b;
        label = L"""| %$label \rangle^{\perp}""",
        font_size,
        kwargs...
    )
    return model_plot
end

function plot_state!(model_plot, ψ; label, font_size, kwargs...)
    plot!(
        model_plot,
        [0, ψ[1]],
        [0, ψ[2]];
        color = RGB(161 / 256, 105 / 256, 101 / 256),
        arrow = arrow(:closed, 0.50),
        kwargs...
    )
    annotate!(
        model_plot,
        (
            ψ[1] * 1.15,
            ψ[2] * 1.15,
            text(L"|" * label * L"\rangle", font_size, :left, :center, :black)
        )
    )
    return model_plot
end

function plot_projection!(model_plot, proj; kwargs...)
    plot!(
        model_plot,
        [0, proj[1]],
        [0, proj[2]];
        arrow = arrow(:closed, 0.50),
        linewidth = 2.5,
        color = RGB(136 / 256, 168 / 256, 138 / 256),
        top_margin = 5mm,
        bottom_margin = 2mm,
        right_margin = -5mm,
        left_margin = -2mm,
        kwargs...
    )
    return model_plot
end

function plot_projector!(model_plot, proj, ψ; kwargs...)
    plot!(
        model_plot,
        [proj[1], ψ[1]],
        [proj[2], ψ[2]];
        color = :black,
        linewidth = 1,
        linestyle = :dash,
        kwargs...
    )
    return model_plot
end

function make_basis(θ)
    b = [1, 0]
    v1 = 𝕦(θ) * b
    x = range(-1, 1, length = 100)
    return v1
end

function compute_state(θψ)
    V = [1, 0]
    # initial state relative to V
    return 𝕦(θψ) * V
end

function compute_projection(θ, ψ)
    V = [1, 0]
    # basis vector for unrelated new 
    N = 𝕦(θ) * V
    # projector matrix for unrelated trace
    MN = N * N'
    # projection onto unrelated trace
    return MN * ψ
end

function make_circle(r)
    θ = LinRange(0, 2 * π, 500)
    return @. r * sin(θ), r * cos(θ)
end

"""
    plot_predictions(
        preds::Matrix{<:Matrix{<:Real}}`,
        responses::Vector{<:Int},
        n_trials::Int;
        row_labels = ["Gist", "Verbatim", "Gist+Verbatim", "Unrelated"],
        col_labels = ["Old", "Related", "Unrelated"],
        kwargs...
    )

Generates a plot of posterior or prior predictive distributions for each condition. 

# Arguments

- `preds::Matrix{<:Matrix{<:Real}}`: predictions for the GQEM where each sub-matrix is contains the predictions across all conditions
    for a single simulation
- `responses::Matrix{<:Int}`: a matrix of *yes* responses where rows correspond to instruction conditions, and columns correspond
        to word types
- `n_trials::Int`: the number of trials per condition.

# Keywords

- `row_labels = ["Gist", "Verbatim", "Gist+Verbatim", "Unrelated"]`: row labels for the grid plot 
- `col_labels = ["Old", "Related", "Unrelated"]`: column labels of the grid plot
- `kwargs...`: optional keyword options passed to override default values for `histogram`
"""
function plot_predictions(
    preds::Matrix{<:Matrix{<:Real}},
    responses::Matrix{<:Integer},
    n_trials::Int;
    row_labels = ["Gist", "Verbatim", "Gist+Verbatim", "Unrelated"],
    col_labels = ["Old", "Related", "Unrelated"],
    kwargs...
)
    preds = stack(preds, dims = 3)
    n_rows = 5
    n_cols = 4
    p = plot(
        legend = false,
        layout = grid(
            n_rows,
            n_cols,
            heights = compute_weights(n_rows),
            widths = compute_weights(n_cols)
        ),
        #bottom_margin=[-5mm -5mm],
        margin = 0.25Plots.cm,
        size = (800, 600),
        dpi = 300
    )

    [
        plot!(
            p[r, 1],
            (0, 0),
            xlimits = (-0.1, 0.1),
            ylimits = (-0.1, 0.1),
            grid = false,
            axis = ([], false)
        ) for r ∈ 1:n_rows
    ]
    [
        plot!(
            p[1, c],
            (0, 0),
            xlimits = (-1, 1),
            ylimits = (-1, 1),
            grid = false,
            axis = ([], false)
        ) for c ∈ 1:n_cols
    ]
    [
        histogram!(
            p[r + 1, c + 1],
            preds[r, c, :],
            xlims = (0, 1),
            ylims = (0, 20),
            leg = false,
            grid = false,
            color = RGB(123 / 256, 156 / 256, 126 / 256),
            norm = true
        ) for r ∈ 1:(n_rows - 1), c ∈ 1:(n_cols - 1)
    ]

    data_probs = responses ./ n_trials
    data_probs = data_probs'[:]
    i = 1
    for r ∈ 2:n_rows, c ∈ 2:n_cols
        vline!(p[r, c], [data_probs[i]], color = :black, linewidth = 2)
        i += 1
    end
    [
        annotate!(
            p[i, 1],
            0.0,
            0.0,
            text(row_labels[i - 1], 10, :center, :center, rotation = 90)
        ) for i ∈ 2:n_rows
    ]
    [
        annotate!(p[1, i], 0.0, 0.0, text(col_labels[i - 1], 10, :center, :center)) for
        i ∈ 2:n_cols
    ]
    return p
end

function compute_weights(n)
    w = [0.01, fill(0.99, n)...]
    weights = w ./ sum(w)
    [1.0 - sum(weights[2:end]), weights[2:end]...]
end

end
