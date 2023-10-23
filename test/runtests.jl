using QEDevents
using Test
using SafeTestsets

@testset "QEDevents.jl" begin
    @time @safetestset "sampler interfaces" begin
        include("interfaces/sampler_interface.jl")
    end
end
