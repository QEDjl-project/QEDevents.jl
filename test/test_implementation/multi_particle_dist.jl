
PARTICLE_DIRECTIONS = (Incoming(), Outgoing(), QEDevents.UnknownDirection())

struct TestMultiParticleDist <: MultiParticleDistribution
    parts::Tuple
    dirs::Tuple
end

function TestMultiParticleDist(n::Int)
    return TestMultiParticleDist(
        Tuple(rand(PARTICLE_SET, n)), Tuple(rand(PARTICLE_DIRECTIONS, n))
    )
end

Base.length(d::TestMultiParticleDist) = length(d.parts)

function _particles(d::TestMultiParticleDist)
    return d.parts
end

_particle_directions(d::TestMultiParticleDist) = d.dirs

function Distributions.rand(rng::AbstractRNG, d::TestMultiParticleDist)
    return _groundtruth_multi_rand(rng, d)
end
