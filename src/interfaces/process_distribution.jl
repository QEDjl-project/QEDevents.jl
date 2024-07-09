#TODO: fix the links
"""

  ScatteringProcessDistribution

Base type for sample drawing from scattering process distributions. The following interface functions
should be implemented:

* `QEDbase.process(d::ScatteringProcessDistribution)`
* `QEDbase.model(d::ScatteringProcessDistribution)`
* `QEDbase.phase_space_definition(d::ScatteringProcessDistribution)`
* [`QEDevents._randmom(rng::AbstractRNG,d::ScatteringProcessDistribution)`](@ref)

"""
const ScatteringProcessDistribution = ParticleSampleable{ProcessLikeVariate}

Broadcast.broadcastable(d::ScatteringProcessDistribution) = Ref(d)

function QEDbase.incoming_particles(d::ScatteringProcessDistribution)
    return incoming_particles(process(d))
end

function QEDbase.outgoing_particles(d::ScatteringProcessDistribution)
    return outgoing_particles(process(d))
end

"""
Interface function, which asserts that the given `input` is valid.
"""
function _assert_valid_input_type(d::ScatteringProcessDistribution, psp::PhaseSpacePoint)
    process(d) == process(psp) || throw(
        InvalidInputError(
            "process definition of the distribution $(process(d)) is not the same as of the phase space point $(process(psp))",
        ),
    )
    model(d) == model(psp) || throw(
        InvalidInputError(
            "model definition of the distribution $(model(d)) is not the same as of the phase space point $(model(psp))",
        ),
    )
    phase_space_definition(d) == phase_space_definition(psp) || throw(
        InvalidInputError(
            "phase space definition of the distribution $(phase_space_definition(d)) is not the same as of the phase space point $(phase_space_definition(psp))",
        ),
    )
    return nothing
end

function _assemble_psp_type(
    proc::PROC, model::MODEL, ps_def::PSDEF, mom_type::Type{MOM}
) where {
    PROC<:AbstractProcessDefinition,
    MODEL<:AbstractModelDefinition,
    PSDEF<:AbstractPhasespaceDefinition,
    MOM<:AbstractFourMomentum,
}
    IN_PARTICLES = Tuple{
        _assemble_tuple_types(incoming_particles(proc), Incoming(), MOM)...
    }
    OUT_PARTICLES = Tuple{
        _assemble_tuple_types(outgoing_particles(proc), Outgoing(), MOM)...
    }

    return PhaseSpacePoint{PROC,MODEL,PSDEF,IN_PARTICLES,OUT_PARTICLES,MOM}
end

# used for pre-allocation of vectors of psps
function Base.eltype(d::ScatteringProcessDistribution)
    return _assemble_psp_type(
        process(d), model(d), phase_space_definition(d), _momentum_type(d)
    )
end

function Distributions.rand(rng::AbstractRNG, d::ScatteringProcessDistribution)
    in_moms, out_moms = _randmom(rng, d)

    return PhaseSpacePoint(
        process(d), model(d), phase_space_definition(d), in_moms, out_moms
    )
end
