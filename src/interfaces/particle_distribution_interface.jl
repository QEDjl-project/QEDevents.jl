# N ... dimension of the vector space,
# N=0 ... single mom,
# N=1 ... vector of moms
abstract type ParticleLikeVariate{N} <: VariateForm end
const SingleParticleVariate = ParticleLikeVariate{0}

Base.length(::Sampleable{SingleParticleVariate}) = 1
Base.size(::Sampleable{SingleParticleVariate}) = ()
Base.eltype(::Type{<:Sampleable{SingleParticleVariate,Continuous}}) = SFourMomentum

# TODO: really necessary?
function Distributions.nsamples(
    ::Type{D}, x::Number
) where {D<:Sampleable{SingleParticleVariate}}
    return 1
end
function Distributions.nsamples(
    ::Type{D}, x::AbstractArray
) where {D<:Sampleable{SingleParticleVariate}}
    return length(x)
end

abstract type ParticleDistribution{F<:ParticleLikeVariate} <: Sampleable{F,Continuous} end

"""

    SingleParticleDistribution

Base type for sample drawing from single particle distributions. The following interface functions
should be implemented:

```julia
    QEDevents.particle(d::SingleParticleDistribution)
    Distributions.rand(rng::AbstractRNG,d::SingleParticleDistribution) -> SFourMomentum
    QEDevents._weight(d::SingleParticleDistribution,x::SFourMomentum) -> <: Real
```

Optional:

```julia
    QEDevents.direction(d::SingleParticleDistribution)
    QEDevents._assert_valid_input(d::SingleParticleDistribution,x::SFourMomentum)
    QEDevents._post_processing(d::SingleParticleDistribution,x::SFourMomentum,out::Real)
    QEDevents.max_weight(d::SingleParticleDistribution)
```

"""
const SingleParticleDistribution = ParticleDistribution{SingleParticleVariate}

Broadcast.broadcastable(d::SingleParticleDistribution) = Ref(d)

"""

    particle(::SingleParticleDistribution)

Interface function to be implemented. Return the particle associated with the given distribution.
"""
function particle end

# multiple samples
function Distributions.rand(
    rng::AbstractRNG, s::Sampleable{SingleParticleVariate}, dims::Dims
)
    out = Array{eltype(s)}(undef, dims)
    return @inbounds rand!(rng, sampler(s), out)
end

#=
#
# TODO: is this needed?
function rand(
    rng::AbstractRNG, s::Sampleable{<:SingleParticleVariate}, dims::Dims,
)
    sz = size(s)
    ax = map(Base.OneTo, dims)
    out = [Array{eltype(s)}(undef, sz) for _ in Iterators.product(ax...)]
    return @inbounds rand!(rng, sampler(s), out, false)
end

=#

function Distributions._rand!(
    rng::AbstractRNG, d::SingleParticleDistribution, A::AbstractArray{<:SFourMomentum}
)
    @inbounds for i in eachindex(A)
        A[i] = Distributions.rand(rng, d)
    end
    return A
end

# TODO: refac sampler interface (maybe remove in favor to this)
"""
    _weight(d::SingleParticleDistribution,x::SFourMomentum)

TBW

"""
#_weight

# TODO: refac sampler interface (maybe remove in favor to this)
"""
    max_weight(d::SingleParticleDistribution)

TBW
"""
#max_weight
