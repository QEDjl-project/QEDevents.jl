# N ... dimension of the vector space,
# N=0 ... single mom,
# N=1 ... vector of moms
abstract type ParticleLikeVariate{N} <: VariateForm end
const SingleParticleVariate = ParticleLikeVariate{0}

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
