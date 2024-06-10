### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ 9f5300ac-2725-11ef-1799-2583bdfb06ae
begin
    using Pkg: Pkg
    Pkg.activate(".")

    using QEDbase
    using QEDprocesses
    using QEDevents
    using Random
    using BenchmarkTools

    using Distributions: Distributions
end

# ╔═╡ d68f8349-a6b7-4432-8b11-9d995ba38bf5
begin
    const MultiParticleDistribution = QEDevents.ParticleSampleable{
        QEDevents.MultiParticleVariate
    }

    Broadcast.broadcastable(d::MultiParticleDistribution) = Ref(d)

    Base.size(d::MultiParticleDistribution) = (length(d),)

    function _particles end
    function _particle_directions(d::MultiParticleDistribution)
        return Tuple(fill(QEDevents.UnknownDirection(), length(d)))
    end

    # recursion termination: base case
    @inline _assemble_tuple_types(::Tuple{}, ::Tuple{}, ::Type) = ()

    # function assembling the correct type information for the tuple of ParticleStatefuls in a phasespace point constructed from momenta
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

    function Base.eltype(d::MultiParticleDistribution)
        return Tuple{
            _assemble_tuple_types(
                _particles(d), _particle_directions(d), QEDevents._momentum_type(d)
            )...,
        }
    end
end

# ╔═╡ d569e999-0fa2-4bfb-948f-68a78786f45c

# ╔═╡ aee44b96-d857-4ca7-b699-f88baa6692ba
begin
    struct TestParticle1 <: AbstractParticleType end
    struct TestParticle2 <: AbstractParticleType end
    struct TestParticle3 <: AbstractParticleType end

    PARTS = [TestParticle1(), TestParticle2(), TestParticle3()]
    DIRS = [Incoming(), Outgoing(), QEDevents.UnknownDirection()]

    struct TestMultiParticleDist <: MultiParticleDistribution
        parts::Tuple
        dirs::Tuple
    end

    function TestMultiParticleDist(n::Int)
        return TestMultiParticleDist(Tuple(rand(PARTS, n)), Tuple(rand(DIRS, n)))
    end

    Base.length(d::TestMultiParticleDist) = length(d.parts)

    function _particles(d::TestMultiParticleDist)
        return d.parts
    end

    _particle_directions(d::TestMultiParticleDist) = d.dirs

    function Distributions.rand(rng::AbstractRNG, d::TestMultiParticleDist)
        rnd_moms = [rand(rng, SFourMomentum) for _ in 1:length(d)]
        return Tuple(
            map(
                x -> ParticleStateful(x...),
                zip(_particle_directions(d), _particles(d), rnd_moms),
            ),
        )
    end
end

# ╔═╡ 5e585fad-0742-4e29-9d3d-ffa8e166fdfd
begin
    dist = TestMultiParticleDist(3)
    @show length(dist)
    @show size(dist)
    @show _particles(dist)
    @show _particle_directions(dist)
end

# ╔═╡ 1fb10ca2-b340-4456-81f2-5d46de37fc85
Vector{eltype(dist)}(undef, 5)

# ╔═╡ 4619c613-24bd-4a37-953d-9e9214388937
RNG = MersenneTwister(0)

# ╔═╡ 6e17ca34-e568-4b72-9214-cc9db1a4990c
rand(RNG, dist, 4)

# ╔═╡ Cell order:
# ╠═9f5300ac-2725-11ef-1799-2583bdfb06ae
# ╠═d68f8349-a6b7-4432-8b11-9d995ba38bf5
# ╠═d569e999-0fa2-4bfb-948f-68a78786f45c
# ╠═aee44b96-d857-4ca7-b699-f88baa6692ba
# ╠═1fb10ca2-b340-4456-81f2-5d46de37fc85
# ╠═5e585fad-0742-4e29-9d3d-ffa8e166fdfd
# ╠═4619c613-24bd-4a37-953d-9e9214388937
# ╠═6e17ca34-e568-4b72-9214-cc9db1a4990c
