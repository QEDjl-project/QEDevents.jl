
"""

    _particle(::Type{SingleParticleDistribution})

Interface function to be implemented. Return the particle associated with the given distribution.
"""
function _particle end

_particle_direction(::SingleParticleDistribution) = UnknownDirection()

_momentum_type(::SingleParticleDistribution) = SFourMomentum

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

####
# derived functionality
####

function Base.eltype(s::SingleParticleDistribution)
    return ParticleStateful{
        typeof(_particle_direction(s)),typeof(_particle(s)),_momentum_type(s)
    }
end
