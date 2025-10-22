### General particle distribution

# todo: find better name for variate forms used in QEDevents.jl
abstract type QEDlikeVariate <: Distributions.VariateForm end

abstract type ParticleLikeVariate{N} <: QEDlikeVariate end

const SingleParticleVariate = ParticleLikeVariate{0}

const MultiParticleVariate = ParticleLikeVariate{1}

abstract type ProcessLikeVariate <: QEDlikeVariate end

abstract type ParticleSampleable{F <: QEDlikeVariate} <:
Distributions.Sampleable{F, Distributions.Continuous} end

function _momentum_type(s::ParticleSampleable)
    return SFourMomentum{Float64}
end

function _randmom end

function _assert_valid_input_type(s::ParticleSampleable, x) end

function _assert_valid_input(s::ParticleSampleable, x) end

function _weight end

@inline function _post_processing(s::ParticleSampleable, x, res)
    return res
end

function is_exact end

function weight(s::ParticleSampleable, input)
    _assert_valid_input_type(s, input)
    _assert_valid_input(s, input)
    raw_result = _weight(s, input)
    return _post_processing(s, input, raw_result)
end

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

### Single Particle

const SingleParticleDistribution = ParticleSampleable{SingleParticleVariate}

Broadcast.broadcastable(d::SingleParticleDistribution) = Ref(d)

Base.length(::SingleParticleDistribution) = 1
Base.size(::SingleParticleDistribution) = ()

function _particle end

function _particle_direction end
#default
_particle_direction(::SingleParticleDistribution) = UnknownDirection()

function _assert_valid_input_type(
        d::SingleParticleDistribution, x::ParticleStateful{D, P}
    ) where {D, P}
    typeof(_particle_direction(d)) == D ||
        throw(InvalidInputError("expected $(typeof(_particle_direction(d))) but got $D"))

    typeof(_particle(d)) == P ||
        throw(InvalidInputError("expected $(typeof(_particle(d))) but got $P"))

    return nothing
end

# used for pre-allocation of vectors of particle-stateful
# todo: maybe find a better solution
function Base.eltype(s::SingleParticleDistribution)
    return ParticleStateful{
        typeof(_particle_direction(s)), typeof(_particle(s)), _momentum_type(s),
    }
end

function Distributions.rand(rng::AbstractRNG, d::SingleParticleDistribution)
    rnd_momentum = _randmom(rng, d)
    return ParticleStateful(_particle_direction(d), _particle(d), rnd_momentum)
end

### Multi-particle

const MultiParticleDistribution = ParticleSampleable{MultiParticleVariate}

Broadcast.broadcastable(d::MultiParticleDistribution) = Ref(d)

Base.length(d::MultiParticleDistribution) = length(_particles(d))
Base.size(d::MultiParticleDistribution) = (length(d),)

function _particles end

function _particle_directions end
#default
function _particle_direction(d::MultiParticleDistribution)
    return Tuple(fill(UnknownDirection(), length(d)))
end

function _assert_valid_input_type(
        d::MultiParticleDistribution, x::PS
    ) where {PS <: Tuple{Vararg{ParticleStateful}}}
    _recursive_type_check(x, _particles(d), _particle_directions(d))
    return nothing
end

# used for pre-allocation of vectors of particle-stateful
function Base.eltype(d::MultiParticleDistribution)
    return Tuple{
        _assemble_tuple_types(_particles(d), _particle_directions(d), _momentum_type(d))...,
    }
end

function Distributions.rand(rng::AbstractRNG, d::MultiParticleDistribution)
    n = length(d)
    moms = _randmom(rng, d)
    dirs = _particle_directions(d)
    parts = _particles(d)

    # ntuple is not type-stable for parametric type in Julia 1.10
    return Tuple{_assemble_tuple_types(parts, dirs, _momentum_type(d))...}(
        ntuple(i -> ParticleStateful(dirs[i], parts[i], moms[i]), Val(n))
    )
end


### process distribution

const ScatteringProcessDistribution = ParticleSampleable{ProcessLikeVariate}

Broadcast.broadcastable(d::ScatteringProcessDistribution) = Ref(d)

function QEDbase.incoming_particles(d::ScatteringProcessDistribution)
    return incoming_particles(process(d))
end

function QEDbase.outgoing_particles(d::ScatteringProcessDistribution)
    return outgoing_particles(process(d))
end

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
    phase_space_layout(d) == phase_space_layout(psp) || throw(
        InvalidInputError(
            "the phase space layout of the distribution $(phase_space_layout(d)) is not the same as that of the phase space point $(phase_space_layout(psp))",
        ),
    )
    return nothing
end

function _assemble_psp_type(
        proc::PROC, model::MODEL, ps_def::PSL, mom_type::Type{MOM}
    ) where {
        PROC <: AbstractProcessDefinition,
        MODEL <: AbstractModelDefinition,
        PSL <: AbstractPhaseSpaceLayout,
        MOM <: AbstractFourMomentum,
    }
    IN_PARTICLES = Tuple{
        _assemble_tuple_types(incoming_particles(proc), Incoming(), MOM)...,
    }
    OUT_PARTICLES = Tuple{
        _assemble_tuple_types(outgoing_particles(proc), Outgoing(), MOM)...,
    }

    return PhaseSpacePoint{PROC, MODEL, PSL, IN_PARTICLES, OUT_PARTICLES, MOM}
end

# used for pre-allocation of vectors of psps
function Base.eltype(d::ScatteringProcessDistribution)
    return _assemble_psp_type(
        process(d), model(d), phase_space_layout(d), _momentum_type(d)
    )
end

function Distributions.rand(rng::AbstractRNG, d::ScatteringProcessDistribution)
    in_moms, out_moms = _randmom(rng, d)

    return PhaseSpacePoint(process(d), model(d), phase_space_layout(d), in_moms, out_moms)
end
