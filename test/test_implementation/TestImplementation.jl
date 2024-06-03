module TestImplementation

export TestParticle
export TestSingleParticleDist

using QEDbase
using QEDprocesses
using QEDevents
using Distributions
import Random: AbstractRNG

include("groundtruths.jl")

struct TestParticle <: QEDbase.AbstractParticleType end

struct TestSingleParticleDistPlain <: SingleParticleDistribution end

struct TestSingleParticleDist{P,D,T} <: SingleParticleDistribution
    particle::P
    dir::D
    mom_type::Type{T}
end

QEDevents._particle(d::TestSingleParticleDist) = d.particle
QEDevents._particle_direction(d::TestSingleParticleDist) = d.dir
QEDevents._momentum_type(::TestSingleParticleDist{P,D,T}) where {P,D,T} = T

function TestSingleParticleDist(part::AbstractParticleType)
    return TestSingleParticleDist(part, QEDevents.UnknownDirection(), SFourMomentum)
end
function TestSingleParticleDist(part::AbstractParticleType, dir::ParticleDirection)
    return TestSingleParticleDist(part, dir, SFourMomentum)
end

function Distributions.rand(rng::AbstractRNG, d::TestSingleParticleDist)
    return _groundtruth_single_rand(rng, d)
end
function QEDevents._weight(d::SingleParticleDistribution, x::SFourMomentum)
    return _groundtruth_weight(d, x)
end

end
