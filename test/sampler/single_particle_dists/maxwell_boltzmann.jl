using QEDbase
using QEDcore
using QEDevents
using Random: Random
import Distributions: Normal, Gamma

RNG = Random.MersenneTwister(137137137)

include("../../test_implementation/TestImpl.jl")
include("../testutils.jl")

test_particle = rand(RNG, TestImpl.PARTICLE_SET)
test_direction = rand(RNG, (Incoming(), Outgoing(), UnknownDirection()))

const N_SAMPLES = 1_000_000 # samples to be tested
const TEMPERATURES = (1e-6, 1e-3, 1.0, 1e3, 1e6)

@testset "$temp" for temp in TEMPERATURES
    test_dist = MaxwellBoltzmannParticle(test_direction, test_particle, temp)

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
        # maybe this comes in handy: https://github.com/JuliaStats/Distributions.jl/blob/47c040beef8c61bad3e1eefa4fc8194e3a62b55a/test/testutils.jl#L188C10-L188C22
        test_sample = rand(RNG, test_dist, N_SAMPLES)

        @testset "magnitude" begin
            a = sqrt(mass(test_particle) * temp)
            mag_projection = TestProjection(getMag, MaxwellBoltzmann(a))
            @test test_univariate_samples(mag_projection, test_sample)
        end

        @testset "x component" begin
            a = sqrt(mass(test_particle) * temp)
            x_projection = TestProjection(getX, Normal(0.0, a))
            @test test_univariate_samples(x_projection, test_sample)
        end

        @testset "y component" begin
            a = sqrt(mass(test_particle) * temp)
            y_projection = TestProjection(getY, Normal(0.0, a))
            @test test_univariate_samples(y_projection, test_sample)
        end

        @testset "z component" begin
            a = sqrt(mass(test_particle) * temp)
            z_projection = TestProjection(getZ, Normal(0.0, a))
            @test test_univariate_samples(z_projection, test_sample)
        end
    end

    @testset "weight properties" begin
        # TODO:
        # * write a utils function for that (for general dists?)
        test_samples = rand(RNG, test_dist, N_SAMPLES)
        test_weights = weight.(test_dist, test_samples)
        @test all(test_weights .<= max_weight(test_dist))
    end
end
