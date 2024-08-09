# utilities for QEDevents

# TODO:
# most of the functions are copied from QEDcore to not rely on internals. However
# at some point, we should think how to provide these kinds of functionalities for more
# than one package.

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

###
# assemble type for tuple of ParticleStateful
###

# version for different directions

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

# version for same direction for all particles

# recursion termination: base case
@inline _assemble_tuple_types(::Tuple{}, ::ParticleDirection, ::Type) = ()

# function assembling the correct type information for the tuple of ParticleStatefuls in a phasespace point constructed from momenta
@inline function _assemble_tuple_types(
    particle_types::Tuple{SPECIES_T,Vararg{AbstractParticleType}}, dir::DIR_T, ELTYPE::Type
) where {SPECIES_T<:AbstractParticleType,DIR_T<:ParticleDirection}
    return (
        ParticleStateful{DIR_T,SPECIES_T,ELTYPE},
        _assemble_tuple_types(particle_types[2:end], dir, ELTYPE)...,
    )
end
