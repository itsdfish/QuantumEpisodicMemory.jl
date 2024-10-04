module PlotsExt

using LaTeXStrings
using QuantumEpisodicMemory
using Plots

import Plots: plot
using QuantumEpisodicMemory: 𝕦

"""
    plot(dist::AbstractGQEM; font_size = 10, kwargs...)

Plots the projection of an `AbstractGQEM` model as a set of unit circles. 

# Arguments

- `dist::AbstractGQEM`: a GQEM distribution object

# Keywords 

- `font_size = 10`: font size of the vector labels 
- `kwargs...`: optional keyword arguments passed to the `plot` functions 
"""
function plot(dist::AbstractGQEM; font_size = 10, kwargs...)
    plots = Plots.Plot[]
    (; θG, θU, θψO, θψR, θψU) = dist
    θV = 0.0
    Ψ = enumerate((θψO, θψR, θψU))
    my_cgrad = cgrad([:black, :grey], 3)
    _model_plot = plot_circle(1; kwargs...)
    plot_bases!(_model_plot, θG; label = "G", color = my_cgrad[1], font_size, kwargs...)
    plot_bases!(_model_plot, 0; label = "V", color = my_cgrad[2], font_size, kwargs...)
    plot_bases!(_model_plot, θU; label = "U", color = my_cgrad[3], font_size, kwargs...)
    basis_theta = (θV, θG, θU)
    state_labels = (L"\psi_V", L"\psi_G", L"\psi_U")
    # iterate over the state vectors 
    for (i, θψ) ∈ Ψ
        # iterate over projections
        for j ∈ 1:3
            model_plot = deepcopy(_model_plot)
            ψ = compute_state(θψ)
            plot_state!(model_plot, ψ; label = state_labels[i], font_size, kwargs...)
            proj = compute_projection(basis_theta[j], ψ)
            plot_projection!(model_plot, proj; kwargs...)
            plot_projector!(model_plot, proj, ψ; kwargs...)
            push!(plots, model_plot)
        end
    end
    return plot(plots...; size = (1200, 800))
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
        kwargs...
    )
end

function plot_basis!(model_plot, b; color, label, font_size, kwargs...)
    plot!(model_plot, [0, b[1]], [0, b[2]]; arrow = arrow(:closed, 0.50), color)
    annotate!(
        model_plot,
        (b[1] * 1.15, b[2] * 1.15, text(label, font_size, :left, :center, :black))
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
        #linewidth = 2,
        #linestyle = :dot,
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
        linewidth = 2,
        color = RGB(136 / 256, 168 / 256, 138 / 256),
        #linestyle = :dot,
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

end
