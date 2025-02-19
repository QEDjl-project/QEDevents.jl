
struct TestProcessDistribution{PROC,MODEL,PSL} <: ScatteringProcessDistribution
    proc::PROC
    model::MODEL
    psl::PSL
end

QEDbase.process(d::TestProcessDistribution) = d.proc
QEDbase.model(d::TestProcessDistribution) = d.model
QEDbase.phase_space_layout(d::TestProcessDistribution) = d.psl

function QEDevents._randmom(rng::AbstractRNG, d::TestProcessDistribution)
    return _groundtruth_process_randmom(rng, d)
end

function QEDevents._weight(d::TestProcessDistribution, x::AbstractPhaseSpacePoint)
    return _groundtruth_process_weight(d, x)
end
