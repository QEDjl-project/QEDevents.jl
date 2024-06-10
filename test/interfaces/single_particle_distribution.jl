using QEDprocesses
using QEDevents
using QEDbase
using Random: Random
import Random: AbstractRNG, MersenneTwister, default_rng

# only imported, because we want to test,
# if QEDevents works without this (epsecially the Base.rand which is exported by
# Distributions)
using Distributions: Distributions

include("../test_implementation/TestImpl.jl")

RNG = MersenneTwister(137137137)

ATOL = 0.0
RTOL = sqrt(eps())

test_particle = rand(RNG, TestImpl.PARTICLE_SET)
struct WrongParticle <: AbstractParticleType end # for type checking in weight
struct WrongDirection <: ParticleDirection end # for type checking in weight

DIRECTIONS = (Incoming(), Outgoing(), QEDevents.UnknownDirection())
RND_SEED = ceil(Int, 1e6 * rand(RNG)) # for comparison

@testset "default properties" begin
    test_dist_plain = TestImpl.TestSingleParticleDistPlain()
    @test QEDevents._particle_direction(test_dist_plain) == QEDevents.UnknownDirection()
    @test QEDevents._momentum_type(test_dist_plain) == SFourMomentum
end

@testset "$dir" for dir in DIRECTIONS
    test_dist = TestImpl.TestSingleParticleDist(dir, test_particle)

    @testset "static properties" begin
        @test @inferred QEDevents._particle(test_dist) == test_particle
        @test @inferred QEDevents._particle_direction(test_dist) == dir
        @test @inferred length(test_dist) == 1
        @test @inferred size(test_dist) == ()
        @test @inferred eltype(test_dist) ==
            ParticleStateful{typeof(dir),typeof(test_particle),SFourMomentum}
    end

    @testset "single sample" begin
        Random.seed!(RND_SEED)
        rng = default_rng()
        psf_groundtruth = TestImpl._groundtruth_single_rand(rng, test_dist)

        Random.seed!(RND_SEED)
        rng = default_rng()
        psf_rng = @inferred rand(rng, test_dist)

        Random.seed!(RND_SEED)
        psf_default = @inferred rand(test_dist)

        @test psf_groundtruth == psf_rng
        @test psf_rng == psf_default
    end

    @testset "multiple samples" begin
        @testset "$dim" for dim in (1, 2, 3)
            checked_lengths = (1, rand(RNG, 1:10))
            shapes = Iterators.product(fill(checked_lengths, dim)...)

            @testset "$shape" for shape in shapes
                Random.seed!(RND_SEED)
                rng = default_rng()
                psf_rng = @inferred rand(rng, test_dist, shape...)

                Random.seed!(RND_SEED)
                psf_default = @inferred rand(test_dist, shape...)

                Random.seed!(RND_SEED)
                rng = default_rng()
                mom_prealloc_rng = Array{SFourMomentum}(undef, shape...)
                psf_prealloc_rng = ParticleStateful.(dir, test_particle, mom_prealloc_rng)
                @inferred Random.rand!(rng, test_dist, psf_prealloc_rng)

                Random.seed!(RND_SEED)
                mom_prealloc_default = Array{SFourMomentum}(undef, shape)
                psf_prealloc_default =
                    ParticleStateful.(dir, test_particle, mom_prealloc_default)
                @inferred Random.rand!(test_dist, psf_prealloc_default)

                @test all(psf_rng == psf_default)
                @test all(psf_rng == psf_prealloc_rng)
                @test all(psf_rng == psf_prealloc_default)
            end
        end
    end

    @testset "weights" begin
        @testset "evaluation" begin
            test_input = rand(RNG, test_dist)
            @test weight(test_dist, test_input) ==
                TestImpl._groundtruth_single_weight(test_dist, test_input)
        end

        @testset "fails" begin
            # failing inputs with either wrong particle, wrong direction or both
            psf_wrong_particle = ParticleStateful(
                dir, WrongParticle(), rand(RNG, SFourMomentum)
            )
            psf_wrong_direction = ParticleStateful(
                WrongDirection(), test_particle, rand(RNG, SFourMomentum)
            )
            psf_wrong = ParticleStateful(
                WrongDirection(), WrongParticle(), rand(RNG, SFourMomentum)
            )

            @test_throws InvalidInputError weight(test_dist, psf_wrong_particle)
            @test_throws InvalidInputError weight(test_dist, psf_wrong_direction)
            @test_throws InvalidInputError weight(test_dist, psf_wrong)
        end
    end
end
