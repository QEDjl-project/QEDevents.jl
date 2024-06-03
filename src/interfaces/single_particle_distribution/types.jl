
const SingleParticleVariate = ParticleLikeVariate{0}

"""

    SingleParticleDistribution

Base type for sample drawing from single particle distributions. The following interface functions
should be implemented:

```julia
    QEDevents._particle(d::SingleParticleDistribution)
    Distributions.rand(rng::AbstractRNG,d::SingleParticleDistribution)
    QEDevents._weight(d::SingleParticleDistribution,x::SFourMomentum)
```

Optional:

```julia
    QEDevents._particle_direction(d::SingleParticleDistribution)
    QEDevents._assert_valid_input(d::SingleParticleDistribution,x::SFourMomentum)
    QEDevents._post_processing(d::SingleParticleDistribution,x::SFourMomentum,out::Real)
    QEDevents.max_weight(d::SingleParticleDistribution)
```

"""
const SingleParticleDistribution = ParticleDistribution{SingleParticleVariate}

Broadcast.broadcastable(d::SingleParticleDistribution) = Ref(d)

Base.length(::Sampleable{SingleParticleVariate}) = 1
Base.size(::Sampleable{SingleParticleVariate}) = ()
