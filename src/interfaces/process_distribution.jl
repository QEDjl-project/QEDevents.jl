
"""

  ScatteringProcessDistribution

Base type for sample drawing from scattering process distributions. The following interface functions
should be implemented:

* [`QEDbase.scattering_process(d::ScatteringProcessDistribution)`](@ref)
* [`QEDbase.computational_model(d::ScatteringProcessDistribution)`](@ref)
* [`QEDbase.phasespace_definition(d::ScatteringProcessDistribution)`](@ref)
* [`Base.size(d::ScatteringProcessDistribution)`](@ref)
* [`QEDevents.randmom(rng::AbstractRNG,d::ScatteringProcessDistribution)`](@ref)

Additionally, the following interface functions can be implemented if they differ from the
the ones infered from the `scattering_process` (whatever this means in the particular implementation):

* [`QEDbase.incoming_particles(d::ScatteringProcessDistribution)`](@ref)
* [`QEDbase.outgoing_particles(d::ScatteringProcessDistribution)`](@ref)

"""
const MultiParticleDistribution = ParticleSampleable{ProcessLikeVariate}

Broadcast.broadcastable(d::ScatteringProcessDistribution) = Ref(d)
Base.length(d::ScatteringProcessDistribution) = prod(size(d))

function QEDbase.incoming_particles(d::ScatteringProcessDistribution)
    return incoming_particles(scattering_process(d))
end

function QEDbase.outgoing_particles(d::ScatteringProcessDistribution)
    return outgoing_particles(scattering_process(d))
end

"""

    randmom(rng::AbstractRNG,d::MultiParticleDistribution)

Return an iterable container (e.g. vector or tuple) of momenta according to the distribution `d`.
"""
function randmom end

# recursion termination: success
@inline _recursive_type_check(::Tuple{}, ::Tuple{}, ::Tuple{}) = nothing

# recursion termination: overload for unequal number of particles
@inline function _recursive_type_check(
    ::Tuple{Vararg{ParticleStateful,N}},
    ::Tuple{Vararg{AbstractParticleType,M}},
    ::Tuple{Vararg{ParticleDirection,M}},
) where {N,M}
    throw(InvalidInputError("expected $(M) particles but got $(N)"))
    return nothing
end

# recursion termination: overload for invalid types
@inline function _recursive_type_check(
    ::Tuple{ParticleStateful{DIR_IN_T,SPECIES_IN_T},Vararg{ParticleStateful,N}},
    ::Tuple{SPECIES_T,Vararg{AbstractParticleType,N}},
    ::Tuple{DIR_T,Vararg{ParticleDirection,N}},
) where {
    N,
    DIR_IN_T<:ParticleDirection,
    DIR_T<:ParticleDirection,
    SPECIES_IN_T<:AbstractParticleType,
    SPECIES_T<:AbstractParticleType,
}
    throw(
        InvalidInputError(
            "expected $(DIR_T()) $(SPECIES_T()) but got $(DIR_IN_T()) $(SPECIES_IN_T())"
        ),
    )
    return nothing
end

@inline function _recursive_type_check(
    t::Tuple{ParticleStateful{DIR_T,SPECIES_T},Vararg{ParticleStateful,N}},
    p::Tuple{SPECIES_T,Vararg{AbstractParticleType,N}},
    dir::Tuple{DIR_T,Vararg{ParticleDirection,N}},
) where {N,DIR_T<:ParticleDirection,SPECIES_T<:AbstractParticleType}
    return _recursive_type_check(t[2:end], p[2:end], dir[2:end])
end

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

# recursion termination: base case
@inline _assemble_tuple_types(::Tuple{}, ::Tuple{}, ::Type) = ()

@inline function _assemble_tuple_types(
    particle_types::Tuple{SPECIES_T,Vararg{AbstractParticleType}},
    dir::Tuple{DIR_T,Vararg{ParticleDirection}},
    ELTYPE::Type,
) where {SPECIES_T<:AbstractParticleType,DIR_T<:ParticleDirection}
    return (
        ParticleStateful{DIR_T,SPECIES_T,ELTYPE},
        _assemble_tuple_types(particle_types[2:end], dir[2:end], ELTYPE)...,
    )
end

# used for pre-allocation of vectors of particle-stateful
function Base.eltype(d::MultiParticleDistribution)
    return Tuple{
        _assemble_tuple_types(_particles(d), _particle_directions(d), _momentum_type(d))...
    }
end

function Distributions.rand(rng::AbstractRNG, d::MultiParticleDistribution)
    n = length(d)
    moms = randmom(rng, d)
    dirs = _particle_directions(d)
    parts = _particles(d)

    return ntuple(i -> ParticleStateful(dirs[i], parts[i], moms[i]), Val(n))
end
