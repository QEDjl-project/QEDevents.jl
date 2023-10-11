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
#function _groundtruth_diffCS(x, y)
#    return sum(x) * sum(y)
#end

#struct TestModel <: AbstractModelDefinition end
#QEDcompton.fundamental_interaction_type(::TestModel) = :test_interaction

#struct TestProcess <: AbstractProcessDefinition end
#QEDcompton.incoming_particles(::TestProcess) = (:particle1, :particle2)
#QEDcompton.outgoing_particles(::TestProcess) = (:particle3, :particle4)

#struct TestProcessSetup{P,M,PS} <: AbstractProcessSetup
#    proc::P
#    model::M
#    initPS::PS
#end

struct TestSetup{D} <: QEDevents.AbstractComputationSetup
    dist::D
end

function TestSetup(n_final::Integer)
    return TestSetup(
        product_distribution(Uniform.(-rand(n_final), 1.0))
    )
end

Base.size(stp::TestSetup,N::Integer) = size(stp.dist)
Base.size(stp::TestSetup) = size(stp,1) #??

#QEDcompton.scattering_process(stp::TestSamplerSetup) = stp.proc
#QEDcompton.compute_model(stp::TestSamplerSetup) = stp.model
QEDevents._compute(stp::TestSetup, x) = pdf(stp.dist, x)
#Base.maximum(stp::TestSamplerSetup) = pdf(stp.dist, zeros(size(stp.dist)))

#struct TestSampler{SFourMomentum} <: AbstractScatteringProcessSampler{SFourMomentum}
#    stp::TestSetup
#end
struct TestSampler <: AbstractSampler
    stp::TestSetup
end
Base.size(samp::TestSampler,N::Integer) = size(samp.stp,N)
Base.size(samp::TestSampler) = size(samp,1)
#function _rand!(rng::AbstractRNG, smplr::TestSampler, x::AbstractVector{T}) where {T}
#    rand!(rng, smplr.stp.dist, x)
#end

function QEDevents._rand!(rng::AbstractRNG, smplr::TestSampler, res::AbstractVector{P}) where {P}
    #_rand!(rng,smplr,res[:,i])
    rand!(rng, smplr.stp.dist, res)
    return res
end

#struct TestSampler{S<:TestSamplerSetup} <: AbstractScatteringProcessSampler{S}
#    stp::S
#end
is_exact(::TestSampler) = RAND_EXACTNESS

@testset "interface tests ($N_init, $N_final)" for (N_init, N_final) in Iterators.product(
    (1, rand(RNG, 2:8)), (1, rand(RNG, 2:8))
)
    #=
    QEDcompton.initial_phasespace_dimension(::TestProcess, ::TestModel) = N_init
    QEDcompton.final_phasespace_dimension(::TestProcess, ::TestModel) = N_final

    function QEDcompton._differential_cross_section(
        ::TestProcess, ::TestModel, initPS::AbstractVector{T}, finalPS::AbstractVector{T}
    ) where {T<:Real}
        return _groundtruth_diffCS(initPS, finalPS)
    end

    function QEDcompton._total_cross_section(
        ::TestProcess, ::TestModel, initPS::AbstractVector{T}
    ) where {T<:Real}
        return sum(initPS)
    end

    QEDcompton.scattering_process(stp::TestProcessSetup) = stp.proc
    QEDcompton.compute_model(stp::TestProcessSetup) = stp.model
    
    function QEDcompton._compute(stp::TestProcessSetup, x)
        # Fix me: this should be more general! 
        # (maybe only possible, if the compute interface is similarly rich as the differential cross section interface) 
        return QEDcompton._differential_cross_section(stp.proc, stp.model, stp.initPS, x)
    end
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
        proc_stp = TestSetup(N_final)########
        test_smplr = TestSampler(proc_stp)#TestSampler{SFourMomentum}(proc_stp)

        @testset "properties" begin
            @test setup(test_smplr) == proc_stp
            @test is_exact(test_smplr) == RAND_EXACTNESS
            @test size(test_smplr) == size(proc_stp) #########
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
