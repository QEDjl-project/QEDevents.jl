
"""

   ScatteringProcessDistribution

Base type for sample drawing from scattering process distributions. The following interface functions
should be implemented:

* `QEDprocesses.scattering_process(d::ScatteringProcessDistribution)`
* `QEDprocesses.computation_model(d::ScatteringProcessDistribution)`
* `QEDprocesses.phasespace_definition(d::ScatteringProcessDistribution)`

"""
const ScatteringProcessDistribution = ParticleSampleable{ProcessLikeVariate}

Broadcast.broadcastable(d::ScatteringProcessDistribution) = Ref(d)

Base.length(::ScatteringProcessDistribution) = 1
Base.size(::ScatteringProcessDistribution) = ()

"""
Interface function, which asserts that the given `input` is valid.
"""
function _assert_valid_input_type(d::ScatteringProcessDistribution, x::PhaseSpacePoint)
    return nothing
end

# used for pre-allocation of vectors of phase-space points
# todo: implement correctly -> use the type building functions from QEDprocesses.
function Base.eltype(s::ScatteringProcessDistribution)
    return PhaseSpacePoint
end
