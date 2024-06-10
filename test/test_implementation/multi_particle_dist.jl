
PARTICLE_DIRECTIONS = (Incoming(), Outgoing(), QEDevents.UnknownDirection())

struct TestMultiParticleDist{DT<:Tuple,PT<:Tuple,RT} <: MultiParticleDistribution
    dirs::DT
    parts::PT
    function TestMultiParticleDist(dirs::DT, parts::PT) where {DT,PT}
        res_type = Tuple{QEDevents._assemble_tuple_types(parts, dirs, SFourMomentum)...}
        return new{DT,PT,res_type}(dirs, parts)
    end
end

#Base.length(d::TestMultiParticleDist) = length(d.parts)

function QEDevents._particles(d::TestMultiParticleDist)
    return d.parts
end

QEDevents._particle_directions(d::TestMultiParticleDist) = d.dirs

function Distributions.rand(
    rng::AbstractRNG, d::TestMultiParticleDist{DT,PT,RT}
)::RT where {DT,PT,RT}
    return _groundtruth_multi_rand(rng, d)
end

function QEDevents._weight(d::TestMultiParticleDist, x::Tuple{Vararg{ParticleStateful}})
    return _groundtruth_multi_weight(d, x)
end

# plain multi particle distribution
# for testing of default implementations
struct TestMultiParticleDistPlain <: MultiParticleDistribution
    n::Int
end

QEDevents._particles(d::TestMultiParticleDistPlain) = Tuple(fill(TestParticle(), d.n))
