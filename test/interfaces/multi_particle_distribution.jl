
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

struct WrongParticle <: AbstractParticleType end # for type checking in weight
struct WrongDirection <: ParticleDirection end # for type checking in weight

DIRECTIONS = (Incoming(), Outgoing(), QEDevents.UnknownDirection())
RND_SEED = ceil(Int, 1e6 * rand(RNG)) # for comparison
@testset "N=$N" for N in (1, rand(RNG, 2:10))
    @testset "default properties" begin
        test_dist_plain = TestImpl.TestMultiParticleDistPlain(N)
        @test all(
            QEDevents._particle_direction(test_dist_plain) .== QEDevents.UnknownDirection()
        )
        @test QEDevents._momentum_type(test_dist_plain) == SFourMomentum
    end

    test_particles = Tuple(rand(RNG, TestImpl.PARTICLE_SET, N))
    test_directions = Tuple(rand(RNG, DIRECTIONS, N))
    test_dist = TestImpl.TestMultiParticleDist(test_directions, test_particles)

    @testset "static properties" begin
        @test @inferred QEDevents._particles(test_dist) == test_particles
        @test @inferred QEDevents._particle_directions(test_dist) == test_directions
        @test @inferred length(test_dist) == N
        @test @inferred size(test_dist) == (N,)

        # todo: consider to move _assemble_tuple_types to the test implementation
        # (groundtruths must not rely on package internals)
        @test @inferred eltype(test_dist) == Tuple{
            QEDevents._assemble_tuple_types(
                QEDevents._particles(test_dist),
                QEDevents._particle_directions(test_dist),
                QEDevents._momentum_type(test_dist),
            )...,
        }
    end

    @testset "single sample" begin
        Random.seed!(RND_SEED)
        rng = default_rng()
        psf_groundtruth = TestImpl._groundtruth_multi_rand(rng, test_dist)

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
                tuple_psf_rng = @inferred rand(rng, test_dist, shape...)

                Random.seed!(RND_SEED)
                tuple_psf_default = @inferred rand(test_dist, shape...)

                Random.seed!(RND_SEED)
                rng = default_rng()
                res_type = eltype(test_dist)
                tuple_psf_prealloc_rng = Array{res_type}(undef, shape...)
                @inferred Random.rand!(rng, test_dist, tuple_psf_prealloc_rng)

                Random.seed!(RND_SEED)
                res_type = eltype(test_dist)
                tuple_psf_prealloc_default = Array{res_type}(undef, shape...)
                @inferred Random.rand!(test_dist, tuple_psf_prealloc_default)

                @test all(tuple_psf_rng == tuple_psf_default)
                @test all(tuple_psf_rng == tuple_psf_prealloc_rng)
                @test all(tuple_psf_rng == tuple_psf_prealloc_default)
            end
        end
    end
    @testset "weights" begin
        @testset "evaluation" begin
            test_input = rand(RNG, test_dist)
            @test weight(test_dist, test_input) ==
                TestImpl._groundtruth_multi_weight(test_dist, test_input)
        end

        @testset "fails" begin
            correct_input = rand(RNG, test_dist)

            # failing inputs with either wrong particle, wrong direction or both
            psf_wrong_particle = ParticleStateful(
                test_directions[1], WrongParticle(), rand(RNG, SFourMomentum)
            )
            input_wrong_particle = TestImpl.tuple_setindex(
                correct_input, 1, psf_wrong_particle
            )

            psf_wrong_direction = ParticleStateful(
                WrongDirection(), test_particles[1], rand(RNG, SFourMomentum)
            )
            input_wrong_direction = TestImpl.tuple_setindex(
                correct_input, 1, psf_wrong_direction
            )

            psf_wrong = ParticleStateful(
                WrongDirection(), WrongParticle(), rand(RNG, SFourMomentum)
            )
            input_wrong = TestImpl.tuple_setindex(correct_input, 1, psf_wrong)

            # failing input with wrong length
            input_wrong_length = (psf_wrong, correct_input...)

            @test_throws InvalidInputError weight(test_dist, input_wrong_particle)
            @test_throws InvalidInputError weight(test_dist, input_wrong_direction)
            @test_throws InvalidInputError weight(test_dist, input_wrong)
            @test_throws InvalidInputError weight(test_dist, input_wrong_length)
        end
    end
end
