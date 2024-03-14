######
# Uniform Proposal Sampler
#
# This file contains all types and functionality to produce uniform samples for
# a given setup.
######



struct UniformSampler{S<:AbstractComputationSetup,D} <: AbstractProposalSampler
    # TODO: think about a default setup
    stp::S
    dist::D

    function UniformSampler(stp::S,bounds::AbstractVector) where {S<: AbstractComputationSetup}
        dist = product_distribution([Uniform(b...) for b in bounds])
        return new{S,typeof(dist)}(stp,dist)
    end
end

function train!(::UniformSampler) 
    @warn "Uniform sampler does not need to be trained."
    return nothing
end

# TODO: generalize this! -> write issue about this! 
Base.eltype(::UniformSampler) = Float64

function _weight(u::UniformSampler,x)
    pdf(u.dist,x)
end

function _rand!(rng::AbstractRNG, u::UniformSampler, x::AbstractVecOrMat{T}) where {T<:Real}
    return Distributions.rand!(rng, u.dist, x)
end

