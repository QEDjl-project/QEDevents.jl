using QEDbase
using QEDcore
using QEDevents
using Random: Random

RNG = Random.MersenneTwister(137137137)

include("../../test_implementation/TestImpl.jl")

test_particle = rand(RNG, TestImpl.PARTICLE_SET)
test_direction = rand(RNG, (Incoming(), Outgoing(), UnknownDirection()))

const N_SAMPLES = 10000 # samples to be tested
const TEMPERATURES = (1e-6, 1e-3, 1.0, 1e3, 1e6)

@testset "$temp" for temp in TEMPERATURES
    test_dist = MaxwellBoltzmannDistribution(test_direction, test_particle, temp)

    @testset "dist properties" begin
        @test temperature(test_dist) == temp
        @test QEDevents._particle(test_dist) == test_particle
        @test QEDevents._particle_direction(test_dist) == test_direction
    end

    @testset "sample properties" begin
        test_sample = rand(RNG, test_dist)
        @test QEDcore.particle_species(test_sample) == test_particle
        @test QEDcore.particle_direction(test_sample) == test_direction
    end

    @testset "sample distribution" begin
        # TODO:
        # * find a way to test if n samples follow the distribution given by weight.
        # * preparation: one needs a corrdinate_map for the samples, whose weight function
        # is known. For instance, the 3-magnitude of samples from MaxwellBoltzmannDistribution
        # is Maxwell-Boltzmann distributed
        # * idea: normalize the weight function by using max_weight and normalize the
        # binned numbers analogously. Then find a way to compare those two.
        # maybe this comes in handy: https://github.com/JuliaStats/Distributions.jl/blob/47c040beef8c61bad3e1eefa4fc8194e3a62b55a/test/testutils.jl#L188C10-L188C22
        #
    end

    @testset "weight properties" begin
        # TODO:
        # * write a utils function for that (for general dists?)
        test_samples = rand(RNG, test_dist, N_SAMPLES)
        test_weights = weight.(test_dist, test_samples)

        @test all(test_weights .<= max_weight(test_dist))
    end
end
