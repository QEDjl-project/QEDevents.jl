
const PARTICLE_DIRECTIONS = (Incoming(), Outgoing(), QEDevents.UnknownDirection())

struct TestMultiParticleDist{DT<:Tuple,PT<:Tuple,RT} <: MultiParticleDistribution
    dirs::DT
    parts::PT
    function TestMultiParticleDist(dirs::DT, parts::PT) where {DT,PT}
        res_type = Tuple{
            QEDevents._assemble_tuple_types(parts, dirs, SFourMomentum{Float64})...
        }
        return new{DT,PT,res_type}(dirs, parts)
    end
end

function QEDevents._particles(d::TestMultiParticleDist)
    return d.parts
end

QEDevents._particle_directions(d::TestMultiParticleDist) = d.dirs

function QEDevents._randmom(rng::AbstractRNG, d::TestMultiParticleDist)
    return _groundtruth_multi_randmom(rng, d)
end

function QEDevents._weight(d::TestMultiParticleDist, x::Tuple{Vararg{ParticleStateful}})
    return _groundtruth_multi_weight(d, x)
end

# plain multi particle distribution
# for testing of default implementations
struct TestMultiParticleDistPlain <: MultiParticleDistribution
    n::Int
end

QEDevents._particles(d::TestMultiParticleDistPlain) = rand(Mocks.PARTICLE_SET, d.n)
