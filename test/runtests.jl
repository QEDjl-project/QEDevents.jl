using QEDevents
using Test
using SafeTestsets

begin

    @time @safetestset "deprecated" begin
        include("deprecated.jl")
    end
    @time @safetestset "Maxwell Boltzmann" begin
        include("sampler/single_particle_dists/maxwell_boltzmann.jl")
    end
end
