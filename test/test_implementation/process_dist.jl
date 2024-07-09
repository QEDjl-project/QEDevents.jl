
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

function QEDevents._weight(d::TestProcessDistribution, x::PhaseSpacePoint)
    return _groundtruth_process_weight(d, x)
end
