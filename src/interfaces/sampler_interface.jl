#################
# The sampler interface
#
# In this file, we define the interface for general samplers and specific
# samplers for scattering processes.
#################

"""
Abstract base type for general sampler.

!!! note "Sampler interface"

    Functions to be implemented

    ```Julia
    CustomSampler <: AbstractSampler

    Base.eltype(::CustomSampler)# type of the generated samples
    QEDevents._weight(::CustomSampler,x)
    QEDevents.setup(::CustomSampler) # return the setup for generating the samples
    Base.size(::CustomSampler)  # Return the dimensionality of the sampler (e.g. number of outgoing four-momenta per sample).
    QEDevents.is_exact(::CustomSampler)
    QEDevents._rand!(rng::AbstractRNG, ::AbstractSampler, x::AbstractVector{T}) where {T}

    ```
    
    optional

    ```Julia
    _post_processing(::CustomSampler,x)
    ```

"""
abstract type AbstractSampler <: AbstractComputationSetup end
Base.eltype(smplr::AbstractSampler) = throw(MethodError(eltype, (smplr,)))
"""
Interface function, which asserts that the given `input` is valid.
"""
function QEDprocesses._assert_valid_input(smplr::AbstractSampler, x::AbstractVecOrMat)
    size(x, 1) == size(smplr, 1)[1] || throw(
        InvalidInputError(
            "The dimensionality of the input is $(size(x,1)) but it should be $(size(smplr,1)[1]).",
        ),
    )
    return eltype(x) == eltype(smplr) || throw(
        InvalidInputError(
            "The element type of the input is $(eltype(x)) but it should be $(eltype(smplr)).",
        ),
    )
end

function QEDprocesses._compute(smplr::AbstractSampler, sample)
    return _weight(smplr::AbstractSampler, sample)
end

"""

    _weight(::AbstractSampler, sample)

Interface function, which returns the weight associated with the given sample according to the sampler.

!!! note ""
    
    This function must not do input validation. This is done by [`weight`](@ref), which calls `_weight` after input validation.

"""
function _weight end

"""

    setup(::AbstractSampler)

Interface function, which returns the `setup::AbstractComputeSetup` associated with the sampler.
"""
function setup end

"""

    is_exact(::AbstractSampler)

Interface function, which returns whether the sampler is exactly representing the base distribution or not.
"""
function is_exact end

"""   

    $(TYPEDSIGNATURES)

Interface function, which validates the input, calculates the weight via [`_weight`](@ref), and performs an optional post-processing via `QEDprocesses._post_processing`.
"""
function weight(smplr::AbstractSampler, sample)
    return compute(smplr, sample)
end

"""

    $(TYPEDSIGNATURES)

Generate a random sample from the sampler and write it into the given vector.
"""
function _rand!(rng::AbstractRNG, smplr::AbstractSampler, x::AbstractVector)
    throw(MethodError(_rand!, (rng, smplr, x)))
end

function _rand!(rng::AbstractRNG, smplr::AbstractSampler, res::AbstractMatrix{P}) where {P}
    for i in 1:size(res, 2)
        _rand!(rng, smplr, view(res, :, i))
    end
    return res
end

function rand!(rng::AbstractRNG, smplr::AbstractSampler, x::AbstractVecOrMat)
    QEDprocesses._assert_valid_input(smplr, x)
    return _rand!(rng, smplr, x)
end

function rand(rng::AbstractRNG, smplr::AbstractSampler)
    return _rand!(rng, smplr, Vector{eltype(smplr)}(undef, size(smplr, 1)))
end

function rand(rng::AbstractRNG, smplr::AbstractSampler, N::Integer)
    return _rand!(rng, smplr, Matrix{eltype(smplr)}(undef, size(smplr, 1), N))
end


####
# Sampler related to scattering processes
####

abstract type AbstractScatteringProcessSampler{T<:QEDbase.AbstractFourMomentum} <:
              AbstractSampler end

function scattering_process(smplr::AbstractScatteringProcessSampler)
    return scattering_process(setup(smplr))
end
physical_model(smplr::AbstractScatteringProcessSampler) = physical_model(setup(smplr))

@inline Base.eltype(::AbstractScatteringProcessSampler{T}) where {T} = T

"""

    max_weight(::AbstractSampler)

Interface function, which returns the maximum possible weight for the sampler.
"""
function max_weight end

####
# Proposal Sampler
####

"""
    AbstractProposalSampler <: AbstractSampler

Base type for proposal sampler. For these sampler
one needs to implement the standard sampler interface:

```Julia
    Base.eltype(::CustomSampler)# type of the generated samples
    QEDevents._weight(::CustomSampler,x)
    QEDevents.setup(::CustomSampler) # return the setup for generating the samples
    Base.size(::CustomSampler)  # Return the dimensionality of the sampler (e.g. number of outgoing four-momenta per sample).
    QEDevents._rand!(rng::AbstractRNG, ::AbstractSampler, x::AbstractVector{T}) where {T}
```
where `is_exact(::AbstractProposalSampler) == false`.
Additionally, one needs to implement the training function, which adopts the given setup:

```Julia
    train!(smplr::AbstractProposalSampler, train_params; loss=Nothing)
```
"""
abstract type AbstractProposalSampler <: AbstractSampler end
is_exact(::AbstractProposalSampler) = false


"""

    train!(smplr::AbstractProposalSampler, train_params; loss=Nothing)

Interface function to perfom the training of a proposal sampler. 
"""
function train! end

