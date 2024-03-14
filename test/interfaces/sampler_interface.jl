using QEDprocesses
using QEDevents
using QEDbase
import Random: AbstractRNG, MersenneTwister
using Distributions
import Distributions: rand, rand!, _rand!

RNG = MersenneTwister(708583836976)

ATOL = 0.0
RTOL = sqrt(eps())

RAND_EXACTNESS = rand(RNG, Bool)

struct TestSetup{D} <: AbstractComputationSetup
    dist::D
end

function TestSetup(dim::Integer)
    return TestSetup(product_distribution(Uniform.(-rand(dim), 1.0)))
end

Base.size(stp::TestSetup, N::Integer) = size(stp.dist)[1]
Base.size(stp::TestSetup) = size(stp, 1)

QEDprocesses._compute(stp::TestSetup, x) = pdf(stp.dist, x)

struct TestSampler <: AbstractSampler
    stp::TestSetup
end
Base.eltype(::TestSampler) = Float64
Base.size(samp::TestSampler, N::Integer=1) = size(samp.stp, N)

function QEDevents._rand!(
    rng::AbstractRNG, smplr::TestSampler, res::AbstractVector{P}
) where {P}
    rand!(rng, smplr.stp.dist, res)
    return res
end

is_exact(::TestSampler) = RAND_EXACTNESS

setup(smplr::TestSampler) = smplr.stp
QEDevents._weight(smplr::TestSampler, x) = compute(smplr.stp, x) # assuming a product of Uniforms
max_weight(smplr::TestSampler) = pdf(smplr.stp.dist, zeros(size(smplr.stp.dist)))
function _rand!(rng::AbstractRNG, s::TestSampler, x::AbstractVector{T}) where {T<:Real}
    # assuming a sampler setup from Distributions.jl
    return rand!(rng, s.stp.dist, x)
end

struct TestSampler_FAIL <: AbstractSampler
    stp::TestSetup
end

@testset "sampler interface" for DIM in [1, rand(RNG, 2:8)]
    @testset "interface fail" begin
        proc_stp = TestSetup(DIM)
        test_smplr_failed = TestSampler_FAIL(proc_stp)
        x_out = rand(RNG, DIM)

        @test_throws MethodError setup(test_smplr_failed)
        @test_throws MethodError is_exact(test_smplr_failed) 
        @test_throws MethodError size(test_smplr_failed)
        @test_throws MethodError max_weight(test_smplr_failed)
        @test_throws MethodError weight(test_smplr_failed, x_out)

        test_x_inplace = zeros(DIM)
        @test_throws MethodError rand!(RNG,test_smplr_failed,test_x_inplace)
        @test_throws MethodError rand(RNG,test_smplr_failed)
    end
    @testset "process sampler interface" begin
        proc_stp = TestSetup(DIM)
        test_smplr = TestSampler(proc_stp)

        @testset "properties" begin
            @test setup(test_smplr) == proc_stp
            @test is_exact(test_smplr) == RAND_EXACTNESS
            @test size(test_smplr) == size(proc_stp) == DIM
            @test isapprox(
                max_weight(test_smplr), pdf(proc_stp.dist, zeros(DIM)), atol=ATOL, rtol=RTOL
            )
        end

        @testset "weight: vector" begin
            x_out = rand(RNG, DIM)
            test_vals = weight(test_smplr, x_out)
            groundtruth = pdf(proc_stp.dist, x_out)
            @test isapprox(test_vals, groundtruth, atol=ATOL, rtol=RTOL)
        end

        @testset "weight: matrix" begin
            x_out = rand(RNG, DIM, 2)
            test_vals = weight(test_smplr, x_out)
            groundtruth = pdf(proc_stp.dist, x_out)
            @test isapprox(test_vals, groundtruth, atol=ATOL, rtol=RTOL)
        end

        @testset "rand: vector" begin
            # reproduce the same random samples three times
            rng1 = deepcopy(RNG)
            rng2 = deepcopy(RNG)
            rng3 = deepcopy(RNG)

            test_x_inplace = zeros(DIM)
            rand!(rng1, test_smplr, test_x_inplace)
            test_x = rand(rng2, test_smplr)
            groundtruth = rand(rng3, proc_stp.dist)

            @test isapprox(test_x_inplace, groundtruth, atol=ATOL, rtol=RTOL)
            @test isapprox(test_x, groundtruth, atol=ATOL, rtol=RTOL)
        end

        @testset "rand: matrix" begin
            # reproduce the same random samples three times
            rng1 = deepcopy(RNG)
            rng2 = deepcopy(RNG)
            rng3 = deepcopy(RNG)

            test_x_inplace = zeros(DIM, 2)
            rand!(rng1, test_smplr, test_x_inplace)
            test_x = rand(rng2, test_smplr, 2)
            groundtruth = rand(rng3, proc_stp.dist, 2)

            @test isapprox(test_x_inplace, groundtruth, atol=ATOL, rtol=RTOL)
            @test isapprox(test_x, groundtruth, atol=ATOL, rtol=RTOL)
        end

        @testset "interface fail" begin
            @test_throws InvalidInputError rand!(RNG, test_smplr, zeros(DIM + 1))
            @test_throws InvalidInputError rand!(RNG, test_smplr, zeros(DIM + 1, 2))
            @test_throws InvalidInputError rand!(RNG, test_smplr, zeros(Float32, DIM))
        end
    end
end
