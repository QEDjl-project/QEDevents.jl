
"""
    _particle(dist::SingleParticleDistribution)::QEDbase.AbstractParticle

Return the particle associated with the `dist`.

!!! note

    Interface function to be implemented for single-particle distributions.

"""
function _particle end

"""
    _particle_direction(dist::SingleParticleDistribution)::QEDbase.ParticleDirection

Return the particle-direction of the particle associated with `dist`.
!!! note

    Interface function to be implemented for single-particle distributions.

"""
_particle_direction(::SingleParticleDistribution) = UnknownDirection()

"""
_momentum_type(dist::SingleParticleDistribution)::Type{<:QEDbase.AbstractFourMomentum}

Return the momentum type of the particle associated with `dist`.
!!! note

    Interface function to be implemented for single-particle distributions.

"""
_momentum_type(::SingleParticleDistribution) = SFourMomentum

"""
Interface function, which asserts that the given `input` is valid.
"""
function _assert_valid_input_type(
    d::SingleParticleDistribution, x::ParticleStateful{D,P}
) where {D,P}
    eltype(_particle_direction(d)) == D ||
        throw(InvalidInputError("expected $(_particle_direction(d)) but got $D"))

    return eltype(_particle(d)) == P ||
           throw(InvalidInputError("expected $(_particle(d)) but got $P"))
end

"""
    _assert_valid_input(d::SingleParticleDistribution,x::ParticleStateful)

Throw `InvalidInputError` of the input is not valid, do nothing otherwise. The default is doing nothing and returns `nothing`.

!!! note

    Interface function to be implemented optionally for single-particle distributions.

"""
@inline function _assert_valid_input(d::SingleParticleDistribution, x::ParticleStateful)
    return nothing
end

"""

    _post_processing(d::SingleParticleDistribution, input::ParticleStateful, result::Real)

Return post-processed version of `result`. The default does nothing and returns `result`.

!!! note

    Interface function to be implemented optionally for single-particle distributions.

"""
@inline function _post_processing(stp::AbstractComputationSetup, input, result)
    return result
end

"""
    _weight(d::SingleParticleDistribution, sample)

Return the weight associated with the given sample according to the distribution `d`.

!!! note

    Interface function to be implemented for single-particle distributions.

!!! note

    This function must not do input validation. This is done by [`weight`](@ref), which calls `_weight` after input validation.

"""
function _weight(d::SingleParticleDistribution, x)
    throw(
        # todo: implement interface error, method errors are a bit misleading
        MethodError(_weight, (d, x)),
    )
end

"""
    weight(d::SingleParticleDistribution, input::ParticleStateful)

Return the weight of the given sample accoring to the given distribution.

!!! note

    This function automatically performs input validation and post-processing using the respective interface functions.
    The order of calls is

    ```julia
        _assert_valid_input_type
        _assert_valid_input
        _weight
        _post_processing
    ```
"""
function weight(d::SingleParticleDistribution, input::ParticleStateful)
    _assert_valid_input_type(d, input)
    _assert_valid_input(d, input)
    raw_result = _weight(d, input)
    return _post_processing(d, input, raw_result)
end

"""

    is_exact(::AbstractSampler)

Return if a given particle sampler is exact.

!!! note

    Interface function to be implemented for single-particle distributions.

"""
function is_exact(d::SingleParticleDistribution)
    # todo: this can be defined on a more general level
    throw(
        # todo: implement interface error, method errors are a bit misleading
        MethodError(is_exact, d),
    )
end

"""
    max_weight(d::SingleParticleDistribution)

Return the maximum weight of a given particle distribution.
!!! note

    Interface function to be implemented for single-particle distributions.

"""
function max_weight(d::SingleParticleDistribution)
    # todo: this can be defined on a more general level
    throw(
        # todo: implement interface error, method errors are a bit misleading
        MethodError(max_weight, d),
    )
end

####
# derived functionality
####

function Base.eltype(s::SingleParticleDistribution)
    return ParticleStateful{
        typeof(_particle_direction(s)),typeof(_particle(s)),_momentum_type(s)
    }
end
