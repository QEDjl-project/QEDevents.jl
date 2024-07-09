
struct TestProcessDistribution{PROC,MODEL,PSDEF} <: ScatteringProcessDistribution
    proc::PROC
    model::MODEL
    ps_def::PSDEF
end

function (d::TestMultiParticleDist)
    return d.parts
end
#=
* [`QEDbase.scattering_process(d::ScatteringProcessDistribution)`](@ref)
* [`QEDbase.computational_model(d::ScatteringProcessDistribution)`](@ref)
* [`QEDbase.phasespace_definition(d::ScatteringProcessDistribution)`](@ref)
* [`Base.size(d::ScatteringProcessDistribution)`](@ref)
* [`QEDevents.randmom(rng::AbstractRNG,d::ScatteringProcessDistribution)`](@ref)
=#
QEDbase.scattering_process(d::TestProcessDistribution) = d.proc
QEDbase.computational_model(d::TestProcessDistribution) = d.model
QEDbase.phasespace_definition(d::TestProcessDistribution) = d.ps_def

function QEDevents._randmom(rng::AbstractRNG, d::TestProcessDistribution)
    return _groundtruth_process_randmom(rng, d)
end

function QEDevents._weight(d::TestMultiParticleDist, x::Tuple{Vararg{ParticleStateful}})
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
