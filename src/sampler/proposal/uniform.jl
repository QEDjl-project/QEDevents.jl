######
# Uniform Proposal Sampler
#
# This file contains all types and functionality to produce uniform samples for
# a given setup.
######

"""

    UniformSampler(stp::QEDprocesses.AbstractComputationSetup, bounds::AbstractVector)

# Example 
```
using QEDprocesses, QEDevents
struct TestSetup <: AbstractComputationSetup end

lower_bounds = [0,-1,3]
upper_bounds = [1,1,8]

uniform_sampler = UniformSampler(lower_bounds, upper_bounds)

weight(uniform_sampler,[0.5,0.0,4.0])
```

"""
struct UniformSampler{DIM,D} <: AbstractProposalSampler
    dist::D

    function UniformSampler(lower_bounds::AbstractVector,upper_bounds::AbstractVector) 
        dist = product_distribution(Uniform.(lower_bounds,upper_bounds))
        return new{typeof(dist)}(dist)
    end
end

function setup(::UniformSampler) 
    @warn "Uniform sampler does not need a setup."
    return nothing
end

function train!(::UniformSampler, config...) 
    @warn "Uniform sampler does not need to be trained."
    return nothing
end

# TODO: generalize this! -> write issue about this! 
Base.eltype(::UniformSampler) = Float64


Base.size(s::UniformSampler) = size(s.dist)
Base.size(s::UniformSampler, k) = size(s)[k]

function _weight(u::UniformSampler,x)
    pdf(u.dist,x)
end

function _rand!(rng::AbstractRNG, u::UniformSampler, x::AbstractVecOrMat{T}) where {T<:Real}
    return Distributions.rand!(rng, u.dist, x)
end

