using QEDevents
using Test
using SafeTestsets

begin
    @time @safetestset "single particle distribution" begin
        include("interfaces/single_particle_distribution.jl")
    end
    @time @safetestset "multi particle distribution" begin
        include("interfaces/multi_particle_distribution.jl")
    end
    @time @safetestset "scattering process distribution" begin
        include("interfaces/process_distribution.jl")
    end

    @time @safetestset "Maxwell Boltzmann" begin
        include("sampler/single_particle_dists/maxwell_boltzmann.jl")
    end
end
