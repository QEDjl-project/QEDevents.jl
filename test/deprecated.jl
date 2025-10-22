using QEDevents
using QEDbase
using QEDbase.Mocks
using QEDcore
using Random: Random
import Random: AbstractRNG, MersenneTwister, default_rng

# only imported, because we want to test,
# if QEDevents works without this (epsecially the Base.rand which is exported by
# Distributions)
using Distributions: Distributions

include("test_implementation/TestImpl.jl")

RNG = MersenneTwister(137137137)

RND_SEED = ceil(Int, 1.0e6 * rand(RNG)) # for comparison

ATOL = 0.0
RTOL = sqrt(eps())

test_particle = rand(RNG, Mocks.PARTICLE_SET)
struct WrongParticle <: AbstractParticleType end # for type checking in weight
struct WrongDirection <: ParticleDirection end # for type checking in weight

DIRECTIONS = (Incoming(), Outgoing(), QEDevents.UnknownDirection())
TESTMODEL = MockModel()
TESTPSL = MockOutPhaseSpaceLayout(MockMomentum)
const MOM_TYPE = SFourMomentum{Float64}

@testset "single particles" begin
    @testset "default properties" begin
        test_dist_plain = TestImpl.TestSingleParticleDistPlain()
        @test QEDevents._particle_direction(test_dist_plain) == QEDevents.UnknownDirection()
        @test QEDevents._momentum_type(test_dist_plain) == MOM_TYPE
    end

    @testset "$dir" for dir in DIRECTIONS
        test_dist = TestImpl.TestSingleParticleDist(dir, test_particle)

        @testset "static properties" begin
            @test @inferred QEDevents._particle(test_dist) == test_particle
            @test @inferred QEDevents._particle_direction(test_dist) == dir
            @test @inferred length(test_dist) == 1
            @test @inferred size(test_dist) == ()
            @test @inferred eltype(test_dist) ==
                ParticleStateful{typeof(dir), typeof(test_particle), MOM_TYPE}
        end

        @testset "randmom" begin
            @testset "single sample" begin
                Random.seed!(RND_SEED)
                rng = default_rng()
                mom_groundtruth = TestImpl._groundtruth_single_randmom(rng, test_dist)

                Random.seed!(RND_SEED)
                rng = default_rng()
                mom_rng = @inferred QEDevents._randmom(rng, test_dist)

                @test mom_groundtruth == mom_rng
            end
        end

        @testset "rand" begin
            @testset "single sample" begin
                Random.seed!(RND_SEED)
                rng = default_rng()
                mom_groundtruth = TestImpl._groundtruth_single_randmom(rng, test_dist)
                psf_groundtruth = ParticleStateful(dir, test_particle, mom_groundtruth)

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
                        mom_prealloc_rng = Array{MOM_TYPE}(undef, shape...)
                        psf_prealloc_rng =
                            ParticleStateful.(dir, test_particle, mom_prealloc_rng)
                        @inferred Random.rand!(rng, test_dist, psf_prealloc_rng)

                        Random.seed!(RND_SEED)
                        mom_prealloc_default = Array{MOM_TYPE}(undef, shape)
                        psf_prealloc_default =
                            ParticleStateful.(dir, test_particle, mom_prealloc_default)
                        @inferred Random.rand!(test_dist, psf_prealloc_default)

                        @test all(psf_rng == psf_default)
                        @test all(psf_rng == psf_prealloc_rng)
                        @test all(psf_rng == psf_prealloc_default)
                    end
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
                psf_wrong_particle = ParticleStateful(dir, WrongParticle(), rand(RNG, MOM_TYPE))
                psf_wrong_direction = ParticleStateful(
                    WrongDirection(), test_particle, rand(RNG, MOM_TYPE)
                )
                psf_wrong = ParticleStateful(
                    WrongDirection(), WrongParticle(), rand(RNG, MOM_TYPE)
                )

                @test_throws InvalidInputError weight(test_dist, psf_wrong_particle)
                @test_throws InvalidInputError weight(test_dist, psf_wrong_direction)
                @test_throws InvalidInputError weight(test_dist, psf_wrong)
            end
        end
    end
end


@testset "process distribition" begin
    @testset "($N_INCOMING,$N_OUTGOING)" for (N_INCOMING, N_OUTGOING) in Iterators.product(
            (1, rand(RNG, 2:8)), (1, rand(RNG, 2:8))
        )
        INCOMING_PARTICLES = Tuple(rand(RNG, Mocks.PARTICLE_SET, N_INCOMING))
        OUTGOING_PARTICLES = Tuple(rand(RNG, Mocks.PARTICLE_SET, N_OUTGOING))

        TESTPROC = MockProcess(INCOMING_PARTICLES, OUTGOING_PARTICLES)

        test_dist = TestImpl.TestProcessDistribution(TESTPROC, TESTMODEL, TESTPSL)

        @testset "properties" begin
            @test @inferred process(test_dist) == TESTPROC
            @test @inferred model(test_dist) == TESTMODEL
            @test @inferred phase_space_layout(test_dist) == TESTPSL

            @test @inferred incoming_particles(test_dist) == INCOMING_PARTICLES
            @test @inferred outgoing_particles(test_dist) == OUTGOING_PARTICLES

            @test @inferred QEDevents._momentum_type(test_dist) == MOM_TYPE
            @test @inferred eltype(test_dist) ==
                QEDevents._assemble_psp_type(TESTPROC, TESTMODEL, TESTPSL, MOM_TYPE)
        end

        @testset "single sample" begin
            Random.seed!(RND_SEED)
            rng = default_rng()
            in_moms_groundtruth, out_moms_groundtruth = TestImpl._groundtruth_process_randmom(
                rng, test_dist
            )
            psp_groundtruth = PhaseSpacePoint(
                TESTPROC, TESTMODEL, TESTPSL, in_moms_groundtruth, out_moms_groundtruth
            )

            Random.seed!(RND_SEED)
            rng = default_rng()
            psp_rng = @inferred rand(rng, test_dist)

            Random.seed!(RND_SEED)
            psp_default = @inferred rand(test_dist)

            @test psp_groundtruth == psp_rng
            @test psp_rng == psp_default
        end

        @testset "multiple samples" begin
            @testset "$dim" for dim in (1, 2, 3)
                checked_lengths = (1, 2, rand(RNG, 3:10))
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
                @test @inferred weight(test_dist, test_input) ==
                    TestImpl._groundtruth_process_weight(test_dist, test_input)
            end
            @testset "fails" begin
                WRONG_TESTPROC = Mocks.MockProcess_FAIL_DIFFCS(
                    INCOMING_PARTICLES, OUTGOING_PARTICLES
                )
                WRONG_TESTMODEL = MockModel_FAIL()
                WRONG_TESTPSL = MockOutPhaseSpaceLayout_FAIL(MockMomentum)

                invalid_combs = [
                    (proc, model, ps_def) for (proc, model, ps_def) in Iterators.product(
                            (TESTPROC, WRONG_TESTPROC),
                            (TESTMODEL, WRONG_TESTMODEL),
                            (TESTPSL, WRONG_TESTPSL),
                        ) if !TestImpl._all_valid(proc, model, ps_def)
                ]

                correct_in_moms, correct_out_moms = QEDevents._randmom(RNG, test_dist)

                @testset "$test_proc $test_model $test_ps_def" for (
                        test_proc, test_model, test_ps_def,
                    ) in invalid_combs
                    wrong_input = PhaseSpacePoint(
                        test_proc, test_model, test_ps_def, correct_in_moms, correct_out_moms
                    )

                    @test_throws InvalidInputError weight(test_dist, wrong_input)
                end
            end
        end
    end
end

@testset "multi-particle distributions" begin
    @testset "N=$N" for N in (1, rand(RNG, 2:8))
        @testset "default properties" begin
            test_dist_plain = TestImpl.TestMultiParticleDistPlain(N)
            @test all(
                QEDevents._particle_direction(test_dist_plain) .== QEDevents.UnknownDirection()
            )
            @test QEDevents._momentum_type(test_dist_plain) == MOM_TYPE
        end

        test_particles = Tuple(rand(RNG, Mocks.PARTICLE_SET, N))
        test_directions = Tuple(rand(RNG, DIRECTIONS, N))
        test_dist = TestImpl.TestMultiParticleDist(test_directions, test_particles)

        @testset "static properties" begin
            @test @inferred QEDevents._particles(test_dist) == test_particles
            @test @inferred QEDevents._particle_directions(test_dist) == test_directions
            @test @inferred length(test_dist) == N
            @test @inferred size(test_dist) == (N,)

            # todo: consider to move _assemble_tuple_types to the test implementation
            # (groundtruths must not rely on package internals)
            # See https://github.com/QEDjl-project/QEDprocesses.jl/issues/75
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
            moms_groundtruth = TestImpl._groundtruth_multi_randmom(rng, test_dist)
            psf_groundtruth = Tuple(
                ParticleStateful(test_directions[i], test_particles[i], moms_groundtruth[i]) for
                    i in 1:N
            )

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
                checked_lengths = (1, 2, rand(RNG, 3:10))
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
                    test_directions[1], WrongParticle(), rand(RNG, MOM_TYPE)
                )
                input_wrong_particle = TestImpl.tuple_setindex(
                    correct_input, 1, psf_wrong_particle
                )

                psf_wrong_direction = ParticleStateful(
                    WrongDirection(), test_particles[1], rand(RNG, MOM_TYPE)
                )
                input_wrong_direction = TestImpl.tuple_setindex(
                    correct_input, 1, psf_wrong_direction
                )

                psf_wrong = ParticleStateful(
                    WrongDirection(), WrongParticle(), rand(RNG, MOM_TYPE)
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
end
