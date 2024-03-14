using QEDprocesses
using QEDevents
using QEDbase
using Random

RNG = MersenneTwister(137137137)

ATOL = 0.0
RTOL = sqrt(eps())

DIMS = [1,rand(RNG,2:8),rand(RNG,9:30)]

# volume of a box with bounds
_volume(bounds) = prod(bounds[2] .- bounds[1])


@testset "sampler interface" begin
    @test hasmethod( QEDevents._weight, Tuple{UniformSampler, <: Union{}})
    @test hasmethod( Base.eltype, Tuple{UniformSampler})
    @test hasmethod(Base.size, Tuple{UniformSampler})
    @test hasmethod(QEDevents.setup, Tuple{UniformSampler})
    @test hasmethod(QEDevents.train!, Tuple{UniformSampler, <:Union{}})
    @test hasmethod(QEDevents._rand!, Tuple{<:AbstractRNG, UniformSampler, <:AbstractVector})
end

@testset "dim: $dim" for dim in DIMS
    bounds = [-rand(RNG,dim),rand(RNG,dim)]
    uniform_sampler = UniformSampler(bounds...)

    @testset "rand: vector" begin
        # reproduce the same random samples three times
        rng1 = deepcopy(RNG)
        rng2 = deepcopy(RNG)
        rng3 = deepcopy(RNG)

        test_x_inplace = zeros(dim)
        rand!(rng1, uniform_sampler, test_x_inplace)
        test_x = rand(rng2, uniform_sampler)
        groundtruth = rand(rng3, uniform_sampler.dist)

        @test isapprox(test_x_inplace, groundtruth, atol=ATOL, rtol=RTOL)
        @test isapprox(test_x, groundtruth, atol=ATOL, rtol=RTOL)
    end

    @testset "rand: matrix" begin
        # reproduce the same random samples three times
        rng1 = deepcopy(RNG)
        rng2 = deepcopy(RNG)
        rng3 = deepcopy(RNG)

        test_x_inplace = zeros(dim, 2)
        rand!(rng1, uniform_sampler, test_x_inplace)
        test_x = rand(rng2, uniform_sampler, 2)
        groundtruth = rand(rng3, uniform_sampler.dist, 2)

        @test isapprox(test_x_inplace, groundtruth, atol=ATOL, rtol=RTOL)
        @test isapprox(test_x, groundtruth, atol=ATOL, rtol=RTOL)
    end 
    @testset "pdf" begin
        test_weight = weight(uniform_sampler,zeros(dim))
        @test isapprox(test_weight,inv(_volume(bounds)))
    end
end
