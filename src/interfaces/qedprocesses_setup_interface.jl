###############
# The process setup 
#
# In this file, we define the interface for general computation and process setups.
###############

abstract type AbstractComputationSetup end

# convenience function to check if an object is a computation setup
_is_computation_setup(::AbstractComputationSetup) = true

abstract type AbstractInvalidInputException <: Exception end

struct InvalidInputError <: AbstractInvalidInputException
    msg::String
end
function Base.showerror(io::IO, err::InvalidInputError)
    return println(io, "InvalidInputError: $(err.msg).")
end

@inline function _assert_valid_input(stp::AbstractComputationSetup, input)
    return nothing
end

@inline function _post_processing(stp::AbstractComputationSetup, input, result)
    return result
end

function _compute end

function compute(stp::AbstractComputationSetup, input)
    _assert_valid_input(stp, input)
    raw_result = _compute(stp, input)
    return _post_processing(stp, input, raw_result)
end

abstract type AbstractProcessSetup <: AbstractComputationSetup end

function scattering_process end

function physical_model end

@inline function number_incoming_particles(stp::AbstractProcessSetup)
    return number_incoming_particles(scattering_process(stp))
end
@inline function number_outgoing_particles(stp::AbstractProcessSetup)
    return number_outgoing_particles(scattering_process(stp))
end
