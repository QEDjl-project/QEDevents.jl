
"""

  ScatteringProcessDistribution

Base type for sample drawing from scattering process distributions. The following interface functions
should be implemented:

* [`QEDbase.scattering_process(d::ScatteringProcessDistribution)`](@ref)
* [`QEDbase.computational_model(d::ScatteringProcessDistribution)`](@ref)
* [`QEDbase.phasespace_definition(d::ScatteringProcessDistribution)`](@ref)
* [`Base.size(d::ScatteringProcessDistribution)`](@ref)
* [`QEDevents.randmom(rng::AbstractRNG,d::ScatteringProcessDistribution)`](@ref)

"""
const ScatteringProcessDistribution = ParticleSampleable{ProcessLikeVariate}

Broadcast.broadcastable(d::ScatteringProcessDistribution) = Ref(d)
Base.length(d::ScatteringProcessDistribution) = prod(size(d))

function QEDbase.incoming_particles(d::ScatteringProcessDistribution)
    return incoming_particles(scattering_process(d))
end

function QEDbase.outgoing_particles(d::ScatteringProcessDistribution)
    return outgoing_particles(scattering_process(d))
end

#=
"""
Interface function, which asserts that the given `input` is valid.
"""
function _assert_valid_input_type(
    d::MultiParticleDistribution, x::PS
) where {PS<:Tuple{Vararg{ParticleStateful}}}
    # TODO: implement correct type check
    _recursive_type_check(x, _particles(d), _particle_directions(d))
    return nothing
end
=#

# TODO: move this to QEDcore.
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
        scattering_process(d),
        computational_model(d),
        phasespace_definition(d),
        _momentum_type(d),
    )
end

function Distributions.rand(rng::AbstractRNG, d::ScatteringProcessDistribution)
    in_moms, out_moms = randmom(rng, d)

    return PhaseSpacePoint(
        scattering_process(d),
        computational_model(d),
        phasespace_definition(d),
        in_moms,
        out_moms,
    )
end
