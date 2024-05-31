
# N ... dimension of the vector space,
# N=0 ... single mom,
# N=1 ... vector of moms
abstract type ParticleLikeVariate{N} <: VariateForm end
const SingleParticleVariate = ParticleLikeVariate{0}

"""
    ParticleDistribution

TBW

"""
abstract type ParticleDistribution{F<:ParticleLikeVariate} <: Sampleable{F,Continuous} end

# generic sampler
function Distributions.rand(
    rng::AbstractRNG, s::Sampleable{<:ParticleLikeVariate}, dims::Dims
)
    out = Array{eltype(s)}(undef, dims)
    return @inbounds rand!(rng, sampler(s), out)
end

# multiple samples
function Distributions._rand!(rng::AbstractRNG, d::ParticleDistribution, A::AbstractArray)
    @inbounds for i in eachindex(A)
        A[i] = Distributions.rand(rng, d)
    end
    return A
end
