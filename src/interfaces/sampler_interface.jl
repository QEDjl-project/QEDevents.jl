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
    CustomSampler <: AbstractSampler{Float64}

    Base.eltype  # type of the generated samples
    QEDevents._weight
    Base.size  # Return the dimensionality of the sampler (number of outgoing four-momenta per sample).
    is_exact
    QEDevents._rand!(rng::AbstractRNG, ::AbstractSampler, x::AbstractVector{T}) where {T}

    ```
    
    optional

    ```Julia
    _post_processing
    ```

"""
abstract type AbstractSampler <: AbstractComputationSetup end

@inline Base.eltype(::AbstractSampler) = Float64

"""
Interface function, which asserts that the given `input` is valid.
"""
function _assert_valid_input(smplr::AbstractSampler, x::AbstractVecOrMat)
    size(x,1)==size(smplr,1)[1] || error("Invalid input. The dimensionality of the input is") # $(size(x,1)) but it should be $(size(smplr,1)[1]).")
    eltype(x)==eltype(smplr) || error("Invalid input. The element type of the input is $(eltype(x)) but it should be $(eltype(smplr)).")
end

function _compute(smplr::AbstractSampler, sample)
    _weight(smplr::AbstractSampler, sample)
end


"""

    _weight(::AbstractSampler, sample)

Return the weight associated with the given sample according to the sampler.
"""
function _weight end




"""

    setup(::AbstractSampler)

???
"""
function setup end

"""

    is_exact(::AbstractSampler)

Return if the sampler is exactly representing the base? distribution or not.
"""
function is_exact end


function weight(smplr::AbstractSampler, sample)
    compute(smplr,sample)
end

"""

    rand(rng, ::AbstractSampler, ::AbstractVector{P}) where {P}

Generate a random sample from the sampler and write it into the given vector.
"""
function _rand! end

function _rand!(rng::AbstractRNG, smplr::AbstractSampler, res::AbstractMatrix{P}) where {P}
    for i in 1:size(res,2)
        _rand!(rng,smplr,view(res,:,i))
    end
    return res
end

function rand!(rng::AbstractRNG, smplr::AbstractSampler, x::AbstractVecOrMat)
    _assert_valid_input(smplr, x)
    _rand!(rng,smplr,x)
end

function rand(rng::AbstractRNG, smplr::AbstractSampler)
    _rand!(rng, smplr, Vector{eltype(smplr)}(undef, size(smplr,1)))
end

function rand(rng::AbstractRNG, smplr::AbstractSampler, N::Integer)
    _rand!(rng, smplr, Matrix{eltype(smplr)}(undef, size(smplr,1), N)) ###check
end



# abstract process sampler

abstract type AbstractScatteringProcessSampler{T<:QEDbase.AbstractFourMomentum} <: AbstractSampler end

#deligations to the setup
function scattering_process(smplr::AbstractScatteringProcessSampler)
    return scattering_process(setup(smplr))
end
physical_model(smplr::AbstractScatteringProcessSampler) = physical_model(setup(smplr))

@inline Base.eltype(::AbstractScatteringProcessSampler{T}) where T = T 


# abstract rejection sampler

function max_weight end



