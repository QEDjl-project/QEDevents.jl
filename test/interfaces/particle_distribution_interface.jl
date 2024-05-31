using QEDprocesses
using QEDevents
using QEDbase
using Random: Random
import Random: AbstractRNG, MersenneTwister, default_rng

# only imported, because we want to tests,
# if QEDevents works without this (epsecially the Base.rand which is exported by
# Distributions)
using Distributions: Distributions

RNG = MersenneTwister(708583836976)

ATOL = 0.0
RTOL = sqrt(eps())

struct TestParticle <: AbstractParticle end
struct TestSingleParticleDist <: SingleParticleDistribution end

QEDevents.particle(d::TestSingleParticleDist) = TestParticle()
Distributions.rand(rng::AbstractRNG, d::TestSingleParticleDist) = rand(rng, SFourMomentum)
QEDevents._weight(d::SingleParticleDistribution, x::SFourMomentum) = one(eltype(x))

@testset "single particle distribution" begin
    @testset "static properties" begin
        test_single_dist = TestSingleParticleDist()
        @test length(test_single_dist) == 1
        @test size(test_single_dist) == ()
        @test eltype(typeof(test_single_dist)) == SFourMomentum
        @test Distributions.nsamples(typeof(test_single_dist), 2) == 1
        @test Distributions.nsamples(typeof(test_single_dist), [0, 0]) == 2
    end

    @testset "sampling" begin
        @testset "single sample" begin
            test_single_dist = TestSingleParticleDist()

            Random.seed!(1234)
            rng = default_rng()
            mom_rng = rand(rng, test_single_dist)

            Random.seed!(1234)
            mom_default = rand(test_single_dist)

            @test mom_rng == mom_default
        end

        @testset "multiple samples" begin
            test_single_dist = TestSingleParticleDist()

            Random.seed!(1234)
            rng = default_rng()
            mom_rng = rand(rng, test_single_dist, 2)

            Random.seed!(1234)
            mom_default = rand(test_single_dist, 2)

            Random.seed!(1234)
            rng = default_rng()
            mom_prealloc_rng = Vector{SFourMomentum}(undef, 2)
            Random.rand!(rng, test_single_dist, mom_prealloc_rng)

            Random.seed!(1234)
            rng = default_rng()
            mom_prealloc_default = Vector{SFourMomentum}(undef, 2)
            Random.rand!(rng, test_single_dist, mom_prealloc_default)

            @test all(mom_rng == mom_default)
            @test all(mom_rng == mom_prealloc_rng)
            @test all(mom_rng == mom_prealloc_default)
        end
    end
end
