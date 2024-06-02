
"""

    particle(::Type{SingleParticleDistribution})

Interface function to be implemented. Return the particle associated with the given distribution.
"""
function particle end

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
