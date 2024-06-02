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

struct TestParticle <: QEDbase.AbstractParticleType end
struct TestSingleParticleDist <: SingleParticleDistribution end

QEDevents._particle(d::TestSingleParticleDist) = TestParticle
function Distributions.rand(rng::AbstractRNG, d::TestSingleParticleDist)
    rnd_mom = rand(rng, SFourMomentum)
    return ParticleStateful(QEDevents.UnknownDirection(), TestParticle(), rnd_mom)
end
QEDevents._weight(d::SingleParticleDistribution, x::SFourMomentum) = one(eltype(x))

@testset "single particle distribution" begin
    @testset "static properties" begin
        test_single_dist = TestSingleParticleDist()

        @test QEDevents._particle(test_single_dist) == TestParticle
        @test length(test_single_dist) == 1
        @test size(test_single_dist) == ()
        #@test eltype(typeof(test_single_dist)) == SFourMomentum
        @test eltype(test_single_dist) ==
            ParticleStateful{QEDevents.UnknownDirection,TestParticle,SFourMomentum}
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
            @testset "$dim" for dim in (1, rand(RNG, 1:10))
                checked_lengths = (1, rand(RNG, 1:10))
                shapes = Iterators.product(fill(checked_lengths, dim)...)

                @testset "$shape" for shape in shapes
                    Random.seed!(1234)
                    rng = default_rng()
                    psf_rng = rand(rng, test_single_dist, shape...)

                    Random.seed!(1234)
                    psf_default = rand(test_single_dist, shape...)

                    Random.seed!(1234)
                    rng = default_rng()
                    mom_prealloc_rng = Array{SFourMomentum}(undef, shape...)
                    psf_prealloc_rng =
                        ParticleStateful.(
                            QEDevents.UnknownDirection(), TestParticle(), mom_prealloc_rng
                        )
                    Random.rand!(rng, test_single_dist, psf_prealloc_rng)

                    Random.seed!(1234)
                    rng = default_rng()
                    mom_prealloc_default = Array{SFourMomentum}(undef, shape)
                    psf_prealloc_default =
                        ParticleStateful.(
                            QEDevents.UnknownDirection(),
                            TestParticle(),
                            mom_prealloc_default,
                        )
                    Random.rand!(rng, test_single_dist, psf_prealloc_default)

                    @test all(psf_rng == psf_default)
                    @test all(psf_rng == psf_prealloc_rng)
                    @test all(psf_rng == psf_prealloc_default)
                end
            end
        end
    end
end
