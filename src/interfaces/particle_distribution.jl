
# todo: find better name for variate forms used in QEDevents.jl
abstract type QEDlikeVariate <: Distributions.VariateForm end

"""
    ParticleLikeVariate{N<:Int}

Auxiliary type to represent the number of axes in the space of all particles:

* `N == 0` single particle variate
* `N == 1` multiple particle variate

"""
abstract type ParticleLikeVariate{N} <: QEDlikeVariate end

"""

    SingleParticleVariate

Auxiliary type to represent single particles in the context of distributions and sampler.
A sample from this variate form has the type `ParticleStateful`.

"""
const SingleParticleVariate = ParticleLikeVariate{0}

"""

   MultiParticleVariate

Auxiliary type to represent multiple particles in the context of distributions and sampler.
A sample from this variate form has the type `Vector{ParticleStateful}`.

"""
const MultiParticleVariate = ParticleLikeVariate{1}

"""

    ProcessLikeVariate

Auxiliary type to represent distributions and samplers for scattering processes.

A sample from this variate form has the type `PhaseSpacePoint`.

"""
abstract type ProcessLikeVariate <: QEDlikeVariate end

"""

    ParticleSampleable{V<:QEDlikeVariate}

Abstract base type for sampleable particle distributions and sampler in the context of `QEDevents.jl`.
Here a particle-sampleable is generally a type which has some sort of `rand` function to produce random
samples for properties of given particles, like four-momentum, spin, polarization, etc..

To implement the particle-sampleable interface, the following functions need to be given:

* `Base.eltype(s::ParticleSampleable)`: return the innermost type of the samples
* [`_weight(s::ParticleSampleable,x)`](@ref): return the weight of a given sample `x`
* [`is_exact(s::ParticleSampleable)`](@ref): return wether or not a particle-sampleable is exact

Optionally, one can enhance the calculation of weights by providing

* [`_assert_valid_input_type(s::ParticleSampleable,x)`](@ref): assert input has the correct type
* [`_assert_valid_input(s::ParticleSampleable,x)`](@ref): assert input has correct properties
* [`_post_processing(s::ParticleSampleable,x,res)`](@ref): apply some postprocesing to the result of `_weight`.

See [`weight`](@ref) for details. Furthermore, one can provide custom four-momentum types used for
the generation of samples by implementing

* [`_momentum_type(s::ParticleSampleable)`](@ref): return the momentum type used

For the actual sampling, one must implement

* [`_randmom(d::ParticleSampleable)`](@ref): return momenta according to `d`

Using these interface functions, the following versions `rand` function are implemented.
However, if in the particular case, there are more sophisticated implementations for the
respective version of the `rand` function (see below), they can be implemented instead of `_randmom`.
Nevertheless, in this case, it is recommended for convenience to implement a `_randmom` function as well, maybe
using the result of `rand`.

!!! note "Single particle distribution"
    For `SingleParticleVariate`samplers, the single sample version `rand` is given:

    ```julia
    Distributions.rand(
        rng::Random.AbstractRNG,
        s::ParticleSampleable{SingleParticleVariate})
    ```
    which returns a random sample from `s` as a `ParticleStateful`.

!!! note "Multiple particle distribution"
    For `MultiParticleVariate` samplers, the mutating version of `rand` implemented:

    ```julia
    Distributions._rand!(
        rng::Random.AbstractRNG,
        s::ParticleSampleable{MultiParticleVariate},
        out::AbstractArray{ParticleStateful})
    ```
    which also provides implementations of `rand` for one or more samples.

!!! note "Scattering process distribution"
    For `ProcessLikeVariate` distributions, the single sample version of `rand` is given:

    ```julia
    Distributions.rand(
        rng::Random.AbstractRNG,
        s::ParticleSampleable{ProcessLikeVariate})
    ```
    which returns a `PhaseSpacePoint` including the respective scattering process, computation model and phase-space definition.

"""
abstract type ParticleSampleable{F<:QEDlikeVariate} <:
              Distributions.Sampleable{F,Distributions.Continuous} end

"""
    _momentum_type(s::ParticleSampleable,x)

Return the momentum type used for the generation of samples. The default is `SFourMomentum`.

!!! note

    This interface function is optional for subtypes of [`ParticleSampleable`](@ref).

"""
function _momentum_type(s::ParticleSampleable)
    return SFourMomentum
end

"""

    _randmom(rng::AbstractRNG,d::ParticleSampleable)

Return random momentum/momenta according to the distribution `d`. The momentum type used in the return must
be equal to the one returned by [`_momentum_type`](@ref).

The actual return type for `_randmom` depends on the variate form.

!!! note "Single particle distributions"

    The `_randmom` function must return a single momentum, which type is the same as retured by [`_momentum_type`](@ref)

!!! note "Multiple particle distribution"

    For a set of particles, the `_randmom` function must return an iterable container of momenta (e.g. a tuple or vector), which length is the same
    as the number of particles according to the distribution. The element type of this container must be the same as returned by [`_momentum_type`](@ref).

!!! note "Scattering process distributions"

    For scattering processes, the `_randmom` function must return two iterable containers of momenta, one for the incoming and one for the outgoing particles.
    The momentum type in both of the containers must be the same as returned by [`_momentum_type`](@ref).

"""
function _randmom end

"""
    _assert_valid_input_type(s::ParticleSampleable,x)


Throw `InvalidInputError` if the input `x` has the wrong type, do nothing otherwise. This function is usually used for complicated types, where
the implementation via multiple dispatch is cumbersome. The default is doing nothing.

!!! note

    This interface function is optional for subtypes of [`ParticleSampleable`](@ref).

"""
function _assert_valid_input_type(s::ParticleSampleable, x) end

"""
    _assert_valid_input(s::ParticleSampleable,x)


Throw `InvalidInputError` if the input `x` is not valid, do nothing otherwise. This function is usually used for checking,
if the input has the assumed properties. Type checks are done using multiple dispatch, or [`_assert_valid_input_type`](@ref).
The default is doing nothing.

!!! note

    This interface function is optional for subtypes of [`ParticleSampleable`](@ref).

"""
function _assert_valid_input(s::ParticleSampleable, x) end

"""

    _weight(s::ParticleSampleable, x)

Return the weight associated with the given sample `x` according to the particle-sampleable `s`.
This function must not do input validation. This is done by [`weight`](@ref), which calls
`_weight` after input validation.

!!! note

    This interface function must be implemented for subtypes of [`ParticleSampleable`](@ref).

"""
function _weight end

"""

    _post_processing(s::ParticleSampleable, x, result)

Return post-processed version of `result`. The default does nothing and returns `result`.

!!! note

    This interface function is optional for subtypes of [`ParticleSampleable`](@ref).

"""
@inline function _post_processing(s::ParticleSampleable, x, res)
    return res
end

"""

    is_exact(s::ParticleSampleable)

Return whether or not the particle-sampleable `s` is exactly representing the distribution given by [`weight`](@ref).

!!! note

    This interface function must be implemented for subtypes of [`ParticleSampleable`](@ref).

"""
function is_exact end

"""
    weight(d::ParticleSampleable, sample)

Return the weight of the given sample according to the given distribution.

This function automatically performs input validation and post-processing using the respective interface functions.
The order of calls is

* [`_assert_valid_input_type`](@ref)
* [`_assert_valid_input`](@ref)
* [`_weight`](@ref)
* [`_post_processing`](@ref)

"""
function weight(s::ParticleSampleable, input)
    _assert_valid_input_type(s, input)
    _assert_valid_input(s, input)
    raw_result = _weight(s, input)
    return _post_processing(s, input, raw_result)
end

"""

    max_weight(::ParticleSampleable)

Interface function, which returns the maximum possible weight for the particle-sampleable.
"""
function max_weight end

# generic sampler for multiple samples
# todo: restrict to Union{SingleParticleVariate,ProcessLikeVariate}
# for MultiParticleVariate, this should be done by Distributions
# if not: implement the correct version!
function Distributions.rand(rng::AbstractRNG, s::ParticleSampleable, dims::Dims)
    out = Array{eltype(s)}(undef, dims)
    return @inbounds rand!(rng, s, out)
end

# todo: restrict to Union{SingleParticleVariate,ProcessLikeVariate}
# for MultiParticleVariate, this is an interface function!
function Distributions._rand!(rng::AbstractRNG, d::ParticleSampleable, A::AbstractArray)
    @inbounds for i in eachindex(A)
        A[i] = Distributions.rand(rng, d)
    end
    return A
end
