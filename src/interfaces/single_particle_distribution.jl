
"""

    SingleParticleDistribution

Base type for sample drawing from single particle distributions. The following interface functions
should be implemented:

* [`QEDevents._particle(d::SingleParticleDistribution)`](@ref): return associated particle
* [`QEDevents._particle_direction(d::SingleParticleDistribution)`](@ref): return associated particle direction
* [`QEDevents._randmom(d::SingleParticleDistribution)`](@ref): return momentum according to `d`

"""
const SingleParticleDistribution = ParticleSampleable{SingleParticleVariate}

Broadcast.broadcastable(d::SingleParticleDistribution) = Ref(d)

Base.length(::SingleParticleDistribution) = 1
Base.size(::SingleParticleDistribution) = ()

"""
    _particle(dist::SingleParticleDistribution)::AbstractParticle

Return the particle associated with the `dist`.

!!! note

    Interface function to be implemented for single-particle distributions.

"""
function _particle end

"""
    _particle_direction(dist::SingleParticleDistribution)::ParticleDirection

Return the particle-direction of the particle associated with `dist`.
!!! note

    Interface function to be implemented for single-particle distributions.

"""
function _particle_direction end
#default
_particle_direction(::SingleParticleDistribution) = UnknownDirection()

"""
Interface function, which asserts that the given `input` is valid.
"""
function _assert_valid_input_type(
    d::SingleParticleDistribution, x::ParticleStateful{D,P}
) where {D,P}
    typeof(_particle_direction(d)) == D ||
        throw(InvalidInputError("expected $(typeof(_particle_direction(d))) but got $D"))

    typeof(_particle(d)) == P ||
        throw(InvalidInputError("expected $(typeof(_particle(d))) but got $P"))

    return nothing
end

# used for pre-allocation of vectors of particle-stateful
# todo: maybe find a better solution
function Base.eltype(s::SingleParticleDistribution)
    return ParticleStateful{
        typeof(_particle_direction(s)),typeof(_particle(s)),_momentum_type(s)
    }
end

function Distributions.rand(rng::AbstractRNG, d::SingleParticleDistribution)
    rnd_momentum = _randmom(rng, d)
    return ParticleStateful(_particle_direction(d), _particle(d), rnd_momentum)
end
