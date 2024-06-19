
# dummy particles
struct TestParticle <: QEDbase.AbstractParticleType end # generic particle
struct TestParticleFermion <: QEDbase.FermionLike end
struct TestParticleBoson <: QEDbase.BosonLike end

const PARTICLE_SET = [TestParticleFermion(), TestParticleBoson()]
