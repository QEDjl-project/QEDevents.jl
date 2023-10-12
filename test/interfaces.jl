#using QEDprocesses
using Random
using Distributions
using QEDbase

RNG = MersenneTwister(708583836976)
N_init = rand(RNG, 2:8)
N_final = rand(RNG, 2:8)

ATOL = 0.0
RTOL = sqrt(eps())

RAND_MAX = rand(RNG)
RAND_EXACTNESS = rand(RNG, Bool)

struct TestSetup{D} <: QEDevents.AbstractComputationSetup
    dist::D
end

function TestSetup(n_final::Integer)
    return TestSetup(
        product_distribution(Uniform.(-rand(n_final), 1.0))
    )
end

Base.size(stp::TestSetup,N::Integer) = size(stp.dist)[1] ###best way?
Base.size(stp::TestSetup) = size(stp,1) #??

QEDevents._compute(stp::TestSetup, x) = pdf(stp.dist, x)
#Base.maximum(stp::TestSamplerSetup) = pdf(stp.dist, zeros(size(stp.dist)))


struct TestSampler <: AbstractSampler
    stp::TestSetup
end

Base.size(samp::TestSampler,N::Integer) = size(samp.stp,N)
Base.size(samp::TestSampler) = size(samp,1)

function QEDevents._rand!(rng::AbstractRNG, smplr::TestSampler, res::AbstractVector{P}) where {P}
    rand!(rng, smplr.stp.dist, res)
    return res
end

is_exact(::TestSampler) = RAND_EXACTNESS

@testset "interface tests ($N_init, $N_final)" for (N_init, N_final) in Iterators.product(
    (1, rand(RNG, 2:8)), (1, rand(RNG, 2:8))
)
    #=
    Base.maximum(stp::TestProcessSetup{P,M,PS}) where {P,M,PS<:AbstractVector} = RAND_MAX
    function Base.maximum(stp::TestProcessSetup{P,M,PS}) where {P,M,PS<:AbstractMatrix}
        return ones(eltype(stp.initPS), size(stp.initPS, 2))RAND_MAX
    end
    =#
    setup(smplr::TestSampler) = smplr.stp
    QEDevents._weight(smplr::TestSampler, x) = QEDevents.compute(smplr.stp, x) # assuming a product of Uniforms    ##remove the QEDevents nstead of replacing by processes because exported
    max_weight(smplr::TestSampler) = maximum(smplr.stp.dist)
    function Distributions._rand!(
        rng::Random.AbstractRNG, s::TestSampler, x::AbstractVector{T}
    ) where {T<:Real}
        # assuming a sampler setup from Distributions.jl
        return Distributions.rand!(rng, s.stp.dist, x)
    end


    @testset "process sampler interface" begin
        proc_stp = TestSetup(N_final)
        test_smplr = TestSampler(proc_stp)

        @testset "properties" begin
            @test setup(test_smplr) == proc_stp
            @test is_exact(test_smplr) == RAND_EXACTNESS
            @test size(test_smplr) == size(proc_stp)
            #=@test isapprox(  #############################
                max_weight(test_smplr),
                pdf(proc_stp.dist, zeros(N_final)),
                atol=ATOL,
                rtol=RTOL,
            )=#
        end

        @testset "weight: vector" begin
            x_out = rand(RNG, N_final)
            test_vals = weight(test_smplr, x_out)
            groundtruth = pdf(proc_stp.dist, x_out)
            @test isapprox(test_vals, groundtruth, atol=ATOL, rtol=RTOL)
        end

        @testset "weight: vector-matrix" begin
            x_out = rand(RNG, N_final, 2)
            test_vals = weight(test_smplr, x_out)
            groundtruth = pdf(proc_stp.dist, x_out)
            @test isapprox(test_vals, groundtruth, atol=ATOL, rtol=RTOL)
        end

        @testset "rand: vector" begin
            # reproduce the same random samples three times
            rng1 = deepcopy(RNG)
            rng2 = deepcopy(RNG)
            rng3 = deepcopy(RNG)

            test_x_inplace = zeros(N_final)
            rand!(rng1, test_smplr, test_x_inplace)
            test_x = rand(rng2, test_smplr)
            groundtruth = rand(rng3, proc_stp.dist)
            ###_____versions

            @test isapprox(test_x_inplace, groundtruth, atol=ATOL, rtol=RTOL)
            @test isapprox(test_x, groundtruth, atol=ATOL, rtol=RTOL)
        end
        
        @testset "rand: matrix" begin
            # reproduce the same random samples three times
            rng1 = deepcopy(RNG)
            rng2 = deepcopy(RNG)
            rng3 = deepcopy(RNG)

            test_x_inplace = zeros(N_final, 2)
            rand!(rng1, test_smplr, test_x_inplace)
            test_x = rand(rng2, test_smplr, 2)
            groundtruth = rand(rng3, proc_stp.dist, 2)

            @test isapprox(test_x_inplace, groundtruth, atol=ATOL, rtol=RTOL)
            @test isapprox(test_x, groundtruth, atol=ATOL, rtol=RTOL)
        end
    end
end
