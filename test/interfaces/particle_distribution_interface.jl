using QEDprocesses
using QEDevents
using QEDbase
using Random: Random
import Random: AbstractRNG, MersenneTwister, default_rng

# only imported, because we want to tests,
# if QEDevents works without this (epsecially the Base.rand which is exported by
# Distributions)
using Distributions: Distributions

include("../test_implementation/TestImplementation.jl")

RNG = MersenneTwister(708583836976)

ATOL = 0.0
RTOL = sqrt(eps())

test_particle = TestImplementation.TestParticle()
test_single_dist = TestImplementation.TestSingleParticleDist(test_particle)

DIRECTIONS = (Incoming(), Outgoing(), QEDevents.UnknownDirection())
RND_SEED = ceil(Int, 1e6 * rand(RNG)) # for comparison

@testset "default properties" begin
    test_single_dist_plain = TestImplementation.TestSingleParticleDistPlain()
    @test QEDevents._particle_direction(test_single_dist_plain) ==
        QEDevents.UnknownDirection()
    @test QEDevents._momentum_type(test_single_dist_plain) == SFourMomentum
end

@testset "$dir" for dir in DIRECTIONS
    test_single_dist = TestImplementation.TestSingleParticleDist(test_particle, dir)

    @testset "static properties" begin
        @test QEDevents._particle(test_single_dist) == test_particle
        @test QEDevents._particle_direction(test_single_dist) == dir
        @test length(test_single_dist) == 1
        @test size(test_single_dist) == ()
        @test eltype(test_single_dist) ==
            ParticleStateful{typeof(dir),typeof(test_particle),SFourMomentum}
    end

    @testset "single sample" begin
        Random.seed!(RND_SEED)
        rng = default_rng()
        mom_rng = rand(rng, test_single_dist)

        Random.seed!(RND_SEED)
        mom_default = rand(test_single_dist)

        @test mom_rng == mom_default
    end

    @testset "multiple samples" begin
        @testset "$dim" for dim in (1, rand(RNG, 1:10))
            checked_lengths = (1, rand(RNG, 1:10))
            shapes = Iterators.product(fill(checked_lengths, dim)...)

            @testset "$shape" for shape in shapes
                Random.seed!(RND_SEED)
                rng = default_rng()
                psf_rng = rand(rng, test_single_dist, shape...)

                Random.seed!(RND_SEED)
                psf_default = rand(test_single_dist, shape...)

                Random.seed!(RND_SEED)
                rng = default_rng()
                mom_prealloc_rng = Array{SFourMomentum}(undef, shape...)
                psf_prealloc_rng =
                    ParticleStateful.(
                        dir, TestImplementation.TestParticle(), mom_prealloc_rng
                    )
                Random.rand!(rng, test_single_dist, psf_prealloc_rng)

                Random.seed!(RND_SEED)
                rng = default_rng()
                mom_prealloc_default = Array{SFourMomentum}(undef, shape)
                psf_prealloc_default =
                    ParticleStateful.(
                        dir, TestImplementation.TestParticle(), mom_prealloc_default
                    )
                Random.rand!(rng, test_single_dist, psf_prealloc_default)

                @test all(psf_rng == psf_default)
                @test all(psf_rng == psf_prealloc_rng)
                @test all(psf_rng == psf_prealloc_default)
            end
        end
    end
end
