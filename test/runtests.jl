using QEDevents
using Test
using SafeTestsets

@testset "QEDevents.jl" begin
    @time @safetestset "single particle distribution" begin
        include("interfaces/single_particle_distribution.jl")
    end

    @time @safetestset "particle distribution" begin
        include("interfaces/particle_distribution_interface.jl")
    end
end
