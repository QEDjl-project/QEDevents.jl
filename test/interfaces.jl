#using QEDprocesses
using QEDevents
using Random
using Distributions
using QEDbase

RNG = MersenneTwister(708583836976)
DIM = rand(RNG, 2:8)

ATOL = 0.0
RTOL = sqrt(eps())

RAND_MAX = rand(RNG)
RAND_EXACTNESS = rand(RNG, Bool)

struct TestSetup{D} <: QEDevents.AbstractComputationSetup
    dist::D
end

function TestSetup(dim::Integer)
    return TestSetup(product_distribution(Uniform.(-rand(dim), 1.0)))
end

Base.size(stp::TestSetup, N::Integer) = size(stp.dist)[1] ###best way?
Base.size(stp::TestSetup) = size(stp, 1) #??

QEDevents._compute(stp::TestSetup, x) = pdf(stp.dist, x)

struct TestSampler <: AbstractSampler
    stp::TestSetup
end

Base.size(samp::TestSampler, N::Integer) = size(samp.stp, N)
Base.size(samp::TestSampler) = size(samp, 1)

function QEDevents._rand!(
    rng::AbstractRNG, smplr::TestSampler, res::AbstractVector{P}
) where {P}
    rand!(rng, smplr.stp.dist, res)
    return res
end

is_exact(::TestSampler) = RAND_EXACTNESS

setup(smplr::TestSampler) = smplr.stp
QEDevents._weight(smplr::TestSampler, x) = QEDevents.compute(smplr.stp, x) # assuming a product of Uniforms    ##remove the QEDevents nstead of replacing by processes because exported
max_weight(smplr::TestSampler) = pdf(smplr.stp.dist, zeros(size(smplr.stp.dist)))
function Distributions._rand!(
    rng::Random.AbstractRNG, s::TestSampler, x::AbstractVector{T}
) where {T<:Real}
    # assuming a sampler setup from Distributions.jl
    return Distributions.rand!(rng, s.stp.dist, x)
end

@testset "sampler interface" begin
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
            @test_throws QEDevents.InvalidInputError rand!(RNG, test_smplr, zeros(DIM + 1))
            @test_throws QEDevents.InvalidInputError rand!(
                RNG, test_smplr, zeros(DIM + 1, 2)
            )
            @test_throws QEDevents.InvalidInputError rand!(
                RNG, test_smplr, zeros(Float32, DIM)
            )
        end
    end
end
