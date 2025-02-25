
"""

   MultiParticleDistribution

Base type for sample drawing from multiple particle distributions. The following interface functions
should be implemented:

* [`QEDevents._particles(d::MultiParticleDistribution)`](@ref)
* [`QEDevents._particle_directions(d::MultiParticleDistribution)`](@ref)
* [`QEDevents._randmom(rng::AbstractRNG,d::MultiParticleDistribution)`](@ref)

"""
const MultiParticleDistribution = ParticleSampleable{MultiParticleVariate}

Broadcast.broadcastable(d::MultiParticleDistribution) = Ref(d)

Base.length(d::MultiParticleDistribution) = length(_particles(d))
Base.size(d::MultiParticleDistribution) = (length(d),)

"""
    _particle(dist::MultiParticleDistribution)

Return tuple of particles associated with the `dist`.

!!! note

    Interface function to be implemented for multi-particle distributions.

"""
function _particles end

"""
    _particle_direction(dist::MultiParticleDistribution)

Return tuple of particle-directions for all particles associated with `dist`.

!!! note

    Interface function to be implemented for multi-particle distributions.

"""
function _particle_directions end
#default
function _particle_direction(d::MultiParticleDistribution)
    return Tuple(fill(UnknownDirection(), length(d)))
end

"""
Interface function, which asserts that the given `input` is valid.
"""
function _assert_valid_input_type(
    d::MultiParticleDistribution, x::PS
) where {PS<:Tuple{Vararg{ParticleStateful}}}
    _recursive_type_check(x, _particles(d), _particle_directions(d))
    return nothing
end

# used for pre-allocation of vectors of particle-stateful
function Base.eltype(d::MultiParticleDistribution)
    return Tuple{
        _assemble_tuple_types(_particles(d), _particle_directions(d), _momentum_type(d))...
    }
end

function Distributions.rand(rng::AbstractRNG, d::MultiParticleDistribution)
    n = length(d)
    moms = _randmom(rng, d)
    dirs = _particle_directions(d)
    parts = _particles(d)

    # ntuple is not type-stable for parametric type in Julia 1.10
    return Tuple{_assemble_tuple_types(parts, dirs, _momentum_type(d))...}(
        ntuple(i -> ParticleStateful(dirs[i], parts[i], moms[i]), Val(n))
    )
end
