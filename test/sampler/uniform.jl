using QEDprocesses
using QEDevents
using QEDbase
using Random

RNG = MersenneTwister(137137137)

ATOL = 0.0
RTOL = sqrt(eps())

struct TestSetup <: AbstractComputationSetup end
test_setup = TestSetup()

DIMS = [1,rand(RNG,2:8),rand(RNG,9:30)]


_volume(bounds) = prod([b[2]-b[1] for b in bounds])

@testset "dim: $dim" for dim in DIMS
    bounds = [[-rand(RNG),rand(RNG)] for _ in 1:dim]
    uniform_sampler = UniformSampler(test_setup,bounds)

    @testset "pdf" begin
        test_weight = weight(uniform_sampler,zeros(dim))
        @test isapprox(test_weight,inv(_volume(bounds)))
    end
end
