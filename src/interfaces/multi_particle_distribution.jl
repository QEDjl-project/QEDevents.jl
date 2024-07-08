
"""

   MultiParticleDistribution

Base type for sample drawing from multiple particle distributions. The following interface functions
should be implemented:

* [`QEDevents._particles(d::MultiParticleDistribution)`](@ref)
* [`QEDevents._particle_directions(d::MultiParticleDistribution)`](@ref)
* [`QEDevents._randmom(rng::AbstractRNG,d::MultiParticleDistribution)`](@ref)

"""
const MultiParticleDistribution = ParticleSampleable{MultiParticleVariate}

Broadcast.broadcastable(d::MultiParticleDistribution) = Ref(d)

Base.length(d::MultiParticleDistribution) = length(_particles(d))
Base.size(d::MultiParticleDistribution) = (length(d),)

"""
    _particle(dist::MultiParticleDistribution)

Return tuple of particles associated with the `dist`.

!!! note

    Interface function to be implemented for multi-particle distributions.

"""
function _particles end

"""
    _particle_direction(dist::MultiParticleDistribution)

Return tuple of particle-directions for all particles associated with `dist`.

!!! note

    Interface function to be implemented for multi-particle distributions.

"""
function _particle_directions end
#default
function _particle_direction(d::MultiParticleDistribution)
    return Tuple(fill(UnknownDirection(), length(d)))
end

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
    moms = _randmom(rng, d)
    dirs = _particle_directions(d)
    parts = _particles(d)

    return ntuple(i -> ParticleStateful(dirs[i], parts[i], moms[i]), Val(n))
end
