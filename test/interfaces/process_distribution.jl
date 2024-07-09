using QEDevents
using QEDbase
using QEDcore
using Random: Random
import Random: AbstractRNG, MersenneTwister, default_rng

# only imported because we want to test if QEDevents works without this
# (especially the Base.rand, which is exported by Distributions)
using Distributions: Distributions

include("../test_implementation/TestImpl.jl")

RNG = MersenneTwister(137137)

RND_SEED = ceil(Int, 1e6 * rand(RNG)) # for comparison
ATOL = 0.0
RTOL = sqrt(eps())
TESTMODEL = TestImpl.TestModel()
TESTPSDEF = TestImpl.TestPhasespaceDef()

@testset "($N_INCOMING,$N_OUTGOING)" for (N_INCOMING, N_OUTGOING) in Iterators.product(
    (1, rand(RNG, 2:8)), (1, rand(RNG, 2:8))
)
    INCOMING_PARTICLES = Tuple(rand(RNG, TestImpl.PARTICLE_SET, N_INCOMING))
    OUTGOING_PARTICLES = Tuple(rand(RNG, TestImpl.PARTICLE_SET, N_OUTGOING))

    TESTPROC = TestImpl.TestProcess(INCOMING_PARTICLES, OUTGOING_PARTICLES)

    test_dist = TestImpl.TestProcessDistribution(TESTPROC, TESTMODEL, TESTPSDEF)

    @testset "properties" begin
        @test @inferred process(test_dist) == TESTPROC
        @test @inferred model(test_dist) == TESTMODEL
        @test @inferred phase_space_definition(test_dist) == TESTPSDEF

        @test @inferred incoming_particles(test_dist) == INCOMING_PARTICLES
        @test @inferred outgoing_particles(test_dist) == OUTGOING_PARTICLES

        @test @inferred QEDevents._momentum_type(test_dist) == SFourMomentum
        @test @inferred eltype(test_dist) == QEDevents._assemble_psp_type(
            TESTPROC, TESTMODEL, TESTPSDEF, SFourMomentum
        )
    end

    @testset "single sample" begin
        Random.seed!(RND_SEED)
        rng = default_rng()
        in_moms_groundtruth, out_moms_groundtruth = TestImpl._groundtruth_process_randmom(
            rng, test_dist
        )
        psp_groundtruth = PhaseSpacePoint(
            TESTPROC, TESTMODEL, TESTPSDEF, in_moms_groundtruth, out_moms_groundtruth
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
end
