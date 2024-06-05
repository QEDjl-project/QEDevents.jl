
"""

    MultiParticleDistribution

Base type for sample drawing from multiple-particle distributions. The following interface functions
should be implemented:

* `Base.length(d::MultiParticleDistribution)`: return number of particles associated with the distribution
* [`QEDevents._particles(d::MultiParticleDistribution)`](@ref): return a tuple of particles associated with the distribution
* [`QEDevents._particle_directions(d::MultiParticleDistribution)`](@ref): return a tuple of particle-directions associated with the distribution

"""
const MultiParticleDistribution = ParticleSampleable{MultiParticleVariate}

Broadcast.broadcastable(d::MultiParticleDistribution) = Ref(d)
Base.size(d::MultiParticleDistribution) = (length(d),)

"""
    _particles(d::MultiParticleDistribution)

TBW
"""
function _particles end

"""
    _particle_directions(d::MultiParticleDistribution)

TBW
"""
function _particle_directions end

"""
TODO: implement this correctly (maybe use recursive multiple dispatch similar to QEDprocesses)
"""
function _assert_valid_input_type(
    d::MultiParticleDistribution, x::Tuple{<:ParticleStateful{D,P}}
) where {D,P}
    return nothing
end

"""
TODO: move upstream to ParticleDistribution
"""
function _assert_valid_input_size(d::MultiParticleDistribution, x)
    return nothing
end

# TODO:
# * implement correct _rand! function
# *
