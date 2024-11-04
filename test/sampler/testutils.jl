using Distributions: Distributions
import Distributions: pdf, quantile, Normal
import StatsBase: fit, Histogram, middle
using LinearAlgebra

struct TestProjection{F,D<:Distributions.UnivariateDistribution}
    proj::F
    target_dist::D
end

# https://github.com/JuliaStats/Distributions.jl/blob/47c040beef8c61bad3e1eefa4fc8194e3a62b55a/test/testutils.jl#L188C10-L188C22
"""
    test_univariate_samples(p::TestProjection,samples)

Tests if the given projection of the given samples follow the target_dist.
"""
function test_univariate_samples(
    p::TestProjection, samples::AbstractVector{<:ParticleStateful}; nbins=50, q=1e-4
)
    moms = momentum.(samples)
    samples_proj = p.proj.(moms)

    h = normalize(fit(Histogram, samples_proj; nbins=nbins, closed=:right); mode=:pdf)
    ww = h.weights
    w = map(Base.Fix1(pdf, p.target_dist), h.edges[1])
    n = length(h.edges[1]) - 1
    max_w = maximum(w)

    for i in 1:n
        m = middle(w[i + 1], w[i])
        bp = Normal(m, max_w * sqrt(q))
        clb = max(quantile(bp, q / 2), 0.0)
        cub = quantile(bp, 1 - q / 2)
        @assert cub >= clb
        if !(clb <= ww[i]) || !(ww[i] <= cub)
            return false
        end
    end

    return true
end
