
struct TestProcessDistribution{PROC,MODEL,PSDEF} <: ScatteringProcessDistribution
    proc::PROC
    model::MODEL
    ps_def::PSDEF
end

QEDbase.process(d::TestProcessDistribution) = d.proc
QEDbase.model(d::TestProcessDistribution) = d.model
QEDbase.phase_space_definition(d::TestProcessDistribution) = d.ps_def

function QEDevents._randmom(rng::AbstractRNG, d::TestProcessDistribution)
    return _groundtruth_process_randmom(rng, d)
end

function QEDevents._weight(d::TestProcessDistribution, x::Tuple{Vararg{ParticleStateful}})
    return _groundtruth_process_weight(d, x)
end

#=
# plain multi particle distribution
# for testing of default implementations
struct TestMultiParticleDistPlain <: MultiParticleDistribution
    n::Int
end

QEDevents._particles(d::TestMultiParticleDistPlain) = Tuple(fill(TestParticle(), d.n))
=#
