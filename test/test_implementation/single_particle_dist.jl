####################
# Test implementation for single particle distributions
####################

struct TestSingleParticleDistPlain <: SingleParticleDistribution end

struct TestSingleParticleDist{D,P,T} <: SingleParticleDistribution
    dir::D
    part::P
    mom_type::Type{T}
end

function TestSingleParticleDist(part::AbstractParticleType)
    return TestSingleParticleDist(QEDevents.UnknownDirection(), part, SFourMomentum)
end

function TestSingleParticleDist(dir::ParticleDirection, part::AbstractParticleType)
    return TestSingleParticleDist(dir, part, SFourMomentum)
end

QEDevents._particle(d::TestSingleParticleDist) = d.part
QEDevents._particle_direction(d::TestSingleParticleDist) = d.dir
QEDevents._momentum_type(d::TestSingleParticleDist{D,P,T}) where {D,P,T} = T

function Distributions.rand(rng::AbstractRNG, d::TestSingleParticleDist)
    return _groundtruth_single_rand(rng, d)
end

function QEDevents._weight(d::TestSingleParticleDist, x::ParticleStateful)
    return _groundtruth_single_weight(d, x)
end
